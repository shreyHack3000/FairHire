import random

def get_severity_label(score):
    """Maps a numeric score to a CVSS-style severity label."""
    if 0 <= score <= 3:
        return "Low"
    elif 3 < score <= 6:
        return "Medium"
    elif 6 < score <= 8:
        return "High"
    elif 8 < score <= 10:
        return "Critical"
    return "Unknown"

def generate_cve_id():
    """Generates a pseudo-CVE ID for the bias finding."""
    return f"IN-BIAS-2025-{random.randint(1000, 9999)}"

def create_findings_report(college_res, name_res, location_res):
    """
    Consolidates individual bias result dictionaries into a structured audit report.
    Also generates data for the 'Bias Fingerprint' radar chart.
    """
    
    # Define the bias categories and their respective result sources
    # college_res, name_res, location_res are expected to be dicts: {"score": X, "ratio": Y, "evidence": Z}
    bias_configs = [
        {
            "id": "college",
            "title": "Institutional Pedigree Bias",
            "results": college_res,
            "parameter": "College Tier / University Name"
        },
        {
            "id": "name",
            "title": "Socio-Cultural Identity Bias",
            "results": name_res,
            "parameter": "Candidate Full Name"
        },
        {
            "id": "location",
            "title": "Geographic Access Bias",
            "results": location_res,
            "parameter": "Candidate Current City"
        }
    ]
    
    findings = []
    radar_chart_data = {}
    
    for config in bias_configs:
        res = config["results"]
        score = res.get("score", 0.0)
        
        finding = {
            "cve_id": generate_cve_id(),
            "title": config["title"],
            "severity_score": score,
            "severity_label": get_severity_label(score),
            "affected_parameter": config["parameter"],
            "evidence": res.get("evidence", "Statistical variance detected."),
            "disparity_ratio": res.get("ratio", 1.0)
        }
        findings.append(finding)
        
        # Populate radar chart values (0-10 scale)
        radar_chart_data[config["title"]] = score
        
    return findings, radar_chart_data

# --- Example Usage ---
if __name__ == "__main__":
    # Test scores
    report = create_findings_report(8.5, 4.2, 2.0)
    
    print("--- Bias Audit Findings Report ---")
    for item in report:
        print(f"[{item['cve_id']}] {item['title']} - {item['severity_label']} ({item['severity_score']})")
        print(f"   Parameter: {item['affected_parameter']}")
        print(f"   Ratio: {item['disparity_ratio']}")
        print("-" * 40)
