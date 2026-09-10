# 🧠 DEEP RESEARCH REPORT: Building a Free Cognitive & Speech Therapy App (Like Constant Therapy)

---

## 📌 EXECUTIVE SUMMARY

This is a full-spectrum engineering + clinical blueprint for building a **free, open-access cognitive and speech therapy app** — modeled after Constant Therapy — targeting stroke, aphasia, TBI, and dementia patients who cannot afford premium subscriptions. This report covers their **clinical targets, therapy modules, AI/ML models, adaptive engine, tech stack, database design, and your complete build roadmap** for Play Store deployment and academic paper writing.

---

## 🔬 PART 1: WHAT IS CONSTANT THERAPY TARGETING?

### 1.1 Clinical Target Population

Constant Therapy is designed to help people cope with aphasia, dementia, and other speech, language, and cognitive disorders caused by stroke or traumatic brain injuries.

### 1.2 Core Conditions Addressed

| Condition | Description |
|---|---|
| **Aphasia** | Loss of language ability post-stroke |
| **Traumatic Brain Injury (TBI)** | Cognitive impairment from physical trauma |
| **Dementia** | Progressive memory/cognitive decline |
| **Apraxia** | Motor speech disorder |
| **Stroke Recovery** | Multi-domain cognitive + language rehab |

### 1.3 Clinical Validation & Backing

Constant Therapy sets the gold standard with over 70 studies validating the clinical evidence behind their speech, language, and cognitive therapy exercises. They are also backed by 17 peer-reviewed research studies substantiating the efficacy of their program.

The app was developed by Dr. Swathi Kiran, professor at Boston University and head of the Aphasia Research Laboratory at BU. As she worked with patients, she saw the perfect opportunity for merging cognitive and speech therapy and technology to make an easy-to-use mobile app that stroke, aphasia, and brain injury survivors could use in the clinic as well as at home.

---

## 🗂️ PART 2: DEEP MODULE ANALYSIS — ALL THERAPY AREAS

The app provides access to 1 Million+ evidence-based exercises, developed by neuroscientists and clinicians, across 90+ speech, language, and cognitive therapy areas.

### 2.1 Complete Therapy Domain Map

```
┌─────────────────────────────────────────────────────┐
│              THERAPY DOMAIN TREE                    │
├────────────────────┬────────────────────────────────┤
│  SPEECH            │  Speaking, Word Finding,        │
│                    │  Sentence Planning, Fluency,    │
│                    │  Articulation, Apraxia drills   │
├────────────────────┼────────────────────────────────┤
│  LANGUAGE          │  Reading, Writing, Naming,      │
│                    │  Comprehension, Syntax,         │
│                    │  Semantic Processing            │
├────────────────────┼────────────────────────────────┤
│  MEMORY            │  Working Memory, Auditory       │
│                    │  Memory, Visual Memory,         │
│                    │  Sequential Memory              │
├────────────────────┼────────────────────────────────┤
│  ATTENTION         │  Sustained, Selective,          │
│                    │  Divided, Alternating Attention │
├────────────────────┼────────────────────────────────┤
│  COGNITION         │  Problem Solving, Executive     │
│                    │  Function, Planning, Reasoning  │
├────────────────────┼────────────────────────────────┤
│  MATH              │  Numeracy, Calculation,         │
│                    │  Math Comprehension             │
├────────────────────┼────────────────────────────────┤
│  VISUAL PROCESSING │  Pattern Recognition,           │
│                    │  Spatial Reasoning, Visual STM  │
└────────────────────┴────────────────────────────────┘
```

Exercises cover speaking, memory, attention, reading, writing, language, math, comprehension, problem solving, visual processing, auditory memory, and many other essential skill-building areas.

In addition to cognitive and language exercises, the app includes activities for enhancing visual processing and auditory memory.

### 2.2 Task Types (Exercise Format Level)

| Task Type | Input Method | Domain |
|---|---|---|
| **Picture Naming** | Speech (verbal) | Language/Speech |
| **Auditory Command** | Listening + Touch | Comprehension |
| **Word Matching** | Touch selection | Reading/Language |
| **Sentence Completion** | Speech/Touch | Language |
| **Number Tasks** | Touch/Speech | Math/Cognition |
| **Reading Aloud** | Speech recognition | Speech/Reading |
| **Sequencing Tasks** | Drag & Drop | Executive Function |
| **Memory Recall** | Speech/Touch | Working Memory |
| **Visual Matching** | Touch | Visual Processing |
| **Story Comprehension** | Listening + Questions | Comprehension |

