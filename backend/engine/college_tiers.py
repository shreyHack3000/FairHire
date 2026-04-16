import pandas as pd
import numpy as np

# Dictionary defining college tiers for bias detection
TIER_1 = [
    "IIT Delhi", "IIT Bombay", "IIT Madras", "IIT Kanpur", "IIT Kharagpur", 
    "IIT Roorkee", "IIT Guwahati", "NIT Trichy", "BITS Pilani", "IIT BHU"
]

TIER_2 = [
    "DTU", "VIT", "SRM", "Manipal", "NSIT", "IIIT Hyderabad", 
    "NIT Surathkal", "NIT Warangal", "BITS Hyderabad", "BITS Goa"
]

def map_tier(college_name):
    """ Helper function to map a college name to its corresponding tier. Case-insensitive. """
    if not isinstance(college_name, str):
        return "Tier 3"
        
    college_clean = college_name.strip().lower()
    
    # Check against lowercase lists
    if any(c.lower() == college_clean for c in TIER_1):
        return "Tier 1"
    elif any(c.lower() == college_clean for c in TIER_2):
        return "Tier 2"
    else:
        return "Tier 3"

def detect_college_bias(df):
    """
    Analyzes a DataFrame for hiring bias based on college tiers.
    Returns:
    - Dictionary: {"score": float, "ratio": float, "evidence": str}
    """
    
    # 1. Map each candidate's college to a tier
    df = df.copy()
    df['tier'] = df['college'].apply(map_tier)
    
    # 2. Group candidates by tier and calculate selection rate
    stats = df.groupby('tier')['status'].agg(['mean', 'count']).rename(columns={'mean': 'selection_rate'})
    
    tier_1_rate = stats.loc['Tier 1', 'selection_rate'] if 'Tier 1' in stats.index else 0
    tier_3_rate = stats.loc['Tier 3', 'selection_rate'] if 'Tier 3' in stats.index else 0
    
    # Calculate Disparity Ratio
    if tier_3_rate == 0:
        disparity_ratio = 10.0 if tier_1_rate > 0 else 1.0
    else:
        disparity_ratio = tier_1_rate / tier_3_rate
    
    # Calculate severity score (0 to 10)
    severity_score = min(10, max(0, (disparity_ratio - 1) * 2.5))
    
    # Construct descriptive evidence
    evidence = (f"Candidates from Tier 1 colleges are selected at a rate of {tier_1_rate:.1%}, "
                f"while Tier 3 candidates are selected at {tier_3_rate:.1%}. "
                f"This results in a disparity ratio of {disparity_ratio:.1f}x.")

    return {
        "score": round(float(severity_score), 2),
        "ratio": round(float(disparity_ratio), 2),
        "evidence": evidence
    }

# --- Example Usage (Manual Test) ---
if __name__ == "__main__":
    # Mock data
    data = {
        'college': ['IIT Delhi', 'IIT Bombay', 'DTU', 'SRM', 'Local College A', 'Local College B'] * 10,
        'status': [1, 1, 1, 0, 0, 0] * 10  # Tier 1 high selection, Tier 3 zero selection in this mock
    }
    sample_df = pd.DataFrame(data)
    
    score = detect_college_bias(sample_df)
    print(f"Detected College Bias Severity Score: {score}/10")
