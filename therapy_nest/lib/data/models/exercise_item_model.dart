/// The type of exercise task presented to the user.
///
/// Each type implies a different stimulus schema and response format.
/// The [ExerciseCardRenderer] widget switches on this enum to render
/// the appropriate exercise widget.
enum ExerciseTaskType {
  /// Show a picture, user speaks or types the name.
  pictureNaming,

  /// Show prompt + optional audio, user selects from text options.
  wordMatch,

  /// Show prompt, user selects from image options.
  multipleChoiceImage,

  /// Show a sequence briefly, user recalls the order.
  sequenceRecall,

  /// Show items, user drags them into correct order.
  sortOrder,

  /// Show sentence with a blank, user selects the missing word.
  sentenceCompletion,

  /// Show a passage + question, user selects from options.
  readingComprehension,

  /// TTS speaks a word, user repeats — scored via ASR.
  speechRepeat,

  /// Show digit → select word form (or reverse).
  numberRecognition,

  /// Addition/subtraction with visual object icons for concrete support.
  visualArithmetic,

  /// Price totals and change calculation (USD).
  moneyCalculation,

  /// Analog clock face → select correct time from options.
  clockReading,

  /// Fill-in-the-missing-number in an arithmetic sequence.
  numberSequence,

  /// Real-world multi-step math word problems.
  wordProblem,

  /// Show a grid, user taps the target item(s).
  targetFind,

  /// Show word-picture pairs, user matches after hiding.
  wordPairMatch,

  /// TTS reads word list, user selects heard words from larger list.
  auditoryMatch,

  /// Images shown one at a time, user taps "Match" if current = N steps ago.
  nBackVisual,

  /// TTS reads short story, user answers multiple-choice questions.
  storyMemory,

  /// Grid of symbols — user taps all instances of a target symbol (timed).
  symbolSearch,

  /// Mixed number/letter list — user taps items matching a rule.
  numberLetterFilter,

  /// Simultaneous dual task — tap target colors while tracking words.
  dualTask,

  /// Alternating rules per item — measures cognitive flexibility.
  taskSwitch,

  /// TTS speaks a command, user taps correct shape(s) on a grid.
  followInstruction,

  /// Category generation — user names as many items as possible in a time limit.
  wordFluency,

  /// TTS speaks or shows a word, user types the correct spelling.
  spelling,

  /// TTS speaks a phrase (2–8 words) → user repeats → word-by-word score.
  phraseRepeat,

  /// Display sentence → user reads aloud → word accuracy rate.
  oralReading,

  /// Display functional script → TTS models each line → user reads/repeats.
  scriptTraining,

  /// Show a word → user selects matching image, or vice versa.
  wordPictureMatch,

  /// Display a sentence → TTS reads aloud → MC comprehension question.
  sentenceReading,

  /// Show real-world text (menu, label, sign) → comprehension MC question.
  functionalReading,

  /// TTS speaks a word → user types spelling on custom large-key keyboard.
  spellingDictation,

  /// Show word/phrase → user copies by typing with per-character feedback.
  copyWriting,

  /// Show 3–6 words → user drags into alphabetical order.
  alphabetizeWords,
}

