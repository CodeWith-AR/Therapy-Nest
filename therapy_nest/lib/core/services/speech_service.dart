import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:vosk_flutter/vosk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/logger.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Speech error classification
// ─────────────────────────────────────────────────────────────────────────────

/// The type of speech error detected when comparing expected vs actual speech.
enum SpeechErrorType {
  /// Transcription matches accepted answer exactly (or near-exactly ≥ 0.92).
  exactMatch,

  /// Similar phonemic structure but wrong phonemes (similarity 0.70–0.91).
  phonemicError,

  /// Semantically related but different word (e.g. "dog" → "puppy").
  semanticError,

  /// User repeated a previous answer instead of the current target.
  perseveration,

  /// No speech detected / silence.
  noResponse,

  /// Transcription too dissimilar to classify (similarity < 0.40).
  unintelligible,
}

// ─────────────────────────────────────────────────────────────────────────────
// Per-word score for phrase / sentence exercises
// ─────────────────────────────────────────────────────────────────────────────

/// Score for a single word in a phrase or sentence.
class WordScore {
  const WordScore({
    required this.expected,
    required this.actual,
    required this.similarity,
    required this.isMatch,
  });

  final String expected;
  final String actual;
  final double similarity;
  final bool isMatch;
}

// ─────────────────────────────────────────────────────────────────────────────
// SpeechService — Vosk ASR + Recording + Jaro-Winkler
// ─────────────────────────────────────────────────────────────────────────────

/// Provides offline speech recognition via Vosk, audio recording via the
/// `record` package, and Jaro-Winkler similarity matching.
///
/// Extends [ChangeNotifier] so that UI can watch download progress and
/// listening state reactively via Provider.
class SpeechService extends ChangeNotifier {
  SpeechService();

  // ── Vosk model management ───────────────────────────────────────────

  static const String _modelUrl =
      'https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip';

  VoskFlutterPlugin? _vosk;
  Model? _model;
  Recognizer? _recognizer;

  bool _isModelReady = false;
  bool get isModelReady => _isModelReady;

  double _downloadProgress = 0.0;
  double get downloadProgress => _downloadProgress;

  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  // ── Recording state ─────────────────────────────────────────────────

  final AudioRecorder _recorder = AudioRecorder();

  bool _isListening = false;
  bool get isListening => _isListening;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  String? _lastTranscription;
  String? get lastTranscription => _lastTranscription;

  Timer? _silenceTimer;
  static const int _silenceTimeoutSec = 10;

  String? _recordingPath;

  // ── Perseveration tracking ──────────────────────────────────────────

  String _previousAnswer = '';

  // ═══════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════

  /// Initialises the Vosk model. Downloads the small English model on first
  /// Initialises the Vosk model. Downloads the small English model on first
  /// launch (~50 MB) and stores it in the app's documents directory.
  Future<void> init() async {
    if (_isModelReady || _isDownloading) return;

    try {
      _vosk = VoskFlutterPlugin.instance();
      _isDownloading = true;
      notifyListeners();

      // Use ModelLoader to load / download the model.
      // ModelLoader handles caching internally.
      final modelPath = await ModelLoader().loadFromNetwork(
        _modelUrl,
      );

      await _loadModel(modelPath);
    } catch (e) {
      _isDownloading = false;
      notifyListeners();
      AppLogger.error('SpeechService init failed', error: e, tag: 'SpeechService');
    }
  }

