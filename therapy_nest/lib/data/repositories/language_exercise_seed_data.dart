import '../models/exercise_item_model.dart';

/// 50+ language exercise items for the adaptive item bank.
///
/// Covers all 6 Module 6 exercise types:
/// - picture_naming (6A)   — 10 items
/// - word_fluency (6B)     — 8 items
/// - sentence_completion (6C) — 10 items
/// - follow_instruction (6D) — 8 items
/// - reading_comprehension (6E) — 8 items
/// - spelling (6F)         — 8 items
///
/// Difficulty range: b = -2.0 to +2.0
/// All items include clinical cueing hierarchy (4 levels).
const List<ExerciseItemModel> languageExerciseSeedData = [
  // ═══════════════════════════════════════════════════════════════════
  // 6A — PICTURE NAMING (10 items)
  // ═══════════════════════════════════════════════════════════════════

  ExerciseItemModel(
    id: 'lang_pn_01',
    exerciseTypeCode: 'picture_naming',
    taskType: ExerciseTaskType.pictureNaming,
    domain: 'language',
    difficulty: -2.0,
    stimulus: {
      'promptText': 'What is this?',
      'icon': 0xe06f, // Icons.star
      'fontFamily': 'MaterialIcons',
      'inputMode': 'mc',
      'options': ['Star', 'Moon', 'Sun', 'Cloud'],
    },
    acceptedAnswers: ['Star'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'It shines in the night sky'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "St"'},
      {'level': '3', 'type': 'sentence', 'text': 'Twinkle twinkle little ___'},
      {'level': '4', 'type': 'model', 'text': 'The answer is Star'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_pn_02',
    exerciseTypeCode: 'picture_naming',
    taskType: ExerciseTaskType.pictureNaming,
    domain: 'language',
    difficulty: -1.5,
    stimulus: {
      'promptText': 'What is this?',
      'icon': 0xe1d7, // Icons.home
      'fontFamily': 'MaterialIcons',
      'inputMode': 'mc',
      'options': ['House', 'School', 'Shop', 'Church'],
    },
    acceptedAnswers: ['House'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'You live here with your family'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with the letter "H"'},
      {'level': '3', 'type': 'sentence', 'text': 'There\'s no place like ___'},
      {'level': '4', 'type': 'model', 'text': 'The answer is House'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_pn_03',
    exerciseTypeCode: 'picture_naming',
    taskType: ExerciseTaskType.pictureNaming,
    domain: 'language',
    difficulty: -1.0,
    stimulus: {
      'promptText': 'What is this?',
      'icon': 0xe25a, // Icons.local_florist (flower)
      'fontFamily': 'MaterialIcons',
      'inputMode': 'mc',
      'options': ['Flower', 'Tree', 'Grass', 'Leaf'],
    },
    acceptedAnswers: ['Flower'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'It grows in the garden and has petals'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "Fl"'},
      {'level': '3', 'type': 'sentence', 'text': 'She picked a beautiful ___ from the garden'},
      {'level': '4', 'type': 'model', 'text': 'The answer is Flower'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_pn_04',
    exerciseTypeCode: 'picture_naming',
    taskType: ExerciseTaskType.pictureNaming,
    domain: 'language',
    difficulty: -0.5,
    stimulus: {
      'promptText': 'What is this?',
      'icon': 0xe559, // Icons.watch
      'fontFamily': 'MaterialIcons',
      'inputMode': 'mc',
      'options': ['Watch', 'Ring', 'Bracelet', 'Clock'],
    },
    acceptedAnswers: ['Watch'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'You wear it on your wrist to tell time'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with the letter "W"'},
      {'level': '3', 'type': 'sentence', 'text': 'He checked his ___ to see the time'},
      {'level': '4', 'type': 'model', 'text': 'The answer is Watch'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_pn_05',
    exerciseTypeCode: 'picture_naming',
    taskType: ExerciseTaskType.pictureNaming,
    domain: 'language',
    difficulty: 0.0,
    stimulus: {
      'promptText': 'What is this?',
      'icon': 0xe3e0, // Icons.phone
      'fontFamily': 'MaterialIcons',
      'inputMode': 'mc',
      'options': ['Telephone', 'Radio', 'Remote', 'Camera'],
    },
    acceptedAnswers: ['Telephone', 'Phone'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'You use this to call people'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "Tel" or "Ph"'},
      {'level': '3', 'type': 'sentence', 'text': 'She answered the ringing ___'},
      {'level': '4', 'type': 'model', 'text': 'The answer is Telephone'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_pn_06',
    exerciseTypeCode: 'picture_naming',
    taskType: ExerciseTaskType.pictureNaming,
    domain: 'language',
    difficulty: 0.5,
    stimulus: {
      'promptText': 'What is this?',
      'icon': 0xe332, // Icons.brush
      'fontFamily': 'MaterialIcons',
      'inputMode': 'type',
      'options': <String>[],
    },
    acceptedAnswers: ['Brush', 'Paintbrush'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'An artist uses this to paint'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "Br"'},
      {'level': '3', 'type': 'sentence', 'text': 'The painter dipped her ___ in paint'},
      {'level': '4', 'type': 'model', 'text': 'The answer is Brush'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_pn_07',
    exerciseTypeCode: 'picture_naming',
    taskType: ExerciseTaskType.pictureNaming,
    domain: 'language',
    difficulty: 1.0,
    stimulus: {
      'promptText': 'What is this?',
      'icon': 0xe0e5, // Icons.build (wrench/tool)
      'fontFamily': 'MaterialIcons',
      'inputMode': 'mc',
      'options': ['Wrench', 'Hammer', 'Screwdriver', 'Pliers'],
    },
    acceptedAnswers: ['Wrench'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'A tool used to turn nuts and bolts'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "Wr"'},
      {'level': '3', 'type': 'sentence', 'text': 'The mechanic grabbed the ___ to fix the pipe'},
      {'level': '4', 'type': 'model', 'text': 'The answer is Wrench'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_pn_08',
    exerciseTypeCode: 'picture_naming',
    taskType: ExerciseTaskType.pictureNaming,
    domain: 'language',
    difficulty: 1.5,
    stimulus: {
      'promptText': 'What is this?',
      'icon': 0xe0c2, // Icons.biotech
      'fontFamily': 'MaterialIcons',
      'inputMode': 'mc',
      'options': ['Microscope', 'Telescope', 'Binoculars', 'Magnifier'],
    },
    acceptedAnswers: ['Microscope'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Scientists use this to see very tiny things'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "Mi"'},
      {'level': '3', 'type': 'sentence', 'text': 'She examined the cells under the ___'},
      {'level': '4', 'type': 'model', 'text': 'The answer is Microscope'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_pn_09',
    exerciseTypeCode: 'picture_naming',
    taskType: ExerciseTaskType.pictureNaming,
    domain: 'language',
    difficulty: 2.0,
    stimulus: {
      'promptText': 'What is this?',
      'icon': 0xe4c9, // Icons.scale (balance)
      'fontFamily': 'MaterialIcons',
      'inputMode': 'type',
      'options': <String>[],
    },
    acceptedAnswers: ['Scale', 'Balance', 'Scales'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Used to measure how heavy something is'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "Sc" or "Ba"'},
      {'level': '3', 'type': 'sentence', 'text': 'Justice is often depicted holding a ___'},
      {'level': '4', 'type': 'model', 'text': 'The answer is Scale'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_pn_10',
    exerciseTypeCode: 'picture_naming',
    taskType: ExerciseTaskType.pictureNaming,
    domain: 'language',
    difficulty: 2.0,
    stimulus: {
      'promptText': 'What is this?',
      'icon': 0xe40b, // Icons.router
      'fontFamily': 'MaterialIcons',
      'inputMode': 'mc',
      'options': ['Router', 'Modem', 'Speaker', 'Monitor'],
    },
    acceptedAnswers: ['Router'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'This device provides wireless internet'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "Ro"'},
      {'level': '3', 'type': 'sentence', 'text': 'Restart the ___ if the Wi-Fi is down'},
      {'level': '4', 'type': 'model', 'text': 'The answer is Router'},
    ],
  ),

  // ═══════════════════════════════════════════════════════════════════
  // 6B — WORD FLUENCY / CATEGORY GENERATION (8 items)
  // ═══════════════════════════════════════════════════════════════════

  ExerciseItemModel(
    id: 'lang_wf_01',
    exerciseTypeCode: 'word_fluency',
    taskType: ExerciseTaskType.wordFluency,
    domain: 'language',
    difficulty: -2.0,
    stimulus: {
      'category': 'animals',
      'timeLimitMs': 60000,
      'minTarget': 3,
      'validItems': [
        'cat', 'dog', 'fish', 'bird', 'horse', 'cow', 'pig', 'sheep',
        'chicken', 'duck', 'rabbit', 'mouse', 'rat', 'hamster', 'goat',
        'lion', 'tiger', 'bear', 'elephant', 'monkey', 'snake', 'frog',
        'turtle', 'whale', 'dolphin', 'deer', 'fox', 'wolf', 'zebra',
        'giraffe',
      ],
    },
    acceptedAnswers: ['3'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Think of pets, farm animals, or wild animals'},
      {'level': '2', 'type': 'phonemic', 'text': 'Try animals that start with C, D, or F'},
      {'level': '3', 'type': 'sentence', 'text': 'Cat, Dog, ...'},
      {'level': '4', 'type': 'model', 'text': 'Cat, Dog, Fish, Bird, Horse'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_wf_02',
    exerciseTypeCode: 'word_fluency',
    taskType: ExerciseTaskType.wordFluency,
    domain: 'language',
    difficulty: -1.0,
    stimulus: {
      'category': 'food',
      'timeLimitMs': 60000,
      'minTarget': 4,
      'validItems': [
        'apple', 'banana', 'bread', 'cheese', 'chicken', 'rice', 'pasta',
        'pizza', 'cake', 'cookie', 'egg', 'milk', 'butter', 'fish',
        'steak', 'soup', 'salad', 'sandwich', 'orange', 'grape', 'carrot',
        'potato', 'tomato', 'corn', 'lettuce', 'onion', 'pepper',
      ],
    },
    acceptedAnswers: ['4'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Think of fruits, meals, or snacks'},
      {'level': '2', 'type': 'phonemic', 'text': 'Try foods that start with B, C, or P'},
      {'level': '3', 'type': 'sentence', 'text': 'Apple, Bread, ...'},
      {'level': '4', 'type': 'model', 'text': 'Apple, Bread, Cheese, Rice, Pizza'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_wf_03',
    exerciseTypeCode: 'word_fluency',
    taskType: ExerciseTaskType.wordFluency,
    domain: 'language',
    difficulty: 0.0,
    stimulus: {
      'category': 'clothing',
      'timeLimitMs': 60000,
      'minTarget': 5,
      'validItems': [
        'shirt', 'pants', 'shoes', 'socks', 'hat', 'jacket', 'coat',
        'dress', 'skirt', 'shorts', 'sweater', 'gloves', 'scarf', 'tie',
        'belt', 'boots', 'sandals', 'vest', 'blouse', 'jeans',
      ],
    },
    acceptedAnswers: ['5'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Think of things you wear on your body'},
      {'level': '2', 'type': 'phonemic', 'text': 'Try items that start with S, P, or H'},
      {'level': '3', 'type': 'sentence', 'text': 'Shirt, Pants, Shoes, ...'},
      {'level': '4', 'type': 'model', 'text': 'Shirt, Pants, Shoes, Hat, Jacket'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_wf_04',
    exerciseTypeCode: 'word_fluency',
    taskType: ExerciseTaskType.wordFluency,
    domain: 'language',
    difficulty: 0.5,
    stimulus: {
      'category': 'body parts',
      'timeLimitMs': 60000,
      'minTarget': 5,
      'validItems': [
        'head', 'arm', 'leg', 'hand', 'foot', 'eye', 'ear', 'nose',
        'mouth', 'neck', 'shoulder', 'elbow', 'knee', 'finger', 'toe',
        'chest', 'back', 'stomach', 'wrist', 'ankle', 'chin', 'forehead',
        'thumb', 'hip',
      ],
    },
    acceptedAnswers: ['5'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Start from the top of your body and work down'},
      {'level': '2', 'type': 'phonemic', 'text': 'Try parts that start with H, A, or L'},
      {'level': '3', 'type': 'sentence', 'text': 'Head, Arm, Leg, ...'},
      {'level': '4', 'type': 'model', 'text': 'Head, Arm, Leg, Hand, Foot, Eye'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_wf_05',
    exerciseTypeCode: 'word_fluency',
    taskType: ExerciseTaskType.wordFluency,
    domain: 'language',
    difficulty: 1.0,
    stimulus: {
      'category': 'tools',
      'timeLimitMs': 60000,
      'minTarget': 5,
      'validItems': [
        'hammer', 'screwdriver', 'saw', 'drill', 'wrench', 'pliers',
        'tape', 'ruler', 'level', 'chisel', 'clamp', 'sandpaper',
        'scissors', 'knife', 'axe', 'shovel', 'rake', 'crowbar',
      ],
    },
    acceptedAnswers: ['5'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Think of things used to build or fix things'},
      {'level': '2', 'type': 'phonemic', 'text': 'Try tools that start with H, S, or D'},
      {'level': '3', 'type': 'sentence', 'text': 'Hammer, Screwdriver, ...'},
      {'level': '4', 'type': 'model', 'text': 'Hammer, Screwdriver, Saw, Drill, Wrench'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_wf_06',
    exerciseTypeCode: 'word_fluency',
    taskType: ExerciseTaskType.wordFluency,
    domain: 'language',
    difficulty: 1.5,
    stimulus: {
      'category': 'transport',
      'timeLimitMs': 60000,
      'minTarget': 6,
      'validItems': [
        'car', 'bus', 'train', 'plane', 'bicycle', 'motorcycle', 'boat',
        'ship', 'truck', 'taxi', 'subway', 'helicopter', 'ferry',
        'ambulance', 'van', 'scooter', 'tram', 'jet',
      ],
    },
    acceptedAnswers: ['6'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Think of ways to travel on land, water, or air'},
      {'level': '2', 'type': 'phonemic', 'text': 'Try vehicles starting with C, B, or T'},
      {'level': '3', 'type': 'sentence', 'text': 'Car, Bus, Train, ...'},
      {'level': '4', 'type': 'model', 'text': 'Car, Bus, Train, Plane, Bicycle, Boat'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_wf_07',
    exerciseTypeCode: 'word_fluency',
    taskType: ExerciseTaskType.wordFluency,
    domain: 'language',
    difficulty: 2.0,
    stimulus: {
      'category': 'household items',
      'timeLimitMs': 60000,
      'minTarget': 7,
      'validItems': [
        'chair', 'table', 'lamp', 'bed', 'sofa', 'pillow', 'blanket',
        'curtain', 'mirror', 'clock', 'vase', 'shelf', 'drawer', 'rug',
        'towel', 'plate', 'cup', 'fork', 'spoon', 'knife', 'pan',
        'pot', 'broom', 'mop', 'bucket',
      ],
    },
    acceptedAnswers: ['7'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Think of things in the kitchen, bedroom, or living room'},
      {'level': '2', 'type': 'phonemic', 'text': 'Try items starting with C, T, or L'},
      {'level': '3', 'type': 'sentence', 'text': 'Chair, Table, Lamp, ...'},
      {'level': '4', 'type': 'model', 'text': 'Chair, Table, Lamp, Bed, Sofa, Pillow, Blanket'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_wf_08',
    exerciseTypeCode: 'word_fluency',
    taskType: ExerciseTaskType.wordFluency,
    domain: 'language',
    difficulty: 2.0,
    stimulus: {
      'category': 'things that are round',
      'timeLimitMs': 60000,
      'minTarget': 7,
      'validItems': [
        'ball', 'wheel', 'clock', 'plate', 'coin', 'moon', 'sun',
        'orange', 'donut', 'ring', 'globe', 'button', 'pizza', 'tire',
        'eye', 'pearl', 'bubble', 'marble', 'circle', 'earth',
      ],
    },
    acceptedAnswers: ['7'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Think of objects shaped like a circle'},
      {'level': '2', 'type': 'phonemic', 'text': 'Try B, C, or M words'},
      {'level': '3', 'type': 'sentence', 'text': 'Ball, Wheel, Clock, ...'},
      {'level': '4', 'type': 'model', 'text': 'Ball, Wheel, Clock, Plate, Coin, Moon, Sun'},
    ],
  ),

  // ═══════════════════════════════════════════════════════════════════
  // 6C — SENTENCE COMPLETION (10 items)
  // ═══════════════════════════════════════════════════════════════════

  ExerciseItemModel(
    id: 'lang_sc_01',
    exerciseTypeCode: 'sentence_completion',
    taskType: ExerciseTaskType.sentenceCompletion,
    domain: 'language',
    difficulty: -2.0,
    stimulus: {
      'sentenceWithBlank': 'The dog chased the ___.',
      'options': ['cat', 'cloud', 'letter', 'phone'],
    },
    acceptedAnswers: ['cat'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Dogs like to chase a small furry animal'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with the letter "C"'},
      {'level': '3', 'type': 'sentence', 'text': 'C _ _'},
      {'level': '4', 'type': 'model', 'text': 'The answer is cat'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_sc_02',
    exerciseTypeCode: 'sentence_completion',
    taskType: ExerciseTaskType.sentenceCompletion,
    domain: 'language',
    difficulty: -1.5,
    stimulus: {
      'sentenceWithBlank': 'He put on his ___ before going outside.',
      'options': ['shoes', 'pillow', 'spoon', 'lamp'],
    },
    acceptedAnswers: ['shoes'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'You wear these on your feet'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "Sh"'},
      {'level': '3', 'type': 'sentence', 'text': 'Sh _ _ _'},
      {'level': '4', 'type': 'model', 'text': 'The answer is shoes'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_sc_03',
    exerciseTypeCode: 'sentence_completion',
    taskType: ExerciseTaskType.sentenceCompletion,
    domain: 'language',
    difficulty: -1.0,
    stimulus: {
      'sentenceWithBlank': 'The children played in the ___.',
      'options': ['park', 'oven', 'ceiling', 'envelope'],
    },
    acceptedAnswers: ['park'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'An outdoor place with swings and slides'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with the letter "P"'},
      {'level': '3', 'type': 'sentence', 'text': 'P _ _ _'},
      {'level': '4', 'type': 'model', 'text': 'The answer is park'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_sc_04',
    exerciseTypeCode: 'sentence_completion',
    taskType: ExerciseTaskType.sentenceCompletion,
    domain: 'language',
    difficulty: -0.5,
    stimulus: {
      'sentenceWithBlank': 'She used a ___ to cut the paper.',
      'options': ['scissors', 'hammer', 'phone', 'blanket'],
    },
    acceptedAnswers: ['scissors'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'A tool with two sharp blades'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "Sc"'},
      {'level': '3', 'type': 'sentence', 'text': 'Sc _ _ _ _ _ _'},
      {'level': '4', 'type': 'model', 'text': 'The answer is scissors'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_sc_05',
    exerciseTypeCode: 'sentence_completion',
    taskType: ExerciseTaskType.sentenceCompletion,
    domain: 'language',
    difficulty: 0.0,
    stimulus: {
      'sentenceWithBlank': 'The ___ carried passengers to the airport.',
      'options': ['bus', 'tree', 'pencil', 'blanket'],
    },
    acceptedAnswers: ['bus'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'A large vehicle that many people ride together'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with the letter "B"'},
      {'level': '3', 'type': 'sentence', 'text': 'B _ _'},
      {'level': '4', 'type': 'model', 'text': 'The answer is bus'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_sc_06',
    exerciseTypeCode: 'sentence_completion',
    taskType: ExerciseTaskType.sentenceCompletion,
    domain: 'language',
    difficulty: 0.5,
    stimulus: {
      'sentenceWithBlank': 'The baker took the bread out of the ___.',
      'options': ['oven', 'garden', 'river', 'window'],
    },
    acceptedAnswers: ['oven'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'A hot appliance used to bake things'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with the letter "O"'},
      {'level': '3', 'type': 'sentence', 'text': 'O _ _ _'},
      {'level': '4', 'type': 'model', 'text': 'The answer is oven'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_sc_07',
    exerciseTypeCode: 'sentence_completion',
    taskType: ExerciseTaskType.sentenceCompletion,
    domain: 'language',
    difficulty: 1.0,
    stimulus: {
      'sentenceWithBlank': 'After the storm, a beautiful ___ appeared in the sky.',
      'options': ['rainbow', 'volcano', 'earthquake', 'tornado'],
    },
    acceptedAnswers: ['rainbow'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'It has many colors in an arc shape'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "Ra"'},
      {'level': '3', 'type': 'sentence', 'text': 'Ra _ _ _ _ _'},
      {'level': '4', 'type': 'model', 'text': 'The answer is rainbow'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_sc_08',
    exerciseTypeCode: 'sentence_completion',
    taskType: ExerciseTaskType.sentenceCompletion,
    domain: 'language',
    difficulty: 1.5,
    stimulus: {
      'sentenceWithBlank': 'The ___ prescribed medicine for the patient.',
      'options': ['doctor', 'teacher', 'driver', 'painter'],
    },
    acceptedAnswers: ['doctor'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'A medical professional who treats sick people'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "Do"'},
      {'level': '3', 'type': 'sentence', 'text': 'Do _ _ _ _'},
      {'level': '4', 'type': 'model', 'text': 'The answer is doctor'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_sc_09',
    exerciseTypeCode: 'sentence_completion',
    taskType: ExerciseTaskType.sentenceCompletion,
    domain: 'language',
    difficulty: 2.0,
    stimulus: {
      'sentenceWithBlank': 'Despite the ___ evidence, the jury found him not guilty.',
      'options': ['overwhelming', 'invisible', 'delicious', 'musical'],
    },
    acceptedAnswers: ['overwhelming'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'It means there was a very large amount'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "Ov"'},
      {'level': '3', 'type': 'sentence', 'text': 'Ov _ _ _ _ _ _ _ _ _ _'},
      {'level': '4', 'type': 'model', 'text': 'The answer is overwhelming'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_sc_10',
    exerciseTypeCode: 'sentence_completion',
    taskType: ExerciseTaskType.sentenceCompletion,
    domain: 'language',
    difficulty: 2.0,
    stimulus: {
      'sentenceWithBlank': 'The ambassador\'s ___ improved relations between the two countries.',
      'options': ['diplomacy', 'appetite', 'clumsiness', 'hobby'],
    },
    acceptedAnswers: ['diplomacy'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Skill in handling international affairs tactfully'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "Di"'},
      {'level': '3', 'type': 'sentence', 'text': 'Di _ _ _ _ _ _ _'},
      {'level': '4', 'type': 'model', 'text': 'The answer is diplomacy'},
    ],
  ),

  // ═══════════════════════════════════════════════════════════════════
  // 6D — FOLLOW INSTRUCTIONS (8 items)
  // ═══════════════════════════════════════════════════════════════════

  ExerciseItemModel(
    id: 'lang_fi_01',
    exerciseTypeCode: 'follow_instruction',
    taskType: ExerciseTaskType.followInstruction,
    domain: 'language',
    difficulty: -2.0,
    stimulus: {
      'instruction': 'Touch the red circle',
      'shapes': [
        {'type': 'circle', 'color': 'red', 'size': 'medium', 'label': 'A'},
        {'type': 'square', 'color': 'blue', 'size': 'medium', 'label': 'B'},
        {'type': 'circle', 'color': 'green', 'size': 'medium', 'label': 'C'},
        {'type': 'square', 'color': 'yellow', 'size': 'medium', 'label': 'D'},
      ],
      'correctIndices': [0],
    },
    acceptedAnswers: ['1/1'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Look for a round shape'},
      {'level': '2', 'type': 'phonemic', 'text': 'It is the color of an apple'},
      {'level': '3', 'type': 'visual', 'text': 'Look at shape A'},
      {'level': '4', 'type': 'model', 'text': 'Touch shape A — the red circle'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_fi_02',
    exerciseTypeCode: 'follow_instruction',
    taskType: ExerciseTaskType.followInstruction,
    domain: 'language',
    difficulty: -1.5,
    stimulus: {
      'instruction': 'Touch the large blue square',
      'shapes': [
        {'type': 'square', 'color': 'blue', 'size': 'small', 'label': 'A'},
        {'type': 'circle', 'color': 'red', 'size': 'large', 'label': 'B'},
        {'type': 'square', 'color': 'blue', 'size': 'large', 'label': 'C'},
        {'type': 'circle', 'color': 'green', 'size': 'small', 'label': 'D'},
      ],
      'correctIndices': [2],
    },
    acceptedAnswers: ['1/1'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Look for a big shape with four equal sides'},
      {'level': '2', 'type': 'phonemic', 'text': 'The color of the sky'},
      {'level': '3', 'type': 'visual', 'text': 'Look at shape C'},
      {'level': '4', 'type': 'model', 'text': 'Touch shape C — the large blue square'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_fi_03',
    exerciseTypeCode: 'follow_instruction',
    taskType: ExerciseTaskType.followInstruction,
    domain: 'language',
    difficulty: -0.5,
    stimulus: {
      'instruction': 'Touch the small green circle and the yellow square',
      'shapes': [
        {'type': 'square', 'color': 'yellow', 'size': 'medium', 'label': 'A'},
        {'type': 'circle', 'color': 'green', 'size': 'small', 'label': 'B'},
        {'type': 'circle', 'color': 'red', 'size': 'large', 'label': 'C'},
        {'type': 'square', 'color': 'blue', 'size': 'small', 'label': 'D'},
      ],
      'correctIndices': [0, 1],
    },
    acceptedAnswers: ['2/2'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'You need to touch two shapes'},
      {'level': '2', 'type': 'phonemic', 'text': 'One is green and round, the other is yellow with corners'},
      {'level': '3', 'type': 'visual', 'text': 'Look at shapes A and B'},
      {'level': '4', 'type': 'model', 'text': 'Touch shapes A and B'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_fi_04',
    exerciseTypeCode: 'follow_instruction',
    taskType: ExerciseTaskType.followInstruction,
    domain: 'language',
    difficulty: 0.0,
    stimulus: {
      'instruction': 'Touch the purple star',
      'shapes': [
        {'type': 'circle', 'color': 'red', 'size': 'medium', 'label': 'A'},
        {'type': 'star', 'color': 'purple', 'size': 'medium', 'label': 'B'},
        {'type': 'triangle', 'color': 'blue', 'size': 'large', 'label': 'C'},
        {'type': 'square', 'color': 'green', 'size': 'small', 'label': 'D'},
        {'type': 'star', 'color': 'yellow', 'size': 'medium', 'label': 'E'},
        {'type': 'circle', 'color': 'orange', 'size': 'small', 'label': 'F'},
      ],
      'correctIndices': [1],
    },
    acceptedAnswers: ['1/1'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Look for a shape with five points'},
      {'level': '2', 'type': 'phonemic', 'text': 'It is a mix of red and blue color'},
      {'level': '3', 'type': 'visual', 'text': 'Look at shape B'},
      {'level': '4', 'type': 'model', 'text': 'Touch shape B — the purple star'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_fi_05',
    exerciseTypeCode: 'follow_instruction',
    taskType: ExerciseTaskType.followInstruction,
    domain: 'language',
    difficulty: 0.5,
    stimulus: {
      'instruction': 'Touch the small red triangle and the large blue circle',
      'shapes': [
        {'type': 'triangle', 'color': 'red', 'size': 'small', 'label': 'A'},
        {'type': 'circle', 'color': 'blue', 'size': 'large', 'label': 'B'},
        {'type': 'square', 'color': 'green', 'size': 'medium', 'label': 'C'},
        {'type': 'triangle', 'color': 'yellow', 'size': 'large', 'label': 'D'},
        {'type': 'circle', 'color': 'red', 'size': 'small', 'label': 'E'},
        {'type': 'square', 'color': 'blue', 'size': 'small', 'label': 'F'},
      ],
      'correctIndices': [0, 1],
    },
    acceptedAnswers: ['2/2'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'You need two shapes — a small pointed one and a big round one'},
      {'level': '2', 'type': 'phonemic', 'text': 'One is red, the other is blue'},
      {'level': '3', 'type': 'visual', 'text': 'Shapes A and B'},
      {'level': '4', 'type': 'model', 'text': 'Touch shapes A and B'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_fi_06',
    exerciseTypeCode: 'follow_instruction',
    taskType: ExerciseTaskType.followInstruction,
    domain: 'language',
    difficulty: 1.0,
    stimulus: {
      'instruction': 'Touch the green circle, then the blue square, then the red triangle',
      'shapes': [
        {'type': 'triangle', 'color': 'red', 'size': 'medium', 'label': 'A'},
        {'type': 'square', 'color': 'blue', 'size': 'medium', 'label': 'B'},
        {'type': 'circle', 'color': 'green', 'size': 'medium', 'label': 'C'},
        {'type': 'star', 'color': 'yellow', 'size': 'small', 'label': 'D'},
        {'type': 'circle', 'color': 'purple', 'size': 'large', 'label': 'E'},
        {'type': 'square', 'color': 'red', 'size': 'small', 'label': 'F'},
      ],
      'correctIndices': [0, 1, 2],
    },
    acceptedAnswers: ['3/3'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Three shapes to touch — a round one, a boxy one, and a pointed one'},
      {'level': '2', 'type': 'phonemic', 'text': 'Colors: green, blue, red'},
      {'level': '3', 'type': 'visual', 'text': 'Shapes C, B, and A'},
      {'level': '4', 'type': 'model', 'text': 'Touch shapes C, B, and A'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_fi_07',
    exerciseTypeCode: 'follow_instruction',
    taskType: ExerciseTaskType.followInstruction,
    domain: 'language',
    difficulty: 1.5,
    stimulus: {
      'instruction': 'Touch all the circles but not the small ones',
      'shapes': [
        {'type': 'circle', 'color': 'red', 'size': 'large', 'label': 'A'},
        {'type': 'circle', 'color': 'blue', 'size': 'small', 'label': 'B'},
        {'type': 'square', 'color': 'green', 'size': 'medium', 'label': 'C'},
        {'type': 'circle', 'color': 'yellow', 'size': 'medium', 'label': 'D'},
        {'type': 'triangle', 'color': 'purple', 'size': 'large', 'label': 'E'},
        {'type': 'circle', 'color': 'teal', 'size': 'small', 'label': 'F'},
      ],
      'correctIndices': [0, 3],
    },
    acceptedAnswers: ['2/2'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Find the round shapes that are NOT tiny'},
      {'level': '2', 'type': 'phonemic', 'text': 'Skip shapes B and F'},
      {'level': '3', 'type': 'visual', 'text': 'Shapes A and D'},
      {'level': '4', 'type': 'model', 'text': 'Touch shapes A and D'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_fi_08',
    exerciseTypeCode: 'follow_instruction',
    taskType: ExerciseTaskType.followInstruction,
    domain: 'language',
    difficulty: 2.0,
    stimulus: {
      'instruction': 'Touch the large shape that is not red and not a circle',
      'shapes': [
        {'type': 'circle', 'color': 'red', 'size': 'large', 'label': 'A'},
        {'type': 'square', 'color': 'blue', 'size': 'large', 'label': 'B'},
        {'type': 'triangle', 'color': 'green', 'size': 'small', 'label': 'C'},
        {'type': 'circle', 'color': 'yellow', 'size': 'small', 'label': 'D'},
        {'type': 'square', 'color': 'red', 'size': 'large', 'label': 'E'},
        {'type': 'star', 'color': 'purple', 'size': 'medium', 'label': 'F'},
      ],
      'correctIndices': [1],
    },
    acceptedAnswers: ['1/1'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Eliminate: circles, red shapes, and small shapes'},
      {'level': '2', 'type': 'phonemic', 'text': 'The answer is blue'},
      {'level': '3', 'type': 'visual', 'text': 'Shape B'},
      {'level': '4', 'type': 'model', 'text': 'Touch shape B — the large blue square'},
    ],
  ),

  // ═══════════════════════════════════════════════════════════════════
  // 6E — READING COMPREHENSION (8 items)
  // ═══════════════════════════════════════════════════════════════════

  ExerciseItemModel(
    id: 'lang_rc_01',
    exerciseTypeCode: 'reading_comprehension',
    taskType: ExerciseTaskType.readingComprehension,
    domain: 'language',
    difficulty: -2.0,
    stimulus: {
      'passage': 'The cat sat on the mat. It was a sunny day. The cat was happy.',
      'question': 'Where did the cat sit?',
      'options': ['On the mat', 'On the chair', 'In the garden', 'Under the table'],
    },
    acceptedAnswers: ['On the mat'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Look at the first sentence of the passage'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "On the m..."'},
      {'level': '3', 'type': 'visual', 'text': 'On the m _ _'},
      {'level': '4', 'type': 'model', 'text': 'The answer is: On the mat'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_rc_02',
    exerciseTypeCode: 'reading_comprehension',
    taskType: ExerciseTaskType.readingComprehension,
    domain: 'language',
    difficulty: -1.5,
    stimulus: {
      'passage': 'Tom went to the store. He bought apples and milk. Then he walked home.',
      'question': 'What did Tom buy?',
      'options': ['Apples and milk', 'Bread and cheese', 'Eggs and butter', 'Rice and fish'],
    },
    acceptedAnswers: ['Apples and milk'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Look at the second sentence'},
      {'level': '2', 'type': 'phonemic', 'text': 'One item is a fruit, the other is a drink'},
      {'level': '3', 'type': 'visual', 'text': 'A _ _ _ _ _ and m _ _ _'},
      {'level': '4', 'type': 'model', 'text': 'The answer is: Apples and milk'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_rc_03',
    exerciseTypeCode: 'reading_comprehension',
    taskType: ExerciseTaskType.readingComprehension,
    domain: 'language',
    difficulty: -0.5,
    stimulus: {
      'passage': 'Maria woke up early. She ate breakfast and put on her uniform. She walked to school with her friend.',
      'question': 'Where was Maria going?',
      'options': ['To school', 'To the park', 'To the hospital', 'To the store'],
    },
    acceptedAnswers: ['To school'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'She wore a uniform — where would she go in uniform?'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "To sc..."'},
      {'level': '3', 'type': 'visual', 'text': 'Look at the last sentence'},
      {'level': '4', 'type': 'model', 'text': 'The answer is: To school'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_rc_04',
    exerciseTypeCode: 'reading_comprehension',
    taskType: ExerciseTaskType.readingComprehension,
    domain: 'language',
    difficulty: 0.0,
    stimulus: {
      'passage': 'The fire truck raced down the street with its sirens blaring. People moved their cars out of the way. The firefighters arrived at the building in just three minutes.',
      'question': 'How long did it take the firefighters to arrive?',
      'options': ['Three minutes', 'Five minutes', 'Ten minutes', 'One hour'],
    },
    acceptedAnswers: ['Three minutes'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'The time is mentioned in the last sentence'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "Th"'},
      {'level': '3', 'type': 'visual', 'text': 'Th _ _ _ minutes'},
      {'level': '4', 'type': 'model', 'text': 'The answer is: Three minutes'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_rc_05',
    exerciseTypeCode: 'reading_comprehension',
    taskType: ExerciseTaskType.readingComprehension,
    domain: 'language',
    difficulty: 0.5,
    stimulus: {
      'passage': 'Sarah loves painting. Every Saturday, she goes to art class. Last week, she painted a picture of the ocean. Her teacher said it was her best work yet.',
      'question': 'How did the teacher feel about Sarah\'s painting?',
      'options': ['Very impressed', 'Disappointed', 'Confused', 'Angry'],
    },
    acceptedAnswers: ['Very impressed'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'The teacher said it was her "best work yet"'},
      {'level': '2', 'type': 'phonemic', 'text': '"Best work" suggests a positive feeling'},
      {'level': '3', 'type': 'visual', 'text': 'V _ _ _ impressed'},
      {'level': '4', 'type': 'model', 'text': 'The answer is: Very impressed'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_rc_06',
    exerciseTypeCode: 'reading_comprehension',
    taskType: ExerciseTaskType.readingComprehension,
    domain: 'language',
    difficulty: 1.0,
    stimulus: {
      'passage': 'The library was quiet. An old man sat in the corner reading a newspaper. A young woman searched the shelves for a book about gardening. Outside, rain pattered against the windows.',
      'question': 'What was the weather like?',
      'options': ['Rainy', 'Sunny', 'Snowy', 'Windy'],
    },
    acceptedAnswers: ['Rainy'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Look at the last sentence about what was happening outside'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "Ra"'},
      {'level': '3', 'type': 'visual', 'text': 'Rain pattered against the windows'},
      {'level': '4', 'type': 'model', 'text': 'The answer is: Rainy'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_rc_07',
    exerciseTypeCode: 'reading_comprehension',
    taskType: ExerciseTaskType.readingComprehension,
    domain: 'language',
    difficulty: 1.5,
    stimulus: {
      'passage': 'Even though the forecast predicted clear skies, Jake grabbed his umbrella before leaving the house. His mother had always told him, "Better safe than sorry." Sure enough, by noon, dark clouds gathered overhead.',
      'question': 'Why did Jake take the umbrella?',
      'options': [
        'He was cautious like his mother taught him',
        'It was already raining',
        'He needed it for shade',
        'His friend asked him to bring it',
      ],
    },
    acceptedAnswers: ['He was cautious like his mother taught him'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'What did his mother always tell him?'},
      {'level': '2', 'type': 'phonemic', 'text': '"Better safe than sorry" — he was being prepared'},
      {'level': '3', 'type': 'visual', 'text': 'He was cautious...'},
      {'level': '4', 'type': 'model', 'text': 'The answer is: He was cautious like his mother taught him'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_rc_08',
    exerciseTypeCode: 'reading_comprehension',
    taskType: ExerciseTaskType.readingComprehension,
    domain: 'language',
    difficulty: 2.0,
    stimulus: {
      'passage': 'The old lighthouse had guided ships for over a hundred years. When the city decided to demolish it and replace it with a modern beacon, many residents were upset. They argued that the lighthouse was a symbol of their heritage and should be preserved. After months of debate, the city agreed to restore the lighthouse instead.',
      'question': 'What can we infer about the community?',
      'options': [
        'They valued their history and traditions',
        'They preferred modern technology',
        'They did not care about the lighthouse',
        'They wanted a bigger lighthouse',
      ],
    },
    acceptedAnswers: ['They valued their history and traditions'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'The residents fought to keep the lighthouse — what does that show?'},
      {'level': '2', 'type': 'phonemic', 'text': 'The key word is "heritage"'},
      {'level': '3', 'type': 'visual', 'text': 'They valued their h _ _ _ _ _ _'},
      {'level': '4', 'type': 'model', 'text': 'The answer is: They valued their history and traditions'},
    ],
  ),

  // ═══════════════════════════════════════════════════════════════════
  // 6F — SPELLING (8 items)
  // ═══════════════════════════════════════════════════════════════════

  ExerciseItemModel(
    id: 'lang_sp_01',
    exerciseTypeCode: 'spelling',
    taskType: ExerciseTaskType.spelling,
    domain: 'language',
    difficulty: -2.0,
    stimulus: {
      'word': 'cat',
      'icon': 0xe3e2, // Icons.pets
      'fontFamily': 'MaterialIcons',
    },
    acceptedAnswers: ['cat'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'A small furry pet that meows'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "C"'},
      {'level': '3', 'type': 'visual', 'text': 'C _ _'},
      {'level': '4', 'type': 'model', 'text': 'The spelling is: c-a-t'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_sp_02',
    exerciseTypeCode: 'spelling',
    taskType: ExerciseTaskType.spelling,
    domain: 'language',
    difficulty: -1.5,
    stimulus: {
      'word': 'house',
      'icon': 0xe1d7, // Icons.home
      'fontFamily': 'MaterialIcons',
    },
    acceptedAnswers: ['house'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'A building where people live'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "H" and ends with "se"'},
      {'level': '3', 'type': 'visual', 'text': 'H _ _ _ e'},
      {'level': '4', 'type': 'model', 'text': 'The spelling is: h-o-u-s-e'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_sp_03',
    exerciseTypeCode: 'spelling',
    taskType: ExerciseTaskType.spelling,
    domain: 'language',
    difficulty: -0.5,
    stimulus: {
      'word': 'table',
    },
    acceptedAnswers: ['table'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'Furniture where you eat meals'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "T" and has 5 letters'},
      {'level': '3', 'type': 'visual', 'text': 'T _ _ l e'},
      {'level': '4', 'type': 'model', 'text': 'The spelling is: t-a-b-l-e'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_sp_04',
    exerciseTypeCode: 'spelling',
    taskType: ExerciseTaskType.spelling,
    domain: 'language',
    difficulty: 0.0,
    stimulus: {
      'word': 'window',
    },
    acceptedAnswers: ['window'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'You look through this in a wall to see outside'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "W" and has 6 letters'},
      {'level': '3', 'type': 'visual', 'text': 'W _ _ d _ w'},
      {'level': '4', 'type': 'model', 'text': 'The spelling is: w-i-n-d-o-w'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_sp_05',
    exerciseTypeCode: 'spelling',
    taskType: ExerciseTaskType.spelling,
    domain: 'language',
    difficulty: 0.5,
    stimulus: {
      'word': 'kitchen',
      'icon': 0xe252, // Icons.kitchen
      'fontFamily': 'MaterialIcons',
    },
    acceptedAnswers: ['kitchen'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'The room where you cook food'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "Ki" and has 7 letters'},
      {'level': '3', 'type': 'visual', 'text': 'K _ _ c h _ _'},
      {'level': '4', 'type': 'model', 'text': 'The spelling is: k-i-t-c-h-e-n'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_sp_06',
    exerciseTypeCode: 'spelling',
    taskType: ExerciseTaskType.spelling,
    domain: 'language',
    difficulty: 1.0,
    stimulus: {
      'word': 'beautiful',
    },
    acceptedAnswers: ['beautiful'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'It means very pretty or lovely'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "Bea" and has 9 letters'},
      {'level': '3', 'type': 'visual', 'text': 'B _ a u _ _ f _ l'},
      {'level': '4', 'type': 'model', 'text': 'The spelling is: b-e-a-u-t-i-f-u-l'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_sp_07',
    exerciseTypeCode: 'spelling',
    taskType: ExerciseTaskType.spelling,
    domain: 'language',
    difficulty: 1.5,
    stimulus: {
      'word': 'necessary',
    },
    acceptedAnswers: ['necessary'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'It means something is needed or required'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "Ne" — remember: one C, two S\'s'},
      {'level': '3', 'type': 'visual', 'text': 'N e c _ _ s _ _ y'},
      {'level': '4', 'type': 'model', 'text': 'The spelling is: n-e-c-e-s-s-a-r-y'},
    ],
  ),

  ExerciseItemModel(
    id: 'lang_sp_08',
    exerciseTypeCode: 'spelling',
    taskType: ExerciseTaskType.spelling,
    domain: 'language',
    difficulty: 2.0,
    stimulus: {
      'word': 'restaurant',
    },
    acceptedAnswers: ['restaurant'],
    cues: [
      {'level': '1', 'type': 'semantic', 'text': 'A place where you go to eat meals prepared by a chef'},
      {'level': '2', 'type': 'phonemic', 'text': 'It starts with "Re" — watch for the silent "au"'},
      {'level': '3', 'type': 'visual', 'text': 'R e s t _ _ r _ n t'},
      {'level': '4', 'type': 'model', 'text': 'The spelling is: r-e-s-t-a-u-r-a-n-t'},
    ],
  ),
];
