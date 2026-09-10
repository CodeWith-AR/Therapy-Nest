# Constant Therapy: Deep-Dive Analysis & Blueprint for a Free Cognitive Rehabilitation App

*Research compiled August 13, 2026. Sources listed at the end — figures like user counts and pricing change over time, so re-verify anything date-sensitive before publishing/citing in a paper.*

**Contents**
1. Executive Summary
2. Constant Therapy: Company Profile
3. Clinical Domains & Exercise Modules (the "what")
4. The AI Layer: NeuroPerformance Engine & Therapy Calculator (the "how")
5. Speech & Language Processing
6. Regulatory & Compliance Landscape
7. Competitive Landscape
8. System Architecture for Your App
9. Core Feature List (MVP → later phases)
10. Proposed Database Schema
11. Recommended Tech Stack
12. Designing for Low-Cost, Low-Connectivity Users
13. Making "Free" Actually Sustainable
14. Publishing on Google Play — Checklist
15. Clinical & Ethical Guardrails
16. Suggested Paper Outline
17. Sources

---

## 1. Executive Summary

Constant Therapy is a clinically-grounded speech/language/cognitive rehab app that grew out of Boston University's Aphasia Research Laboratory, not a consumer brain-training app. Its edge isn't any single exercise — it's three things working together: (a) a large, clinically-validated content library covering ~14 rehab domains, (b) an adaptive engine that personalizes difficulty per patient, and (c) a two-sided model where clinicians can remotely assign and monitor home practice. It is expensive ($29.99–299.99/mo–yr) and English/Spanish-only in practice, which is exactly the gap a free, localized version can fill.

The internal specifics you asked about — exact database schema, exact model weights — are not public (they're patented/trade secret). What *is* public is enough to reverse-engineer a credible, evidence-based approach: a published methodology paper describing their core predictive model, patent-level descriptions of the personalization engine, and detailed public exercise catalogs. Sections 4, 10, and 11 turn that into a concrete, buildable design.

---

## 2. Constant Therapy: Company Profile

### Timeline
- **2013** — Veera Anantha founds Constant Therapy Inc.
- **2017–2020** — Operates as "The Learning Corp" (Anantha as CTO/President during this period)
- **April 2020** — Relaunches as **Constant Therapy Health**; Dr. Swathi Kiran formalized as co-founder/Scientific Director
- **Dec 2024** — FDA grants **Breakthrough Device Designation** to a distinct clinical variant ("ST App") for post-stroke patients
- **2026** — 800,000+ users, 300M+ exercises completed, available in English (US/UK/Australia/India dialects) and US Spanish

### People
| Person | Role | Background |
|---|---|---|
| **Veera Anantha, PhD** | CEO & Co-founder | PhD Electrical/Computer Engineering + MS Physics, Northwestern; BTech, IIT Bombay; ex-Motorola engineering leadership; holds 6 tech patents |
| **Mahendra** (co-founder) | Architected the platform; co-invented the patented NeuroPerformance Engine | Distributed-systems background; oversees engineering, data science, IP |
| **Dr. Swathi Kiran** | Scientific Director & Co-founder | Professor of Neurorehabilitation & Founding Director, BU Center for Brain Recovery; Director, Aphasia Research Lab; 180+ peer-reviewed papers; NIH-funded; BSc Speech-Language Pathology (All India Institute of Speech and Hearing), PhD Aphasia (Northwestern) |

### Scale & recognition
- 800,000+ registered users; 300M+ exercises completed (sources from mid-2026 cite figures between 325M and 340M depending on platform listing)
- Recognized by the American Stroke Association, AARP, TIME's Top HealthTech Companies, the American Heart Association's Innovators' Network, and won the 2022 Hearst Health Prize
- Deployed at institutions including Spaulding Rehabilitation Network, the Stroke Comeback Center, and the MossRehab Aphasia Center

### Business model (two-sided)
| Product | Audience | Price |
|---|---|---|
| **Constant Therapy: Brain+Speech** | Patients (direct-to-consumer) | $29.99/mo or $299.99/yr (US); ~£22.99/mo, £234.99/yr (UK) — 14-day free trial, 30-day money-back guarantee, HSA/FSA-eligible |
| **Constant Therapy Clinician** | Individual clinicians/educators/researchers | Free for personal 1:1 use |
| **Enterprise Clinician** | Hospitals/health systems | Paid license — HIPAA-compliant, EMR/EHR data export, enterprise access control |

This is the template worth copying: **the consumer side subsidizes nothing — institutions and paying patients fund the platform, while a lightweight clinician tool is free to drive adoption and word-of-mouth.** For a "free for patients" model, you'd likely need to invert this (see Section 13).

---

## 3. Clinical Domains & Exercise Modules

Constant Therapy's catalog isn't "14 separate games" — it's ~14 top-level clinical domains, expressed through 85+ *task types*, each of which generates many parameterized *items* (1M+ total). Critically, most tasks are cross-tagged to several domains at once (a design pattern worth copying — it multiplies your content's value without multiplying build effort).

