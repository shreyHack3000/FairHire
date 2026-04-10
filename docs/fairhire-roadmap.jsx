import { useState } from "react";

const PHASES = [
  {
    id: 1,
    code: "P1",
    title: "Foundation",
    subtitle: "Skeleton is alive",
    days: "Apr 9–10",
    emoji: "🏗",
    color: "#2563EB",
    light: "#DBEAFE",
    capability: "At the end of this phase: GitHub repo exists, Firebase project is live, Flutter app opens in browser, sample CSV is ready. Nothing works together yet — but every person has something to build on.",
    persons: [
      {
        id: "A",
        name: "Person A",
        role: "Backend Lead",
        tasks: [
          {
            title: "Create GitHub repo + project structure",
            purpose: "Central source of truth for all 4 people. Without this nothing can be shared or merged. Every other task in Phase 1 depends on this existing first.",
            steps: [
              "Create repo named 'FairHire' on GitHub (set to PUBLIC)",
              "Push folder structure: /backend, /flutter_app, /data, /report_template, README.md",
              "Add all 4 teammates as collaborators (Settings → Collaborators)",
              "Create branches: main, dev, person-b, person-c, person-d",
              "Everyone clones their own branch on Day 1"
            ],
            connects: "Person B, C, D all clone from this repo on Day 1. All code merges here.",
            requirements: "Git installed, GitHub account",
            tips: "Use Antigravity to auto-generate the README.md structure. Commit message convention: feat/fix/docs prefix. Everyone pushes to their own branch, Person A reviews and merges to dev daily."
          },
          {
            title: "Obtain Gemini API key",
            purpose: "Person D needs this on Day 3 to build the fix recommendation prompt. Getting it now avoids blocking the AI integration later.",
            steps: [
              "Go to aistudio.google.com",
              "Sign in with Google account → Create new API key",
              "Copy the key immediately",
              "Add to backend/.env as GEMINI_API_KEY=your_key_here",
              "Add .env to .gitignore immediately — never commit this"
            ],
            connects: "Person D uses this key when building Gemini prompts in Phase 2.",
            requirements: "Google account, aistudio.google.com access",
            tips: "Free tier gives 60 requests/min — more than enough for demo. Share the key with teammates via private message only, never GitHub. The free tier is plenty — don't pay for anything."
          },
          {
            title: "Python environment + Flask skeleton",
            purpose: "Set up the development environment so Phase 2 backend work can start immediately on Day 3 without setup friction.",
            steps: [
              "Create /backend folder in the repo",
              "python -m venv venv && source venv/bin/activate",
              "pip install flask pandas google-generativeai python-dotenv flask-cors",
              "pip freeze > requirements.txt",
              "Create app.py with a basic Flask hello-world POST /audit route that returns mock JSON",
              "Test: python app.py → curl -X POST localhost:5000/audit"
            ],
            connects: "This is the engine Person C's Flutter app will call in Phase 3. Mock JSON output unblocks Person C immediately.",
            requirements: "Python 3.11+, pip",
            tips: "Use Antigravity: 'Create a Flask project with a /audit POST endpoint skeleton that accepts a multipart CSV file and returns a hardcoded mock JSON bias report'. Get the mock running first — real logic comes in Phase 2."
          }
        ]
      },
      {
        id: "B",
        name: "Person B",
        role: "Firebase + DevOps",
        tasks: [
          {
            title: "Firebase project setup",
            purpose: "Firebase is the backbone — Auth, database, and file storage all in one SDK. Every other person is blocked until this exists and the config files are shared.",
            steps: [
              "Go to console.firebase.google.com → Create project 'fairhire-app'",
              "Enable Authentication → Email/Password provider",
              "Enable Firestore Database → Start in test mode",
              "Enable Cloud Storage → Start in test mode",
              "Download google-services.json and firebase.json config files",
              "Share both files with Person C via WhatsApp/Discord immediately — do not wait"
            ],
            connects: "Person C needs firebase.json to initialize Flutter. Person A needs project ID for Cloud Run config in Phase 4.",
            requirements: "Google account, Firebase console access (free Spark plan)",
            tips: "Use test mode for Firestore and Storage rules during the hackathon — don't waste time on security rules until Phase 4. Free Spark plan handles all demo traffic comfortably."
          },
          {
            title: "Firestore schema design + mock data",
            purpose: "Define how audit reports are stored so Person C can build the history screen without waiting for real API data. The mock documents are critical for unblocking frontend work.",
            steps: [
              "Collection: 'audits'",
              "Document fields: { uid, company_name, audit_date, overall_score, severity_label, findings[], created_at }",
              "Each finding: { cve_id, title, severity, affected_rows, evidence, fix, confidence, effort }",
              "Manually create 3 sample documents in Firebase console with different scores (8.4, 6.1, 3.2) and dates",
              "Save schema as /data/firestore_schema.json on GitHub"
            ],
            connects: "Person C builds the history screen against these mock documents. Person A formats API response to match this exact structure.",
            requirements: "Firebase project created (your previous task)",
            tips: "Create documents showing scores improving over time: 8.4 HIGH → 6.1 MEDIUM → 3.2 LOW across 3 months. This tells the story of a company improving after using FairHire. Judges will notice this narrative and remember it."
          }
        ]
      },
      {
        id: "C",
        name: "Person C",
        role: "Flutter Frontend",
        tasks: [
          {
            title: "Flutter Web project initialization",
            purpose: "Get a working Flutter web app that opens in browser. This is the container all 4 screens will live in — routing, theming, and package setup done once.",
            steps: [
              "flutter create fairhire_app --platforms web",
              "Add to pubspec.yaml: firebase_core, firebase_auth, cloud_firestore, firebase_storage, file_picker, fl_chart, http",
              "flutter pub get",
              "Copy firebase.json from Person B into project root",
              "flutterfire configure → select fairhire-app project",
              "Set up 4 named routes: /login, /upload, /report, /history",
              "flutter run -d chrome → confirm app opens in browser"
            ],
            connects: "This is the app Person B's Firebase config plugs into and Person A's backend API connects to.",
            requirements: "Flutter SDK 3.x, Chrome browser, firebase.json config from Person B",
            tips: "Use Antigravity: 'Create a Flutter Web app with MaterialApp and 4 named routes: /login, /upload, /report, /history. Each route shows a placeholder screen with the route name.' Don't design UI yet — just get routing working first."
          },
          {
            title: "Design system + theme setup",
            purpose: "Define colors, fonts, and reusable components once so all 4 screens look like a cohesive professional product, not 4 separate student assignments.",
            steps: [
              "Create /lib/theme/app_theme.dart",
              "Primary: #0F172A (dark navy), Accent: #EF4444 (red for high severity), Success: #22C55E",
              "Text styles: headingLarge, bodyText, codeText (monospace for CVE IDs)",
              "Create reusable widgets: SeverityBadge(score), CVECard(finding), ScoreGauge(score)",
              "Apply theme in main.dart MaterialApp",
              "Test all components render on a test screen"
            ],
            connects: "Person B uses these same components for the radar chart. Consistent styling across all screens.",
            requirements: "Flutter project initialized (your previous task)",
            tips: "The UI must feel like a security tool — dark navy background, red severity indicators, monospace font for CVE IDs. Think: Burp Suite meets Google Material. Use Google Fonts package: DM Mono for CVE IDs, Plus Jakarta Sans for body. This design language is what makes FairHire look real."
          }
        ]
      },
      {
        id: "D",
        name: "Person D",
        role: "Data + Presentation",
        tasks: [
          {
            title: "Sample hiring CSV (50 rows)",
            purpose: "The most important asset in the entire project. Every demo, every test, every judge interaction uses this CSV. It must tell a clear, dramatic bias story that is immediately obvious.",
            steps: [
              "Columns: candidate_id, name, college, college_tier, city, skills, years_exp, selected",
              "Tier 1 (IIT/NIT): 15 candidates → 13 selected (87% rate)",
              "Tier 2 (DTU/VIT): 15 candidates → 8 selected (53% rate)",
              "Tier 3 (GLBITM/others): 20 candidates → 4 selected (20% rate)",
              "CRITICAL: Keep skills and years_exp identical across tiers — this isolates the bias",
              "Add 2 counter-examples (Tier-3 selected, Tier-1 rejected) to look like real data",
              "Save as /data/sample_hiring.csv and push to GitHub"
            ],
            connects: "Person A tests bias engine against this. Person C uses it in demo. Used in demo video recording.",
            requirements: "Excel or Google Sheets",
            tips: "Include real college names: IIT Delhi, IIT Bombay, NIT Trichy, DTU Delhi, VIT Vellore, SRM Chennai, GLBITM Ghaziabad, Agra University, Meerut Institute. The 87% vs 20% disparity is the shock moment in the demo. Make it obvious."
          },
          {
            title: "College tier master list (200+ colleges)",
            purpose: "The bias engine needs to know which tier every college belongs to. Without this JSON the detection logic cannot classify a single candidate.",
            steps: [
              "Create /data/college_tiers.json",
              "Tier 1: All 23 IITs, 31 NITs, BITS Pilani campuses, IISc Bangalore",
              "Tier 2: DTU, NSIT, VIT Vellore, SRM Chennai, Manipal, Thapar, PES, COEP, VJTI",
              "Tier 3: All state universities and private colleges not in Tier 1/2",
              "Format: { 'IIT Delhi': 1, 'VIT Vellore': 2, 'GLBITM': 3, ... }",
              "Push to GitHub — Person A imports this directly"
            ],
            connects: "Person A imports college_tiers.json directly into the bias detection engine on Day 3.",
            requirements: "Google search for full NIT/IIT lists. Wikipedia has all 23 IITs and 31 NITs.",
            tips: "Ask Claude: 'Give me a Python dict of all IITs, NITs, and top private engineering colleges in India with tier labels 1, 2, or 3'. Verify the Tier 1 list manually (23 IITs + 31 NITs), trust AI for Tier 2 and 3. Aim for 200+ total entries."
          }
        ]
      }
    ]
  },
  {
    id: 2,
    code: "P2",
    title: "Brain",
    subtitle: "Bias engine works in terminal",
    days: "Apr 11–14",
    emoji: "🧠",
    color: "#059669",
    light: "#D1FAE5",
    capability: "At the end of this phase: Run a Python script, pass it the sample CSV, and it prints a complete JSON bias report with CVE IDs, severity scores, and Gemini-generated fix recommendations. No UI yet — but the core AI intelligence is complete and testable.",
    persons: [
      {
        id: "A",
        name: "Person A",
        role: "Backend Lead",
        tasks: [
          {
            title: "College tier bias detector (Pandas)",
            purpose: "FairHire's core intelligence. Reads the CSV, groups candidates by college tier, and statistically proves whether college tier predicts selection outcome — independent of skills or experience.",
            steps: [
              "Load CSV: df = pd.read_csv(file)",
              "Load college_tiers.json, map each candidate's college to a tier (1/2/3)",
              "Group by tier: rates = df.groupby('college_tier')['selected'].mean()",
              "Compute disparity_ratio = tier1_selection_rate / tier3_selection_rate",
              "If disparity_ratio > 1.5 → bias detected (flag as finding)",
              "severity_score = min(10, round((disparity_ratio - 1) * 4, 1))",
              "Count affected_rows = Tier-3 candidates who were rejected",
              "Return: { detected, disparity_ratio, tier_rates, severity_score, affected_rows }"
            ],
            connects: "Output dict feeds the CVE scorer (next task) and Gemini explainer (Person D's task).",
            requirements: "sample_hiring.csv and college_tiers.json from Person D. Must be in /data folder.",
            tips: "Use Antigravity: 'Write a Python function check_college_bias(df, college_tiers_dict) that computes selection rate per college tier, calculates disparity ratio between tier 1 and tier 3, and returns a finding dict with severity score 0-10.' Test manually: python -c 'import pandas as pd; from bias_detector import check; print(check(pd.read_csv(\"data/sample.csv\")))'"
          },
          {
            title: "CVE ID generator + CVSS severity scorer",
            purpose: "This is what makes FairHire look like a real security audit tool — not a student project. Every bias finding gets a unique, trackable ID exactly like real cybersecurity vulnerability databases.",
            steps: [
              "CVE format: IN-BIAS-2025-{zero-padded 4 digits}",
              "Generate sequentially per audit: first finding = IN-BIAS-2025-0001",
              "CVSS-style labels: 0–3.9 = LOW (green), 4–6.9 = MEDIUM (orange), 7–8.9 = HIGH (red), 9–10 = CRITICAL (dark red)",
              "Build complete finding object: { cve_id, title, severity_score, severity_label, disparity_ratio, affected_rows, tier1_rate, tier3_rate, evidence_summary }",
              "evidence_summary must be specific: 'Tier 1 candidates selected at 87% vs Tier 3 at 20% — identical Python/ML skills and 2 years experience'"
            ],
            connects: "This complete finding object is passed to Person D's Gemini prompt and returned in the Flask API response to Person C.",
            requirements: "Bias detector working (previous task)",
            tips: "The evidence_summary is what judges will quote in their feedback. 'Tier 1 candidates selected at 87% vs Tier 3 at 20% for identical skill sets' is 10x more powerful than 'college bias detected'. Make it specific and shocking."
          },
          {
            title: "Flask API — POST /audit endpoint",
            purpose: "Wraps the Python bias engine in an HTTP API so Flutter can call it from the browser. The bridge between frontend and backend — without this the two sides cannot communicate.",
            steps: [
              "POST /audit — accepts multipart form with CSV file upload",
              "Parse CSV: df = pd.read_csv(request.files['file'])",
              "Call check_college_bias(df) → get finding dict",
              "Call gemini_explain(finding) → get AI recommendation (Person D's function)",
              "Assemble full report JSON: { audit_id, overall_score, severity_label, executive_summary, findings[] }",
              "Return report JSON with 200 status",
              "Add CORS: from flask_cors import CORS; CORS(app) — required for Flutter web calls"
            ],
            connects: "Person C's Flutter app POSTs to this endpoint. Run on localhost:5000 now, move to Cloud Run URL in Phase 4.",
            requirements: "Bias detector + CVE scorer working. Person D's gemini_explain() function must be importable.",
            tips: "CRITICAL: Return a hardcoded mock JSON response first on Day 11 — this unblocks Person C while you finish the real logic. Share the mock JSON file with Person C via WhatsApp immediately. Real logic goes in by Day 13."
          },
          {
            title: "Mock report JSON handoff to Person C",
            purpose: "The single most important handoff in the project. Person C cannot build the report screen without knowing the exact JSON shape. Give them a complete, realistic example on Day 11.",
            steps: [
              "Create /data/mock_report.json with full structure",
              "Include: audit_id, overall_score=8.4, severity_label='HIGH', executive_summary (2 sentences)",
              "One complete finding: cve_id='IN-BIAS-2025-0001', all fields with realistic values",
              "Include sample Gemini explanation text and fix recommendation",
              "Push to GitHub AND share on WhatsApp immediately",
              "Tell Person C: 'Build the entire report screen against this JSON. I'll replace with real API by Day 14.'"
            ],
            connects: "Unblocks Person C and Person B by 3 full days. Most important 30-minute task in the project.",
            requirements: "CVE ID format decided. Gemini output format decided with Person D.",
            tips: "Spend 30 minutes making this JSON look really compelling — realistic percentages (87% vs 20%), a well-written Gemini explanation, proper CVE ID. Person C may use this mock JSON in the demo video even if the real API isn't ready."
          }
        ]
      },
      {
        id: "D",
        name: "Person D",
        role: "Data + Presentation",
        tasks: [
          {
            title: "Gemini fix recommendation prompt engineering",
            purpose: "Raw bias numbers mean nothing to an HR manager. Gemini translates the technical finding into plain English with a specific, actionable fix they can implement the next day. This is the AI magic layer of FairHire.",
            steps: [
              "Create /backend/gemini/explainer.py",
              "Configure API: import google.generativeai as genai; genai.configure(api_key=os.getenv('GEMINI_API_KEY'))",
              "Build prompt: include disparity_ratio, severity_score, affected_rows, tier rates in the prompt",
              "Instruct Gemini: 'Respond ONLY in valid JSON. No markdown. No preamble. Fields: explanation, recommended_fix, fix_confidence_pct, implementation_effort (Low/Medium/High), business_impact'",
              "Parse response: json.loads(response.text)",
              "Handle JSON parse errors gracefully — Gemini occasionally adds markdown",
              "Test 5 times — check output quality and consistency"
            ],
            connects: "Person A imports gemini_explain() from this file and calls it inside the Flask /audit endpoint.",
            requirements: "GEMINI_API_KEY from Person A in the .env file. Must be importable from /backend/app.py.",
            tips: "The prompt instruction 'Respond ONLY in valid JSON. No markdown. No preamble.' is critical — without it Gemini adds ```json code blocks that break parsing. Also add: 'The HR manager reading this is not technical — use simple language, be specific, avoid jargon.' Test with 5 different bias severity levels."
          }
        ]
      }
    ]
  },
  {
    id: 3,
    code: "P3",
    title: "Interface",
    subtitle: "Judges can see and touch it",
    days: "Apr 13–18",
    emoji: "🖥",
    color: "#7C3AED",
    light: "#EDE9FE",
    capability: "At the end of this phase: A judge can open the Flutter app, log in, upload the sample CSV, wait 10 seconds, and see a professional pentest-style bias audit report with CVE IDs, severity scores, radar chart, and Gemini explanations. Full demo flow working locally.",
    persons: [
      {
        id: "C",
        name: "Person C",
        role: "Flutter Frontend",
        tasks: [
          {
            title: "Screen 1: Login",
            purpose: "First impression. Must look professional and HR-facing. A judge forms their opinion of the product quality in the first 3 seconds of seeing this screen.",
            steps: [
              "Create /lib/screens/login_screen.dart",
              "FairHire logo + tagline: 'AI Bias Auditor for Indian Hiring'",
              "Email + password TextFields with input validation",
              "Sign In button → FirebaseAuth.instance.signInWithEmailAndPassword()",
              "On success → Navigator.pushReplacementNamed('/upload')",
              "Error handling: show SnackBar with specific error message",
              "Add visible demo credentials on the screen: 'Demo: demo@fairhire.com / FairHire@2025'"
            ],
            connects: "Routes to upload screen on success. Firebase Auth (Person B's setup) handles all authentication.",
            requirements: "Firebase Auth configured in Flutter (Phase 1). Design system colors from Phase 1.",
            tips: "Build with a hardcoded bypass first: if (email == 'demo@fairhire.com') navigate to upload screen directly. Replace with real Firebase call once Person B confirms Auth works. The visible demo credentials on the login screen are non-negotiable — judges will not create accounts."
          },
          {
            title: "Screen 2: Upload + audit trigger",
            purpose: "The action moment. HR manager uploads their dataset. Must feel powerful and trustworthy, like submitting a file to a professional security scanner.",
            steps: [
              "Create /lib/screens/upload_screen.dart",
              "Large drag-and-drop zone UI with dashed border and upload icon",
              "file_picker: FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv'])",
              "Show file name + estimated row count after selection",
              "POST to Flask API: http.MultipartRequest with file bytes",
              "Animated loading state with rotating text: 'Scanning for bias patterns...' → 'Running statistical analysis...' → 'Generating recommendations...'",
              "On response: navigate to /report passing report JSON as arguments"
            ],
            connects: "Calls Person A's Flask /audit endpoint (localhost:5000 now, Cloud Run URL in Phase 4). Uploads file to Person B's Cloud Storage.",
            requirements: "Flask API URL from Person A. Use hardcoded mock JSON response first — swap real API in Phase 4.",
            tips: "MOST IMPORTANT TIP: Build against the mock JSON from Person A first. Hardcode the mock response as a string in the app, add a 3-second fake loading delay, then navigate to report. This lets you build the full UI in 2 days without waiting for the backend. Real API swap takes 30 minutes in Phase 4."
          },
          {
            title: "Screen 3: Pentest-style audit report (hero screen)",
            purpose: "The money screen. This is what judges will screenshot and remember. Must look like a real security audit report — CVE IDs, severity bars, evidence tables. Not a dashboard — a professional report.",
            steps: [
              "HEADER: 'FAIRHIRE BIAS AUDIT REPORT' in DM Mono + audit ID + date + company name",
              "OVERALL SCORE: large number (8.4/10) with severity label 'HIGH' in bold red",
              "EXECUTIVE SUMMARY: Gemini-generated 2-sentence overview of findings",
              "FINDINGS SECTION — each finding card contains:",
              "  • CVE ID badge (IN-BIAS-2025-0001) in monospace red on dark background",
              "  • Severity progress bar (colored: green/orange/red/dark-red)",
              "  • Evidence table: Tier 1 rate (87%) vs Tier 3 rate (20%)",
              "  • Recommended Fix text (Gemini output)",
              "  • Fix Confidence pill: '91% confidence' in green",
              "  • Implementation Effort badge: LOW / MEDIUM / HIGH",
              "Inject Person B's radar chart widget between executive summary and findings"
            ],
            connects: "Displays data from Person A's API response JSON. Person B's radar chart widget is inserted here.",
            requirements: "Mock report JSON from Person A (Day 11 handoff). Design system from Phase 1.",
            tips: "This screen determines 60% of the judge's impression. Dark card background, red CVE badge in monospace, color-coded severity bars. Use Antigravity to generate the full widget tree first, then spend 3-4 hours on visual polish manually. The CVE badge and evidence table are the two elements that make this look real — prioritize those."
          },
          {
            title: "Screen 4: Report history",
            purpose: "Shows FairHire is a continuous monitoring tool, not a one-time audit. A company tracks their bias score improving over time — this communicates product vision without words.",
            steps: [
              "Create /lib/screens/history_screen.dart",
              "Query Firestore: audits where uid == currentUser.uid, orderBy created_at descending",
              "ListView: each row shows date, overall score, severity badge (color-coded), company name",
              "Tap row → load saved report and navigate to /report",
              "Empty state: 'No audits yet. Upload a dataset to get started.'",
              "Floating action button: 'New Audit' → navigate to /upload"
            ],
            connects: "Reads from Firestore (Person B's setup). Person B pre-populated with 3 mock historical records.",
            requirements: "Firestore schema from Person B. Firebase initialized in Flutter.",
            tips: "Person B pre-populated Firestore with 3 historical mock audits showing scores 8.4 → 6.1 → 3.2. Your list will show this improving trend without any real data. This narrative — a company getting better over time — is extremely powerful for judges. Make the score color-coded: red for HIGH, orange for MEDIUM, green for LOW."
          }
        ]
      },
      {
        id: "B",
        name: "Person B",
        role: "Firebase + DevOps",
        tasks: [
          {
            title: "Bias fingerprint radar chart widget",
            purpose: "The visual judges remember. A spider/radar chart showing bias dimensions at a glance. Even a judge who skips reading the text understands the severity instantly from this visual.",
            steps: [
              "Create /lib/widgets/bias_fingerprint_chart.dart",
              "Use fl_chart RadarChart widget",
              "4 dimensions: College Tier Bias (live data), Name Bias (0 — greyed), Location Bias (0 — greyed), Vernacular Bias (0 — greyed)",
              "Active dimension fills in red/orange based on severity score from API",
              "Inactive dimensions grey with small 'v2' badge — not a weakness, shows roadmap",
              "Add legend below: red = detected, grey = coming in v2",
              "Animate fill on screen load with 600ms ease-in animation",
              "Add onTap on active dimension → show tooltip with exact percentage"
            ],
            connects: "Person C injects this widget into the report screen between executive summary and findings.",
            requirements: "fl_chart package installed. Report JSON schema from Person A — needs severity_score field.",
            tips: "The grey placeholder dimensions are a feature, not a weakness. They tell judges 'this is v1, more detectors planned' — showing product roadmap thinking. Use Antigravity to generate the fl_chart RadarChart code since the API is complex. The animation on load is important — a static chart is forgettable, an animated one gets noticed."
          },
          {
            title: "Save report to Firestore + history integration",
            purpose: "Persist every audit report so the history screen works. Without this, every app restart loses all previous audits — the continuous monitoring story collapses.",
            steps: [
              "After Flask API returns report JSON, save to Firestore:",
              "Collection: 'audits', Document ID: auto-generated",
              "Fields: all report JSON fields + uid (from Firebase Auth) + created_at (server timestamp)",
              "Trigger save from Person C's upload screen after successful API response",
              "Verify data appears in Firebase console after a test audit",
              "Pre-populate 3 historical mock records in Firestore for demo account (scores: 8.4, 6.1, 3.2 across 3 months)"
            ],
            connects: "Powers Person C's history screen. Pre-populated records tell the improving score narrative without real data.",
            requirements: "Firestore initialized. Firebase Auth working (to get uid). Report JSON structure from Person A.",
            tips: "Add the save call in Person C's upload screen: after http response is parsed, call FirestoreService.saveAudit(report). Create a simple FirestoreService class with a saveAudit() method — keep it clean and reusable. Pre-populate the mock historical records on Day 13 so Person C can test history screen immediately."
          }
        ]
      }
    ]
  },
  {
    id: 4,
    code: "P4",
    title: "Deployment",
    subtitle: "Live on the internet",
    days: "Apr 19–21",
    emoji: "🚀",
    color: "#DC2626",
    light: "#FEE2E2",
    capability: "At the end of this phase: The full FairHire system is live on real Google Cloud infrastructure. Judges can open the URL from anywhere, log in, upload a CSV, and get a real bias audit report. This is your prototype submission link.",
    persons: [
      {
        id: "A",
        name: "Person A",
        role: "Backend Lead",
        tasks: [
          {
            title: "Dockerfile + Cloud Run deployment",
            purpose: "Takes your local Flask server and puts it on Google Cloud permanently so anyone in the world can call it — including Flutter running in judges' browsers.",
            steps: [
              "Create /backend/Dockerfile:",
              "  FROM python:3.11-slim",
              "  WORKDIR /app",
              "  COPY requirements.txt . && pip install -r requirements.txt --no-cache-dir",
              "  COPY . .",
              "  EXPOSE 8080",
              "  CMD [\"python\", \"-m\", \"flask\", \"run\", \"--host=0.0.0.0\", \"--port=8080\"]",
              "Test locally: docker build -t fairhire-engine . && docker run -p 8080:8080 fairhire-engine",
              "Deploy: gcloud run deploy fairhire-engine --source . --region asia-south1 --allow-unauthenticated",
              "Set env vars: gcloud run services update fairhire-engine --set-env-vars GEMINI_API_KEY=your_key",
              "Copy the HTTPS URL → share with Person C and B immediately"
            ],
            connects: "Person C updates Flutter API URL to this HTTPS URL. Person B updates CORS whitelist.",
            requirements: "Google Cloud account (free tier), gcloud CLI installed, Docker installed",
            tips: "Use region asia-south1 (Mumbai) — lowest latency for Indian judges. Set min-instances=1 to avoid cold starts: gcloud run services update fairhire-engine --min-instances=1. This one setting makes the first API request instant instead of 10 seconds. Free tier covers all demo traffic."
          },
          {
            title: "Backend stability + monitoring",
            purpose: "Ensure the backend stays alive during the submission window when judges are actively testing. A crashed backend = disqualification regardless of everything else.",
            steps: [
              "Test /audit endpoint 10 times in a row — check for any failures or timeouts",
              "Check Cloud Run logs: gcloud run services logs read fairhire-engine",
              "Verify Gemini API key has not hit rate limits",
              "Test with 3 different CSV files: sample_hiring.csv, edge cases (all same tier), large file (200 rows)",
              "Set min-instances=1 to prevent cold starts",
              "Document the live API URL in README and team WhatsApp group"
            ],
            connects: "Keeps the prototype live for judges. All other Phase 5 submission work depends on this being stable.",
            requirements: "Cloud Run deployed (previous task)",
            tips: "If Cloud Run is too complex, deploy to Railway.app or Render.com as backup — both have free tiers and zero-config Python deployment. Primary choice is Cloud Run (impresses Google judges), but don't let deployment block you past Day 20."
          }
        ]
      },
      {
        id: "B",
        name: "Person B",
        role: "Firebase + DevOps",
        tasks: [
          {
            title: "Flutter Web → Firebase Hosting",
            purpose: "Builds Flutter into static web files and deploys to Firebase Hosting. This gives you the fairhire.web.app URL that goes on the submission form.",
            steps: [
              "Person C updates API URL in Flutter from localhost to Cloud Run HTTPS URL",
              "flutter build web --release (release mode is 5x faster than debug)",
              "firebase login → firebase init hosting",
              "Set public directory to: build/web",
              "firebase deploy --only hosting",
              "Open fairhire.web.app in incognito browser → test full flow",
              "Test on mobile browser too — judges may check on phones"
            ],
            connects: "This is the submission URL. Share immediately with all teammates and add to Hack2Skill form.",
            requirements: "Cloud Run URL from Person A. flutter build web must succeed without errors.",
            tips: "If flutter build web fails, run flutter doctor and fix any missing dependencies. After deploy, test in incognito — incognito simulates a new user with no cached data. The live URL must work from a fresh browser session."
          },
          {
            title: "Basic security rules",
            purpose: "Switch from test mode to basic rules so judges' data is protected and the app looks production-ready — not a prototype with an open database.",
            steps: [
              "Firestore rules: allow read, write: if request.auth != null && request.auth.uid == resource.data.uid;",
              "Storage rules: allow read, write: if request.auth != null;",
              "Test rules in Firebase console → Rules Playground",
              "firebase deploy --only firestore:rules,storage",
              "Verify: unauthenticated user cannot access Firestore (check in browser network tab)"
            ],
            connects: "Protects user data. A judge who inspects network requests will see whether your database is open.",
            requirements: "Firebase project, Firestore and Storage in use",
            tips: "Takes 10 minutes and signals professionalism. A judge who opens DevTools and sees open database access will immediately downgrade the technical merit score. Basic auth rules prevent this."
          }
        ]
      },
      {
        id: "C",
        name: "Person C",
        role: "Flutter Frontend",
        tasks: [
          {
            title: "Live API integration + UI polish",
            purpose: "Replace hardcoded mock JSON with real Cloud Run API calls and polish every screen so it looks production-ready for judges who open it.",
            steps: [
              "Update API_URL constant to Cloud Run HTTPS URL from Person A",
              "Test full flow: login → upload sample CSV → real API response → real report displayed",
              "Fix any JSON parsing errors from real API response",
              "UI polish checklist: consistent spacing, all error states handled, loading states on every screen",
              "Add app favicon and browser tab title: 'FairHire — Bias Audit Platform'",
              "Test on Chrome, Edge, and Firefox",
              "Fix any web-specific Flutter rendering issues (fonts, file picker CORS)"
            ],
            connects: "Final app connects to Person A's Cloud Run backend and all Person B's Firebase services.",
            requirements: "Cloud Run URL from Person A. All Firebase services live from Person B.",
            tips: "The loading animation text rotation is critical: 'Scanning for bias patterns...' → 'Running statistical tests...' → 'Generating fix recommendations...' rotates every 2.5 seconds. A 10-second API call with animated status text feels fast. The same wait with a spinner feels broken. Do not skip this."
          },
          {
            title: "Demo account + pre-populated data",
            purpose: "Judges will not create accounts. A visible demo login with pre-run audits in the history makes the experience seamless and doubles the number of judges who actually try the product.",
            steps: [
              "Create Firebase Auth account: demo@fairhire.com / FairHire@2025",
              "Log in as demo account, run 3 audits with sample CSV (different file names each time)",
              "Verify history screen shows 3 audits with scores: 8.4 HIGH → 6.1 MEDIUM → 3.2 LOW",
              "Add demo credentials visibly on login screen: 'Try demo: demo@fairhire.com / FairHire@2025'",
              "Test entire flow as the demo account one final time",
              "Take final screenshots for Person D's deck"
            ],
            connects: "Person D uses this account for video recording. Judges use it to try the product independently.",
            requirements: "Live Firebase Auth. Firestore pre-populated historical data from Person B.",
            tips: "This is the highest-ROI task in Phase 4. 30 minutes of setup doubles judge engagement with your product. The pre-populated history showing improving scores (8.4 → 6.1 → 3.2) tells the continuous monitoring product story better than any slide."
          }
        ]
      },
      {
        id: "D",
        name: "Person D",
        role: "Data + Presentation",
        tasks: [
          {
            title: "End-to-end testing as a judge",
            purpose: "Someone must test the system as a real HR manager would — not as a developer who built it. Person D finds all the things the team missed because they're too close to the product.",
            steps: [
              "Open fairhire.web.app in incognito browser (simulates a fresh new user)",
              "Try logging in with wrong password — does error show clearly?",
              "Log in with demo credentials — does it work?",
              "Upload sample_hiring.csv — does the loading animation play?",
              "Read every section of the report — is anything confusing or broken?",
              "Try uploading a .jpg file — does it show a proper error?",
              "Test on mobile browser (your phone)",
              "Document every issue in a shared Google Doc, prioritize by severity"
            ],
            connects: "Person C fixes UI bugs from your report. Person A fixes any API errors. This testing makes the demo smooth.",
            requirements: "Live deployment from Person A and B. Incognito browser.",
            tips: "Ask yourself: 'If I knew nothing about this project and someone sent me this URL, would I understand what to do?' Every point of confusion is a fix that needs to happen before submission. You are the judge simulation — be harsh."
          }
        ]
      }
    ]
  },
  {
    id: 5,
    code: "P5",
    title: "Submission",
    subtitle: "Win the judges",
    days: "Apr 22–24",
    emoji: "🏆",
    color: "#D97706",
    light: "#FEF3C7",
    capability: "At the end of this phase: All 6 submission requirements are complete and submitted on Hack2Skill by April 23rd. The team has a rehearsed demo they can deliver in 3 minutes. FairHire is live, working, and unforgettable.",
    persons: [
      {
        id: "A",
        name: "Person A",
        role: "Backend Lead",
        tasks: [
          {
            title: "Final stability + README architecture section",
            purpose: "Keep the backend live during the judging window and contribute the technical architecture section to the README that Person B is building.",
            steps: [
              "Verify Cloud Run is running: curl https://your-cloud-run-url/health",
              "Check min-instances=1 is set (no cold starts for judges)",
              "Write 1-page technical section for README: API endpoints, bias detection algorithm, CVSS scoring formula, Gemini integration flow",
              "Add architecture mermaid diagram to README",
              "Final check: Gemini API key has days of quota remaining",
              "Monitor Cloud Run logs on submission day"
            ],
            connects: "README goes into Person B's GitHub submission. Stable backend keeps the prototype link working for judges.",
            requirements: "Cloud Run deployed from Phase 4.",
            tips: "Set up a simple /health endpoint in Flask that returns {'status': 'ok'}. Share this URL with all teammates so anyone can check if the backend is alive during judging."
          }
        ]
      },
      {
        id: "B",
        name: "Person B",
        role: "Firebase + DevOps",
        tasks: [
          {
            title: "GitHub README (professional quality)",
            purpose: "Judges will open the GitHub repo link on the submission form. A great README signals a real product. A bad one signals a student project — regardless of how good the code is.",
            steps: [
              "Header: FairHire logo + shields.io badges (Flutter, Firebase, Cloud Run, Gemini API)",
              "Tagline: 'India's first AI bias vulnerability auditor for hiring systems'",
              "Problem section: 2 paragraphs with statistics (1.5M graduates, 60% companies use AI screening)",
              "Solution: 4 bullet points covering unique features (College tier bias, CVE IDs, Bias Fingerprint, Gemini fixes)",
              "Architecture: mermaid flowchart diagram (renders automatically on GitHub)",
              "Screenshots: login screen, upload screen, full report screen, radar chart — 4 images",
              "Live Demo section: large clickable link + QR code to fairhire.web.app",
              "Team section: 4 names with roles"
            ],
            connects: "This is what judges see when they click the GitHub link on the Hack2Skill submission form.",
            requirements: "Screenshots from live app. Architecture diagram from Person A. Live URL confirmed working.",
            tips: "Add the mermaid architecture diagram — GitHub renders it natively with no setup: ```mermaid graph LR ... ```. Add the live URL and QR code to every section footer. A README with 4 app screenshots gets 3x more judge engagement than text-only. Use shields.io for version badges — they look professional instantly."
          }
        ]
      },
      {
        id: "C",
        name: "Person C",
        role: "Flutter Frontend",
        tasks: [
          {
            title: "Final QA + submission screenshots",
            purpose: "Take the final set of high-quality screenshots for Person D's deck and verify the live app is perfect for judges.",
            steps: [
              "Open fairhire.web.app at 1440px browser width (standard laptop)",
              "Take screenshots of all 4 screens at full quality (Cmd+Shift+4 on Mac, Snipping Tool on Windows)",
              "Run through the complete demo flow one final time: login → upload → report → history",
              "Verify demo credentials work: demo@fairhire.com / FairHire@2025",
              "Check mobile view (Chrome DevTools responsive mode)",
              "Share all screenshots with Person D for the deck"
            ],
            connects: "Person D uses screenshots for the PowerPoint deck. Screenshots also go in Person B's README.",
            requirements: "Live app from Phase 4 fully working.",
            tips: "Take screenshots with real data showing — the 8.4/10 HIGH severity score on the report screen, the CVE badge IN-BIAS-2025-0001, the radar chart with the active red dimension. These are the visual proof points that go in the deck and README."
          }
        ]
      },
      {
        id: "D",
        name: "Person D",
        role: "Data + Presentation",
        tasks: [
          {
            title: "Demo video (2 min 30 sec)",
            purpose: "The video is what most judges watch first — before opening the app or reading the deck. It must hook them in 20 seconds and tell the complete product story.",
            steps: [
              "0:00–0:20: Camera on Person A. Personal story. 'I am a CS student from GLBITM. AI rejected my resume before a human read it. Not because I lacked skills — because of where I studied. I built FairHire.'",
              "0:20–0:40: Screen recording with voiceover. Show the scale of the problem — statistics, examples of biased AI.",
              "0:40–1:30: Live product demo. Log in as demo account → upload sample CSV → animated loading → full report → highlight CVE ID badge → point to radar chart → show Gemini fix recommendation.",
              "1:30–2:00: Show report history screen. 3 audits, scores improving 8.4 → 6.1 → 3.2. Voiceover: 'Companies track their bias score improving over time.'",
              "2:00–2:20: Impact. '1.5 million Indian engineering graduates filtered by biased AI every year. FairHire fixes the system — not the student.'",
              "2:20–2:30: Team intro + fairhire.web.app URL on screen. 'Try it now.'",
              "Edit in CapCut. Add captions. Subtle background music. Export at 1080p."
            ],
            connects: "Attached to Hack2Skill submission form as YouTube unlisted link.",
            requirements: "Live working app from Phase 4. OBS Studio or Loom for screen recording. CapCut for editing.",
            tips: "Record the demo section 3 separate times — use the cleanest take where the app loads fastest. The personal story opening is non-negotiable — that 20-second authenticity moment is worth more than any technical feature. Keep under 2:45 total — judges watch dozens and will skip long videos. Add captions for accessibility and judges watching without sound."
          },
          {
            title: "PowerPoint deck (10 slides)",
            purpose: "Backup for judges who read slides before watching the video. Must stand completely alone and tell the FairHire story with evidence, screenshots, and numbers.",
            steps: [
              "Slide 1: FairHire logo + 'India's First AI Bias Vulnerability Auditor' + fairhire.web.app URL",
              "Slide 2: Personal story — Person A photo, GLBITM, the rejection experience, quote",
              "Slide 3: Problem at scale — 1.5M graduates, 60% companies use AI screening, bias statistics with sources",
              "Slide 4: Why existing tools fail — IBM AIF360 and Google What-If Tool have zero India context",
              "Slide 5: FairHire solution — clean architecture diagram: Upload → Detect → Score → Explain → Report",
              "Slide 6: Technical stack — Flutter + Firebase + Cloud Run + Gemini API with logos",
              "Slide 7: Live demo screenshot — full pentest report screen with CVE badge visible",
              "Slide 8: CVE system + Bias Fingerprint radar chart screenshot",
              "Slide 9: Impact + roadmap — v2 adds name/location/vernacular bias detectors",
              "Slide 10: Team (4 names + roles) + live URL + QR code"
            ],
            connects: "Attached to Hack2Skill form. Used in any live presentation round if FairHire advances.",
            requirements: "Screenshots from Person C. Architecture details from Person A.",
            tips: "Use Canva with a dark theme matching the app — navy background, red accents. One main point per slide, no paragraphs. Add the live URL as a QR code on every slide footer — judges should be able to try the app while reading the deck. Submit as PDF format to avoid font rendering issues on judge's machine."
          },
          {
            title: "Hack2Skill form submission",
            purpose: "The actual finish line. Missing a field or attaching a broken link means disqualification regardless of how good the product is. Do this on April 23rd — not 24th.",
            steps: [
              "Go to vision.hack2skill.com",
              "Problem Statement field: type 'PS4 — Unbiased AI Decision Making' + 2-paragraph explanation",
              "Solution Overview: 3-paragraph description of FairHire with unique angles",
              "Prototype Link: fairhire.web.app — open this link in incognito and verify it works BEFORE pasting",
              "Project Deck: upload PDF version of PowerPoint",
              "GitHub Repository: paste public GitHub URL — verify repo is PUBLIC before submitting",
              "Demo Video: upload to YouTube as Unlisted → paste YouTube URL",
              "Referral code: NDFKUY",
              "Submit April 23rd — one day early. Use April 24th as emergency buffer."
            ],
            connects: "This is the submission. Every phase of work in this roadmap feeds into this one form.",
            requirements: "All deliverables complete. Prototype URL live. Video on YouTube. Deck as PDF.",
            tips: "Upload video to YouTube Unlisted — not a direct file upload — because direct uploads have size limits and may not play on judge's machine. Double-check GitHub repo is PUBLIC (Settings → scroll to Danger Zone → Change visibility). Submit 23rd. If the form shows errors on 24th, you have no buffer."
          }
        ]
      }
    ]
  }
];