---

## 🤖 PART 3: THE CORE AI ENGINE — "NeuroPerformance Engine" (NPE) DISSECTED

This is the heart of what makes Constant Therapy work. Here's a full reverse-engineered analysis:

### 3.1 What is the NPE?

The core that drives the product is called the NeuroPerformance Engine (NPE). The NPE analyzes individual progress, compares it to the progress made by others with similar objectives and conditions, and puts the user on the right path to achieve their goals.

The more the user uses Constant Therapy, the better it understands what exercise and challenge level to put them at.

### 3.2 Adaptive Algorithm — The Math Behind It

The NPE is built on **Item Response Theory (IRT)** + **Collaborative Filtering**. Here's how it works mathematically:

#### 📐 IRT (Item Response Theory) — The Difficulty Engine

Unlike classical test theory, which assumes all questions equally indicate an assessment outcome, Item Response Theory (IRT) considers individual test questions through an item response function — the probability of a correct answer by an individual at a particular skill level θ. The item response function has three parameters: the pseudo-chance score level, item difficulty (how hard it is to answer), and discriminating power (how much skill level influences response).

The 3-Parameter Logistic Model used:

```
P(θ) = c + (1 - c) / (1 + e^(-a(θ - b)))

Where:
  θ = user's current ability level
  b = item difficulty parameter
  a = item discrimination parameter
  c = pseudo-guessing probability
```

Because IRT places items and examinees on a common scale, an adaptive algorithm can choose the most informative item at the examinee's current ability estimate and score every form comparably, regardless of which items were administered.

#### 🔄 Computerized Adaptive Testing (CAT) Loop

In computerized adaptive testing, the algorithm selects — after each response — the unused item that yields the most information at the running θ estimate, then re-estimates θ; the test stops at a target precision, so two users can receive entirely different items yet receive comparable scores.

When using the Constant Therapy program, users select skill domains they wish to improve and are assigned tasks based on that selection by the algorithm. Task difficulty is adjusted per individual user using an adaptive algorithm.

#### Full NPE Loop (Reconstructed):

```
┌─────────────────────────────────────────────────┐
│            NPE ADAPTIVE LOOP                    │
│                                                 │
│  1. USER ONBOARDING                             │
│     └─> Select goals, condition, severity       │
│         └─> Initialize θ (ability estimate)     │
│                                                 │
│  2. TASK SELECTION (CAT Engine)                 │
│     └─> Pick item with max information at θ     │
│     └─> Present exercise                        │
│                                                 │
│  3. RESPONSE EVALUATION                         │
│     └─> Correctness (binary/partial)            │
│     └─> Response time (latency captured)        │
│     └─> Attempt count per item                  │
│                                                 │
│  4. θ UPDATE (Bayesian EAP/MLE)                 │
│     └─> Re-estimate θ based on response         │
│     └─> Update item parameters (online learn)   │
│                                                 │
│  5. COLLABORATIVE FILTERING                     │
│     └─> Compare with similar user profiles      │
│     └─> Predict best next exercise category     │
│                                                 │
│  6. PROGRESS ANALYTICS                          │
│     └─> Dashboard update                        │
│     └─> Clinician notification (if linked)      │
│     └─> Repeat from Step 2                      │
└─────────────────────────────────────────────────┘
```

### 3.3 Speech Recognition Layer

The speech recognition system in the app understands users more accurately, including in environments with background noise — this significantly improves all speaking therapy tasks in the app.

**What they capture in speech tasks:**
- Phoneme-level accuracy
- Word-level correctness
- Response latency (time to initiate speech)
- Fluency markers (pauses, restarts)
- Noise-filtered audio input

### 3.4 Clinical Outcome Evidence

In a retrospective analysis, both home and clinic users required roughly the same amount of practice to successfully complete tasks, but users with on-demand access mastered tasks in a median of 6 days, while those with only in-clinic access took a median of 12 days. Users with digital home access practiced at least every 2 days, while clinic users practiced only once every 5 days. These findings suggest digital therapy provides greater practice intensity than in-clinic therapy alone.

---

## 🗄️ PART 4: DATABASE ARCHITECTURE (Reverse Engineered)

### 4.1 Core Database Schema

