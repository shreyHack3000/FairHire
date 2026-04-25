from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import io
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Import custom bias detection and scoring modules
from engine.college_tiers import detect_college_bias
from engine.name_bias import detect_name_bias
from engine.location_bias import detect_location_bias
from engine.cvss_scorer import create_findings_report
from gemini.explainer import generate_batch_recommendations

# Initialize the Flask application
app = Flask(__name__)

CORS(app)

@app.route('/', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy", "service": "FairHire Backend"}), 200

@app.route('/audit', methods=['POST'])
def audit():
    """
    Endpoint to receive a CSV file, analyze it for bias, 
    and return a structured audit report with AI-remediation steps.
    """
    
    try:
        # 1. Validate File Upload
        if 'file' in request.files:
            file = request.files['file']
            if file.filename == '':
                return jsonify({"error": "No file selected for upload"}), 400
            if not file.filename.lower().endswith('.csv'):
                return jsonify({"error": "Invalid file format."}), 400
            stream = io.StringIO(file.stream.read().decode("UTF8"), newline=None)
            filename = file.filename
        elif request.is_json:
            data = request.get_json()
            if 'file_b64' in data:
                import base64
                decoded_bytes = base64.b64decode(data['file_b64'])
                stream = io.StringIO(decoded_bytes.decode("UTF8"), newline=None)
                filename = data.get('filename', 'upload.csv')
            else:
                return jsonify({"error": "No file data in JSON"}), 400
        else:
            return jsonify({"error": "Invalid request format. Send multipart or JSON."}), 400

        # 2. Load CSV into a Pandas DataFrame
        df = pd.read_csv(stream)
        
        # --- Normalization Logic ---
        # Normalize column names: strip whitespace, lowercase, and replace spaces with underscores
        df.columns = df.columns.str.strip().str.lower().str.replace(' ', '_')
        
        # Ensure 'selected' column is mapped to 'status' for internal engine consistency
        if 'selected' in df.columns:
            df.rename(columns={'selected': 'status'}, inplace=True)
        # ---------------------------

        # 3. Execute Bias Detection Modules
        # Each function now returns a dictionary: {"score": X, "ratio": Y, "evidence": "Z"}
        college_results = detect_college_bias(df)
        name_results = detect_name_bias(df)
        location_results = detect_location_bias(df)
        
        # 4. Generate Structured Findings (CVSS-style)
        # Pass the full result dictionaries to the scorer
        findings, radar_data = create_findings_report(college_results, name_results, location_results)
        
        # 5. Enhance Findings with Batched AI Recommendations (Gemini)
        # Instead of calling API per finding, we bundle them into ONE request
        batch_insights = generate_batch_recommendations(findings)
        
        final_findings = []
        for finding in findings:
            cve_id = finding.get('cve_id')
            # Fetch specific insight from the batched response using the CVE ID
            ai_recommendation = batch_insights.get(cve_id, {
                'explanation': 'Additional insight being computed.',
                'fix': 'Contact administrator.',
                'confidence_percent': 50,
                'effort_level': 'Low'
            })
            
            merged_finding = {**finding, "ai_insight": ai_recommendation}
            final_findings.append(merged_finding)
        
        # 6. Construct Final Audit Response
        audit_report = {
            "status": "success",
            "filename": filename,
            "total_candidates_analyzed": len(df),
            "overall_risk_profile": "High" if any(f['severity_score'] > 7 for f in findings) else "Moderate",
            "bias_fingerprint": radar_data, # For Radar/Spider Chart visualization
            "findings": final_findings
        }

        return jsonify(audit_report), 200

    except Exception as e:
        # Catch errors such as parsing failures or missing columns in the CSV
        return jsonify({
            "status": "error",
            "message": f"Audit failed: {str(e)}"
        }), 500

# Entry point for running the application
if __name__ == '__main__':
    # Use PORT from environment variable (default 8080 for Cloud Run)
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
