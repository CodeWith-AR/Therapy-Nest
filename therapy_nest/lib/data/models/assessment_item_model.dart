/// The type of task presented in a baseline assessment item.
enum AssessmentTaskType {
  /// Show picture, select correct word from 4 options.
  multipleChoice,

  /// TTS reads word/phrase, select matching picture from 4 options.
  auditoryChoice,

  /// Show sequence of colored shapes, then recall correct sequence.
  sequenceRecall,

  /// Find and tap target symbols in a grid (timed).
  symbolSearch,

  /// TTS speaks word, user repeats — scored via ASR fuzzy match.
  speechRepetition,

  /// Number recognition or clock reading — select correct answer.
  numberRecognition,
}

/// A single assessment item used during baseline evaluation.
///
/// Items are pre-seeded with IRT difficulty parameters (`difficulty`)
/// and belong to one of the six clinical domains.
class AssessmentItemModel {
  const AssessmentItemModel({
    required this.id,
    required this.domain,
    required this.taskType,
    required this.difficulty,
    required this.stimulus,
    required this.options,
    required this.correctAnswer,
    this.acceptedAnswers = const [],
  });

  /// Unique identifier for this item (e.g. "lang_01").
  final String id;

  /// Clinical domain: language, comprehension, memory, attention, speech, math.
  final String domain;

  /// The interaction modality for this item.
  final AssessmentTaskType taskType;

  /// IRT difficulty parameter (b). Range: roughly -2.0 to +2.0.
  final double difficulty;

  /// Flexible stimulus payload — contents vary by [taskType].
  ///
  /// Examples:
  /// - multipleChoice: `{ 'icon': 0xe148, 'label': 'Apple' }`
  /// - sequenceRecall: `{ 'colors': ['red', 'blue', 'green'], 'shapes': ['circle', 'square', 'triangle'] }`
  /// - symbolSearch:   `{ 'target': '★', 'grid': ['★','●','▲', ...], 'targetCount': 3 }`
  final Map<String, dynamic> stimulus;

  /// The list of answer options presented to the user.
  final List<String> options;

  /// The single correct answer string.
  final String correctAnswer;

  /// Additional accepted answers (e.g. phoneme-similar words for speech).
  final List<String> acceptedAnswers;

  /// Whether [answer] is correct (exact match or in accepted list).
  bool isCorrect(String answer) {
    if (answer == correctAnswer) return true;
    return acceptedAnswers.contains(answer);
  }
}