/// Maps a string code to [ExerciseTaskType].
ExerciseTaskType exerciseTaskTypeFromCode(String code) {
  switch (code) {
    case 'picture_naming':
      return ExerciseTaskType.pictureNaming;
    case 'word_match':
      return ExerciseTaskType.wordMatch;
    case 'multiple_choice_image':
      return ExerciseTaskType.multipleChoiceImage;
    case 'sequence_recall':
      return ExerciseTaskType.sequenceRecall;
    case 'sort_order':
      return ExerciseTaskType.sortOrder;
    case 'sentence_completion':
      return ExerciseTaskType.sentenceCompletion;
    case 'reading_comprehension':
      return ExerciseTaskType.readingComprehension;
    case 'speech_repeat':
      return ExerciseTaskType.speechRepeat;
    case 'number_recognition':
      return ExerciseTaskType.numberRecognition;
    case 'visual_arithmetic':
      return ExerciseTaskType.visualArithmetic;
    case 'money_calculation':
      return ExerciseTaskType.moneyCalculation;
    case 'clock_reading':
      return ExerciseTaskType.clockReading;
    case 'number_sequence':
      return ExerciseTaskType.numberSequence;
    case 'word_problem':
      return ExerciseTaskType.wordProblem;
    case 'target_find':
      return ExerciseTaskType.targetFind;
    case 'word_pair_match':
      return ExerciseTaskType.wordPairMatch;
    case 'auditory_match':
      return ExerciseTaskType.auditoryMatch;
    case 'n_back_visual':
      return ExerciseTaskType.nBackVisual;
    case 'story_memory':
      return ExerciseTaskType.storyMemory;
    case 'symbol_search':
      return ExerciseTaskType.symbolSearch;
    case 'number_letter_filter':
      return ExerciseTaskType.numberLetterFilter;
    case 'dual_task':
      return ExerciseTaskType.dualTask;
    case 'task_switch':
      return ExerciseTaskType.taskSwitch;
    case 'follow_instruction':
      return ExerciseTaskType.followInstruction;
    case 'word_fluency':
      return ExerciseTaskType.wordFluency;
    case 'spelling':
      return ExerciseTaskType.spelling;
    case 'phrase_repeat':
      return ExerciseTaskType.phraseRepeat;
    case 'oral_reading':
      return ExerciseTaskType.oralReading;
    case 'script_training':
      return ExerciseTaskType.scriptTraining;
    case 'word_picture_match':
      return ExerciseTaskType.wordPictureMatch;
    case 'sentence_reading':
      return ExerciseTaskType.sentenceReading;
    case 'functional_reading':
      return ExerciseTaskType.functionalReading;
    case 'spelling_dictation':
      return ExerciseTaskType.spellingDictation;
    case 'copy_writing':
      return ExerciseTaskType.copyWriting;
    case 'alphabetize_words':
      return ExerciseTaskType.alphabetizeWords;
    default:
      return ExerciseTaskType.wordMatch;
  }
}

/// Maps [ExerciseTaskType] to its string code.
String exerciseTaskTypeToCode(ExerciseTaskType type) {
  switch (type) {
    case ExerciseTaskType.pictureNaming:
      return 'picture_naming';
    case ExerciseTaskType.wordMatch:
      return 'word_match';
    case ExerciseTaskType.multipleChoiceImage:
      return 'multiple_choice_image';
    case ExerciseTaskType.sequenceRecall:
      return 'sequence_recall';
    case ExerciseTaskType.sortOrder:
      return 'sort_order';
    case ExerciseTaskType.sentenceCompletion:
      return 'sentence_completion';
    case ExerciseTaskType.readingComprehension:
      return 'reading_comprehension';
    case ExerciseTaskType.speechRepeat:
      return 'speech_repeat';
    case ExerciseTaskType.numberRecognition:
      return 'number_recognition';
    case ExerciseTaskType.visualArithmetic:
      return 'visual_arithmetic';
    case ExerciseTaskType.moneyCalculation:
      return 'money_calculation';
    case ExerciseTaskType.clockReading:
      return 'clock_reading';
    case ExerciseTaskType.numberSequence:
      return 'number_sequence';
    case ExerciseTaskType.wordProblem:
      return 'word_problem';
    case ExerciseTaskType.targetFind:
      return 'target_find';
    case ExerciseTaskType.wordPairMatch:
      return 'word_pair_match';
    case ExerciseTaskType.auditoryMatch:
      return 'auditory_match';
    case ExerciseTaskType.nBackVisual:
      return 'n_back_visual';
    case ExerciseTaskType.storyMemory:
      return 'story_memory';
    case ExerciseTaskType.symbolSearch:
      return 'symbol_search';
    case ExerciseTaskType.numberLetterFilter:
      return 'number_letter_filter';
    case ExerciseTaskType.dualTask:
      return 'dual_task';
    case ExerciseTaskType.taskSwitch:
      return 'task_switch';
    case ExerciseTaskType.followInstruction:
      return 'follow_instruction';
    case ExerciseTaskType.wordFluency:
      return 'word_fluency';
    case ExerciseTaskType.spelling:
      return 'spelling';
    case ExerciseTaskType.phraseRepeat:
      return 'phrase_repeat';
    case ExerciseTaskType.oralReading:
      return 'oral_reading';
    case ExerciseTaskType.scriptTraining:
      return 'script_training';
    case ExerciseTaskType.wordPictureMatch:
      return 'word_picture_match';
    case ExerciseTaskType.sentenceReading:
      return 'sentence_reading';
    case ExerciseTaskType.functionalReading:
      return 'functional_reading';
    case ExerciseTaskType.spellingDictation:
      return 'spelling_dictation';
    case ExerciseTaskType.copyWriting:
      return 'copy_writing';
    case ExerciseTaskType.alphabetizeWords:
      return 'alphabetize_words';
  }
}