const PERSON_META = {
  A: { bg: "#2563EB", light: "#DBEAFE", text: "#1E40AF", label: "Backend Lead" },
  B: { bg: "#059669", light: "#D1FAE5", text: "#065F46", label: "Firebase + DevOps" },
  C: { bg: "#7C3AED", light: "#EDE9FE", text: "#4C1D95", label: "Flutter Frontend" },
  D: { bg: "#D97706", light: "#FEF3C7", text: "#78350F", label: "Data + Deck" },
};

function TaskCard({ task, personId }) {
  const [open, setOpen] = useState(false);
  const m = PERSON_META[personId];
  return (
    <div style={{
      border: `1.5px solid ${open ? m.bg : "#E5E7EB"}`,
      borderRadius: 10,
      marginBottom: 8,
      overflow: "hidden",
      background: open ? m.light + "55" : "white",
      transition: "border-color 0.2s, background 0.2s",
    }}>
      <button onClick={() => setOpen(!open)} style={{
        width: "100%", padding: "11px 14px",
        display: "flex", alignItems: "center", gap: 10,
        background: "transparent", border: "none", cursor: "pointer", textAlign: "left",
      }}>
        <span style={{
          width: 22, height: 22, borderRadius: "50%",
          background: open ? m.bg : "#E5E7EB",
          display: "flex", alignItems: "center", justifyContent: "center",
          fontSize: 13, color: open ? "white" : "#9CA3AF",
          flexShrink: 0, fontWeight: 700, transition: "all 0.2s",
        }}>{open ? "−" : "+"}</span>
        <span style={{ fontSize: 13, fontWeight: 600, color: "#111827", flex: 1, lineHeight: 1.4 }}>
          {task.title}
        </span>
      </button>
      {open && (
        <div style={{ padding: "0 14px 14px", display: "flex", flexDirection: "column", gap: 10 }}>
          <div style={{ background: "white", borderRadius: 8, padding: "10px 12px", border: "1px solid #E5E7EB" }}>
            <div style={{ fontSize: 10, fontWeight: 700, color: m.text, textTransform: "uppercase", letterSpacing: "0.06em", marginBottom: 5 }}>Why this exists</div>
            <div style={{ fontSize: 12, color: "#374151", lineHeight: 1.65 }}>{task.purpose}</div>
          </div>
          <div style={{ background: "white", borderRadius: 8, padding: "10px 12px", border: "1px solid #E5E7EB" }}>
            <div style={{ fontSize: 10, fontWeight: 700, color: m.text, textTransform: "uppercase", letterSpacing: "0.06em", marginBottom: 8 }}>Exact steps</div>
            <div style={{ display: "flex", flexDirection: "column", gap: 5 }}>
              {task.steps.map((step, i) => {
                const isCode = step.startsWith(" ") || step.startsWith("  ");
                return (
                  <div key={i} style={{ display: "flex", gap: 8, alignItems: "flex-start" }}>
                    {!isCode && <span style={{
                      width: 18, height: 18, borderRadius: "50%",
                      background: m.light, color: m.text,
                      fontSize: 10, fontWeight: 700,
                      display: "flex", alignItems: "center", justifyContent: "center",
                      flexShrink: 0, marginTop: 2,
                    }}>{i + 1}</span>}
                    <span style={{
                      fontSize: isCode ? 11 : 12, color: isCode ? "#6B7280" : "#374151",
                      lineHeight: 1.55,
                      fontFamily: isCode ? "monospace" : "inherit",
                      paddingLeft: isCode ? 26 : 0,
                      whiteSpace: "pre-wrap",
                    }}>{isCode ? step.trim() : step}</span>
                  </div>
                );
              })}
            </div>
          </div>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8 }}>
            <div style={{ background: "white", borderRadius: 8, padding: "10px 12px", border: "1px solid #E5E7EB" }}>
              <div style={{ fontSize: 10, fontWeight: 700, color: "#6B7280", textTransform: "uppercase", letterSpacing: "0.06em", marginBottom: 5 }}>Connects to</div>
              <div style={{ fontSize: 11, color: "#374151", lineHeight: 1.55 }}>{task.connects}</div>
            </div>
            <div style={{ background: "white", borderRadius: 8, padding: "10px 12px", border: "1px solid #E5E7EB" }}>
              <div style={{ fontSize: 10, fontWeight: 700, color: "#6B7280", textTransform: "uppercase", letterSpacing: "0.06em", marginBottom: 5 }}>Requirements</div>
              <div style={{ fontSize: 11, color: "#374151", lineHeight: 1.55 }}>{task.requirements}</div>
            </div>
          </div>
          <div style={{
            background: m.light,
            borderRadius: 8, padding: "10px 12px",
            border: `1px solid ${m.bg}33`,
          }}>
            <div style={{ fontSize: 10, fontWeight: 700, color: m.text, textTransform: "uppercase", letterSpacing: "0.06em", marginBottom: 5 }}>AI / Antigravity tip</div>
            <div style={{ fontSize: 12, color: "#374151", lineHeight: 1.65 }}>{task.tips}</div>
          </div>
        </div>
      )}
    </div>
  );
}

