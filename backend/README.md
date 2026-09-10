# Therapy Nest — Adaptive Backend Engine

FastAPI-powered psychometric recommendation and telemetry microservice for **Therapy Nest**.

## 🧠 Core Responsibilities
- **2PL IRT Calibration Engine**: Implements psychometric Item Response Theory with real-time Elo-Bayesian updates, serving optimal exercises tailored to patient recovery velocity ($\theta$).
- **Longitudinal Telemetry & Session Logging**: Ingests exercise completion logs and diagnostic baseline assessments.
- **Supabase PostgreSQL & Auth Integration**: Authenticates client requests via Supabase JWTs and connects asynchronously via `asyncpg`.

---

## 🛠️ Local Development

### 1. Environment Configuration
Copy the template configuration and fill in your Supabase credentials:
```bash
cp .env.example .env
```

Ensure your `.env` contains:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=your-service-role-key
DATABASE_URL=postgresql+asyncpg://postgres:[PASSWORD]@[HOST]:5432/postgres
SECRET_KEY=your-jwt-secret-key
ALLOWED_ORIGINS=*
PORT=8000
```

### 2. Install Dependencies & Run
```bash
python -m venv venv
# On Windows:
.\venv\Scripts\activate
# On macOS / Linux:
source venv/bin/activate

pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Interactive OpenAPI documentation is available at:
`http://localhost:8000/docs`

---

## 🐳 Docker Build

```bash
docker build -t therapy-nest-api .
docker run -p 8000:8000 --env-file .env therapy-nest-api
```

---

## 🚀 Cloud Deployment (Render)
- **Runtime**: Docker
- **Docker Build Context**: `backend`
- **Dockerfile Path**: `backend/Dockerfile`
- **Health Check Path**: `/health`
- **Port**: `8000`