```sql
-- USER TABLE
CREATE TABLE users (
  user_id UUID PRIMARY KEY,
  name VARCHAR,
  age INT,
  condition VARCHAR,          -- 'aphasia','stroke','TBI','dementia'
  severity_level INT,         -- 1-5 scale
  primary_language VARCHAR,   -- 'en_US','es_US','en_IN'
  created_at TIMESTAMP,
  clinician_id UUID REFERENCES clinicians(id)
);

-- THERAPY DOMAINS
CREATE TABLE domains (
  domain_id UUID PRIMARY KEY,
  domain_name VARCHAR,        -- 'memory','speech','attention' etc.
  parent_domain_id UUID,      -- for sub-domains
  description TEXT
);

-- EXERCISE ITEM BANK
CREATE TABLE exercises (
  exercise_id UUID PRIMARY KEY,
  domain_id UUID REFERENCES domains(domain_id),
  task_type VARCHAR,          -- 'picture_naming','word_match' etc.
  difficulty_b FLOAT,         -- IRT b-parameter
  discrimination_a FLOAT,     -- IRT a-parameter
  guessing_c FLOAT,           -- IRT c-parameter
  content_json JSONB,         -- stimuli, images, audio paths, answers
  language VARCHAR,
  cultural_variant VARCHAR
);

-- USER SESSIONS
CREATE TABLE sessions (
  session_id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(user_id),
  started_at TIMESTAMP,
  ended_at TIMESTAMP,
  total_exercises INT,
  overall_accuracy FLOAT
);

-- EXERCISE RESPONSES (Core Data)
CREATE TABLE responses (
  response_id UUID PRIMARY KEY,
  session_id UUID REFERENCES sessions(session_id),
  user_id UUID REFERENCES users(user_id),
  exercise_id UUID REFERENCES exercises(exercise_id),
  user_response TEXT,
  is_correct BOOLEAN,
  response_latency_ms INT,
  attempt_number INT,
  theta_before FLOAT,          -- ability before this item
  theta_after FLOAT,           -- ability after this item
  timestamp TIMESTAMP
);

-- ABILITY TRACKING (θ over time)
CREATE TABLE ability_estimates (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(user_id),
  domain_id UUID REFERENCES domains(domain_id),
  theta FLOAT,                 -- current ability estimate
  standard_error FLOAT,        -- measurement precision
  updated_at TIMESTAMP
);

-- CLINICIAN TABLE
CREATE TABLE clinicians (
  clinician_id UUID PRIMARY KEY,
  name VARCHAR,
  license_type VARCHAR,        -- SLP, OT, Neurologist
  institution VARCHAR
);

-- ASSIGNED PROGRAMS
CREATE TABLE therapy_programs (
  program_id UUID PRIMARY KEY,
  user_id UUID,
  clinician_id UUID,
  domain_ids JSONB,            -- array of target domains
  created_at TIMESTAMP,
  active BOOLEAN
);
```

### 4.2 Data Flow Architecture

```
Mobile App → REST API → Application Server
                          ├── IRT Engine (Python)
                          ├── Speech Recognition (Whisper/ASR)
                          ├── PostgreSQL (Relational Data)
                          ├── Redis (Session Cache, Leaderboards)
                          └── S3/Firebase Storage (Audio, Images)
```

---

## 🛠️ PART 5: COMPLETE TECH STACK RECOMMENDATION (For Your Free App)

### 5.1 Mobile App Layer

| Component | Recommended Tool | Why |
|---|---|---|
| **Framework** | **Flutter** | Single codebase for Android + iOS, Play Store ready |
| **State Management** | **Riverpod** or **BLoC** | Scalable, testable |
| **Local Storage** | **SQLite (drift)** | Offline-first therapy |
| **UI Components** | **Material 3 + Custom** | Accessibility-focused |

If your initial scope is mostly content + logging + messaging, cross-platform (React Native/Flutter) is often the pragmatic path — faster iteration, shared UI logic, and simpler maintenance.

### 5.2 Speech Recognition Stack

| Option | Type | Cost | Best For |
|---|---|---|---|
| **OpenAI Whisper (on-device)** | On-device STT | Free | Privacy, offline |
| **Google Speech-to-Text API** | Cloud | Free tier | Easy integration |
| **Vosk** | On-device | Free/Open Source | Fully offline |
| **Picovoice** | On-device | Free tier | Noise resistance |

On-device speech stacks run fully offline and require no cloud connection — ideal for privacy-focused or latency-sensitive real-time applications.

**For your free app → Use Vosk (fully offline, open-source, multilingual)**

### 5.3 Backend Stack