function PersonPanel({ person }) {
  const m = PERSON_META[person.id];
  return (
    <div style={{
      background: "#FAFAFA",
      borderRadius: 12,
      border: "1px solid #E5E7EB",
      overflow: "hidden",
      minWidth: 0,
    }}>
      <div style={{
        padding: "10px 14px",
        background: m.light,
        borderBottom: "1px solid #E5E7EB",
        display: "flex", alignItems: "center", gap: 8,
      }}>
        <div style={{
          width: 30, height: 30, borderRadius: "50%",
          background: m.bg, color: "white",
          display: "flex", alignItems: "center", justifyContent: "center",
          fontSize: 14, fontWeight: 800, flexShrink: 0,
        }}>{person.id}</div>
        <div>
          <div style={{ fontSize: 12, fontWeight: 700, color: m.text }}>{person.name}</div>
          <div style={{ fontSize: 10, color: m.text + "99" }}>{m.label}</div>
        </div>
        <div style={{
          marginLeft: "auto", fontSize: 10, fontWeight: 600,
          background: m.bg, color: "white",
          padding: "2px 8px", borderRadius: 10,
        }}>{person.tasks.length} task{person.tasks.length !== 1 ? "s" : ""}</div>
      </div>
      <div style={{ padding: 10 }}>
        {person.tasks.map((task, i) => (
          <TaskCard key={i} task={task} personId={person.id} />
        ))}
      </div>
    </div>
  );
}

