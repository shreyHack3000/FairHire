import os
import json
import requests

# Ordered list of models to try
GEMINI_MODELS = [
    'gemini-1.5-flash',
    'gemini-1.5-pro',
]

def generate_batch_recommendations(findings_list):
    """
    Sends all bias findings to Gemini in a single request using REST API.
    """
    api_key = os.getenv('GEMINI_API_KEY')
    
    if not api_key or api_key.strip() == "":
        return _generate_rule_based_recommendations(findings_list)

    api_key = api_key.strip()

    # Build a consolidated prompt
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
    - The Keys are the exact [ID: ...] from above.
    - The Values are objects with: explanation, fix, confidence_percent, effort_level.

    Return ONLY raw JSON. No markdown.
    """

    for model_name in GEMINI_MODELS:
        try:
            print(f"[Gemini REST] Trying model: {model_name}...")
            url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={api_key}"
            
            payload = {
                "contents": [{
                    "parts": [{"text": prompt}]
                }]
            }
            
            response = requests.post(url, json=payload, timeout=30)
            
            if response.status_code == 200:
                data = response.json()
                text = data['candidates'][0]['content']['parts'][0]['text'].strip()
                
                # Basic JSON cleaning
                if text.startswith("```"):
                    text = text.split("```")[1]
                    if text.startswith("json"):
                        text = text[4:]
                
                print(f"[Gemini REST] Success with {model_name}")
                return json.loads(text.strip())
            else:
                print(f"[Gemini REST] {model_name} failed with status {response.status_code}")
                
        except Exception as e:
            print(f"[Gemini REST] Error with {model_name}: {str(e)}")
            continue

    return _generate_rule_based_recommendations(findings_list)

def _generate_rule_based_recommendations(findings_list):
    # (Keeping the existing fallback logic for safety)
    rule_map = {
        "institutional pedigree bias": {
            'explanation': 'Preference for Tier 1 institutions excludes diverse talent pools.',
            'fix': 'Implement blind screening and focus on skill-based assessments.',
            'confidence_percent': 85, 'effort_level': 'Medium'
        },
        "socio-cultural identity bias": {
            'explanation': 'Name-based disparity suggests unconscious bias in screening.',
            'fix': 'Anonymize names during initial screening and use structured scorecards.',
            'confidence_percent': 82, 'effort_level': 'Low'
        },
        "geographic access bias": {
            'explanation': 'Candidates from non-metro areas are being penalized by location.',
            'fix': 'Offer remote interviews and remove location filters from screening.',
            'confidence_percent': 80, 'effort_level': 'Medium'
        }
    }
    result = {}
    for f in findings_list:
        title_lower = f.get('title', '').lower()
        matched = next((v for k, v in rule_map.items() if k in title_lower), {
            'explanation': 'Statistical disparity detected in selection rates.',
            'fix': 'Review hiring pipeline and implement structured interview rubrics.',
            'confidence_percent': 75, 'effort_level': 'Medium'
        })
        result[f.get('cve_id')] = matched
    return result
