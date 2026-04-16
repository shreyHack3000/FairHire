import pandas as pd

# Lists defining Indian city categories for bias detection
METRO = [
    "Delhi", "Mumbai", "Bangalore", "Chennai", "Hyderabad", "Pune", 
    "Kolkata", "Ahmedabad", "Gurgaon", "Noida"
]

TIER_2_CITY = [
    "Jaipur", "Lucknow", "Nagpur", "Indore", "Bhopal", "Chandigarh", 
    "Kochi", "Patna", "Coimbatore", "Vadodara", "Visakhapatnam", "Surat"
]

def map_location_tier(city_name):
    """ Helper to map a city name to its category. """
    if not isinstance(city_name, str):
        return "Tier 3"
    
    city_clean = city_name.strip().title()
    if city_clean in METRO:
        return "Metro"
    elif city_clean in TIER_2_CITY:
        return "Tier 2"
    else:
        return "Tier 3"

def detect_location_bias(df):
    """
    Analyzes a DataFrame for hiring bias based on the candidate's location tier.
    Returns:
    - Dictionary: {"score": float, "ratio": float, "evidence": str}
    """
    df = df.copy()
    
    # 1. Map locations to tiers
    # Using 'city' column (normalized in app.py)
    df['loc_tier'] = df['city'].apply(map_location_tier)
    
    # 2. Calculate selection rates per tier
    stats = df.groupby('loc_tier')['status'].mean()
    
    rate_metro = stats.get('Metro', 0)
    rate_tier3 = stats.get('Tier 3', 0)
    
    # 3. Calculate Disparity between Metro and Tier 3
    if rate_tier3 == 0:
        disparity_ratio = 10.0 if rate_metro > 0 else 1.0
    else:
        disparity_ratio = rate_metro / rate_tier3

    # 4. Map disparity to a 0-10 severity score
    severity_score = min(10, max(0, (disparity_ratio - 1) * 2.5))
    
    # Construct evidence
    evidence = (f"Candidates from Metro cities are selected at a rate of {rate_metro:.1%}, "
                f"while Tier 3 city candidates are selected at {rate_tier3:.1%}. "
                f"Location disparity ratio: {disparity_ratio:.1f}x.")

    return {
        "score": round(float(severity_score), 2),
        "ratio": round(float(disparity_ratio), 2),
        "evidence": evidence
    }

# --- Example Usage ---
if __name__ == "__main__":
    # Mock data showing preference for Metro candidates
    data = {
        'city': ['Bangalore', 'Mumbai', 'Delhi', 'Jaipur', 'Lucknow', 'Small Village A', 'Small Village B'],
        'status': [1, 1, 1, 0, 1, 0, 0] # Metro: 3/3 (100%), Tier 3: 0/2 (0%)
    }
    sample_df = pd.DataFrame(data)
    
    try:
        score = detect_location_bias(sample_df)
        print(f"Location Bias Severity Score: {score}/10")
    except Exception as e:
        print(f"Error: {e}")
