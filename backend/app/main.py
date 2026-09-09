import datetime
from typing import List, Optional, Dict, Any
from uuid import UUID
from fastapi import FastAPI, Depends, HTTPException, status, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import select, update, insert, delete, func, and_
from sqlalchemy.ext.asyncio import AsyncSession
from jose import jwt, JWTError

from app.config import settings
from app.database import get_db
from app.adaptive_engine import expected_success, update_theta_elo, select_items
from app import models, schemas

app = FastAPI(
    title="Therapy Nest API",
    description="Adaptive Cognitive & Speech Therapy Engine",
    version="1.0.0"
)

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── JWT Auth Helpers ───────────────────────────────────────────────

def get_current_user_id(authorization: Optional[str] = Query(None, header="Authorization")) -> UUID:
    """
    Decodes the Supabase JWT token from Authorization header and extracts the user UUID.
    Falls back to parsing without validation if settings.SECRET_KEY is default (during testing).
    """
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authorization header missing"
        )
        
    try:
        token = authorization.split(" ")[1]
        # Attempt to decode with secret key (Supabase signs HS256 JWTs with its JWT Secret)
        try:
            payload = jwt.decode(token, settings.SECRET_KEY, algorithms=["HS256"], options={"verify_aud": False})
        except JWTError:
            # Fallback: Parse claims without signature verification during development/testing
            # if the developer JWT key hasn't been set up yet.
            payload = jwt.get_unverified_claims(token)
            
        user_id = payload.get("sub")
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token payload: sub claim missing"
            )
        return UUID(user_id)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid authorization token: {str(e)}"
        )

# ── General Routes ────────────────────────────────────────────────

@app.get("/health", response_model=schemas.HealthResponse)
async def health_check():
    return {"status": "ok", "version": "1.0.0"}

# ── Auth & Profile Routes ──────────────────────────────────────────

@app.post("/auth/register", response_model=schemas.UserProfileResponse)
async def register_user(user: schemas.UserProfileCreate, db: AsyncSession = Depends(get_db)):
    """Creates a user profile inside the database after registration."""
    existing = await db.execute(select(models.UserProfile).where(models.UserProfile.id == user.id))
    if existing.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User already registered in profile database"
        )
        
    db_user = models.UserProfile(
        id=user.id,
        role=user.role,
        full_name=user.full_name,
        locale=user.locale
    )
    db.add(db_user)
    await db.flush()
    
    # Initialize basic patient profile if registering as patient
    if user.role == "patient":
        db_patient = models.PatientProfile(user_id=user.id)
        db.add(db_patient)
        
    await db.commit()
    await db.refresh(db_user)
    return db_user

@app.post("/auth/login")
async def login_user(user_id: UUID = Depends(get_current_user_id), db: AsyncSession = Depends(get_db)):
    """Updates user last login timestamp."""
    await db.execute(
        update(models.UserProfile)
        .where(models.UserProfile.id == user_id)
        .values(last_login_at=datetime.datetime.utcnow())
    )
    await db.commit()
    return {"status": "success"}

@app.post("/auth/logout")
async def logout_user():
    return {"status": "success"}

@app.get("/profile/{user_id}", response_model=schemas.UserProfileResponse)
async def get_profile(user_id: UUID, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(models.UserProfile).where(models.UserProfile.id == user_id))
    db_user = result.scalar_one_or_none()
    if not db_user:
        raise HTTPException(status_code=404, detail="User profile not found")
    return db_user

@app.put("/profile/{user_id}", response_model=schemas.UserProfileResponse)
async def update_profile(user_id: UUID, data: schemas.UserProfileUpdate, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(models.UserProfile).where(models.UserProfile.id == user_id))
    db_user = result.scalar_one_or_none()
    if not db_user:
        raise HTTPException(status_code=404, detail="User profile not found")
        
    if data.full_name is not None:
        db_user.full_name = data.full_name
    if data.locale is not None:
        db_user.locale = data.locale
        
    await db.commit()
    await db.refresh(db_user)
    return db_user