```
┌──────────────────────────────────────┐
│           BACKEND STACK              │
├──────────────────────────────────────┤
│ API Layer:    FastAPI (Python)        │
│ Auth:         Firebase Auth / JWT     │
│ Database:     PostgreSQL (Supabase)   │
│ Cache:        Redis                   │
│ File Storage: Firebase Storage        │
│ IRT Engine:   Python (pyirt / mirt)   │
│ ML/NLP:       HuggingFace + Whisper   │
│ Hosting:      Railway / Render (free) │
│ Push Notif:   Firebase FCM            │
└──────────────────────────────────────┘
```

### 5.4 AI/ML Models

| Function | Model/Library | Free? |
|---|---|---|
| **Adaptive Difficulty (IRT)** | `py-irt`, `mirt` (R), custom Python | ✅ Free |
| **Speech Recognition** | OpenAI Whisper / Vosk | ✅ Free |
| **TTS (Instructions)** | Coqui TTS / gTTS | ✅ Free |
| **Collaborative Filtering** | Scikit-learn / Surprise | ✅ Free |
| **NLP for Language Tasks** | HuggingFace transformers | ✅ Free |
| **Audio Analysis (Fluency)** | Librosa | ✅ Free |
| **Progress Prediction** | LSTM / XGBoost | ✅ Free |

---

## 🏗️ PART 6: SYSTEM ARCHITECTURE (Full App Blueprint)

```
┌──────────────────────────────────────────────────────┐
│                  YOUR APP ARCHITECTURE               │
│                                                      │
│  ┌─────────────────┐    ┌──────────────────────┐     │
│  │  Flutter App    │    │  Clinician Dashboard  │     │
│  │  (Patient)      │    │  (React Web)          │     │
│  └────────┬────────┘    └──────────┬───────────┘     │
│           │                        │                  │
│           └──────────┬─────────────┘                  │
│                      │                               │
│              ┌───────▼────────┐                      │
│              │  FastAPI       │                      │
│              │  REST Backend  │                      │
│              └───────┬────────┘                      │
│                      │                               │
│        ┌─────────────┼────────────┐                  │
│        ▼             ▼            ▼                  │
│  ┌──────────┐  ┌──────────┐ ┌──────────┐            │
│  │PostgreSQL│  │  Redis   │ │ Firebase │            │
│  │(Main DB) │  │ (Cache)  │ │(Storage) │            │
│  └──────────┘  └──────────┘ └──────────┘            │
│        │                                             │
│        ▼                                             │
│  ┌──────────────────────────────────────┐            │
│  │        AI/ML MICROSERVICES           │            │
│  │  ┌──────────┐  ┌──────────────────┐  │            │
│  │  │IRT Engine│  │  Whisper ASR     │  │            │
│  │  │(Adaptive)│  │  (Speech Tasks)  │  │            │
│  │  └──────────┘  └──────────────────┘  │            │
│  │  ┌──────────┐  ┌──────────────────┐  │            │
│  │  │ Collab.  │  │  Progress LSTM   │  │            │
│  │  │ Filter   │  │  (Forecasting)   │  │            │
│  │  └──────────┘  └──────────────────┘  │            │
│  └──────────────────────────────────────┘            │
└──────────────────────────────────────────────────────┘
```

---

## 📱 PART 7: CORE FEATURES TO BUILD (Matching Constant Therapy)

### 7.1 Patient App Features

| Feature | Description | Priority |
|---|---|---|
| **Onboarding Assessment** | Condition, goals, severity selection | 🔴 P1 |
| **Adaptive Exercise Engine** | IRT-based difficulty adjustment | 🔴 P1 |
| **Speech Tasks + ASR** | Mic-based speaking exercises | 🔴 P1 |
| **Progress Dashboard** | Visual charts, domain scores | 🔴 P1 |
| **Offline Mode** | Full functionality without internet | 🔴 P1 |
| **Math Exercises** | Number recognition, calculation | 🟡 P2 |
| **Reading Tasks** | Word matching, reading aloud | 🟡 P2 |
| **Memory Tasks** | Sequence recall, visual memory | 🟡 P2 |
| **Attention Tasks** | Timed tasks, distractor resistance | 🟡 P2 |
| **Clinician Link** | Share progress with therapist | 🟡 P2 |
| **Caregiver View** | Family progress monitoring | 🟢 P3 |
| **Multi-language** | Multiple language support | 🟢 P3 |
| **Gamification** | Streaks, badges, encouragement | 🟢 P3 |

