import datetime
from sqlalchemy import Column, String, Integer, Numeric, Boolean, DateTime, ForeignKey, BigInteger, Table
from sqlalchemy.dialects.postgresql import JSONB, ARRAY, UUID
from sqlalchemy.orm import relationship
from app.database import Base

class UserProfile(Base):
    __tablename__ = "user_profiles"

    id = Column(UUID(as_uuid=True), primary_key=True)
    role = Column(String(20), nullable=False, default="patient")
    full_name = Column(String(255))
    locale = Column(String(10), default="en-US")
    created_at = Column(DateTime(timezone=True), default=datetime.datetime.utcnow)
    last_login_at = Column(DateTime(timezone=True))

    patient_profile = relationship("PatientProfile", back_populates="user", uselist=False)

class PatientProfile(Base):
    __tablename__ = "patient_profiles"

    user_id = Column(UUID(as_uuid=True), ForeignKey("user_profiles.id", ondelete="CASCADE"), primary_key=True)
    conditions = Column(ARRAY(String), default=[])
    severity_map = Column(JSONB, default={})
    goals = Column(ARRAY(String), default=[])
    sessions_per_week = Column(Integer, default=3)
    minutes_per_session = Column(Integer, default=20)
    dominant_language = Column(String(10), default="en-US")
    consent_research = Column(Boolean, default=False)
    consent_data_sharing = Column(Boolean, default=False)
    onboarding_completed_at = Column(DateTime(timezone=True))

    user = relationship("UserProfile", back_populates="patient_profile")

class Domain(Base):
    __tablename__ = "domains"

    id = Column(Integer, primary_key=True, autoincrement=True)
    code = Column(String(30), unique=True, nullable=False)
    name = Column(String(100), nullable=False)
    description = Column(String)
    icon_name = Column(String(50))

class ExerciseItem(Base):
    __tablename__ = "exercise_items"

    id = Column(UUID(as_uuid=True), primary_key=True)
    exercise_type_code = Column(String(50), nullable=False)
    domain_code = Column(String(30), ForeignKey("domains.code"), nullable=False)
    difficulty = Column(Numeric(5, 2), nullable=False, default=0.0)
    discrimination = Column(Numeric(4, 2), default=1.0)
    locale = Column(String(10), default="en-US")
    stimulus = Column(JSONB, nullable=False)
    accepted_answers = Column(JSONB)
    cues = Column(JSONB, default=[])
    media_url = Column(String)
    tags = Column(ARRAY(String), default=[])
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), default=datetime.datetime.utcnow)

class Session(Base):
    __tablename__ = "sessions"

    id = Column(UUID(as_uuid=True), primary_key=True)
    patient_id = Column(UUID(as_uuid=True), ForeignKey("user_profiles.id"), nullable=False)
    started_at = Column(DateTime(timezone=True), default=datetime.datetime.utcnow)
    ended_at = Column(DateTime(timezone=True))
    target_domains = Column(ARRAY(String), default=[])
    target_item_count = Column(Integer, default=10)
    device_info = Column(JSONB, default={})

class Attempt(Base):
    __tablename__ = "attempts"

    id = Column(UUID(as_uuid=True), primary_key=True)
    session_id = Column(UUID(as_uuid=True), ForeignKey("sessions.id"), nullable=False)
    patient_id = Column(UUID(as_uuid=True), ForeignKey("user_profiles.id"), nullable=False)
    exercise_item_id = Column(UUID(as_uuid=True), ForeignKey("exercise_items.id"), nullable=False)
    response = Column(JSONB)
    is_correct = Column(Boolean)
    partial_score = Column(Numeric(4, 3), default=0.0)
    response_time_ms = Column(Integer)
    hint_count = Column(Integer, default=0)
    theta_before = Column(Numeric(6, 3))
    theta_after = Column(Numeric(6, 3))
    created_at = Column(DateTime(timezone=True), default=datetime.datetime.utcnow)

class AbilityEstimate(Base):
    __tablename__ = "ability_estimates"

    patient_id = Column(UUID(as_uuid=True), ForeignKey("user_profiles.id"), primary_key=True)
    domain_code = Column(String(30), ForeignKey("domains.code"), primary_key=True)
    theta = Column(Numeric(6, 3), default=0.0)
    standard_error = Column(Numeric(5, 3), default=1.0)
    total_attempts = Column(Integer, default=0)
    updated_at = Column(DateTime(timezone=True), default=datetime.datetime.utcnow)

class FunctionalLandmark(Base):
    __tablename__ = "functional_landmarks"

    id = Column(Integer, primary_key=True, autoincrement=True)
    domain_code = Column(String(30), ForeignKey("domains.code"), nullable=False)
    landmark_order = Column(Integer, nullable=False)
    description = Column(String, nullable=False)
    theta_threshold = Column(Numeric(5, 2), nullable=False)

class PatientAchievement(Base):
    __tablename__ = "patient_achievements"

    patient_id = Column(UUID(as_uuid=True), ForeignKey("user_profiles.id"), primary_key=True)
    achievement_code = Column(String(50), primary_key=True)
    unlocked_at = Column(DateTime(timezone=True), default=datetime.datetime.utcnow)

class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    actor_user_id = Column(UUID(as_uuid=True))
    action = Column(String(100))
    target_table = Column(String(50))
    target_id = Column(String)
    metadata = Column(JSONB, default={})
    created_at = Column(DateTime(timezone=True), default=datetime.datetime.utcnow)