| Domain | What it targets | Real examples found in the catalog |
|---|---|---|
| **Attention** (sustained/selective/divided/alternating) | Focus, filtering distraction, task-switching | Symbol Matching, Find the Symbols, Find Alternating Symbols |
| **Memory** (working/short-term/delayed) | Holding & recalling information | Repeat a Pattern, Remember Information About a Person, Match Pictures |
| **Language / Word-Finding** (anomia) | Naming, fluency, word retrieval | Naming tasks with semantic/phonemic cueing |
| **Auditory Comprehension / Listening** | Understanding spoken language | Follow spoken instructions, Voicemail comprehension (with adjustable playback speed) |
| **Reading & Writing** | Literacy-based comprehension/expression | Passage reading with comprehension questions |
| **Speech Production** (articulation, apraxia, dysarthria) | Motor speech, clarity | Spoken-response tasks scored against accepted-answer banks |
| **Math / Numbers** | Functional numeracy, money/time skills | Currency-speaking tasks, clock-reading/speaking tasks, calculation |
| **Problem Solving / Analytical Reasoning** | Planning, sequencing, flexibility | Put Concepts in Order, Put Steps in Order (e.g., "How to refill a prescription") |
| **Visuospatial Processing** | Spatial attention, neglect, navigation | Read a Map |

**Localization**: English dialects (US, UK, Australia, India) plus US Spanish, with content described as "culturally appropriate" (local colloquialisms, visual references). Notably absent: Urdu, Hindi, Arabic, and most other South/Southeast Asian or African languages — a real, defensible gap if you're building for underserved populations who don't primarily speak English or Spanish. Because aphasia and speech therapy exercises must be delivered in a patient's dominant language to be clinically meaningful, this isn't a minor feature gap — it's a genuine clinical/access gap none of the major players (Constant Therapy, Tactus Therapy, Lingraphica) have solved.

---

## 4. The AI Layer: NeuroPerformance Engine & Therapy Calculator

This is the part you called "model trained" — here's what's actually public vs. proprietary, and what to build instead.

### What's publicly known
- **NeuroPerformance Engine (NPE)** — patented; described as analyzing an individual's progress, comparing it against other users with similar conditions/goals, and adjusting the difficulty path. No architecture details are public.
- **Therapy Calculator** — the company published the actual methodology (medRxiv, Jan 2026): a **logistic regression model trained on 3.5 million therapy sessions from 18,000+ patients**, predicting the probability a patient moves from their current *functional landmark* (a defined skill level within a domain, e.g., "reading") to the next one, using **age, etiology (cause — stroke/TBI/etc.), starting performance, and therapy frequency/duration** as predictors.
- **Supporting evidence**: a 10-week pilot RCT (Braley et al., 2021) with 32 post-stroke aphasia patients found self-managed Constant Therapy use produced significantly larger gains on the WAB-R Aphasia Quotient than workbook-based therapy (mean change 6.75 vs. 0.38 — well past the 5-point clinically-significant threshold). A separate retrospective analysis linked practicing 4–5×/week to meaningfully better outcomes than lower-frequency use.
- General field finding worth knowing for your own design: aphasia research suggests an average of roughly 98 hours of total speech-language therapy is associated with positive outcomes, yet most stroke survivors receive only a fraction of that in clinic — which is the core access gap self-managed apps exist to close.