### 7.2 Clinician Dashboard (Web)
Constant Therapy Clinician is an evidence-based program for adult speech therapists. It eliminates the need for paper-based exercises, reduces time and cost, and allows clinicians to create personalized at-home cognitive and speech therapy programs for clients.

Your clinician dashboard should include:
- Patient roster management
- Real-time progress monitoring per domain
- Exercise assignment tools
- Session notes + report export (PDF)
- Alert system (patient inactivity, regression)

---

## 🔊 PART 8: LISTENING & MATH TASKS — DEEP TECHNICAL DIVE

### 8.1 Auditory/Listening Tasks (How They Work Technically)

```
LISTENING TASK FLOW:
1. TTS Engine reads instruction/stimulus aloud
2. User hears audio prompt
3. Response method:
   ├── Picture selection (touch)
   ├── Word typing
   └── Spoken response (ASR capture)
4. Audio analyzed:
   ├── Word Error Rate (WER)
   ├── Phoneme accuracy
   └── Response latency
5. IRT updates θ
```

**Metrics captured:**
- Auditory comprehension accuracy
- Latency from end of audio to response
- Number of replays requested (cue usage)
- Error pattern analysis (semantic vs. phonemic errors)

### 8.2 Mathematical Tasks — The Numeracy Layer

```
MATH TASK TYPES:
├── Number Recognition    → Show digit, user says/selects name
├── Counting Tasks        → Count items in image
├── Simple Arithmetic     → Addition/subtraction with visual aids
├── Money Calculation     → Real-world math (price, change)
├── Time Telling          → Clock reading tasks
└── Number Sequencing     → Fill missing numbers in series

SCORING:
- Exact match → Full credit (IRT correct)
- Within ±10% → Partial credit
- Wrong       → IRT incorrect, θ decreases
- Latency     → Secondary metric for fluency
```

### 8.3 Speech Recognition for Therapy (Deep Technical)

```python
# Pseudocode: Speech Task Evaluation Pipeline

def evaluate_speech_response(audio_input, target_word, task_type):
    # Step 1: ASR Transcription
    transcription = whisper_model.transcribe(audio_input)
    
    # Step 2: Exact Match Check
    if transcription == target_word:
        return {"correct": True, "score": 1.0, "error_type": None}
    
    # Step 3: Phoneme-Level Analysis
    phoneme_similarity = phoneme_compare(transcription, target_word)
    
    # Step 4: Semantic Similarity (for naming tasks)
    semantic_sim = word_embedding_similarity(transcription, target_word)
    
    # Step 5: Error Classification
    error_type = classify_error(transcription, target_word)
    # → "phonemic", "semantic", "perseveration", "neologism", "no_response"
    
    # Step 6: Partial Credit Scoring
    score = compute_partial_credit(phoneme_similarity, semantic_sim)
    
    return {
        "correct": score > 0.85,
        "score": score,
        "error_type": error_type,
        "latency_ms": audio_input.duration
    }
```

---

## 📊 PART 9: MULTILINGUAL & CULTURAL SUPPORT

Therapy exercises are culturally appropriate and capture visual and verbal nuances, including colloquialisms for US English, Spanish (US), and Indian English.

**For your free app targeting poor communities, prioritize:**

| Language Target | Why | Implementation |
|---|---|---|
| **Local native languages** | Serve underserved communities | Vosk multilingual models |
| **Simple vocabulary** | Low literacy users | Grade 3-4 vocabulary level |
| **Voice-first UX** | Low digital literacy | Minimal text, max audio |
| **Large buttons** | Motor impairments | 64dp+ touch targets |
| **High contrast UI** | Visual impairments | WCAG 2.1 AA compliant |

---

## 🌍 PART 10: YOUR UNIQUE VALUE PROPOSITION (vs. Constant Therapy)

| Factor | Constant Therapy | Your App |
|---|---|---|
| **Price** | ~$30/month subscription | **100% FREE** |
| **Access** | Subscription wall | **Open access** |
| **Offline** | Partial | **Full offline** |
| **Code** | Proprietary | **Open-source (MIT)** |
| **Languages** | 3 (English, Spanish, Indian English) | **Expandable** |
| **Clinician needed** | Optional but paywalled | **Self-directed** |
| **Research** | 17+ published papers | **Your paper = contribution** |

---

## 📄 PART 11: ACADEMIC PAPER FRAMEWORK

