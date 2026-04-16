import os
import json
from google import genai

# Ordered list of models to try — verified working on free tier (April 2026)
GEMINI_MODELS = [
    'gemini-2.5-flash-lite',
    'gemini-3-flash-preview',
    'gemini-3.1-flash-lite-preview',
    'gemini-2.0-flash',
]

def generate_batch_recommendations(findings_list):
    """
    Sends all bias findings to Gemini in a single request (Request Bundling).
    Returns a dictionary mapping CVE IDs to their specific AI insights.
    Tries multiple models in order until one works.
    """
    api_key = os.getenv('GEMINI_API_KEY')
    
    if not api_key or "your_gemini_api_key_here" in api_key.lower() or api_key.strip() == "":
        # Return generic insights for all if key is missing
        return {f.get('cve_id'): {
            'explanation': 'MISSING API KEY: AI-powered remediation is unavailable.',
            'fix': 'Please add your GEMINI_API_KEY to the .env file.',
            'confidence_percent': 0, 'effort_level': 'N/A'
        } for f in findings_list}

    # Strip any whitespace from the key
    api_key = api_key.strip()

    # Build a consolidated prompt for all findings (done once, reused for retries)
    findings_str = ""
    for i, f in enumerate(findings_list):
        findings_str += f"\nFinding {i+1} [ID: {f.get('cve_id')}]:\n"
        findings_str += f"- Title: {f.get('title')}\n"
        findings_str += f"- Affected Parameter: {f.get('affected_parameter')}\n"
        findings_str += f"- Evidence: {f.get('evidence')}\n"

    prompt = f"""
    Analyze the following {len(findings_list)} bias findings from an Indian hiring audit:
    {findings_str}

    For EACH finding, generate a professional remediation plan.
    Return your response as a single JSON object where:
    - The Keys are the exact [ID: ...] from above (e.g. IN-BIAS-2025-XXXX).
    - The Values are objects with: explanation, fix, confidence_percent, effort_level.

    Return ONLY raw JSON. No markdown. No backticks. No extra text.
    """

    client = genai.Client(api_key=api_key)

    # Try each model in order until one succeeds
    last_error = None
    for model_name in GEMINI_MODELS:
        try:
            print(f"[Gemini] Trying model: {model_name}...")
            response = client.models.generate_content(
                model=model_name,
                contents=prompt
            )
            
            # Sanitize and Parse
            text = response.text.strip()
            if text.startswith("```"):
                lines = text.splitlines()
                text = "".join([l for l in lines if not l.strip().startswith("```")])
                if text.lower().startswith("json"):
                    text = text[4:]
            
            result = json.loads(text)
            print(f"[Gemini] Success with model: {model_name}")
            return result
            
        except Exception as e:
            last_error = str(e)
            error_lower = last_error.lower()
            print(f"[Gemini] Model {model_name} failed: {last_error[:150]}")
            
            # If it's a key-level issue (invalid key), don't bother trying other models
            if "api_key_invalid" in error_lower or "api key not valid" in error_lower:
                print("[Gemini] API key is invalid. Skipping remaining models.")
                break
            
            # For quota/rate issues, continue to next model
            continue

    # All models failed — return intelligent fallback
    print(f"[Gemini] All models exhausted. Returning rule-based recommendations.")
    return _generate_rule_based_recommendations(findings_list)


def _generate_rule_based_recommendations(findings_list):
    """
    Generates useful remediation recommendations without AI,
    based on the type of bias detected. This ensures the app
    always returns actionable results even when the API is unavailable.
    """
    rule_map = {
        "institutional pedigree bias": {
            'explanation': 'The hiring process shows a strong preference for candidates from top-tier institutions. '
                           'This can exclude equally qualified candidates from lesser-known colleges who may '
                           'bring diverse perspectives and problem-solving approaches.',
            'fix': 'Implement a blind screening process that hides college names during initial evaluation. '
                   'Focus on skill-based assessments, coding challenges, and portfolio reviews instead of institutional reputation. '
                   'Set a minimum diversity threshold for interview shortlists.',
            'confidence_percent': 85,
            'effort_level': 'Medium'
        },
        "socio-cultural identity bias": {
            'explanation': 'Name-based analysis reveals a statistically significant disparity in selection rates '
                           'between different cultural groups. This suggests unconscious bias may be influencing '
                           'hiring decisions at the resume screening stage.',
            'fix': 'Anonymize candidate names during the initial screening phase. Use unique candidate IDs instead. '
                   'Train hiring managers on unconscious bias recognition. Consider implementing structured '
                   'interviews with standardized scoring rubrics.',
            'confidence_percent': 82,
            'effort_level': 'Low'
        },
        "geographic access bias": {
            'explanation': 'Candidates from metro cities are significantly more likely to be selected compared to '
                           'those from smaller cities or rural areas. This may reflect assumptions about candidate '
                           'quality based on location rather than actual competence.',
            'fix': 'Offer remote interviews and remote work options to level the playing field. '
                   'Remove location as a visible field during screening. Evaluate candidates based on skills '
                   'and experience, not proximity to corporate offices. Consider relocation assistance programs.',
            'confidence_percent': 80,
            'effort_level': 'Medium'
        }
    }
    
    result = {}
    for f in findings_list:
        title_lower = f.get('title', '').lower()
        
        # Find matching rule
        matched = None
        for key, value in rule_map.items():
            if key in title_lower:
                matched = value
                break
        
        if not matched:
            matched = {
                'explanation': 'Statistical analysis reveals a significant disparity in selection rates. '
                               'This bias pattern should be investigated and addressed through policy changes.',
                'fix': 'Conduct a detailed review of the hiring pipeline. Implement structured interviews, '
                       'blind screening, and diversity targets to mitigate the detected bias.',
                'confidence_percent': 75,
                'effort_level': 'Medium'
            }
        
        # Add a note that this is rule-based
        insight = matched.copy()
        insight['source'] = 'rule-based (AI unavailable - quota exhausted)'
        result[f.get('cve_id')] = insight
    
    return result
