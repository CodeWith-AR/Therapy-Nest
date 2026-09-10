<div align="center">

<img src="therapy_nest/assets/images/AppLogo.png" alt="Therapy Nest App Icon" width="112" height="112" style="border-radius: 24px; box-shadow: 0 4px 20px rgba(0,0,0,0.1);" />

# Therapy Nest

**An Evidence-Based, Open-Source Cognitive & Speech Therapy Mobile Platform for Stroke Survivors & Neurorehabilitation**

[![Flutter](https://img.shields.io/badge/Flutter-3.29+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.110+-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![Python](https://img.shields.io/badge/Python-3.11+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://python.org)
[![Supabase](https://img.shields.io/badge/Supabase-Database-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

[🌐 Live Web Showcase](https://therapy-nest-web.vercel.app) · [📱 Download Android APK](https://therapy-nest-web.vercel.app#download) · [📄 Clinical Whitepaper](https://therapy-nest-web.vercel.app/research.html)

</div>

---

## 📌 Clinical Mission & Problem

Over **15 million people worldwide suffer a stroke each year**, with 1 in 3 acquiring aphasia or severe cognitive-linguistic deficits. Clinical literature establishes that neuroplastic recovery requires **4+ hours of intensive weekly practice**. Yet, overburdened healthcare systems can typically provide less than 45 minutes of weekly in-clinic speech therapy. Commercial software often charges upwards of $30/month—financially excluding millions of stroke survivors globally.

**Therapy Nest** bridges this rehabilitation gap as a permanently free, open-source daily therapy companion engineered with:
1. **Mathematical Psychometrics (2PL Item Response Theory)**: An adaptive Elo calibration engine that calibrates item difficulty ($b$) to patient ability ($\theta$) to maintain a constant **70–80% success rate ("Flow Channel")**, maximizing neuroplasticity while preventing cognitive burnout.
2. **100% On-Device Acoustic Processing**: Embedded **Vosk ASR** offline speech recognition. Zero raw patient audio is ever streamed to a third-party server, ensuring complete medical privacy (HIPAA/GDPR compliant by design) with instantaneous sub-200ms feedback on low-resource devices.
3. **Offline-First Resilience**: Authoritative local **Drift SQLite** database paired with asynchronous cloud synchronization to **Supabase PostgreSQL**.

---

## 🏛️ Monorepo Architecture

```
Therapy-Nest/
├── 📱 therapy_nest/                       # Flutter Mobile Application (Main App - Android / iOS)
│   ├── lib/
│   │   ├── app/                           # App configuration, router (GoRouter), theme engine
│   │   ├── core/                          # Design tokens, audio & Vosk ASR services
│   │   ├── data/                          # Drift SQLite database, models, repositories
│   │   └── modules/                       # Feature modules (Auth, Home, Therapy, Progress, Assessment)
│   ├── assets/                            # Visual stimuli, icons, Vosk offline acoustic models
│   └── android/                           # Native Android configuration
│
├── ⚡ backend/                            # FastAPI Adaptive IRT & Cloud Engine
│   ├── app/
│   │   ├── adaptive_engine.py             # Psychometric 2PL IRT item selection & ability calibration
│   │   ├── config.py                      # Environment settings (Supabase, asyncpg pooler)
│   │   ├── database.py                    # Async SQLAlchemy PostgreSQL connection engine
│   │   ├── models.py                      # Relational schema (user_profiles, attempts, items)
│   │   └── main.py                        # FastAPI REST endpoints with Supabase JWT auth
│   ├── Dockerfile                         # Container build for Render / Koyeb cloud deployment
│   └── requirements.txt                   # Python dependencies
│
├── 🗄️ database/                           # Supabase PostgreSQL Migrations & Schemas
│   ├── supabase_profile_setup.sql         # User profiles & role-based access triggers
│   ├── therapy_nest_m3_migration.sql      # Exercises, domains & assessment item tables
│   └── therapy_nest_m7_sync_migration.sql # Telemetry & cross-device sync schema
│
├── 🎨 design_inspiration/                 # UI/UX Specifications, Design Tokens & Design Skills
│   ├── DESIGN-claude.md                   # Clinical design system architecture
│   ├── design-2.md                        # Component hierarchy & accessibility specs
│   ├── designV3.md                        # Modern Material 3 neuro-friendly theme tokens
│   ├── skill-2.md                         # UI engineering workflow patterns
│   └── skillV3.md                         # Accessibility and micro-interaction guidelines
│
├── 📚 project_research_and_development/   # Clinical Research, Benchmarks & Deep Dives
│   ├── (ChatGpt)deep-research-report.md    # Clinical speech pathology baseline analysis
│   ├── (Claude)constant-therapy-deep-dive-blueprint.md # Competitive architecture breakdown
│   ├── (Gemini)Constant Therapy App Analysis.md # Psychometric modeling research
│   ├── 1.Therapy_Nest_Best_Approach.md    # Implementation roadmap & technical strategy
│   ├── 2.therapy_nest_app_prompt.md       # Master feature specifications
│   ├── 3.Setup_Guide.md                   # Development environment setup
│   ├── 3.1Phase_A_Setup_Guide.md          # Foundation milestone walkthrough
│   ├── PROJECTPROGRESS.md                 # Longitudinal development logs & sprint history
│   └── lmArenaDeepsearch.md               # Cognitive exercise bank taxonomy
│
├── 🛡️ .gitignore                          # Multi-tier secret protection (credentials, keystores, .env)
├── ⚖️ LICENSE                             # MIT Open Source License
└── 📖 README.md                           # Master repository documentation
```

---

## 🎯 7 Evidence-Based Clinical Domains

Derived from clinical speech-language pathology protocols (such as the **Western Aphasia Battery–Revised (WAB-R)** and BDAE):

| Domain | Clinical Focus | Task Modalities |
|---|---|---|
| **Language / Naming** | Anomia recovery & semantic retrieval | Confrontation naming with 4-level cueing |
| **Reading & Writing** | Grapheme-phoneme translation & alexia | Sentence completion, word-to-picture matching |
| **Auditory Memory** | Working memory & receptive recall | Audio sequence repetition, delayed verbal recall |
| **Attention & Focus** | Sustained vigilance & executive function | Go/No-Go visual matching, flanker discrimination |
| **Speech Production** | Apraxia of speech & articulation clarity | Target syllable vocalization, Vosk phonemic matching |
| **Everyday Math** | Acalculia & functional independence | Time computation, money counting, simple arithmetic |
| **Problem Solving** | Cognitive sequencing & logical deduction | Functional categorical association |

---

## 🔬 Psychometric Engine: 2-Parameter Logistic (2PL) IRT

Item Response Theory models the probability $P$ that a patient with latent cognitive ability $\theta$ successfully solves an exercise item with difficulty $b$ and discrimination $a$:

$$P(\theta) = \frac{1}{1 + e^{-a(\theta - b)}}$$

Following each completed exercise, the patient's ability estimate is updated in real time via an Elo-IRT calibration step:

$$\theta_{t+1} = \theta_t + K \cdot (S - P(\theta_t))$$

where:
- $S \in \{0.0, 1.0\}$ represents binary response accuracy (with fractional penalties for cues utilized: $-0.15$ per level).
- $K$ is the dynamic update factor that narrows as session attempts scale, stabilizing ability bounds.

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: 3.29.x or later
- **Dart SDK**: 3.7.x or later
- **Python**: 3.11.x or later
- **Android Studio / VS Code** with Flutter & Dart extensions
- **Connected Device**: Android 6.0+ (API 23+) or Emulator

---

### 1. Mobile App Setup (`/therapy_nest`)

1. Navigate to the mobile app directory:
   ```bash
   cd therapy_nest
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Setup Firebase Configuration (Example template provided):
   - Copy `android/app/google-services.json.example` to `android/app/google-services.json` and insert your Firebase Project keys:
     ```bash
     cp android/app/google-services.json.example android/app/google-services.json
     ```

4. Run the app on your connected device or emulator:
   ```bash
   flutter run
   ```

5. Build production release APK:
   ```bash
   flutter build apk --release
   ```
   Output: `build/app/outputs/flutter-apk/app-release.apk`

---

### 2. Backend Setup (`/backend`)

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Create and activate a Python virtual environment:
   ```bash
   python -m venv venv
   # On Windows:
   .\venv\Scripts\activate
   # On macOS/Linux:
   source venv/bin/activate
   ```

3. Install required packages:
   ```bash
   pip install -r requirements.txt
   ```

4. Setup environment variables:
   - Copy `.env.example` to `.env` and fill in your Supabase connection credentials:
     ```bash
     cp .env.example .env
     ```

5. Run local development server:
   ```bash
   python run.py
   ```
   API Docs will be live at: `http://127.0.0.1:8000/docs`

---

## 🛡️ Security, Privacy & Data Governance

- **Zero Cloud Audio**: Audio captured for speech evaluation is decoded exclusively on-device through Vosk FFI. No raw voice data is uploaded, complying with HIPAA & GDPR standards.
- **Secret Isolation**: Repository `.gitignore` rules strictly prevent `google-services.json`, `.env`, and release keystores from being tracked or exposed.
- **Row Level Security (RLS)**: PostgreSQL tables enforce `auth.uid() = patient_id` ownership policies.

---

## 📄 License & Medical Disclaimer

### MIT License
This project is open-source software licensed under the **[MIT License](LICENSE)**.

### Medical Disclaimer
*Therapy Nest is intended as a supplementary cognitive and speech practice tool for educational and supportive purposes. It does not provide medical diagnoses or replace clinical therapy prescribed by licensed medical practitioners, neurologists, or certified Speech-Language Pathologists (SLPs).*

---

## 📬 Contact & Support

- **Project Lead & Maintainer**: Abdur Rehman ([@CodeWith-AR](https://github.com/CodeWith-AR))
- **Direct Email**: [mailrehman90527300@gmail.com](mailto:mailrehman90527300@gmail.com)
- **GitHub Issues & Discussions**: [https://github.com/CodeWith-AR/Therapy-Nest/issues](https://github.com/CodeWith-AR/Therapy-Nest/issues)
- **Web Showcase & Help Center**: [https://therapy-nest-web.vercel.app](https://therapy-nest-web.vercel.app)
- **Website Repository**: [CodeWith-AR/Therapy-Nest-Web](https://github.com/CodeWith-AR/Therapy-Nest-Web)