/// A single exercise item used during therapy sessions.
///
/// Items carry IRT parameters ([difficulty], [discrimination]) for
/// the adaptive Elo-style selection engine, a flexible [stimulus]
/// payload whose schema varies by [taskType], and a graduated [cues]
/// list for the clinical cueing hierarchy.
class ExerciseItemModel {
  const ExerciseItemModel({
    required this.id,
    required this.exerciseTypeCode,
    required this.taskType,
    required this.domain,
    required this.difficulty,
    this.discrimination = 1.0,
    this.locale = 'en',
    required this.stimulus,
    required this.acceptedAnswers,
    this.mediaUrl,
    this.cues = const [],
    this.isActive = true,
  });

  /// Unique identifier (e.g. "lang_ex_01").
  final String id;

  /// Raw task type code string (e.g. "word_match").
  final String exerciseTypeCode;

  /// Parsed task type enum.
  final ExerciseTaskType taskType;

  /// Clinical domain: language, comprehension, memory, attention, speech, math.
  final String domain;

  /// IRT difficulty parameter (b). Range: roughly -3.0 to +3.0.
  final double difficulty;

  /// IRT discrimination parameter (a). Default 1.0.
  final double discrimination;

  /// Locale for this item (e.g. "en", "es").
  final String locale;

  /// Flexible stimulus payload — contents vary by [taskType].
  ///
  /// Examples:
  /// - wordMatch: `{ 'promptText': '...', 'options': [...] }`
  /// - sequenceRecall: `{ 'sequence': [...], 'displayTimeMs': 3000 }`
  /// - mathSelect: `{ 'mathPromptText': '3 + 4 = ?', 'options': [...] }`
  final Map<String, dynamic> stimulus;

  /// All accepted answer strings (first is the "primary" correct answer).
  final List<String> acceptedAnswers;

  /// Optional media URL (image, audio).
  final String? mediaUrl;

  /// Graduated cueing hierarchy for this item.
  ///
  /// Each entry: `{ 'level': '1', 'type': 'semantic', 'text': '...' }`
  /// Levels 0-4 per the clinical cueing standard.
  final List<Map<String, String>> cues;

  /// Whether this item is currently active in the item bank.
  final bool isActive;

  /// The primary correct answer (first entry in [acceptedAnswers]).
  String get correctAnswer =>
      acceptedAnswers.isNotEmpty ? acceptedAnswers.first : '';

  /// Whether [answer] is correct (case-insensitive match against accepted list).
  bool isCorrect(String answer) {
    final lower = answer.toLowerCase().trim();
    return acceptedAnswers.any((a) => a.toLowerCase().trim() == lower);
  }

  /// Creates an [ExerciseItemModel] from a JSON map.
  factory ExerciseItemModel.fromJson(Map<String, dynamic> json) {
    final code = json['exercise_type_code'] as String? ?? 'word_match';
    final cuesList =
        (json['cues'] as List<dynamic>?)
            ?.map((c) => Map<String, String>.from(c as Map))
            .toList() ??
        [];

    return ExerciseItemModel(
      id: json['id'] as String,
      exerciseTypeCode: code,
      taskType: exerciseTaskTypeFromCode(code),
      domain: json['domain'] as String,
      difficulty: (json['difficulty'] as num).toDouble(),
      discrimination: (json['discrimination'] as num?)?.toDouble() ?? 1.0,
      locale: json['locale'] as String? ?? 'en',
      stimulus: Map<String, dynamic>.from(json['stimulus'] as Map),
      acceptedAnswers: List<String>.from(json['accepted_answers'] as List),
      mediaUrl: json['media_url'] as String?,
      cues: cuesList,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Converts to a JSON map for persistence.
  Map<String, dynamic> toJson() => {
    'id': id,
    'exercise_type_code': exerciseTypeCode,
    'domain': domain,
    'difficulty': difficulty,
    'discrimination': discrimination,
    'locale': locale,
    'stimulus': stimulus,
    'accepted_answers': acceptedAnswers,
    'media_url': mediaUrl,
    'cues': cues,
    'is_active': isActive,
  };
}