### What's NOT public
Exact model architecture beyond "logistic regression," feature engineering details, infrastructure, the full NPE algorithm, and the database schema are trade secrets/patented IP. Don't trust any source (including AI) that claims to know these precisely — treat the rest of this section as a well-reasoned proposal, not a leak of their actual system.

### Recommended approach for your app (grounded in the above)
1. **Cold-start baseline assessment** — a short adaptive diagnostic per domain when a patient first signs up, to seed an initial ability estimate. This solves the "cold start problem" that's well-documented in adaptive-learning literature.
2. **Per-domain ability tracking** — use a simplified **2-parameter Item Response Theory (IRT)** model:
   `P(correct | θ, item) = 1 / (1 + exp(−a(θ − b)))`
   where θ = patient ability, b = item difficulty, a = item discrimination. If that's too heavy to calibrate early on, use a lighter **Elo-style rating** (borrowed from chess rating systems): update θ after each attempt using `θ_new = θ_old + K × (outcome − expected)`, where `expected = 1 / (1 + 10^((b − θ_old)/400))`. This needs far less data to bootstrap than full IRT.
3. **Item selection** — serve the next item whose difficulty is close to current ability, targeting roughly a 70–80% success rate (the "flow channel" — challenging but not frustrating, well-supported in the difficulty/motivation literature).
4. **Retention via spaced repetition** — use an **SM-2-style algorithm** (the same logic behind Anki/SuperMemo) to resurface previously-missed items at increasing intervals, based on a 0–5 "quality" score derived from correctness, response time, and hint usage.
5. **Your own "Therapy Calculator," later** — once you have even a few thousand of your own sessions, train a logistic regression predicting landmark-transition probability from {age, etiology, baseline score, sessions/week, weeks elapsed} — this directly reproduces Constant Therapy's own published methodology, so you're not guessing.

---

## 5. Speech & Language Processing

Constant Therapy's spoken-response tasks (naming, articulation, currency/clock-speaking) are scored against **accepted-answer banks with fuzzy matching** — an App Store changelog entry literally references "enhanced currency & clock speaking therapy tasks to allow many more variations of acceptable spoken answers," confirming this is answer-list-plus-matching rather than a black-box grader.

For a free app, avoid commercial per-call ASR (Google/Azure Speech APIs) — the cost scales with usage and directly undermines a free model. Options, from the current open-source landscape:

| Tool | Best for | Notes |
|---|---|---|
| **faster-whisper** (Whisper + CTranslate2) | Server-side batch scoring, best general multilingual accuracy | Trained on 680k hours, ~100 languages; most teams' practical "Whisper" deployment |
| **Moonshine** | On-device/offline, low-end phones | As small as 27M parameters; built for edge deployment, beats Whisper Tiny/Small despite smaller size |
| **Vosk** | Lightweight fully-offline toolkit | 20+ languages/dialects, easy pre-trained models, good for a first offline build |
| **Wav2Vec2 (Meta)** | Fine-tuning for a specific/low-resource language | Best starting point if you need a language the above don't cover well — requires labeled audio to fine-tune |

For non-English target languages (Urdu, Hindi, regional languages), plan to fine-tune Wav2Vec2 or Whisper on **Mozilla Common Voice** data plus your own recordings — this is exactly the kind of gap that gives a localized free app real differentiation, since it's underserved even by the big commercial players.

---

## 6. Regulatory & Compliance Landscape

Read this before writing a line of code — it will shape your architecture and store listing.