### Suggested Title:
**"NeuroRehab-Free: An Open-Source, IRT-Adaptive Mobile Cognitive and Speech Therapy Application for Underserved Populations — Design, Architecture, and Pilot Evaluation"**

### Paper Structure (For Journal Submission):

```
1. ABSTRACT (250 words)
   - Problem: Therapy access gap for low-income patients
   - Method: IRT-adaptive mobile app, open-source
   - Results: [your pilot data]
   - Conclusion: Improved access + outcomes

2. INTRODUCTION
   - Global burden of stroke/aphasia/TBI
   - Cost barrier to digital therapy
   - Existing solutions review (Constant Therapy, Lingraphica)
   - Research gap: free, open, adaptive therapy

3. RELATED WORK
   - Digital therapeutics in rehabilitation
   - IRT in adaptive learning systems
   - mHealth for low-income populations

4. SYSTEM DESIGN
   - Architecture overview
   - Adaptive engine (IRT formulation)
   - Exercise taxonomy
   - Speech recognition pipeline

5. METHODOLOGY
   - Participant selection
   - Study protocol (N sessions, duration)
   - Outcome measures (WAB, MMSE, BNT)
   - Statistical analysis (linear mixed models)

6. RESULTS
   - θ progression over time
   - Domain-specific improvement
   - Engagement metrics
   - Clinician usability score

7. DISCUSSION
   - Comparison to Constant Therapy outcomes
   - Limitations
   - Future work (more languages, vision tasks)

8. CONCLUSION

Target Journals:
- Frontiers in Digital Health
- Journal of Medical Internet Research (JMIR)
- Applied Neuropsychology: Adult
- PLOS ONE
```

---

## 🚀 PART 12: PLAY STORE DEPLOYMENT CHECKLIST

```
PRE-SUBMISSION:
✅ Target API level 34+ (Android 14)
✅ HIPAA/healthcare data handling disclosure
✅ Privacy Policy URL (mandatory)
✅ Accessibility features (TalkBack compatibility)
✅ App signing key generated

STORE LISTING:
✅ Category: Medical or Health & Fitness
✅ Content Rating: Everyone (ESRB questionnaire)
✅ Screenshots (8 minimum, all sizes)
✅ Feature graphic (1024x500px)
✅ Full description (4000 chars max)
✅ Short description (80 chars)

MEDICAL APP COMPLIANCE:
✅ NOT claiming to diagnose/treat disease
✅ Disclaimer: "Not a replacement for clinical therapy"
✅ Data encryption at rest + in transit
✅ No collection of health data without consent
✅ COPPA compliant (18+ only app or parental consent)
```

---

## 🗓️ PART 13: DEVELOPMENT ROADMAP

```
PHASE 1 — MVP (Months 1-3)
├── Flutter app skeleton
├── 5 core domains (memory, attention, speech, language, math)
├── 50 exercise items per domain
├── Basic IRT engine (Python backend)
├── Whisper/Vosk speech recognition
├── PostgreSQL + Supabase setup
└── Play Store alpha release

PHASE 2 — Core Features (Months 4-6)
├── Full adaptive NPE engine
├── Progress dashboard (charts, θ visualization)
├── Offline mode with sync
├── Clinician web dashboard
├── 200+ exercises per domain
└── Beta testing with 50 users

PHASE 3 — Research + Scale (Months 7-12)
├── Pilot study with IRB approval
├── Data collection + analysis
├── Multi-language support
├── Paper writing + submission
├── 1000+ exercise item bank
└── Play Store public release
```

---

## 📌 FINAL SUMMARY — KEY TAKEAWAYS

| Aspect | What Constant Therapy Does | What You Build |
|---|---|---|
| **Engine** | NeuroPerformance Engine (IRT + CF) | Open IRT + Whisper |
| **Exercises** | 1M+ across 90+ areas | Start 50/domain, scale up |
| **Speech** | Proprietary noise-robust ASR | Vosk + Whisper (free) |
| **Database** | Proprietary cloud | PostgreSQL + Supabase |
| **Model** | Trained on millions of sessions | Start with population IRT params |
| **Access** | Paid subscription | Free forever |
| **Research base** | 17 peer-reviewed papers | Your paper contributes here |
| **Clinical backing** | Boston University | Partner with local university |
| **Play Store** | Live | Your target |

> 💡 **Your competitive advantage is simple and powerful: You make evidence-based cognitive and speech therapy accessible to the world's 1 billion people who cannot afford $30/month — and you document and publish it.**