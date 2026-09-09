import pytest
import app.adaptive_engine
from app.adaptive_engine import expected_success, update_theta_elo, select_items

def test_expected_success():
    # Equal theta and difficulty -> expected success should be exactly 50% (0.5)
    assert expected_success(theta=0.0, difficulty=0.0) == 0.5
    assert expected_success(theta=1.5, difficulty=1.5) == 0.5
    
    # Higher ability should give success rate > 0.5
    assert expected_success(theta=1.0, difficulty=0.0) > 0.5
    
    # Lower ability should give success rate < 0.5
    assert expected_success(theta=-1.0, difficulty=0.0) < 0.5
    
    # Extreme conditions (bound overflow handling checks)
    assert expected_success(theta=100.0, difficulty=-100.0) == pytest.approx(1.0)
    assert expected_success(theta=-100.0, difficulty=100.0) == pytest.approx(0.0)

def test_update_theta_elo_correct_answer(monkeypatch):
    # Set K_FACTOR to a small value to avoid boundary clipping during tests
    monkeypatch.setattr(app.adaptive_engine, "K_FACTOR", 1.0)
    theta_initial = 0.0
    # Correct answer -> theta should increase
    theta_new = update_theta_elo(theta=theta_initial, difficulty=0.0, is_correct=True)
    assert theta_new > theta_initial
    assert theta_new < 3.0

def test_update_theta_elo_incorrect_answer(monkeypatch):
    monkeypatch.setattr(app.adaptive_engine, "K_FACTOR", 1.0)
    theta_initial = 0.0
    # Incorrect answer -> theta should decrease
    theta_new = update_theta_elo(theta=theta_initial, difficulty=0.0, is_correct=False)
    assert theta_new < theta_initial
    assert theta_new > -3.0

def test_update_theta_elo_partial_score(monkeypatch):
    monkeypatch.setattr(app.adaptive_engine, "K_FACTOR", 1.0)
    theta_initial = 0.0
    # Partial score (0.75) should adjust theta differently than absolute correct/incorrect
    theta_partial = update_theta_elo(theta=theta_initial, difficulty=0.0, is_correct=True, partial_score=0.75)
    theta_full = update_theta_elo(theta=theta_initial, difficulty=0.0, is_correct=True, partial_score=1.0)
    
    assert theta_partial > theta_initial
    assert theta_partial < theta_full

def test_update_theta_elo_hint_penalty(monkeypatch):
    monkeypatch.setattr(app.adaptive_engine, "K_FACTOR", 1.0)
    theta_initial = 0.0
    # More hints should reduce the magnitude of the theta update (k-factor penalty)
    theta_no_hints = update_theta_elo(theta=theta_initial, difficulty=0.0, is_correct=True, hint_count=0)
    theta_one_hint = update_theta_elo(theta=theta_initial, difficulty=0.0, is_correct=True, hint_count=1)
    theta_two_hints = update_theta_elo(theta=theta_initial, difficulty=0.0, is_correct=True, hint_count=2)
    
    delta_no_hints = theta_no_hints - theta_initial
    delta_one_hint = theta_one_hint - theta_initial
    delta_two_hints = theta_two_hints - theta_initial
    
    assert delta_one_hint < delta_no_hints
    assert delta_two_hints < delta_one_hint

def test_select_items():
    items = [
        {"id": "item1", "difficulty": -1.5, "discrimination": 1.0}, # Very easy
        {"id": "item2", "difficulty": -0.5, "discrimination": 1.0}, # Easy
        {"id": "item3", "difficulty": 0.5, "discrimination": 1.0},  # Medium
        {"id": "item4", "difficulty": 1.5, "discrimination": 1.0},  # Hard
    ]
    
    # For a high ability user (theta = 1.5), item3 (difficulty 0.5) is closer to the 75% target success probability
    # compared to item4 (difficulty 1.5) which has exactly 50% success probability.
    selected_high = select_items(theta=1.5, available_items=items, seen_this_week=set(), count=2)
    assert len(selected_high) == 2
    # item3 should be first because distance to target 0.75 is smaller
    assert selected_high[0]["id"] == "item3"
    
    # For a low ability user (theta = -1.5), item1 (difficulty -1.5) has expected success rate of 50% (distance = 0.25),
    # which is closer to the 75% target than item2 (difficulty -0.5) which is 15.4% (distance = 0.596).
    selected_low = select_items(theta=-1.5, available_items=items, seen_this_week=set(), count=2)
    assert len(selected_low) == 2
    assert selected_low[0]["id"] == "item1"

def test_select_items_freshness():
    items = [
        {"id": "item1", "difficulty": 0.0, "discrimination": 1.0},
        {"id": "item2", "difficulty": 0.0, "discrimination": 1.0},
    ]
    # If item1 was seen this week, item2 should rank higher (freshness bonus)
    selected = select_items(theta=0.0, available_items=items, seen_this_week={"item1"}, count=2)
    assert selected[0]["id"] == "item2"