### FDA (United States)
- The consumer app is deliberately positioned as **self-management/wellness**, not treatment — Constant Therapy Health is explicit that it offers tools for self-help rather than guaranteed clinical outcomes. That framing is what keeps the mass-market app outside FDA's Software-as-a-Medical-Device enforcement (FDA exercises enforcement discretion for apps that help patients self-manage *without* providing specific treatment suggestions).
- Separately, in Dec 2024 the FDA granted **Breakthrough Device Designation** — an expedited-review status, *not* clearance — to a distinct clinical product for post-stroke patients.
- **Practical takeaway**: frame your app as a "practice/self-management companion," never as a cure or guaranteed treatment. This is the single highest-leverage legal decision you'll make, and it's the exact playbook the market leader uses.

### Google Play (this changed very recently — check before you launch)
- As of the **January 2026** Health Content & Services policy update, apps in the **Medical or Health category can no longer publish under an Individual developer account** — a verified **Organization account** is now required.
- You must complete the **Health Apps Declaration** (Play Console → App content), disclosing what health features you offer.
- If you make *any* claim about improvement, treatment, or diagnosis, Google requires you to disclose the claimed benefit and its basis — and for anything read as a "Medical Device," proof of regulatory clearance or an explicit non-diagnostic disclaimer.
- Google is also cracking down on "data overreach" — only request Health Connect permissions you can justify for your core function.

### HIPAA (if you serve US users or partner with US clinics)
Technically only binding if you're a "covered entity" or "business associate" — a pure direct-to-patient app with no clinic in the loop is a gray area. Build to the standard anyway, both because it's the right thing to do with disability/health data and because you'll want institutional partnerships eventually:
- TLS 1.2+ in transit, AES-256 at rest
- Role-based access control + MFA for any clinician/admin accounts
- Audit logs for all PHI access
- No PHI in push notifications or application logs
- Signed Business Associate Agreements with any cloud vendor once you do handle data on behalf of a clinic

### Outside the US
If you localize to Pakistan, South Asia, or elsewhere, check the local personal-data-protection framework and any medical-device/health-app rules in that jurisdiction before making treatment-adjacent claims — this is genuinely regional and time-sensitive, so it's worth a short consult with local counsel or your university's legal/ethics office rather than relying on general research like this.

---

## 7. Competitive Landscape

| App | Maker | Focus | Price model | Clinician tools | Evidence base |
|---|---|---|---|---|---|
| **Constant Therapy** | Constant Therapy Health (BU spinout) | Broad: attention, memory, language, speech, math, reasoning — stroke/TBI/aphasia/dementia | $29.99/mo or $299.99/yr, 14-day trial | Free personal tier + paid Enterprise (EHR integration) | 70+ cited studies, 17 peer-reviewed, 1 published RCT (n=32) |
| **Tactus Therapy** | Megan Sutton, SLP (solo studio, Vancouver, since 2011) | Aphasia-specific: naming, comprehension, reading, writing, apraxia — sold as separate focused apps | $14.99–$59.99 per app (one-time); bundle $189.99 | Built-in cueing-level customization for SLP-guided sessions | Independent University of Cambridge study (Stark & Warburton, 2018): 20 min/day × 4 weeks → significant gains in chronic expressive aphasia |
| **Lingraphica** | Lingraphica (AAC device company) | AAC + language exercises (SmallTalk); free aphasia-friendly news reader (TalkPath News) | Varies by product; TalkPath News is free | Yes, tied to their speech-generating device ecosystem | Company-published, linked to their hardware/AAC business |
| General brain-training apps (Lumosity, Elevate, etc.) | Various | Broad cognitive games, not clinically targeted at a diagnosis | Consumer subscription | None | Not comparable evidence base — don't position your app alongside these; you're building a clinical rehab tool, not a brain-game app |