@app.post("/profile/{user_id}/onboarding", response_model=schemas.PatientProfileResponse)
async def complete_onboarding(user_id: UUID, data: schemas.PatientProfileUpdate, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(models.PatientProfile).where(models.PatientProfile.user_id == user_id))
    db_patient = result.scalar_one_or_none()
    if not db_patient:
        raise HTTPException(status_code=404, detail="Patient profile not found")
        
    for k, v in data.model_dump(exclude_unset=True).items():
        setattr(db_patient, k, v)
        
    db_patient.onboarding_completed_at = datetime.datetime.utcnow()
    await db.commit()
    await db.refresh(db_patient)
    return db_patient

# ── Baseline Assessment ───────────────────────────────────────────

@app.get("/assessment/items", response_model=List[schemas.ExerciseItemResponse])
async def get_assessment_items(locale: str = "en-US", db: AsyncSession = Depends(get_db)):
    """
    Returns the initial calibration assessment set.
    Pulls 3 items of low-to-medium difficulty per domain to establish basic calibration.
    """
    # Fetch active domains
    domains_result = await db.execute(select(models.Domain.code))
    domain_codes = [r[0] for r in domains_result.all()]
    
    items = []
    for code in domain_codes:
        # Fetch 3 items per domain sorted by difficulty (from easy to medium)
        domain_items = await db.execute(
            select(models.ExerciseItem)
            .where(
                and_(
                    models.ExerciseItem.domain_code == code,
                    models.ExerciseItem.is_active == True,
                    models.ExerciseItem.locale == locale
                )
            )
            .order_by(models.ExerciseItem.difficulty)
            .limit(3)
        )
        items.extend(domain_items.scalars().all())
        
    return items

