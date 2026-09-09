// Memory exercise seed data — no Flutter imports needed.

import '../models/exercise_item_model.dart';
import 'exercise_repository.dart';

/// 50 memory-domain exercise items covering all 5 memory task types,
/// spanning difficulty b = -2.0 → +2.0.
///
/// Imported by [ExerciseRepository._memoryItems].
const List<ExerciseItemModel> memoryExerciseSeedData = [
  // ═══════════════════════════════════════════════════════════════════
  // 4A — SEQUENCE RECALL  (10 items, mem_seq_01 → mem_seq_10)
  // ═══════════════════════════════════════════════════════════════════

  ExerciseItemModel(
    id: 'mem_seq_01',
    exerciseTypeCode: 'sequence_recall',
    taskType: ExerciseTaskType.sequenceRecall,
    domain: ExerciseRepository.domainMemory,
    difficulty: -2.0,
    stimulus: {
      'sequence': ['red_circle', 'blue_square'],
      'displayTimeMs': 3000,
      'options': [
        'red_circle, blue_square',
        'blue_square, red_circle',
        'red_circle, red_circle',
      ],
    },
    acceptedAnswers: ['red_circle, blue_square'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'The first shape was round and red'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "red"'},
      {'level': '3', 'type': 'visual', 'text': '🔴 → ?'},
      {'level': '4', 'type': 'model', 'text': 'The sequence was: red circle, blue square'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_seq_02',
    exerciseTypeCode: 'sequence_recall',
    taskType: ExerciseTaskType.sequenceRecall,
    domain: ExerciseRepository.domainMemory,
    difficulty: -1.5,
    stimulus: {
      'sequence': ['green_triangle', 'yellow_star'],
      'displayTimeMs': 3000,
      'options': [
        'green_triangle, yellow_star',
        'yellow_star, green_triangle',
        'green_triangle, green_triangle',
      ],
    },
    acceptedAnswers: ['green_triangle, yellow_star'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'The first shape had three sides'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "green"'},
      {'level': '3', 'type': 'visual', 'text': '🟢△ → ?'},
      {'level': '4', 'type': 'model', 'text': 'The sequence was: green triangle, yellow star'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_seq_03',
    exerciseTypeCode: 'sequence_recall',
    taskType: ExerciseTaskType.sequenceRecall,
    domain: ExerciseRepository.domainMemory,
    difficulty: -1.0,
    stimulus: {
      'sequence': ['blue_square', 'red_circle', 'green_triangle'],
      'displayTimeMs': 3000,
      'options': [
        'blue_square, red_circle, green_triangle',
        'red_circle, blue_square, green_triangle',
        'green_triangle, red_circle, blue_square',
      ],
    },
    acceptedAnswers: ['blue_square, red_circle, green_triangle'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'The first shape was a blue square'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "blue"'},
      {'level': '3', 'type': 'visual', 'text': '🟦 → 🔴 → ?'},
      {'level': '4', 'type': 'model', 'text': 'The sequence was: blue square, red circle, green triangle'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_seq_04',
    exerciseTypeCode: 'sequence_recall',
    taskType: ExerciseTaskType.sequenceRecall,
    domain: ExerciseRepository.domainMemory,
    difficulty: -0.5,
    stimulus: {
      'sequence': ['yellow_star', 'blue_square', 'red_circle'],
      'displayTimeMs': 3000,
      'options': [
        'yellow_star, blue_square, red_circle',
        'blue_square, yellow_star, red_circle',
        'red_circle, blue_square, yellow_star',
      ],
    },
    acceptedAnswers: ['yellow_star, blue_square, red_circle'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'The first shape was shaped like a star'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "yellow"'},
      {'level': '3', 'type': 'visual', 'text': '⭐ → 🟦 → ?'},
      {'level': '4', 'type': 'model', 'text': 'The sequence was: yellow star, blue square, red circle'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_seq_05',
    exerciseTypeCode: 'sequence_recall',
    taskType: ExerciseTaskType.sequenceRecall,
    domain: ExerciseRepository.domainMemory,
    difficulty: 0.0,
    stimulus: {
      'sequence': ['red_circle', 'green_triangle', 'blue_square', 'yellow_star'],
      'displayTimeMs': 4000,
      'options': [
        'red_circle, green_triangle, blue_square, yellow_star',
        'green_triangle, red_circle, yellow_star, blue_square',
        'blue_square, red_circle, green_triangle, yellow_star',
      ],
    },
    acceptedAnswers: ['red_circle, green_triangle, blue_square, yellow_star'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'It started with a round red shape'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "red"'},
      {'level': '3', 'type': 'visual', 'text': '🔴 → 🟢△ → 🟦 → ?'},
      {'level': '4', 'type': 'model', 'text': 'The sequence was: red circle, green triangle, blue square, yellow star'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_seq_06',
    exerciseTypeCode: 'sequence_recall',
    taskType: ExerciseTaskType.sequenceRecall,
    domain: ExerciseRepository.domainMemory,
    difficulty: 0.5,
    stimulus: {
      'sequence': ['blue_square', 'yellow_star', 'red_circle', 'green_triangle'],
      'displayTimeMs': 4000,
      'options': [
        'blue_square, yellow_star, red_circle, green_triangle',
        'yellow_star, blue_square, green_triangle, red_circle',
        'red_circle, green_triangle, blue_square, yellow_star',
      ],
    },
    acceptedAnswers: ['blue_square, yellow_star, red_circle, green_triangle'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'It started with a blue shape with four sides'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "blue"'},
      {'level': '3', 'type': 'visual', 'text': '🟦 → ⭐ → 🔴 → ?'},
      {'level': '4', 'type': 'model', 'text': 'The sequence was: blue square, yellow star, red circle, green triangle'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_seq_07',
    exerciseTypeCode: 'sequence_recall',
    taskType: ExerciseTaskType.sequenceRecall,
    domain: ExerciseRepository.domainMemory,
    difficulty: 1.0,
    stimulus: {
      'sequence': ['green_triangle', 'red_circle', 'yellow_star', 'blue_square', 'red_circle'],
      'displayTimeMs': 5000,
      'options': [
        'green_triangle, red_circle, yellow_star, blue_square, red_circle',
        'red_circle, green_triangle, yellow_star, blue_square, red_circle',
        'green_triangle, yellow_star, red_circle, blue_square, red_circle',
      ],
    },
    acceptedAnswers: ['green_triangle, red_circle, yellow_star, blue_square, red_circle'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'It started with a green three-sided shape'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "green"'},
      {'level': '3', 'type': 'visual', 'text': '🟢△ → 🔴 → ⭐ → 🟦 → ?'},
      {'level': '4', 'type': 'model', 'text': 'The sequence was: green triangle, red circle, yellow star, blue square, red_circle'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_seq_08',
    exerciseTypeCode: 'sequence_recall',
    taskType: ExerciseTaskType.sequenceRecall,
    domain: ExerciseRepository.domainMemory,
    difficulty: 1.5,
    stimulus: {
      'sequence': ['yellow_star', 'blue_square', 'green_triangle', 'red_circle', 'yellow_star'],
      'displayTimeMs': 5000,
      'options': [
        'yellow_star, blue_square, green_triangle, red_circle, yellow_star',
        'blue_square, yellow_star, red_circle, green_triangle, yellow_star',
        'yellow_star, green_triangle, blue_square, red_circle, yellow_star',
      ],
    },
    acceptedAnswers: ['yellow_star, blue_square, green_triangle, red_circle, yellow_star'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'It started and ended with the same yellow shape'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "yellow"'},
      {'level': '3', 'type': 'visual', 'text': '⭐ → 🟦 → 🟢△ → 🔴 → ?'},
      {'level': '4', 'type': 'model', 'text': 'The sequence was: yellow star, blue square, green triangle, red circle, yellow star'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_seq_09',
    exerciseTypeCode: 'sequence_recall',
    taskType: ExerciseTaskType.sequenceRecall,
    domain: ExerciseRepository.domainMemory,
    difficulty: 1.75,
    stimulus: {
      'sequence': ['red_circle', 'green_triangle', 'blue_square', 'yellow_star', 'green_triangle', 'red_circle'],
      'displayTimeMs': 5000,
      'options': [
        'red_circle, green_triangle, blue_square, yellow_star, green_triangle, red_circle',
        'green_triangle, red_circle, blue_square, yellow_star, red_circle, green_triangle',
        'red_circle, blue_square, green_triangle, yellow_star, green_triangle, red_circle',
      ],
    },
    acceptedAnswers: ['red_circle, green_triangle, blue_square, yellow_star, green_triangle, red_circle'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'It started with a red circle and ended with a red circle'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "red"'},
      {'level': '3', 'type': 'visual', 'text': '🔴 → 🟢△ → 🟦 → ⭐ → 🟢△ → ?'},
      {'level': '4', 'type': 'model', 'text': 'Six shapes: red circle, green triangle, blue square, yellow star, green triangle, red circle'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_seq_10',
    exerciseTypeCode: 'sequence_recall',
    taskType: ExerciseTaskType.sequenceRecall,
    domain: ExerciseRepository.domainMemory,
    difficulty: 2.0,
    stimulus: {
      'sequence': ['blue_square', 'yellow_star', 'red_circle', 'green_triangle', 'blue_square', 'yellow_star'],
      'displayTimeMs': 4500,
      'options': [
        'blue_square, yellow_star, red_circle, green_triangle, blue_square, yellow_star',
        'yellow_star, blue_square, green_triangle, red_circle, yellow_star, blue_square',
        'blue_square, red_circle, yellow_star, green_triangle, blue_square, yellow_star',
      ],
    },
    acceptedAnswers: ['blue_square, yellow_star, red_circle, green_triangle, blue_square, yellow_star'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Six shapes — first and fifth are both blue squares'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "blue"'},
      {'level': '3', 'type': 'visual', 'text': '🟦 → ⭐ → 🔴 → 🟢△ → 🟦 → ?'},
      {'level': '4', 'type': 'model', 'text': 'The sequence: blue square, yellow star, red circle, green triangle, blue square, yellow star'},
    ],
  ),

  // ═══════════════════════════════════════════════════════════════════
  // 4B — WORD-PAIR MATCH  (10 items, mem_wp_01 → mem_wp_10)
  // ═══════════════════════════════════════════════════════════════════

  ExerciseItemModel(
    id: 'mem_wp_01',
    exerciseTypeCode: 'word_pair_match',
    taskType: ExerciseTaskType.wordPairMatch,
    domain: ExerciseRepository.domainMemory,
    difficulty: -2.0,
    stimulus: {
      'pairs': [
        {'word': 'Apple', 'icon': 0xe070}, // Icons.apple
        {'word': 'House', 'icon': 0xe318}, // Icons.house
      ],
      'displayTimeMs': 8000,
    },
    acceptedAnswers: ['correct'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Think about what you eat and where you live'},
      {'level': '2', 'type': 'phonemic', 'text': 'The fruit starts with "A"'},
      {'level': '3', 'type': 'visual', 'text': 'Apple → 🍎, House → 🏠'},
      {'level': '4', 'type': 'model', 'text': 'Apple matches the fruit icon, House matches the building icon'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_wp_02',
    exerciseTypeCode: 'word_pair_match',
    taskType: ExerciseTaskType.wordPairMatch,
    domain: ExerciseRepository.domainMemory,
    difficulty: -1.5,
    stimulus: {
      'pairs': [
        {'word': 'Sun', 'icon': 0xf06AF}, // Icons.wb_sunny
        {'word': 'Car', 'icon': 0xe1D7}, // Icons.directions_car
      ],
      'displayTimeMs': 8000,
    },
    acceptedAnswers: ['correct'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'One is in the sky, one is on the road'},
      {'level': '2', 'type': 'phonemic', 'text': 'The sky one starts with "S"'},
      {'level': '3', 'type': 'visual', 'text': 'Sun → ☀, Car → 🚗'},
      {'level': '4', 'type': 'model', 'text': 'Sun matches the sun icon, Car matches the car icon'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_wp_03',
    exerciseTypeCode: 'word_pair_match',
    taskType: ExerciseTaskType.wordPairMatch,
    domain: ExerciseRepository.domainMemory,
    difficulty: -1.0,
    stimulus: {
      'pairs': [
        {'word': 'Book', 'icon': 0xe3F7}, // Icons.menu_book
        {'word': 'Music', 'icon': 0xe3EC}, // Icons.music_note
        {'word': 'Star', 'icon': 0xe5F9}, // Icons.star
      ],
      'displayTimeMs': 7000,
    },
    acceptedAnswers: ['correct'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'You read one, listen to another, and see the last in the sky'},
      {'level': '2', 'type': 'phonemic', 'text': 'The reading one starts with "B"'},
      {'level': '3', 'type': 'visual', 'text': 'Book → 📖, Music → 🎵, Star → ⭐'},
      {'level': '4', 'type': 'model', 'text': 'Book matches book icon, Music matches note, Star matches star'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_wp_04',
    exerciseTypeCode: 'word_pair_match',
    taskType: ExerciseTaskType.wordPairMatch,
    domain: ExerciseRepository.domainMemory,
    difficulty: -0.5,
    stimulus: {
      'pairs': [
        {'word': 'Phone', 'icon': 0xe4Ba}, // Icons.phone
        {'word': 'Clock', 'icon': 0xe045}, // Icons.access_time
        {'word': 'Key', 'icon': 0xe73C}, // Icons.vpn_key
      ],
      'displayTimeMs': 6000,
    },
    acceptedAnswers: ['correct'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'You call with one, check time on another, and unlock with the third'},
      {'level': '2', 'type': 'phonemic', 'text': 'The calling device starts with "Ph"'},
      {'level': '3', 'type': 'visual', 'text': 'Phone → 📱, Clock → ⏰, Key → 🔑'},
      {'level': '4', 'type': 'model', 'text': 'Phone → phone icon, Clock → time icon, Key → key icon'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_wp_05',
    exerciseTypeCode: 'word_pair_match',
    taskType: ExerciseTaskType.wordPairMatch,
    domain: ExerciseRepository.domainMemory,
    difficulty: 0.0,
    stimulus: {
      'pairs': [
        {'word': 'Heart', 'icon': 0xe3D4}, // Icons.favorite
        {'word': 'Camera', 'icon': 0xe3AF}, // Icons.camera_alt
        {'word': 'Cloud', 'icon': 0xe155}, // Icons.cloud
        {'word': 'Tree', 'icon': 0xe4BE}, // Icons.park
      ],
      'displayTimeMs': 6000,
    },
    acceptedAnswers: ['correct'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'One beats, one takes photos, one floats, one grows'},
      {'level': '2', 'type': 'phonemic', 'text': 'The photo one starts with "C"'},
      {'level': '3', 'type': 'visual', 'text': 'Heart → ❤, Camera → 📷'},
      {'level': '4', 'type': 'model', 'text': 'Heart → heart, Camera → camera, Cloud → cloud, Tree → park'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_wp_06',
    exerciseTypeCode: 'word_pair_match',
    taskType: ExerciseTaskType.wordPairMatch,
    domain: ExerciseRepository.domainMemory,
    difficulty: 0.5,
    stimulus: {
      'pairs': [
        {'word': 'Lamp', 'icon': 0xe3E7}, // Icons.lightbulb
        {'word': 'Lock', 'icon': 0xe3E8}, // Icons.lock
        {'word': 'Globe', 'icon': 0xf063C}, // Icons.public
        {'word': 'Bell', 'icon': 0xe420}, // Icons.notifications
      ],
      'displayTimeMs': 5000,
    },
    acceptedAnswers: ['correct'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'One lights up, one secures, one is round, one rings'},
      {'level': '2', 'type': 'phonemic', 'text': 'The ringing one starts with "B"'},
      {'level': '3', 'type': 'visual', 'text': 'Lamp → 💡, Lock → 🔒'},
      {'level': '4', 'type': 'model', 'text': 'Lamp → lightbulb, Lock → lock, Globe → earth, Bell → notification'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_wp_07',
    exerciseTypeCode: 'word_pair_match',
    taskType: ExerciseTaskType.wordPairMatch,
    domain: ExerciseRepository.domainMemory,
    difficulty: 1.0,
    stimulus: {
      'pairs': [
        {'word': 'Anchor', 'icon': 0xf04D0}, // Icons.anchor
        {'word': 'Shield', 'icon': 0xe58F}, // Icons.shield
        {'word': 'Diamond', 'icon': 0xe1A6}, // Icons.diamond
        {'word': 'Rocket', 'icon': 0xf069D}, // Icons.rocket_launch
        {'word': 'Palette', 'icon': 0xe427}, // Icons.palette
      ],
      'displayTimeMs': 5000,
    },
    acceptedAnswers: ['correct'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Think sea, protection, precious, space, art'},
      {'level': '2', 'type': 'phonemic', 'text': 'The precious one starts with "D"'},
      {'level': '3', 'type': 'visual', 'text': 'Anchor → ⚓, Shield → 🛡'},
      {'level': '4', 'type': 'model', 'text': 'Anchor → anchor icon, Shield → shield, Diamond → gem, Rocket → rocket, Palette → art'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_wp_08',
    exerciseTypeCode: 'word_pair_match',
    taskType: ExerciseTaskType.wordPairMatch,
    domain: ExerciseRepository.domainMemory,
    difficulty: 1.5,
    stimulus: {
      'pairs': [
        {'word': 'Compass', 'icon': 0xe21E}, // Icons.explore
        {'word': 'Feather', 'icon': 0xe248}, // Icons.edit
        {'word': 'Trumpet', 'icon': 0xe3EC}, // Icons.music_note
        {'word': 'Crown', 'icon': 0xe5F9}, // Icons.star
        {'word': 'Torch', 'icon': 0xf0529}, // Icons.flashlight_on
      ],
      'displayTimeMs': 4000,
    },
    acceptedAnswers: ['correct'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Direction, writing, sound, royalty, light'},
      {'level': '2', 'type': 'phonemic', 'text': 'The direction one starts with "C"'},
      {'level': '3', 'type': 'visual', 'text': 'Compass → 🧭, Crown → 👑'},
      {'level': '4', 'type': 'model', 'text': 'Match each word to its corresponding icon'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_wp_09',
    exerciseTypeCode: 'word_pair_match',
    taskType: ExerciseTaskType.wordPairMatch,
    domain: ExerciseRepository.domainMemory,
    difficulty: 1.75,
    stimulus: {
      'pairs': [
        {'word': 'Magnet', 'icon': 0xe3E8}, // Icons.lock (abstract)
        {'word': 'Prism', 'icon': 0xe1A6}, // Icons.diamond
        {'word': 'Gear', 'icon': 0xe57F}, // Icons.settings
        {'word': 'Lens', 'icon': 0xe3AF}, // Icons.camera_alt
        {'word': 'Scroll', 'icon': 0xe873}, // Icons.description
        {'word': 'Flame', 'icon': 0xe3F7}, // Icons.local_fire_department
      ],
      'displayTimeMs': 3500,
    },
    acceptedAnswers: ['correct'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Attracts metal, splits light, turns, focuses, ancient text, hot'},
      {'level': '2', 'type': 'phonemic', 'text': 'The turning one starts with "G"'},
      {'level': '3', 'type': 'visual', 'text': 'Gear → ⚙, Flame → 🔥'},
      {'level': '4', 'type': 'model', 'text': 'Match each word with its symbolic icon'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_wp_10',
    exerciseTypeCode: 'word_pair_match',
    taskType: ExerciseTaskType.wordPairMatch,
    domain: ExerciseRepository.domainMemory,
    difficulty: 2.0,
    stimulus: {
      'pairs': [
        {'word': 'Satellite', 'icon': 0xe560}, // Icons.satellite_alt
        {'word': 'Molecule', 'icon': 0xe574}, // Icons.science
        {'word': 'Compass', 'icon': 0xe21E}, // Icons.explore
        {'word': 'Hourglass', 'icon': 0xe316}, // Icons.hourglass_empty
        {'word': 'Telescope', 'icon': 0xe745}, // Icons.visibility
        {'word': 'Scale', 'icon': 0xf06AB}, // Icons.balance
      ],
      'displayTimeMs': 3000,
    },
    acceptedAnswers: ['correct'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Space, chemistry, direction, time, seeing far, weighing'},
      {'level': '2', 'type': 'phonemic', 'text': 'The time one starts with "H"'},
      {'level': '3', 'type': 'visual', 'text': 'Satellite → 🛰, Hourglass → ⏳'},
      {'level': '4', 'type': 'model', 'text': 'Match all six word-icon pairs'},
    ],
  ),

  // ═══════════════════════════════════════════════════════════════════
  // 4C — AUDITORY MATCH  (10 items, mem_aud_01 → mem_aud_10)
  // ═══════════════════════════════════════════════════════════════════

  ExerciseItemModel(
    id: 'mem_aud_01',
    exerciseTypeCode: 'auditory_match',
    taskType: ExerciseTaskType.auditoryMatch,
    domain: ExerciseRepository.domainMemory,
    difficulty: -2.0,
    stimulus: {
      'targetWords': ['cat', 'ball'],
      'options': ['cat', 'ball', 'tree', 'milk', 'shoe'],
    },
    acceptedAnswers: ['ball, cat'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'One is a pet, one is round'},
      {'level': '2', 'type': 'phonemic', 'text': 'One starts with "c", one with "b"'},
      {'level': '3', 'type': 'visual', 'text': '🐱 and ⚽'},
      {'level': '4', 'type': 'model', 'text': 'The words were: cat, ball'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_aud_02',
    exerciseTypeCode: 'auditory_match',
    taskType: ExerciseTaskType.auditoryMatch,
    domain: ExerciseRepository.domainMemory,
    difficulty: -1.5,
    stimulus: {
      'targetWords': ['dog', 'cup'],
      'options': ['dog', 'cup', 'hat', 'box', 'pen'],
    },
    acceptedAnswers: ['cup, dog'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'One barks, one holds drinks'},
      {'level': '2', 'type': 'phonemic', 'text': 'One starts with "d", one with "c"'},
      {'level': '3', 'type': 'visual', 'text': '🐕 and ☕'},
      {'level': '4', 'type': 'model', 'text': 'The words were: dog, cup'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_aud_03',
    exerciseTypeCode: 'auditory_match',
    taskType: ExerciseTaskType.auditoryMatch,
    domain: ExerciseRepository.domainMemory,
    difficulty: -1.0,
    stimulus: {
      'targetWords': ['fish', 'moon', 'key'],
      'options': ['fish', 'moon', 'key', 'lamp', 'door', 'ring'],
    },
    acceptedAnswers: ['fish, key, moon'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'One swims, one shines at night, one opens locks'},
      {'level': '2', 'type': 'phonemic', 'text': 'One starts with "f", one with "m", one with "k"'},
      {'level': '3', 'type': 'visual', 'text': '🐟, 🌙, 🔑'},
      {'level': '4', 'type': 'model', 'text': 'The words were: fish, moon, key'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_aud_04',
    exerciseTypeCode: 'auditory_match',
    taskType: ExerciseTaskType.auditoryMatch,
    domain: ExerciseRepository.domainMemory,
    difficulty: -0.5,
    stimulus: {
      'targetWords': ['rain', 'book', 'chair'],
      'options': ['rain', 'book', 'chair', 'snow', 'page', 'table', 'cloud'],
    },
    acceptedAnswers: ['book, chair, rain'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'One falls from sky, one you read, one you sit on'},
      {'level': '2', 'type': 'phonemic', 'text': 'One starts with "r", one with "b", one with "ch"'},
      {'level': '3', 'type': 'visual', 'text': '🌧, 📖, 🪑'},
      {'level': '4', 'type': 'model', 'text': 'The words were: rain, book, chair'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_aud_05',
    exerciseTypeCode: 'auditory_match',
    taskType: ExerciseTaskType.auditoryMatch,
    domain: ExerciseRepository.domainMemory,
    difficulty: 0.0,
    stimulus: {
      'targetWords': ['house', 'bird', 'clock'],
      'options': ['house', 'bird', 'clock', 'home', 'nest', 'watch', 'time', 'tree'],
    },
    acceptedAnswers: ['bird, clock, house'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'You live in one, one flies, one tells time'},
      {'level': '2', 'type': 'phonemic', 'text': 'One starts with "h", one with "b", one with "cl"'},
      {'level': '3', 'type': 'visual', 'text': '🏠, 🐦, ⏰'},
      {'level': '4', 'type': 'model', 'text': 'The words were: house, bird, clock'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_aud_06',
    exerciseTypeCode: 'auditory_match',
    taskType: ExerciseTaskType.auditoryMatch,
    domain: ExerciseRepository.domainMemory,
    difficulty: 0.5,
    stimulus: {
      'targetWords': ['garden', 'bridge', 'candle', 'river'],
      'options': ['garden', 'bridge', 'candle', 'river', 'forest', 'tunnel', 'lantern', 'stream', 'meadow'],
    },
    acceptedAnswers: ['bridge, candle, garden, river'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Flowers grow, you cross it, it gives light, water flows'},
      {'level': '2', 'type': 'phonemic', 'text': 'One starts with "g", one with "br"'},
      {'level': '3', 'type': 'visual', 'text': '🌻, 🌉, 🕯, 🏞'},
      {'level': '4', 'type': 'model', 'text': 'The words were: garden, bridge, candle, river'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_aud_07',
    exerciseTypeCode: 'auditory_match',
    taskType: ExerciseTaskType.auditoryMatch,
    domain: ExerciseRepository.domainMemory,
    difficulty: 1.0,
    stimulus: {
      'targetWords': ['mountain', 'violin', 'thunder', 'blanket'],
      'options': ['mountain', 'violin', 'thunder', 'blanket', 'valley', 'guitar', 'lightning', 'pillow', 'summit', 'cello'],
    },
    acceptedAnswers: ['blanket, mountain, thunder, violin'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Tall landform, string instrument, loud weather, warm cover'},
      {'level': '2', 'type': 'phonemic', 'text': 'One starts with "m", one with "v"'},
      {'level': '3', 'type': 'visual', 'text': '🏔, 🎻, ⚡, 🧣'},
      {'level': '4', 'type': 'model', 'text': 'The words were: mountain, violin, thunder, blanket'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_aud_08',
    exerciseTypeCode: 'auditory_match',
    taskType: ExerciseTaskType.auditoryMatch,
    domain: ExerciseRepository.domainMemory,
    difficulty: 1.5,
    stimulus: {
      'targetWords': ['compass', 'feather', 'marble', 'anchor', 'lantern'],
      'options': ['compass', 'feather', 'marble', 'anchor', 'lantern', 'compass rose', 'pillow', 'stone', 'chain', 'torch', 'needle', 'crystal'],
    },
    acceptedAnswers: ['anchor, compass, feather, lantern, marble'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Direction, bird part, glass ball, boat weight, old light'},
      {'level': '2', 'type': 'phonemic', 'text': 'One starts with "c", one with "f", one with "m"'},
      {'level': '3', 'type': 'visual', 'text': '🧭, 🪶, ⚽, ⚓, 🏮'},
      {'level': '4', 'type': 'model', 'text': 'The words were: compass, feather, marble, anchor, lantern'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_aud_09',
    exerciseTypeCode: 'auditory_match',
    taskType: ExerciseTaskType.auditoryMatch,
    domain: ExerciseRepository.domainMemory,
    difficulty: 1.75,
    stimulus: {
      'targetWords': ['telescope', 'whistle', 'envelope', 'curtain', 'helmet'],
      'options': ['telescope', 'whistle', 'envelope', 'curtain', 'helmet', 'binoculars', 'flute', 'letter', 'drape', 'visor', 'periscope', 'horn'],
    },
    acceptedAnswers: ['curtain, envelope, helmet, telescope, whistle'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'See far, make a sound, mail, window cover, head protection'},
      {'level': '2', 'type': 'phonemic', 'text': 'One starts with "t", one with "w"'},
      {'level': '3', 'type': 'visual', 'text': '🔭, 🏈, ✉, 🪟, ⛑'},
      {'level': '4', 'type': 'model', 'text': 'The words were: telescope, whistle, envelope, curtain, helmet'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_aud_10',
    exerciseTypeCode: 'auditory_match',
    taskType: ExerciseTaskType.auditoryMatch,
    domain: ExerciseRepository.domainMemory,
    difficulty: 2.0,
    stimulus: {
      'targetWords': ['chandelier', 'avalanche', 'tambourine', 'silhouette', 'labyrinth'],
      'options': ['chandelier', 'avalanche', 'tambourine', 'silhouette', 'labyrinth', 'candelabra', 'landslide', 'xylophone', 'shadow', 'maze', 'pendulum', 'harmonica'],
    },
    acceptedAnswers: ['avalanche, chandelier, labyrinth, silhouette, tambourine'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Ceiling light, snow slide, percussion, dark outline, complex path'},
      {'level': '2', 'type': 'phonemic', 'text': 'One starts with "ch", one with "av"'},
      {'level': '3', 'type': 'visual', 'text': 'Very similar distractors — listen carefully'},
      {'level': '4', 'type': 'model', 'text': 'The words were: chandelier, avalanche, tambourine, silhouette, labyrinth'},
    ],
  ),

  // ═══════════════════════════════════════════════════════════════════
  // 4D — N-BACK VISUAL  (10 items, mem_nb_01 → mem_nb_10)
  // ═══════════════════════════════════════════════════════════════════

  ExerciseItemModel(
    id: 'mem_nb_01',
    exerciseTypeCode: 'n_back_visual',
    taskType: ExerciseTaskType.nBackVisual,
    domain: ExerciseRepository.domainMemory,
    difficulty: -2.0,
    stimulus: {
      'nBack': 1,
      'intervalMs': 3000,
      'iconCodes': [0xe070, 0xe3F7, 0xe3F7, 0xe318, 0xe070, 0xe070],
    },
    acceptedAnswers: ['2/2'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Watch for when the same icon appears twice in a row'},
      {'level': '2', 'type': 'phonemic', 'text': 'Tap "Match" when the icon repeats'},
      {'level': '3', 'type': 'visual', 'text': 'Same → tap!'},
      {'level': '4', 'type': 'model', 'text': 'There are 2 matches where the icon repeats the one before it'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_nb_02',
    exerciseTypeCode: 'n_back_visual',
    taskType: ExerciseTaskType.nBackVisual,
    domain: ExerciseRepository.domainMemory,
    difficulty: -1.5,
    stimulus: {
      'nBack': 1,
      'intervalMs': 2800,
      'iconCodes': [0xe3E7, 0xe574, 0xe574, 0xe3E7, 0xe318, 0xe318, 0xe574],
    },
    acceptedAnswers: ['2/2'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Tap when the current icon matches the previous one'},
      {'level': '2', 'type': 'phonemic', 'text': 'Look for back-to-back duplicates'},
      {'level': '3', 'type': 'visual', 'text': '1-back: current == previous?'},
      {'level': '4', 'type': 'model', 'text': 'Two matches: positions 2 and 5'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_nb_03',
    exerciseTypeCode: 'n_back_visual',
    taskType: ExerciseTaskType.nBackVisual,
    domain: ExerciseRepository.domainMemory,
    difficulty: -1.0,
    stimulus: {
      'nBack': 1,
      'intervalMs': 2600,
      'iconCodes': [0xe070, 0xe3AF, 0xe3AF, 0xe318, 0xe574, 0xe318, 0xe318, 0xe070],
    },
    acceptedAnswers: ['2/2'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Tap when the current icon is the same as the one just before'},
      {'level': '2', 'type': 'phonemic', 'text': 'Consecutive duplicates'},
      {'level': '3', 'type': 'visual', 'text': '1-back with 8 items'},
      {'level': '4', 'type': 'model', 'text': 'Matches at positions 2 and 6'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_nb_04',
    exerciseTypeCode: 'n_back_visual',
    taskType: ExerciseTaskType.nBackVisual,
    domain: ExerciseRepository.domainMemory,
    difficulty: -0.5,
    stimulus: {
      'nBack': 1,
      'intervalMs': 2400,
      'iconCodes': [0xe3D4, 0xe3E7, 0xe3D4, 0xe3D4, 0xe574, 0xe3AF, 0xe3AF, 0xe574, 0xe574],
    },
    acceptedAnswers: ['3/3'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Three pairs repeat in a row — find them all'},
      {'level': '2', 'type': 'phonemic', 'text': '1-back, 9 items, 3 matches'},
      {'level': '3', 'type': 'visual', 'text': 'Watch carefully for consecutive duplicates'},
      {'level': '4', 'type': 'model', 'text': 'Matches at positions 3, 6, and 8'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_nb_05',
    exerciseTypeCode: 'n_back_visual',
    taskType: ExerciseTaskType.nBackVisual,
    domain: ExerciseRepository.domainMemory,
    difficulty: 0.0,
    stimulus: {
      'nBack': 2,
      'intervalMs': 2800,
      'iconCodes': [0xe070, 0xe318, 0xe070, 0xe574, 0xe318, 0xe574],
    },
    acceptedAnswers: ['3/3'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Tap when the current icon matches the one shown TWO steps ago'},
      {'level': '2', 'type': 'phonemic', 'text': '2-back — remember two icons back'},
      {'level': '3', 'type': 'visual', 'text': 'Current == 2 ago?'},
      {'level': '4', 'type': 'model', 'text': 'Three 2-back matches in this sequence'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_nb_06',
    exerciseTypeCode: 'n_back_visual',
    taskType: ExerciseTaskType.nBackVisual,
    domain: ExerciseRepository.domainMemory,
    difficulty: 0.5,
    stimulus: {
      'nBack': 2,
      'intervalMs': 2500,
      'iconCodes': [0xe3D4, 0xe3E7, 0xe3D4, 0xe574, 0xe070, 0xe574, 0xe318, 0xe574],
    },
    acceptedAnswers: ['2/2'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Remember: does the current match the one from 2 steps ago?'},
      {'level': '2', 'type': 'phonemic', 'text': '2-back with 8 items'},
      {'level': '3', 'type': 'visual', 'text': 'Skip one, compare'},
      {'level': '4', 'type': 'model', 'text': 'Two 2-back matches'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_nb_07',
    exerciseTypeCode: 'n_back_visual',
    taskType: ExerciseTaskType.nBackVisual,
    domain: ExerciseRepository.domainMemory,
    difficulty: 1.0,
    stimulus: {
      'nBack': 2,
      'intervalMs': 2200,
      'iconCodes': [0xe070, 0xe3AF, 0xe070, 0xe3AF, 0xe574, 0xe3AF, 0xe574, 0xe3E7, 0xe574, 0xe3E7],
    },
    acceptedAnswers: ['6/6'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Many repeats — stay focused on 2 steps back'},
      {'level': '2', 'type': 'phonemic', 'text': '2-back, 10 items, multiple matches'},
      {'level': '3', 'type': 'visual', 'text': 'Compare each with 2 ago'},
      {'level': '4', 'type': 'model', 'text': 'Six 2-back matches in this sequence'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_nb_08',
    exerciseTypeCode: 'n_back_visual',
    taskType: ExerciseTaskType.nBackVisual,
    domain: ExerciseRepository.domainMemory,
    difficulty: 1.5,
    stimulus: {
      'nBack': 3,
      'intervalMs': 2800,
      'iconCodes': [0xe070, 0xe318, 0xe574, 0xe070, 0xe3D4, 0xe318, 0xe574, 0xe3D4],
    },
    acceptedAnswers: ['4/4'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Tap when the current icon matches the one from THREE steps ago'},
      {'level': '2', 'type': 'phonemic', 'text': '3-back — hard! Remember three back'},
      {'level': '3', 'type': 'visual', 'text': 'Current == 3 ago?'},
      {'level': '4', 'type': 'model', 'text': 'Four 3-back matches in an 8-item sequence'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_nb_09',
    exerciseTypeCode: 'n_back_visual',
    taskType: ExerciseTaskType.nBackVisual,
    domain: ExerciseRepository.domainMemory,
    difficulty: 1.75,
    stimulus: {
      'nBack': 3,
      'intervalMs': 2500,
      'iconCodes': [0xe070, 0xe3AF, 0xe574, 0xe070, 0xe3AF, 0xe3D4, 0xe070, 0xe3AF, 0xe3D4, 0xe070],
    },
    acceptedAnswers: ['4/4'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Difficult! Remember what was 3 steps back'},
      {'level': '2', 'type': 'phonemic', 'text': '3-back, 10 items'},
      {'level': '3', 'type': 'visual', 'text': 'Keep a mental buffer of 3'},
      {'level': '4', 'type': 'model', 'text': 'Four matches at positions 3, 4, 6, and 7'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_nb_10',
    exerciseTypeCode: 'n_back_visual',
    taskType: ExerciseTaskType.nBackVisual,
    domain: ExerciseRepository.domainMemory,
    difficulty: 2.0,
    stimulus: {
      'nBack': 3,
      'intervalMs': 2200,
      'iconCodes': [0xe070, 0xe318, 0xe574, 0xe070, 0xe318, 0xe574, 0xe070, 0xe318, 0xe574, 0xe070, 0xe318, 0xe574],
    },
    acceptedAnswers: ['9/9'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'A repeating pattern — but you must verify 3 steps back each time'},
      {'level': '2', 'type': 'phonemic', 'text': '3-back, 12 items, many matches'},
      {'level': '3', 'type': 'visual', 'text': 'The pattern repeats every 3'},
      {'level': '4', 'type': 'model', 'text': 'Nine 3-back matches'},
    ],
  ),

  // ═══════════════════════════════════════════════════════════════════
  // 4E — STORY MEMORY  (10 items, mem_st_01 → mem_st_10)
  // ═══════════════════════════════════════════════════════════════════

  ExerciseItemModel(
    id: 'mem_st_01',
    exerciseTypeCode: 'story_memory',
    taskType: ExerciseTaskType.storyMemory,
    domain: ExerciseRepository.domainMemory,
    difficulty: -2.0,
    stimulus: {
      'storyText': 'Tom has a red ball. He plays with it in the park.',
      'questionText': 'What color is Tom\'s ball?',
      'options': ['Blue', 'Red', 'Green', 'Yellow'],
      'delayMs': 0,
    },
    acceptedAnswers: ['Red'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Think about the color mentioned in the story'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with the letter "R"'},
      {'level': '3', 'type': 'visual', 'text': 'R _ _'},
      {'level': '4', 'type': 'model', 'text': 'The answer is Red'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_st_02',
    exerciseTypeCode: 'story_memory',
    taskType: ExerciseTaskType.storyMemory,
    domain: ExerciseRepository.domainMemory,
    difficulty: -1.5,
    stimulus: {
      'storyText': 'Sara went to the store. She bought milk and bread.',
      'questionText': 'What did Sara buy?',
      'options': ['Eggs and juice', 'Milk and bread', 'Cheese and butter', 'Water and fruit'],
      'delayMs': 0,
    },
    acceptedAnswers: ['Milk and bread'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Think about what you eat for breakfast'},
      {'level': '2', 'type': 'phonemic', 'text': 'One starts with "M", the other with "B"'},
      {'level': '3', 'type': 'visual', 'text': 'M _ _ _ and B _ _ _ _'},
      {'level': '4', 'type': 'model', 'text': 'The answer is Milk and bread'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_st_03',
    exerciseTypeCode: 'story_memory',
    taskType: ExerciseTaskType.storyMemory,
    domain: ExerciseRepository.domainMemory,
    difficulty: -1.0,
    stimulus: {
      'storyText': 'The cat sat on the mat. It was a sunny day. The cat fell asleep.',
      'questionText': 'Where did the cat sit?',
      'options': ['On the bed', 'On the mat', 'On the chair', 'On the table'],
      'delayMs': 2000,
    },
    acceptedAnswers: ['On the mat'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'It rhymes with "cat"'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "m"'},
      {'level': '3', 'type': 'visual', 'text': 'On the m _ _'},
      {'level': '4', 'type': 'model', 'text': 'The answer is On the mat'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_st_04',
    exerciseTypeCode: 'story_memory',
    taskType: ExerciseTaskType.storyMemory,
    domain: ExerciseRepository.domainMemory,
    difficulty: -0.5,
    stimulus: {
      'storyText': 'Ben walked to school with his friend Lisa. They saw a blue bird on the way.',
      'questionText': 'Who walked with Ben?',
      'options': ['Tom', 'Sara', 'Lisa', 'Anna'],
      'delayMs': 3000,
    },
    acceptedAnswers: ['Lisa'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'It is a girl\'s name'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "L"'},
      {'level': '3', 'type': 'visual', 'text': 'L _ _ _'},
      {'level': '4', 'type': 'model', 'text': 'The answer is Lisa'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_st_05',
    exerciseTypeCode: 'story_memory',
    taskType: ExerciseTaskType.storyMemory,
    domain: ExerciseRepository.domainMemory,
    difficulty: 0.0,
    stimulus: {
      'storyText': 'Maria baked cookies on Saturday morning. She used chocolate chips and vanilla. Her children helped mix the dough.',
      'questionText': 'When did Maria bake cookies?',
      'options': ['Sunday afternoon', 'Saturday morning', 'Friday evening', 'Monday night'],
      'delayMs': 5000,
    },
    acceptedAnswers: ['Saturday morning'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'It was on the weekend, in the earlier part of the day'},
      {'level': '2', 'type': 'phonemic', 'text': 'The day starts with "S" and the time with "m"'},
      {'level': '3', 'type': 'visual', 'text': 'S _ _ _ _ _ _ _  m _ _ _ _ _ _'},
      {'level': '4', 'type': 'model', 'text': 'The answer is Saturday morning'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_st_06',
    exerciseTypeCode: 'story_memory',
    taskType: ExerciseTaskType.storyMemory,
    domain: ExerciseRepository.domainMemory,
    difficulty: 0.5,
    stimulus: {
      'storyText': 'The old farmer had three animals: a cow named Daisy, a horse named Thunder, and a pig named Rosie. Every morning he fed them at six o\'clock.',
      'questionText': 'What was the horse\'s name?',
      'options': ['Daisy', 'Rosie', 'Thunder', 'Storm'],
      'delayMs': 8000,
    },
    acceptedAnswers: ['Thunder'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'It is a loud sound during a storm'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "Th"'},
      {'level': '3', 'type': 'visual', 'text': 'Th _ _ _ _ _'},
      {'level': '4', 'type': 'model', 'text': 'The answer is Thunder'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_st_07',
    exerciseTypeCode: 'story_memory',
    taskType: ExerciseTaskType.storyMemory,
    domain: ExerciseRepository.domainMemory,
    difficulty: 1.0,
    stimulus: {
      'storyText': 'Dr. Adams worked at City Hospital for twenty years. Last Tuesday, she performed her five hundredth surgery. The entire staff celebrated with a cake in the break room.',
      'questionText': 'How many surgeries had Dr. Adams performed?',
      'options': ['Two hundred', 'Three hundred', 'Five hundred', 'One thousand'],
      'delayMs': 10000,
    },
    acceptedAnswers: ['Five hundred'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'It is half of one thousand'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "F"'},
      {'level': '3', 'type': 'visual', 'text': '_ _ _ _ hundred'},
      {'level': '4', 'type': 'model', 'text': 'The answer is Five hundred'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_st_08',
    exerciseTypeCode: 'story_memory',
    taskType: ExerciseTaskType.storyMemory,
    domain: ExerciseRepository.domainMemory,
    difficulty: 1.5,
    stimulus: {
      'storyText': 'The museum opened a new exhibit about ancient Egypt on the third floor. Visitors could see golden masks, stone tablets, and a replica of a pharaoh\'s tomb. The exhibit ran from March to September and attracted over fifty thousand visitors.',
      'questionText': 'On which floor was the Egypt exhibit?',
      'options': ['First floor', 'Second floor', 'Third floor', 'Fourth floor'],
      'delayMs': 15000,
    },
    acceptedAnswers: ['Third floor'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'It is above the second floor'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "Th"'},
      {'level': '3', 'type': 'visual', 'text': 'Th _ _ _ floor'},
      {'level': '4', 'type': 'model', 'text': 'The answer is Third floor'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_st_09',
    exerciseTypeCode: 'story_memory',
    taskType: ExerciseTaskType.storyMemory,
    domain: ExerciseRepository.domainMemory,
    difficulty: 1.75,
    stimulus: {
      'storyText': 'Professor Chen traveled to three countries last summer for her research on marine biology. She first visited Australia, then Japan, and finally Iceland. In each country she collected water samples from local coral reefs and studied the effects of temperature changes on marine life.',
      'questionText': 'Which country did Professor Chen visit last?',
      'options': ['Australia', 'Japan', 'Iceland', 'Brazil'],
      'delayMs': 20000,
    },
    acceptedAnswers: ['Iceland'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'It is a cold island nation in the North Atlantic'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "I"'},
      {'level': '3', 'type': 'visual', 'text': 'I _ _ _ _ _ _'},
      {'level': '4', 'type': 'model', 'text': 'The answer is Iceland'},
    ],
  ),
  ExerciseItemModel(
    id: 'mem_st_10',
    exerciseTypeCode: 'story_memory',
    taskType: ExerciseTaskType.storyMemory,
    domain: ExerciseRepository.domainMemory,
    difficulty: 2.0,
    stimulus: {
      'storyText': 'The Riverside Community Center held its annual charity auction on November fourteenth. The highlight was a painting by local artist Elena Vasquez, which sold for twelve thousand dollars. The event raised a total of forty-five thousand dollars, with proceeds going to the children\'s library fund. Mayor Thompson gave the opening speech, and the jazz band Midnight Blue provided entertainment.',
      'questionText': 'How much did Elena Vasquez\'s painting sell for?',
      'options': ['Eight thousand dollars', 'Ten thousand dollars', 'Twelve thousand dollars', 'Fifteen thousand dollars'],
      'delayMs': 30000,
    },
    acceptedAnswers: ['Twelve thousand dollars'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'It is the number of months in a year, times one thousand'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "Tw"'},
      {'level': '3', 'type': 'visual', 'text': 'Tw _ _ _ _ thousand dollars'},
      {'level': '4', 'type': 'model', 'text': 'The answer is Twelve thousand dollars'},
    ],
  ),
];