**Positioning takeaway**: Constant Therapy wins on breadth and clinician integration but loses on price and language coverage. Tactus Therapy wins on aphasia-specific depth and independent evidence but sells piecemeal apps, not a unified adaptive system. Neither localizes well beyond English/Spanish. A free, localized, adaptive app that borrows Constant Therapy's breadth-and-personalization approach and Tactus's clinical focus is a real, defensible niche — you don't need to out-build either on day one, just be genuinely useful in the gap they leave.

---

## 8. System Architecture for Your App

```
┌──────────────────────────────────────────────────────────────┐
│                  MOBILE CLIENT (Android-first)                 │
│  Flutter app │ Local SQLite cache │ Offline exercise bundle    │
│  Patient UI  │ On-device ASR fallback (Vosk/Moonshine)         │
└───────────────────────────┬────────────────────────────────────┘
                             │ HTTPS (syncs opportunistically)
┌───────────────────────────▼────────────────────────────────────┐
│                     BACKEND API (single service to start)       │
│  Auth  │ Session/Attempt logging │ Content service               │
│  Adaptive Engine (ability estimation + item selection)           │
│  Speech-scoring worker (server-side faster-whisper batch job)    │
└───────┬────────────────────────────────────────┬────────────────┘
        │                                        │
┌───────▼─────────┐                    ┌─────────▼──────────┐
│   PostgreSQL      │                    │   Object storage     │
│   (see Section 10)│                    │   (audio, images)     │
└────────────────────┘                    └────────────────────────┘
        │
┌───────▼─────────────────────────┐
│  Clinician/Caregiver Dashboard    │
│  (progress charts, assign tasks)  │
│  — Phase 2                        │
└────────────────────────────────────┘
```

Keep it a monolith at first (one backend service, one database). Splitting into microservices before you have real usage just adds hosting cost and complexity — the opposite of what a free product needs.

---

## 9. Core Feature List (MVP → Later Phases)

**Phase 1 — MVP (build this first, not all 90 exercise types)**
- Onboarding + short baseline mini-assessment per domain
- 4–6 domains, ~15–20 exercise types total
- Simple adaptive difficulty (Elo-style, not full IRT yet)
- Offline mode with background sync
- Basic progress dashboard: streak, accuracy trend, a per-domain radar/bar chart
- Text + audio exercises; server-batch speech scoring for spoken tasks
- **One language, done properly**, rather than five done shallowly — this is your differentiation

**Phase 2**
- Clinician/caregiver companion view: assign exercises, monitor progress remotely
- Expand domain/item bank
- Daily-practice push reminders (the "constant" in Constant Therapy is literally the retention mechanic — consistency drives outcomes per the RCT evidence above)
- Second language

**Phase 3**
- Your own Therapy-Calculator-equivalent predictive model, trained on your real usage data
- Clinician-reviewed, community-contributed content pipeline
- A real pilot study with a partner hospital/NGO/university (feeds directly into your paper)

---

## 10. Proposed Database Schema (PostgreSQL)

This is an original design proposal grounded in the public methodology above — **not** Constant Therapy's actual schema, which isn't public.

