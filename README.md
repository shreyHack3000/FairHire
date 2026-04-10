# FairHire — AI Bias Vulnerability Auditor

> India's first pentest-style bias audit tool for AI hiring systems.

Built for Google Solution Challenge 2026 — Problem Statement 4: Unbiased AI.

## The Problem
60% of large Indian companies use AI to screen resumes.
These systems are trained on biased historical data — IIT graduates
get selected at 85% rate, Tier-3 college graduates at 22%, for the
same skills and experience. The AI filters candidates before a human
ever reads their name.

## What FairHire Does
Upload your company's hiring dataset → FairHire audits it for
college tier bias → generates a professional bias vulnerability
report with CVE IDs, severity scores, and AI-powered fix
recommendations.

## Live Demo
🔗 [fairhire.web.app](https://fairhire.web.app) ← prototype link (live after Apr 19)

## Tech Stack
| Layer | Technology |
|-------|-----------|
| Frontend | Flutter Web |
| Backend | Python, Flask, Pandas |
| AI | Google Gemini API |
| Database | Firebase Firestore |
| Storage | Firebase Cloud Storage |
| Deployment | Google Cloud Run + Firebase Hosting |

## Team Roadmap
See `/docs/fairhire_roadmap.jsx` for the full interactive build plan.
Each person's tasks, steps, and deliverables are inside.

## Project Structure
