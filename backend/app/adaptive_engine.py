import math
from typing import List, Dict, Any, Union, Set

K_FACTOR = 32.0
THETA_MIN = -3.0
THETA_MAX = 3.0
TARGET_SUCCESS_RATE = 0.75

def expected_success(theta: float, difficulty: float, discrimination: float = 1.0) -> float:
    """2-Parameter Logistic IRT model calculation."""
    try:
        # Prevent overflow errors in math.exp
        exponent = -1.702 * discrimination * (theta - difficulty)
        if exponent > 700:
            return 0.0
        elif exponent < -700:
            return 1.0
        return 1.0 / (1.0 + math.exp(exponent))
    except OverflowError:
        return 0.0 if (theta - difficulty) < 0 else 1.0

def update_theta_elo(
    theta: float,
    difficulty: float,
    is_correct: bool,
    partial_score: float = None,
    hint_count: int = 0
) -> float:
    """Updates ability estimate (theta) using Elo algorithm with hint penalty adjustment."""
    expected = expected_success(theta, difficulty)
    
    # Calculate response outcome
    if partial_score is not None:
        outcome = partial_score
    else:
        outcome = 1.0 if is_correct else 0.0
        
    # Apply hint penalty (15% reduction in learning rate per hint)
    k_adjusted = K_FACTOR * max(0.0, 1.0 - (hint_count * 0.15))
    
    new_theta = theta + k_adjusted * (outcome - expected)
    return max(THETA_MIN, min(THETA_MAX, new_theta))

def select_items(
    theta: float,
    available_items: List[Any],
    seen_this_week: Set[str],
    count: int = 10
) -> List[Any]:
    """
    Selects items targeting 75% success rate.
    Scores items using Fisher Information + freshness bonus - distance to target success probability.
    Supports both SQLAlchemy ORM objects and dictionaries.
    """
    scored = []
    for item in available_items:
        # Access attributes dynamically (support both Dict and ORM objects)
        if isinstance(item, dict):
            item_id = str(item.get("id", ""))
            difficulty = float(item.get("difficulty", 0.0))
            discrimination = float(item.get("discrimination", 1.0))
        else:
            item_id = str(getattr(item, "id", ""))
            difficulty = float(getattr(item, "difficulty", 0.0))
            discrimination = float(getattr(item, "discrimination", 1.0))
            
        p = expected_success(theta, difficulty, discrimination)
        
        # Fisher Information metric
        information = (discrimination ** 2) * p * (1.0 - p)
        
        # Freshness bonus to prevent repeating items seen this week
        freshness = 0.3 if item_id not in seen_this_week else 0.0
        
        # Absolute distance from the 75% success target probability
        distance = abs(p - TARGET_SUCCESS_RATE)
        
        # Total scoring value (higher is better)
        score = information + freshness - distance
        scored.append((score, item))
        
    # Sort descending by score
    scored.sort(key=lambda x: x[0], reverse=True)
    return [item for _, item in scored[:count]]