```sql
-- Identity
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role VARCHAR(20) NOT NULL CHECK (role IN ('patient','clinician','caregiver','admin')),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(30),
    password_hash TEXT,
    locale VARCHAR(10) DEFAULT 'en-US',
    created_at TIMESTAMPTZ DEFAULT now(),
    last_login_at TIMESTAMPTZ
);

CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255),
    org_type VARCHAR(30), -- clinic / hospital / ngo / school
    baa_signed BOOLEAN DEFAULT false
);

CREATE TABLE patient_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    date_of_birth DATE,
    etiology VARCHAR(50),          -- stroke / tbi / dementia / other
    diagnosis_detail TEXT,         -- e.g. aphasia subtype
    onset_date DATE,
    dominant_language VARCHAR(10),
    primary_clinician_id UUID REFERENCES users(id),
    organization_id UUID REFERENCES organizations(id),
    consent_research BOOLEAN DEFAULT false,
    consent_data_sharing BOOLEAN DEFAULT false
);

-- Clinical content
CREATE TABLE domains (
    id SERIAL PRIMARY KEY,
    code VARCHAR(30) UNIQUE,       -- attention / memory / language ...
    name VARCHAR(100),
    description TEXT
);

CREATE TABLE exercise_types (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE,
    name VARCHAR(150),
    description TEXT,
    input_modality VARCHAR(20),      -- text/audio/image/drag_drop
    response_modality VARCHAR(20)    -- multiple_choice/spoken/written/tap
);

CREATE TABLE exercise_type_domains (   -- one exercise can target several domains
    exercise_type_id INT REFERENCES exercise_types(id),
    domain_id INT REFERENCES domains(id),
    weight NUMERIC(3,2) DEFAULT 1.0,
    PRIMARY KEY (exercise_type_id, domain_id)
);

CREATE TABLE exercise_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exercise_type_id INT REFERENCES exercise_types(id),
    difficulty NUMERIC(5,2) NOT NULL,   -- IRT-style item difficulty (b)
    locale VARCHAR(10) DEFAULT 'en-US',
    stimulus JSONB NOT NULL,            -- prompt text/image/audio refs
    accepted_answers JSONB,             -- accepted responses for fuzzy match
    media_url TEXT,
    is_active BOOLEAN DEFAULT true
);

-- Activity & adaptive state
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES users(id),
    started_at TIMESTAMPTZ DEFAULT now(),
    ended_at TIMESTAMPTZ,
    device_info JSONB
);

CREATE TABLE attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES sessions(id),
    exercise_item_id UUID REFERENCES exercise_items(id),
    response JSONB,
    is_correct BOOLEAN,
    response_time_ms INT,
    hint_count INT DEFAULT 0,
    audio_url TEXT,                     -- only for spoken responses, opt-in retention
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE ability_estimates (
    patient_id UUID REFERENCES users(id),
    domain_id INT REFERENCES domains(id),
    theta NUMERIC(6,3) DEFAULT 0.0,     -- current ability estimate
    updated_at TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (patient_id, domain_id)
);

CREATE TABLE functional_landmarks (      -- mirrors CT's published "landmark" concept
    id SERIAL PRIMARY KEY,
    domain_id INT REFERENCES domains(id),
    landmark_order INT,
    description TEXT
);

CREATE TABLE patient_landmark_progress (
    patient_id UUID REFERENCES users(id),
    landmark_id INT REFERENCES functional_landmarks(id),
    achieved_at TIMESTAMPTZ,
    predicted_probability NUMERIC(4,3),
    PRIMARY KEY (patient_id, landmark_id)
);

CREATE TABLE care_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES users(id),
    clinician_id UUID REFERENCES users(id),
    target_domains INT[],
    sessions_per_week INT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Compliance
CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,
    actor_user_id UUID,
    action VARCHAR(100),
    target_table VARCHAR(50),
    target_id TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);
```

---

## 11. Recommended Tech Stack

| Layer | Recommendation | Why |
|---|---|---|
| Mobile | **Flutter (Dart)** | Single codebase for Android + iOS, strong offline support, smaller footprint than React Native on low-end devices — matters if your target users have budget phones |
| Backend | **Python (FastAPI)** or Node.js (NestJS) | FastAPI keeps your API and adaptive-engine/ML code in one language, simplifying a small team |
| Database | **PostgreSQL** | Relational integrity for clinical/progress data, JSONB columns for flexible exercise content |
| Cache | **Redis** (optional, add later) | Session state, rate limiting — skip until you actually need it |
| Speech | **faster-whisper** server-side + **Vosk/Moonshine** on-device fallback | Avoids per-call commercial ASR costs entirely; works offline |
| Adaptive engine | Python (`scikit-learn`/`statsmodels` for logistic regression; `py-irt` or `catsim` for IRT) | Proven open-source libraries — don't reinvent IRT calibration |
| Hosting (start) | Low-cost VPS (Hetzner/DigitalOcean) or free tiers (Supabase/Render/Railway) | Cost control is existential for a free product |
| Hosting (scale) | AWS/GCP with BAA-eligible services, once you handle real PHI at scale | Needed once you have institutional/clinic partners |
| CI/CD | GitHub Actions | Free for small/open-source projects |
| Crash/analytics | Self-hosted Sentry + self-hosted PostHog | Avoids recurring SaaS fees that scale with your (free, so non-revenue) user base |

