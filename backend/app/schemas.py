from pydantic import BaseModel, ConfigDict, Field
from typing import List, Dict, Any, Optional
from uuid import UUID
from datetime import datetime

class HealthResponse(BaseModel):
    status: str
    version: str

# ── User Profiles ──────────────────────────────────────────────────

class UserProfileBase(BaseModel):
    role: str = "patient"
    full_name: Optional[str] = None
    locale: str = "en-US"

class UserProfileCreate(UserProfileBase):
    id: UUID

class UserProfileUpdate(BaseModel):
    full_name: Optional[str] = None
    locale: Optional[str] = None

class UserProfileResponse(UserProfileBase):
    id: UUID
    created_at: datetime
    last_login_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)

# ── Patient Profiles ──────────────────────────────────────────────

class PatientProfileBase(BaseModel):
    conditions: List[str] = []
    severity_map: Dict[str, Any] = {}
    goals: List[str] = []
    sessions_per_week: int = 3
    minutes_per_session: int = 20
    dominant_language: str = "en-US"
    consent_research: bool = False
    consent_data_sharing: bool = False

class PatientProfileUpdate(BaseModel):
    conditions: Optional[List[str]] = None
    severity_map: Optional[Dict[str, Any]] = None
    goals: Optional[List[str]] = None
    sessions_per_week: Optional[int] = None
    minutes_per_session: Optional[int] = None
    dominant_language: Optional[str] = None
    consent_research: Optional[bool] = None
    consent_data_sharing: Optional[bool] = None

class PatientProfileResponse(PatientProfileBase):
    user_id: UUID
    onboarding_completed_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)

# ── Domains ────────────────────────────────────────────────────────

class DomainResponse(BaseModel):
    id: int
    code: str
    name: str
    description: Optional[str] = None
    icon_name: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)

# ── Exercise Items ─────────────────────────────────────────────────

class ExerciseItemResponse(BaseModel):
    id: UUID
    exercise_type_code: str
    domain_code: str
    difficulty: float
    discrimination: float
    locale: str
    stimulus: Dict[str, Any]
    accepted_answers: Optional[Dict[str, Any]] = None
    cues: Optional[List[Any]] = []
    media_url: Optional[str] = None
    tags: List[str] = []
    is_active: bool

    model_config = ConfigDict(from_attributes=True)

# ── Sessions ───────────────────────────────────────────────────────

class SessionStartRequest(BaseModel):
    patient_id: UUID
    target_domains: List[str]
    target_item_count: int = 10
    device_info: Dict[str, Any] = {}

class SessionResponse(BaseModel):
    id: UUID
    patient_id: UUID
    started_at: datetime
    ended_at: Optional[datetime] = None
    target_domains: List[str]
    target_item_count: int
    device_info: Dict[str, Any]

    model_config = ConfigDict(from_attributes=True)

# ── Attempts ───────────────────────────────────────────────────────

class AttemptCreate(BaseModel):
    id: UUID
    session_id: UUID
    patient_id: UUID
    exercise_item_id: UUID
    response: Dict[str, Any]
    is_correct: bool
    partial_score: float = 0.0
    response_time_ms: int
    hint_count: int = 0

class AttemptResponse(BaseModel):
    id: UUID
    session_id: UUID
    patient_id: UUID
    exercise_item_id: UUID
    response: Dict[str, Any]
    is_correct: bool
    partial_score: float
    response_time_ms: int
    hint_count: int
    theta_before: Optional[float] = None
    theta_after: Optional[float] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

class SessionEndRequest(BaseModel):
    ended_at: datetime

# ── Progress Summary ───────────────────────────────────────────────

class AbilityEstimateResponse(BaseModel):
    domain_code: str
    theta: float
    standard_error: float
    total_attempts: int
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)

class MilestoneResponse(BaseModel):
    id: str
    domain_code: str
    name: str
    description: str
    theta_threshold: float
    achieved: bool
    achieved_at: Optional[datetime] = None

class AchievementResponse(BaseModel):
    achievement_code: str
    name: str
    description: str
    unlocked: bool
    unlocked_at: Optional[datetime] = None

class WeeklyActivityDetail(BaseModel):
    date: str
    minutes_practiced: int
    session_count: int
    average_accuracy: float

class ProgressSummaryResponse(BaseModel):
    total_sessions: int
    total_minutes: int
    average_accuracy: float
    current_streak: int
    weekly_activity: List[WeeklyActivityDetail]
