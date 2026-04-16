import pandas as pd

# Lists of names categorized by cultural background for bias detection
MUSLIM_NAMES = [
    "Mohammad", "Rizwan", "Fatima", "Ali", "Ayesha", "Zaid", "Sana", "Imran", 
    "Hassan", "Zoya", "Hamza", "Mariam", "Saif", "Sara", "Mustafa", "Noor"
]

HINDU_NAMES = [
    "Rahul", "Priya", "Amit", "Pooja", "Arjun", "Anjali", "Suresh", "Neha", 
    "Vikram", "Kavita", "Rohan", "Deepika", "Kiran", "Aditi", "Manish", "Sunita"
]

def classify_name(name):
    """
    Helper function to classify a name into a cultural group.
    Supports full names by checking each token (e.g., first/last name).
    """
    if not isinstance(name, str):
        return "Other"
    
    # Split name into tokens (e.g., "Rahul Verma" -> ["Rahul", "Verma"])
    tokens = [t.strip().lower() for t in name.split()]
    
    # Check if any token exists in our predefined lists (case-insensitive)
    for token in tokens:
        if any(m_name.lower() == token for m_name in MUSLIM_NAMES):
            return "Muslim"
        if any(h_name.lower() == token for h_name in HINDU_NAMES):
            return "Hindu"
            
    return "Other"

def detect_name_bias(df):
    """
    Analyzes a DataFrame for hiring bias based on cultural groups inferred from names.
    Returns:
    - Dictionary: {"score": float, "ratio": float, "evidence": str}
    """
    df = df.copy()
    
    # 1. Map names to groups
    # Using 'name' column (normalized in app.py)
    df['group'] = df['name'].apply(classify_name)
    
    # 2. Filter for comparison groups
    comparison_df = df[df['group'].isin(['Muslim', 'Hindu'])]
    
    if comparison_df.empty:
        return {"score": 0.0, "ratio": 1.0, "evidence": "No recognizable name-based patterns found in dataset."}

    # 3. Calculate selection rates
    stats = comparison_df.groupby('group')['status'].mean()
    counts = comparison_df.groupby('group')['status'].count()
    
    rate_muslim = stats.get('Muslim', 0)
    rate_hindu = stats.get('Hindu', 0)
    
    # Calculate Disparity 
    max_rate = max(rate_muslim, rate_hindu)
    min_rate = min(rate_muslim, rate_hindu)
    
    if max_rate == 0:
        disparity_ratio = 1.0
    else:
        # Relative disparity ratio
        disparity_ratio = max_rate / max(0.01, min_rate) # avoid div by zero
        
    # Severity score calculation
    severity_score = min(10, (max_rate - min_rate) * 20) if max_rate > 0 else 0
    
    # Construct evidence
    evidence = (f"Analysis of names reveals that candidates in the '{'Hindu' if rate_hindu > rate_muslim else 'Muslim'}' "
                f"group were selected at {max(rate_muslim, rate_hindu):.1%}, compared to "
                f"{min(rate_muslim, rate_hindu):.1%} for the other group. "
                f"Total candidates classified: {len(comparison_df)}.")

    return {
        "score": round(float(severity_score), 2),
        "ratio": round(float(disparity_ratio), 2),
        "evidence": evidence
    }

# --- Example Usage ---
if __name__ == "__main__":
    # Mock data showing a slight bias
    data = {
        'name': ['Mohammad', 'Rizwan', 'Rahul', 'Priya', 'Amit', 'Fatima', 'Suresh', 'Anjali'],
        'status': [0, 1, 1, 1, 1, 0, 1, 1] # Muslim: 1/3 (33%), Hindu: 5/5 (100%)
    }
    sample_df = pd.DataFrame(data)
    
    try:
        score = detect_name_bias(sample_df)
        print(f"Name Bias Severity Score: {score}/10")
    except Exception as e:
        print(f"Error: {e}")