---

## 12. Designing for Low-Cost, Low-Connectivity Users

This is where "free for poor people" needs to show up in engineering decisions, not just pricing:

- **Offline-first, not offline-optional**: cache a rolling set of exercises locally (SQLite/Drift), let patients practice with no connection, sync attempts when a connection appears.
- **Small app size**: use Android App Bundles, compress media aggressively, lazy-load exercise packs by domain instead of shipping everything upfront.
- **Low-RAM device testing**: explicitly test on 2GB-RAM budget Android phones, not just flagship devices — this is where most cost-sensitive users will actually be.
- **Minimize data usage**: compress audio uploads before syncing, batch sync instead of real-time, make server round-trips optional for anything that can run on-device.
- **On-device speech scoring where feasible**: Moonshine/Vosk mean a patient in a low-connectivity area can still get spoken-response feedback without needing bandwidth for every attempt.

---

## 13. Making "Free" Actually Sustainable

Be honest with yourself early: two costs don't disappear just because users don't pay — **clinically-valid content creation** and **compute** (hosting, storage, speech scoring at scale). Open-source ASR removes most of the compute cost; content creation is the real one, because it needs actual clinical expertise, not just engineering time.

Sustainability models seen in adjacent nonprofit/global digital-health work:
- **Donation/philanthropic model** — grant-funded, common in global health digital tools
- **University or hospital incubation** — literally Constant Therapy's own origin story: it was built inside BU before spinning out commercially. A university or teaching hospital partnership could fund your early content-validation work.
- **Inverted freemium** — keep the *patient* app 100% free forever; if you ever need revenue, charge *institutions* (clinics/NGOs) for a dashboard/analytics tier, mirroring Constant Therapy's model but flipping which side pays.
- **Grant ecosystems built for exactly this** — initiatives like WHO's Open Health Stack Software Foundation and the Global Fund's digital-health investments (~$150M/year across 90+ countries) exist specifically to fund free, open, licensing-cost-free digital health infrastructure in under-resourced settings. Worth researching for your specific target region.
- **Open-source, community-reviewed content pipeline** — let SLPs/educators contribute exercises under a clinician-review gate, rather than paying a content team to build everything centrally.

---

## 14. Publishing on Google Play — Checklist

1. Register a **Google Play Organization developer account** (required for Health/Medical category since Jan 2026) — not Individual.
2. Choose your category carefully: framing everything as "practice exercises for cognitive/speech/language skills" (not diagnosis or guaranteed treatment) may reduce regulatory friction, but check the current Health Apps Declaration flow directly in Play Console since requirements evolve.
3. Complete the **Health Apps Declaration** + **Data Safety form** — be exact about what you collect (audio recordings, usage analytics, etc.).
4. Publish a clear, hosted **Privacy Policy**, linked both in-app and in the store listing.
5. Add an explicit disclaimer in-app and in the listing: this is a self-guided practice tool, not a replacement for professional therapy — mirror Constant Therapy's own language here.
6. If you ever claim clinical improvement, be ready to show the evidentiary basis, per Google's Health Content policy.
7. Target modern Android API levels but test explicitly on low-RAM/low-storage devices — your actual target users' phones, not a flagship test device.

---

## 15. Clinical & Ethical Guardrails