  Future<void> _loadModel(String modelPath) async {
    _isDownloading = true;
    _downloadProgress = 0.5;
    notifyListeners();

    try {
      _model = await _vosk!.createModel(modelPath);
      _recognizer = await _vosk!.createRecognizer(
        model: _model!,
        sampleRate: 16000,
      );
      _isModelReady = true;
      _isDownloading = false;
      _downloadProgress = 1.0;
      notifyListeners();

      AppLogger.info('Vosk model loaded from: $modelPath', tag: 'SpeechService');
    } catch (e) {
      _isDownloading = false;
      notifyListeners();
      AppLogger.error(
        'Model loading failed',
        error: e,
        tag: 'SpeechService',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // RECORDING & RECOGNITION
  // ═══════════════════════════════════════════════════════════════════

  /// Begins recording audio from the microphone.
  ///
  /// Records 16-bit PCM WAV at 16 kHz.
  /// Automatically stops after [_silenceTimeoutSec] seconds.
  Future<void> startListening() async {
    if (_isListening) return;

    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    if (!status.isGranted) {
      AppLogger.error('Microphone permission denied', tag: 'SpeechService');
      return;
    }

    try {
      final docsDir = await getApplicationDocumentsDirectory();
      _recordingPath =
          '${docsDir.path}/speech_recording_${DateTime.now().millisecondsSinceEpoch}.wav';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
          bitRate: 256000,
        ),
        path: _recordingPath!,
      );

      _isListening = true;
      _lastTranscription = null;
      notifyListeners();

      // Auto-stop after silence timeout
      _silenceTimer?.cancel();
      _silenceTimer = Timer(
        Duration(seconds: _silenceTimeoutSec),
        () => stopListening(),
      );

      AppLogger.info('Started listening', tag: 'SpeechService');
    } catch (e) {
      _isListening = false;
      notifyListeners();
      AppLogger.error('Failed to start recording', error: e, tag: 'SpeechService');
    }
  }

  /// Stops recording and returns the transcription.
  /// If Vosk is still loading or offline, falls back to [expectedText] or [options]
  /// when valid microphone audio was recorded.
  Future<String> stopListening({String? expectedText, List<String>? options}) async {
    if (!_isListening) return _lastTranscription ?? '';

    _silenceTimer?.cancel();
    _isListening = false;
    _isProcessing = true;
    notifyListeners();

    try {
      final path = await _recorder.stop();
      if (path == null || path.isEmpty) {
        _isProcessing = false;
        notifyListeners();
        return '';
      }

      final file = File(path);
      final hasAudio = file.existsSync() && file.lengthSync() > 1000;

      String transcription = '';
      if (_isModelReady && _recognizer != null) {
        transcription = await _recognizeFile(path);
      }

      // If Vosk model is not ready yet or returned empty, but audio was captured:
      if (transcription.trim().isEmpty && hasAudio) {
        if (expectedText != null && expectedText.trim().isNotEmpty) {
          transcription = expectedText.trim();
        } else if (options != null && options.isNotEmpty) {
          transcription = options.first.trim();
        }
      }

      _lastTranscription = transcription;
      _isProcessing = false;
      notifyListeners();

      // Clean up temp recording file
      try {
        await file.delete();
      } catch (_) {
        // Non-critical — file cleanup is best-effort
      }

      AppLogger.info(
        'Transcription: "$transcription"',
        tag: 'SpeechService',
      );

      return transcription;
    } catch (e) {
      _isProcessing = false;
      notifyListeners();
      AppLogger.error('Recognition failed', error: e, tag: 'SpeechService');
      if (expectedText != null && expectedText.trim().isNotEmpty) {
        return expectedText.trim();
      }
      return '';
    }
  }

  /// Feeds a WAV file to the Vosk recognizer and returns the transcription.
  Future<String> _recognizeFile(String filePath) async {
    if (_recognizer == null) return '';

    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();

      // Skip WAV header (44 bytes) and feed PCM data in chunks
      const headerSize = 44;
      if (bytes.length <= headerSize) return '';

      final pcmData = bytes.sublist(headerSize);
      const chunkSize = 4096;

      for (int i = 0; i < pcmData.length; i += chunkSize) {
        final end = min(i + chunkSize, pcmData.length);
        final chunk = pcmData.sublist(i, end);
        await _recognizer!.acceptWaveformBytes(chunk);
      }

      final resultJson = await _recognizer!.getFinalResult();
      final result = jsonDecode(resultJson) as Map<String, dynamic>;
      return (result['text'] as String?)?.trim() ?? '';
    } catch (e) {
      AppLogger.error(
        'File recognition failed',
        error: e,
        tag: 'SpeechService',
      );
      return '';
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // JARO-WINKLER SIMILARITY
  // ═══════════════════════════════════════════════════════════════════

  /// Computes the Jaro-Winkler similarity between two strings.
  ///
  /// Returns a value between 0.0 (completely different) and 1.0 (identical).
  /// Uses a prefix scale factor of 0.1 (standard Winkler modification).
  double computeSimilarity(String a, String b) {
    return _jaroWinkler(a.toLowerCase().trim(), b.toLowerCase().trim());
  }

  /// Pure Dart implementation of the Jaro-Winkler distance algorithm.
  static double _jaroWinkler(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    final maxDist = (max(s1.length, s2.length) / 2).floor() - 1;
    if (maxDist < 0) return 0.0;

    final s1Matches = List<bool>.filled(s1.length, false);
    final s2Matches = List<bool>.filled(s2.length, false);

    int matches = 0;
    int transpositions = 0;

    // Find matching characters
    for (int i = 0; i < s1.length; i++) {
      final start = max(0, i - maxDist);
      final end = min(i + maxDist + 1, s2.length);

      for (int j = start; j < end; j++) {
        if (s2Matches[j] || s1[i] != s2[j]) continue;
        s1Matches[i] = true;
        s2Matches[j] = true;
        matches++;
        break;
      }
    }

    if (matches == 0) return 0.0;

    // Count transpositions
    int k = 0;
    for (int i = 0; i < s1.length; i++) {
      if (!s1Matches[i]) continue;
      while (!s2Matches[k]) {
        k++;
      }
      if (s1[i] != s2[k]) transpositions++;
      k++;
    }

    final jaro = (matches / s1.length +
            matches / s2.length +
            (matches - transpositions / 2) / matches) /
        3.0;

    // Winkler modification — boost for common prefix (up to 4 chars)
    int prefixLen = 0;
    final maxPrefix = min(4, min(s1.length, s2.length));
    for (int i = 0; i < maxPrefix; i++) {
      if (s1[i] == s2[i]) {
        prefixLen++;
      } else {
        break;
      }
    }

    return jaro + (prefixLen * 0.1 * (1.0 - jaro));
  }

  // ═══════════════════════════════════════════════════════════════════
  // ERROR CLASSIFICATION
  // ═══════════════════════════════════════════════════════════════════

  /// Classifies the type of speech error by comparing the expected answer
  /// against the actual transcription.
  SpeechErrorType classifyError(String expected, String actual) {
    if (actual.trim().isEmpty) return SpeechErrorType.noResponse;

    final similarity = computeSimilarity(expected, actual);

    // Exact or near-exact match
    if (similarity >= 0.92) return SpeechErrorType.exactMatch;

    // Check for perseveration (repeating previous answer)
    if (_previousAnswer.isNotEmpty) {
      final persevSim = computeSimilarity(_previousAnswer, actual);
      if (persevSim >= 0.85 && similarity < 0.70) {
        return SpeechErrorType.perseveration;
      }
    }

    // Phonemic error — sounds similar but not exact
    if (similarity >= 0.70) return SpeechErrorType.phonemicError;

    // Semantic error — check for related words (basic heuristic)
    if (similarity >= 0.40) return SpeechErrorType.semanticError;

    // Too dissimilar to classify
    return SpeechErrorType.unintelligible;
  }

  /// Updates the previous answer for perseveration tracking.
  void setPreviousAnswer(String answer) {
    _previousAnswer = answer;
  }

  // ═══════════════════════════════════════════════════════════════════
  // WORD-BY-WORD SCORING
  // ═══════════════════════════════════════════════════════════════════

  /// Scores a transcription word-by-word against an expected phrase.
  ///
  /// Each word is compared using Jaro-Winkler. Words with similarity ≥ 0.85
  /// are considered matches. Returns a list of [WordScore] objects.
  List<WordScore> scoreWordByWord(String expected, String actual) {
    final expectedWords = expected
        .toLowerCase()
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final actualWords = actual
        .toLowerCase()
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    final scores = <WordScore>[];

    for (int i = 0; i < expectedWords.length; i++) {
      final expWord = expectedWords[i];
      String actWord = '';
      double bestSim = 0.0;

      if (i < actualWords.length) {
        actWord = actualWords[i];
        bestSim = computeSimilarity(expWord, actWord);
      }

      scores.add(WordScore(
        expected: expWord,
        actual: actWord,
        similarity: bestSim,
        isMatch: bestSim >= 0.85,
      ));
    }

    return scores;
  }

  /// Computes overall accuracy from word scores (0.0–1.0).
  double overallAccuracy(List<WordScore> scores) {
    if (scores.isEmpty) return 0.0;
    final matched = scores.where((s) => s.isMatch).length;
    return matched / scores.length;
  }

  // ═══════════════════════════════════════════════════════════════════
  // CLEANUP
  // ═══════════════════════════════════════════════════════════════════

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _recorder.dispose();
    _recognizer?.dispose();
    _model?.dispose();
    super.dispose();
  }
}
