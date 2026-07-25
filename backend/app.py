from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import io
import os
from datetime import datetime
from dotenv import load_dotenv
from flask_sqlalchemy import SQLAlchemy

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

# Apply CORS to allow cross-origin requests from the frontend
CORS(app, resources={r"/*": {"origins": "*"}})

# --- SUPABASE DATABASE CONFIGURATION ---
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# Define the table structure for Supabase PostgreSQL
class AuditHistory(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    filename = db.Column(db.String(255))
    total_analyzed = db.Column(db.Integer)
    risk_profile = db.Column(db.String(50))
    findings_count = db.Column(db.Integer, default=0)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            "id": self.id,
            "filename": self.filename,
            "total_analyzed": self.total_analyzed,
            "risk_profile": self.risk_profile,
            "findings_count": self.findings_count,
            "created_at": self.created_at.isoformat() if self.created_at else None
        }

# Create the table if it doesn't exist yet
with app.app_context():
    try:
        db.create_all()
        print("[Supabase DB] Tables verified/created successfully.")
    except Exception as db_init_err:
        print(f"[Supabase DB Warning] Table creation skipped on startup: {db_init_err}")
# ---------------------------------------

@app.route('/', methods=['GET'])
def home():
    return jsonify({
        "status": "online",
        "message": "The FairHire API (Supabase PostgreSQL powered) is running successfully!"
    }), 200

@app.route('/audits', methods=['GET'])
def get_audits():
    """Returns a list of all historical bias audits stored in Supabase PostgreSQL."""
    try:
        audits = AuditHistory.query.order_by(AuditHistory.created_at.desc()).all()
        return jsonify({
            "status": "success",
            "count": len(audits),
            "audits": [audit.to_dict() for audit in audits]
        }), 200
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": f"Failed to retrieve audit history: {str(e)}"
        }), 500

@app.route('/audits/<int:audit_id>', methods=['GET'])
def get_audit(audit_id):
    """Returns details for a specific historical audit from Supabase PostgreSQL."""
    try:
        audit = AuditHistory.query.get(audit_id)
        if not audit:
            return jsonify({"status": "error", "message": f"Audit {audit_id} not found"}), 404
        return jsonify({
            "status": "success",
            "audit": audit.to_dict()
        }), 200
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": f"Failed to retrieve audit {audit_id}: {str(e)}"
        }), 500

@app.route('/audit', methods=['POST'])
def audit():
    """
    Endpoint to receive a CSV file, analyze it for bias, 
    and return a structured audit report with AI-remediation steps.
    """
    
    # 1. Validate File Upload
    if 'file' not in request.files:
        return jsonify({"error": "No file part in the request"}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No file selected for upload"}), 400

    if not file.filename.lower().endswith('.csv'):
        return jsonify({"error": "Invalid file format. Please upload a CSV file."}), 400

    try:
        # 2. Load CSV into a Pandas DataFrame
        stream = io.StringIO(file.stream.read().decode("UTF8"), newline=None)
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
            "filename": file.filename,
            "total_candidates_analyzed": len(df),
            "overall_risk_profile": "High" if any(f['severity_score'] > 7 for f in findings) else "Moderate",
            "bias_fingerprint": radar_data, # For Radar/Spider Chart visualization
            "findings": final_findings
        }

        # 7. Save the audit summary to Supabase PostgreSQL
        try:
            new_audit = AuditHistory(
                filename=file.filename,
                total_analyzed=len(df),
                risk_profile=audit_report["overall_risk_profile"],
                findings_count=len(final_findings)
            )
            db.session.add(new_audit)
            db.session.commit()
            audit_report["audit_id"] = new_audit.id
        except Exception as db_err:
            db.session.rollback()
            print(f"[Supabase DB Warning] Could not persist audit summary: {db_err}")

        return jsonify(audit_report), 200

    except Exception as e:
        # Catch errors such as parsing failures or missing columns in the CSV
        return jsonify({
            "status": "error",
            "message": f"Audit failed: {str(e)}"
        }), 500

# Entry point for running the application
if __name__ == '__main__':
    # Run the Flask development server
    app.run(host='0.0.0.0', port=5000, debug=True)