export default function FairHireRoadmap() {
  const [activePhase, setActivePhase] = useState(1);
  const [filterPerson, setFilterPerson] = useState("ALL");

  const phase = PHASES.find(p => p.id === activePhase);
  const visiblePersons = filterPerson === "ALL"
    ? phase.persons
    : phase.persons.filter(p => p.id === filterPerson);

  const personHasWork = (pid) => phase.persons.some(p => p.id === pid);

  return (
    <div style={{ minHeight: "100vh", background: "#F1F5F9", fontFamily: "'DM Sans', -apple-system, BlinkMacSystemFont, sans-serif" }}>

      {/* Top header */}
      <div style={{ background: "#0F172A", padding: "18px 24px 0" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 18 }}>
          <div style={{
            width: 38, height: 38, borderRadius: 9,
            background: "linear-gradient(135deg, #2563EB 0%, #7C3AED 100%)",
            display: "flex", alignItems: "center", justifyContent: "center",
            fontSize: 18, fontWeight: 900, color: "white", letterSpacing: "-1px",
          }}>F</div>
          <div>
            <div style={{ fontSize: 17, fontWeight: 800, color: "white", letterSpacing: "-0.02em" }}>FairHire</div>
            <div style={{ fontSize: 11, color: "#64748B" }}>Interactive build roadmap · Prototype deadline: April 24</div>
          </div>
          <div style={{ marginLeft: "auto", display: "flex", gap: 5, alignItems: "center" }}>
            {Object.entries(PERSON_META).map(([id, m]) => (
              <div key={id} title={`Person ${id} — ${m.label}`} style={{
                width: 26, height: 26, borderRadius: "50%",
                background: m.bg, color: "white",
                display: "flex", alignItems: "center", justifyContent: "center",
                fontSize: 11, fontWeight: 800, cursor: "default",
              }}>{id}</div>
            ))}
          </div>
        </div>

        {/* Phase tabs */}
        <div style={{ display: "flex", gap: 2, overflowX: "auto", paddingBottom: 0 }}>
          {PHASES.map(p => {
            const active = activePhase === p.id;
            return (
              <button key={p.id} onClick={() => { setActivePhase(p.id); setFilterPerson("ALL"); }} style={{
                padding: "9px 14px 11px",
                background: active ? "white" : "transparent",
                border: "none",
                borderRadius: "8px 8px 0 0",
                cursor: "pointer",
                display: "flex", flexDirection: "column", gap: 2,
                minWidth: 90,
                transition: "background 0.15s",
              }}>
                <div style={{ display: "flex", alignItems: "center", gap: 5 }}>
                  <span style={{
                    fontSize: 13,
                    filter: active ? "none" : "grayscale(1)",
                    opacity: active ? 1 : 0.5,
                  }}>{p.emoji}</span>
                  <span style={{ fontSize: 12, fontWeight: 700, color: active ? "#111827" : "#64748B" }}>
                    {p.title}
                  </span>
                </div>
                <span style={{ fontSize: 10, color: active ? p.color : "#475569", fontWeight: active ? 600 : 400 }}>
                  {p.days}
                </span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Phase capability bar */}
      <div style={{
        padding: "12px 24px",
        background: phase.light,
        borderBottom: `2px solid ${phase.color}25`,
        display: "flex", gap: 12, alignItems: "flex-start",
      }}>
        <div style={{
          fontSize: 22, flexShrink: 0, marginTop: 1,
        }}>{phase.emoji}</div>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 13, fontWeight: 700, color: "#1E293B", marginBottom: 3 }}>
            Phase {phase.id}: {phase.title} — <span style={{ color: phase.color }}>{phase.subtitle}</span>
          </div>
          <div style={{ fontSize: 12, color: "#475569", lineHeight: 1.65 }}>{phase.capability}</div>
        </div>
      </div>

      {/* Filter bar */}
      <div style={{ padding: "12px 24px 8px", display: "flex", gap: 6, alignItems: "center", flexWrap: "wrap" }}>
        <span style={{ fontSize: 11, color: "#94A3B8", fontWeight: 500, marginRight: 2 }}>View:</span>
        {["ALL", "A", "B", "C", "D"].map(f => {
          const active = filterPerson === f;
          const m = f === "ALL" ? { bg: "#334155", light: "#F1F5F9", text: "#334155" } : PERSON_META[f];
          const hasWork = f === "ALL" || personHasWork(f);
          return (
            <button key={f} onClick={() => hasWork && setFilterPerson(f)} style={{
              padding: "4px 12px",
              borderRadius: 20,
              border: `1.5px solid ${active ? m.bg : "#E2E8F0"}`,
              background: active ? m.bg : "white",
              color: active ? "white" : hasWork ? "#374151" : "#CBD5E1",
              fontSize: 11, fontWeight: 600,
              cursor: hasWork ? "pointer" : "not-allowed",
              opacity: hasWork ? 1 : 0.45,
              transition: "all 0.15s",
            }}>
              {f === "ALL" ? "Everyone" : `Person ${f} — ${PERSON_META[f].label}`}
            </button>
          );
        })}
        <span style={{ marginLeft: "auto", fontSize: 11, color: "#94A3B8" }}>
          Click any task card to expand
        </span>
      </div>

      {/* Person columns */}
      <div style={{
        padding: "8px 24px 32px",
        display: "grid",
        gridTemplateColumns: `repeat(${Math.min(visiblePersons.length, 2)}, 1fr)`,
        gap: 12,
        alignItems: "start",
      }}>
        {visiblePersons.map((person, i) => (
          <PersonPanel key={i} person={person} />
        ))}
      </div>

      {/* Legend footer */}
      <div style={{
        margin: "0 24px 32px",
        padding: "12px 16px",
        background: "white",
        border: "1px solid #E2E8F0",
        borderRadius: 10,
        display: "flex", gap: 24, flexWrap: "wrap", alignItems: "center",
      }}>
        <span style={{ fontSize: 11, fontWeight: 700, color: "#94A3B8" }}>LEGEND</span>
        {[
          "Why this exists — the reason behind the task",
          "Exact steps — numbered actions to take",
          "Connects to — who depends on your output",
          "Requirements — what you need before starting",
          "AI tip — how to use Antigravity / Claude",
        ].map((label, i) => (
          <div key={i} style={{ display: "flex", alignItems: "center", gap: 5 }}>
            <div style={{ width: 5, height: 5, borderRadius: "50%", background: "#94A3B8", flexShrink: 0 }} />
            <span style={{ fontSize: 11, color: "#64748B" }}>{label}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