- **Bring in a licensed SLP, occupational therapist, or neuropsychologist early** — even part-time or as a volunteer advisor. A well-engineered app with clinically-invalid exercises can waste a patient's limited rehab window, or actively frustrate/demoralize them. This is the single most important non-technical factor in the whole project.
- **Don't claim efficacy you haven't measured.** Cite the general literature about an exercise *type* if relevant, but don't imply your specific app was clinically proven until you've actually run a study.
- **If you run a pilot study for your paper**, get institutional/ethics review (an IRB or your university's equivalent) before collecting patient data, use validated outcome measures (Western Aphasia Battery–Revised, Boston Naming Test, MoCA) so your results are comparable to the field, and get informed consent.
- **Treat the data as maximally sensitive** — it combines health status, disability, and sometimes cognitive/communication vulnerability. Default to collecting the minimum necessary, and never share audio recordings or personal data by default.

---

## 16. Suggested Paper Outline

1. **Title / Abstract**
2. **Introduction** — the access/cost gap (cite the $29.99–299.99/mo price point as the barrier you're addressing), motivation, target population
3. **Related Work** — Constant Therapy, Tactus Therapy, Lingraphica; the IRT/adaptive-testing literature; spaced-repetition literature
4. **System Design** — architecture diagram (Section 8), data flow, module breakdown
5. **Core Features & Clinical Domains** (Section 3, adapted to what you actually build)
6. **Adaptive/AI Methodology** — your ability-estimation + item-selection approach; explicitly cite Constant Therapy's own published Therapy Calculator methodology as your closest comparator and point of departure
7. **Implementation / Tech Stack** (Section 11)
8. **Evaluation Plan** — usability pilot first; a small pre/post outcome study if feasible, using validated measures
9. **Ethical Considerations** — data privacy, clinical oversight, non-diagnostic positioning (Section 15)
10. **Limitations & Future Work**
11. **Conclusion**

Tip: the medRxiv "Therapy Calculator" paper (cited below) is a good structural model for how a digital-therapeutics methodology paper in this exact space is written and reviewed.

---

## 17. Sources

- Constant Therapy company/product overview — constanttherapyhealth.com, star.global case study, Google Play & App Store listings, Amazon Appstore listing, Aptoide listing
- Founders — Boston University Sargent College profile & Wikipedia page for Swathi Kiran; Rafik Hariri Institute, TheOrg, Crunchbase, and constanttherapyhealth.com/about-us for Veera Anantha
- Therapy Calculator methodology — "Machine Learning Driven 'Therapy Calculator' for Self-Managed Digital Speech-Language Therapy for Individuals with Post-stroke Aphasia," medRxiv, Jan 2026
- Exercise domains/examples — Google Play & App Store listings (patient + clinician apps), constanttherapyhealth.com/brainwire exercise-spotlight articles
- Pricing — National Aphasia Association resource page (2025), UK Stroke Association app review, constanttherapyhealth.com pricing pages
- FDA regulatory status — constanttherapyhealth.com Breakthrough Device Designation announcement; FDA.gov Digital Health Center of Excellence guidance; Arnold & Porter regulatory advisory (Jan 2026)
- Google Play health policy — Google Play Console Help ("Health app categories," "Health Content and Services"); myappmonitor.com Jan 2026 policy analysis
- HIPAA guidance — accountablehq.com, appinventiv.com, hipaavault.com compliance checklists (2025–2026)
- Competitors — tactustherapy.com, National Aphasia Association resource pages, ASHA Leader article on aphasia apps, Speechify and Aphasia Studio roundups
- Open-source speech recognition — Northflank and AssemblyAI 2026 STT benchmarking articles; arXiv papers on Whisper/Wav2Vec2 for low-resource ASR
- Adaptive learning / IRT — multiple 2025–2026 papers on IRT-based adaptive testing and the cold-start problem in adaptive learning systems
- Spaced repetition (SM-2) — SuperMemo.com, open-source SM-2 implementations
- Free/sustainable digital health models — "Sustainable by Design" (Mayo Clinic Proceedings: Digital Health, 2025); WHO Open Health Stack Software Foundation announcement (2026); Global Fund digital health page