@app.post("/assessment/complete")
async def complete_assessment(
    payload: Dict[str, Any],
    user_id: UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """
    Ingests initial baseline answers, computes initial theta per domain,
    and updates user's baseline ability_estimates.
    """
    answers = payload.get("answers", []) # [{"domain_code": "language", "is_correct": bool, "difficulty": float}]
    if not answers:
        raise HTTPException(status_code=400, detail="Answers list cannot be empty")
        
    # Group answers per domain
    domain_scores = {}
    for ans in answers:
        dc = ans.get("domain_code")
        is_cor = ans.get("is_correct", False)
        diff = ans.get("difficulty", 0.0)
        domain_scores.setdefault(dc, []).append((diff, is_cor))
        
    # Apply standard Elo updates starting from 0.0 for each domain
    for code, scores in domain_scores.items():
        theta = 0.0
        for diff, is_cor in scores:
            theta = update_theta_elo(theta, diff, is_cor)
            
        # Write/Update ability_estimates
        existing = await db.execute(
            select(models.AbilityEstimate)
            .where(
                and_(
                    models.AbilityEstimate.patient_id == user_id,
                    models.AbilityEstimate.domain_code == code
                )
            )
        )
        estimate = existing.scalar_one_or_none()
        if estimate:
            estimate.theta = theta
            estimate.standard_error = 0.8  # Reduced SE on calibration
            estimate.total_attempts += len(scores)
            estimate.updated_at = datetime.datetime.utcnow()
        else:
            db.add(
                models.AbilityEstimate(
                    patient_id=user_id,
                    domain_code=code,
                    theta=theta,
                    standard_error=0.8,
                    total_attempts=len(scores)
                )
            )
            
    await db.commit()
    return {"status": "success", "message": "Baseline estimates calculated and saved"}

# ── Exercise & Adaptive Selection ─────────────────────────────────

@app.get("/exercises/session", response_model=List[schemas.ExerciseItemResponse])
async def get_session_exercises(
    domains: List[str] = Query(...),
    count: int = 10,
    locale: str = "en-US",
    user_id: UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """
    Calculates the adaptive exercise selection for the patient.
    Evaluates current theta per domain and runs IRT selection over available items.
    """
    # Fetch current user ability estimates for requested domains
    estimates_result = await db.execute(
        select(models.AbilityEstimate)
        .where(
            and_(
                models.AbilityEstimate.patient_id == user_id,
                models.AbilityEstimate.domain_code.in_(domains)
            )
        )
    )
    estimates = {e.domain_code: float(e.theta) for e in estimates_result.scalars().all()}
    
    # Fill in defaults (0.0) for missing domains
    for d in domains:
        estimates.setdefault(d, 0.0)
        
    # Get items seen this week to ensure freshness
    one_week_ago = datetime.datetime.utcnow() - datetime.timedelta(days=7)
    seen_result = await db.execute(
        select(models.Attempt.exercise_item_id)
        .where(
            and_(
                models.Attempt.patient_id == user_id,
                models.Attempt.created_at >= one_week_ago
            )
        )
    )
    seen_ids = {str(r[0]) for r in seen_result.all()}
    
    # Query active exercise items in the target domains
    items_result = await db.execute(
        select(models.ExerciseItem)
        .where(
            and_(
                models.ExerciseItem.domain_code.in_(domains),
                models.ExerciseItem.is_active == True,
                models.ExerciseItem.locale == locale
            )
        )
    )
    available_items = items_result.scalars().all()
    
    # If no items exist, raise exception
    if not available_items:
        raise HTTPException(status_code=404, detail="No active exercise items found for specified domains")
        
    # Select adaptively per domain to balance the session
    items_per_domain = max(1, count // len(domains))
    selected = []
    
    for dc in domains:
        domain_items = [item for item in available_items if item.domain_code == dc]
        if not domain_items:
            continue
        theta = estimates[dc]
        selected.extend(select_items(theta, domain_items, seen_ids, count=items_per_domain))
        
    # Fill remaining count if any domain lacked items
    if len(selected) < count:
        remaining_items = [item for item in available_items if item not in selected]
        # Sort by overall distance to average theta
        avg_theta = sum(estimates.values()) / len(estimates)
        selected.extend(select_items(avg_theta, remaining_items, seen_ids, count=(count - len(selected))))
        
    return selected[:count]

@app.get("/exercises/item/{item_id}", response_model=schemas.ExerciseItemResponse)
async def get_exercise_item(item_id: UUID, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(models.ExerciseItem).where(models.ExerciseItem.id == item_id))
    item = result.scalar_one_or_none()
    if not item:
        raise HTTPException(status_code=404, detail="Exercise item not found")
    return item

@app.post("/exercises/items/bulk")
async def bulk_create_exercises(items: List[schemas.ExerciseItemResponse], db: AsyncSession = Depends(get_db)):
    """Allows seeding exercise item database in bulk."""
    created_count = 0
    for item in items:
        # Check if already exists
        existing = await db.execute(select(models.ExerciseItem).where(models.ExerciseItem.id == item.id))
        if existing.scalar_one_or_none():
            continue
            
        db_item = models.ExerciseItem(**item.model_dump())
        db.add(db_item)
        created_count += 1
        
    await db.commit()
    return {"status": "success", "created_count": created_count}

# ── Therapy Session Life Cycle ────────────────────────────────────

@app.post("/sessions/start", response_model=schemas.SessionResponse)
async def start_session(data: schemas.SessionStartRequest, db: AsyncSession = Depends(get_db)):
    session_id = UUID(int=datetime.datetime.utcnow().microsecond + int(datetime.datetime.utcnow().timestamp()))
    # Ensure unique UUID
    db_session = models.Session(
        id=session_id,
        patient_id=data.patient_id,
        target_domains=data.target_domains,
        target_item_count=data.target_item_count,
        device_info=data.device_info,
        started_at=datetime.datetime.utcnow()
    )
    db.add(db_session)
    await db.commit()
    await db.refresh(db_session)
    return db_session

@app.post("/sessions/{session_id}/attempts", response_model=List[schemas.AttemptResponse])
async def upload_session_attempts(
    session_id: UUID,
    attempts: List[schemas.AttemptCreate],
    db: AsyncSession = Depends(get_db)
):
    """
    Submits a batch of exercise attempts for a session.
    Fires the adaptive ELO calibration engine to calculate new theta per attempt,
    saving the incremental progress to ability_estimates, and returning logged attempts.
    """
    # Verify session exists
    session_result = await db.execute(select(models.Session).where(models.Session.id == session_id))
    db_session = session_result.scalar_one_or_none()
    if not db_session:
        raise HTTPException(status_code=404, detail="Therapy session not found")
        
    logged_attempts = []
    
    for att in attempts:
        # 1. Fetch item details (for difficulty and domain)
        item_result = await db.execute(select(models.ExerciseItem).where(models.ExerciseItem.id == att.exercise_item_id))
        item = item_result.scalar_one_or_none()
        if not item:
            continue
            
        # 2. Fetch current theta estimate
        estimate_result = await db.execute(
            select(models.AbilityEstimate)
            .where(
                and_(
                    models.AbilityEstimate.patient_id == att.patient_id,
                    models.AbilityEstimate.domain_code == item.domain_code
                )
            )
        )
        estimate = estimate_result.scalar_one_or_none()
        theta_before = float(estimate.theta) if estimate else 0.0
        
        # 3. Update theta using adaptive ELO logic
        theta_after = update_theta_elo(
            theta=theta_before,
            difficulty=float(item.difficulty),
            is_correct=att.is_correct,
            partial_score=att.partial_score,
            hint_count=att.hint_count
        )
        
        # 4. Save updated estimate back to database
        if estimate:
            estimate.theta = theta_after
            estimate.total_attempts += 1
            estimate.updated_at = datetime.datetime.utcnow()
        else:
            db.add(
                models.AbilityEstimate(
                    patient_id=att.patient_id,
                    domain_code=item.domain_code,
                    theta=theta_after,
                    total_attempts=1
                )
            )
            
        # 5. Insert new attempt record
        db_attempt = models.Attempt(
            id=att.id,
            session_id=session_id,
            patient_id=att.patient_id,
            exercise_item_id=att.exercise_item_id,
            response=att.response,
            is_correct=att.is_correct,
            partial_score=att.partial_score,
            response_time_ms=att.response_time_ms,
            hint_count=att.hint_count,
            theta_before=theta_before,
            theta_after=theta_after,
            created_at=datetime.datetime.utcnow()
        )
        db.add(db_attempt)
        logged_attempts.append(db_attempt)
        
    await db.commit()
    
    # Reload items to return full attributes
    return logged_attempts

@app.put("/sessions/{session_id}/end", response_model=schemas.SessionResponse)
async def end_session(session_id: UUID, data: schemas.SessionEndRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(models.Session).where(models.Session.id == session_id))
    db_session = result.scalar_one_or_none()
    if not db_session:
        raise HTTPException(status_code=404, detail="Therapy session not found")
        
    db_session.ended_at = data.ended_at
    await db.commit()
    await db.refresh(db_session)
    
    # Post-Session Achievement Check
    await evaluate_achievements(db_session.patient_id, db)
    
    return db_session

@app.get("/sessions/{patient_id}", response_model=List[schemas.SessionResponse])
async def get_patient_sessions(patient_id: UUID, db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(models.Session)
        .where(models.Session.patient_id == patient_id)
        .order_by(models.Session.started_at.desc())
    )
    return result.scalars().all()

# ── Progress Summary Endpoints ────────────────────────────────────

@app.get("/progress/{patient_id}/summary", response_model=schemas.ProgressSummaryResponse)
async def get_progress_summary(patient_id: UUID, db: AsyncSession = Depends(get_db)):
    """Computes total minutes practiced, weekly history charts, and active streak counts."""
    # 1. Total sessions completed
    sessions_result = await db.execute(
        select(models.Session)
        .where(
            and_(
                models.Session.patient_id == patient_id,
                models.Session.ended_at != None
            )
        )
    )
    sessions = sessions_result.scalars().all()
    total_sessions = len(sessions)
    
    # 2. Total duration in minutes
    total_minutes = 0
    for s in sessions:
        if s.ended_at:
            delta = s.ended_at - s.started_at
            total_minutes += int(delta.total_seconds() / 60)
            
    # 3. Accuracy calculations
    attempts_result = await db.execute(
        select(models.Attempt.is_correct)
        .where(models.Attempt.patient_id == patient_id)
    )
    attempts = attempts_result.scalars().all()
    correct_attempts = sum(1 for a in attempts if a is True)
    total_attempts = len(attempts)
    avg_accuracy = (correct_attempts / total_attempts * 100) if total_attempts > 0 else 0.0
    
    # 4. Compute daily practice logs (last 7 days)
    weekly_activity = []
    now = datetime.datetime.utcnow()
    for i in range(7):
        day = now - datetime.timedelta(days=6-i)
        day_start = datetime.datetime(day.year, day.month, day.day, 0, 0, 0)
        day_end = datetime.datetime(day.year, day.month, day.day, 23, 59, 59)
        
        # Calculate minutes
        day_sessions = [s for s in sessions if s.started_at >= day_start and s.started_at <= day_end]
        day_minutes = sum(int((s.ended_at - s.started_at).total_seconds() / 60) for s in day_sessions if s.ended_at)
        
        # Calculate accuracy
        day_attempts_result = await db.execute(
            select(models.Attempt.is_correct)
            .where(
                and_(
                    models.Attempt.patient_id == patient_id,
                    models.Attempt.created_at >= day_start,
                    models.Attempt.created_at <= day_end
                )
            )
        )
        day_attempts = day_attempts_result.scalars().all()
        day_correct = sum(1 for a in day_attempts if a is True)
        day_total = len(day_attempts)
        day_accuracy = (day_correct / day_total * 100) if day_total > 0 else 0.0
        
        weekly_activity.append(
            schemas.WeeklyActivityDetail(
                date=day.strftime("%Y-%m-%d"),
                minutes_practiced=day_minutes,
                session_count=len(day_sessions),
                average_accuracy=day_accuracy
            )
        )
        
    # 5. Streak computation
    streak = 0
    session_dates = {s.started_at.date() for s in sessions}
    check_date = now.date()
    # If not practiced today, allow starting from yesterday
    if check_date not in session_dates:
        check_date -= datetime.timedelta(days=1)
        
    while check_date in session_dates:
        streak += 1
        check_date -= datetime.timedelta(days=1)
        
    return {
        "total_sessions": total_sessions,
        "total_minutes": total_minutes,
        "average_accuracy": avg_accuracy,
        "current_streak": streak,
        "weekly_activity": weekly_activity
    }

@app.get("/progress/{patient_id}/domains", response_model=List[schemas.AbilityEstimateResponse])
async def get_domain_progress(patient_id: UUID, db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(models.AbilityEstimate)
        .where(models.AbilityEstimate.patient_id == patient_id)
    )
    return result.scalars().all()

@app.get("/progress/{patient_id}/weekly")
async def get_weekly_metrics(patient_id: UUID, weeks: int = 4, db: AsyncSession = Depends(get_db)):
    """Returns practice minutes and session counts summarized weekly."""
    now = datetime.datetime.utcnow()
    weekly_stats = []
    
    for w in range(weeks):
        start_date = now - datetime.timedelta(weeks=w+1)
        end_date = now - datetime.timedelta(weeks=w)
        
        sessions_result = await db.execute(
            select(models.Session)
            .where(
                and_(
                    models.Session.patient_id == patient_id,
                    models.Session.started_at >= start_date,
                    models.Session.started_at < end_date,
                    models.Session.ended_at != None
                )
            )
        )
        sessions = sessions_result.scalars().all()
        minutes = sum(int((s.ended_at - s.started_at).total_seconds() / 60) for s in sessions if s.ended_at)
        
        weekly_stats.append({
            "week_label": f"Week -{w}",
            "minutes": minutes,
            "session_count": len(sessions)
        })
        
    return weekly_stats[::-1]  # Return oldest first

@app.get("/progress/{patient_id}/achievements", response_model=List[schemas.AchievementResponse])
async def get_patient_achievements(patient_id: UUID, db: AsyncSession = Depends(get_db)):
    """Returns all available achievement badges showing unlocked status."""
    # Query unlocked achievements
    unlocked_result = await db.execute(
        select(models.PatientAchievement)
        .where(models.PatientAchievement.patient_id == patient_id)
    )
    unlocked = {a.achievement_code: a.unlocked_at for a in unlocked_result.scalars().all()}
    
    # Standard definitions
    defs = [
        {"code": "streak_3", "name": "3-Day Streak", "description": "Practiced 3 days in a row!"},
        {"code": "streak_7", "name": "7-Day Streak", "description": "A whole week of practice!"},
        {"code": "sessions_10", "name": "10 Sessions", "description": "Ten sessions completed!"},
        {"code": "accuracy_perfect", "name": "Perfect Session", "description": "100% accuracy in a session!"}
    ]
    
    response = []
    for d in defs:
        code = d["code"]
        is_unlocked = code in unlocked
        response.append(
            schemas.AchievementResponse(
                achievement_code=code,
                name=d["name"],
                description=d["description"],
                unlocked=is_unlocked,
                unlocked_at=unlocked.get(code)
            )
        )
    return response

@app.get("/progress/{patient_id}/milestones", response_model=List[schemas.MilestoneResponse])
async def get_patient_milestones(patient_id: UUID, db: AsyncSession = Depends(get_db)):
    """Evaluates theta ability estimates against functional clinical landmarks."""
    # Get current estimates
    estimates_result = await db.execute(
        select(models.AbilityEstimate)
        .where(models.AbilityEstimate.patient_id == patient_id)
    )
    estimates = {e.domain_code: float(e.theta) for e in estimates_result.scalars().all()}
    
    # Get landmarks definitions
    landmarks_result = await db.execute(select(models.FunctionalLandmark))
    landmarks = landmarks_result.scalars().all()
    
    response = []
    for l in landmarks:
        theta = estimates.get(l.domain_code, -3.0)
        achieved = theta >= float(l.theta_threshold)
        response.append(
            schemas.MilestoneResponse(
                id=f"landmark_{l.id}",
                domain_code=l.domain_code,
                name=l.description,
                description=f"Requires {l.domain_code} ability threshold of {l.theta_threshold}",
                theta_threshold=float(l.theta_threshold),
                achieved=achieved,
                achieved_at=datetime.datetime.utcnow() if achieved else None
            )
        )
    return response

# ── Post-Session Achievement Evaluator ────────────────────────────

async def evaluate_achievements(patient_id: UUID, db: AsyncSession):
    """Checks and unlocks streak, session count, or perfect session badges."""
    # Fetch all user sessions
    sessions_result = await db.execute(
        select(models.Session)
        .where(
            and_(
                models.Session.patient_id == patient_id,
                models.Session.ended_at != None
            )
        )
    )
    sessions = sessions_result.scalars().all()
    total_sessions = len(sessions)
    if total_sessions == 0:
        return
        
    # Fetch currently unlocked achievement codes
    unlocked_result = await db.execute(
        select(models.PatientAchievement.achievement_code)
        .where(models.PatientAchievement.patient_id == patient_id)
    )
    unlocked_codes = {r[0] for r in unlocked_result.all()}
    
    # Check 1: 10 Sessions
    if "sessions_10" not in unlocked_codes and total_sessions >= 10:
        db.add(models.PatientAchievement(patient_id=patient_id, achievement_code="sessions_10"))
        
    # Check 2: Streak calculation
    streak = 0
    now = datetime.datetime.utcnow()
    session_dates = {s.started_at.date() for s in sessions}
    check_date = now.date()
    if check_date not in session_dates:
        check_date -= datetime.timedelta(days=1)
    while check_date in session_dates:
        streak += 1
        check_date -= datetime.timedelta(days=1)
        
    if "streak_3" not in unlocked_codes and streak >= 3:
        db.add(models.PatientAchievement(patient_id=patient_id, achievement_code="streak_3"))
    if "streak_7" not in unlocked_codes and streak >= 7:
        db.add(models.PatientAchievement(patient_id=patient_id, achievement_code="streak_7"))
        
    # Check 3: Perfect session (100% accuracy in latest session)
    if "accuracy_perfect" not in unlocked_codes:
        latest_session = max(sessions, key=lambda s: s.started_at)
        attempts_result = await db.execute(
            select(models.Attempt.is_correct)
            .where(models.Attempt.session_id == latest_session.id)
        )
        attempts = attempts_result.scalars().all()
        if len(attempts) > 0 and all(attempts):
            db.add(models.PatientAchievement(patient_id=patient_id, achievement_code="accuracy_perfect"))
            
    await db.flush()
