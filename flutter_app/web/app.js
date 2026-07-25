const BASE_URL = 'https://fairhire-backend-f8mp.onrender.com';

const SAMPLE_CSV = `Candidate Id,Name,College,College tier,City,Skills,Years exp,selected
STU19CSE483,Rahul Verma,IIT Delhi,1,Delhi,"Python,ML,Data Analysis",2,1
STU18CSE017,Sneha Iyer,NIT Trichy,1,Tiruchirappalli,"Python,ML,Data Analysis",2,1
STU20CSE392,Arjun Mehta,IIT Bombay,1,Bombay,"Python,ML,Data Analysis",2,1
STU19CSE105,Priya Sharma,NIT Surathkal,1,Surathkal,"Python,ML,Data Analysis",2,1
STU18CSE276,Karan Patel,IIT Kanpur,1,Kanpur,"Python,ML,Data Analysis",2,1
STU20CSE451,Ananya Das,NIT Warangal,1,Warangal,"Python,ML,Data Analysis",2,1
STU19CSE089,Rohit Singh,IIT Kharagpur,1,Kharagpur,"Python,ML,Data Analysis",2,1
STU18CSE334,Neha Gupta,NIT Calicut,1,Calicut,"Python,ML,Data Analysis",2,1
STU20CSE512,Aditya Rao,IIT Madras,1,Chennai,"Python,ML,Data Analysis",2,1
STU19CSE063,Pooja Kulkarni,NIT Nagpur,1,Nagpur,"Python,ML,Data Analysis",2,0
STU18CSE248,Vikram Joshi,IIT Roorkee,1,Roorkee,"Python,ML,Data Analysis",2,1
STU20CSE019,Simran Kaur,NIT Jalandhar,1,Jalandhar,"Python,ML,Data Analysis",2,0
STU19CSE367,Aman Khan,NIT Durgapur,1,Durgapur,"Python,ML,Data Analysis",2,0
STU18CSE290,Riya Chatterjee,IIT GUWAHATI,1,Guwahati,"Python,ML,Data Analysis",2,1
STU20CSE441,Saurabh Mishra,IIT Hyderabad,1,Hyderabad,"Python,ML,Data Analysis",2,1
STU19CSE156,Rohan Malhotra,DTU,2,Delhi,"Python,ML,Data Analysis",2,1
STU18CSE078,Kavya Nair,VIT Vellore,2,Vellore,"Python,ML,Data Analysis",2,1
STU20CSE509,Siddharth Jain,DTU,2,Delhi,"Python,ML,Data Analysis",2,1
STU19CSE314,Meera Reddy,VIT Chennai,2,Chennai,"Python,ML,Data Analysis",2,0
STU18CSE422,Abhishek Banerjee,SRM Kattankulathur,2,Kattankulathur,"Python,ML,Data Analysis",2,0
STU20CSE189,Isha Agarwal,DTU,2,Delhi,"Python,ML,Data Analysis",2,1
STU19CSE231,Nikhil Kumar,VIT Vellore,2,Vellore,"Python,ML,Data Analysis",2,0
STU18CSE115,Divya Saxena,Manipal University,2,Manipal,"Python,ML,Data Analysis",2,0
STU20CSE304,Varun Kapoor,DTU,2,Delhi,"Python,ML,Data Analysis",2,1
STU19CSE477,Tanvi Bhatt,VIT Chennai,2,Chennai,"Python,ML,Data Analysis",2,0
STU18CSE092,Gaurav Sharma,SRM Kattankulathur,2,Kattankulathur,"Python,ML,Data Analysis",2,0
STU20CSE213,Shweta Pandey,Thapar Institute,2,Patiala,"Python,ML,Data Analysis",2,0
STU19CSE388,Yash Chopra,BITS Pilani,2,Pilani,"Python,ML,Data Analysis",2,1
STU18CSE561,Anjali Tripathi,VIT Vellore,2,Vellore,"Python,ML,Data Analysis",2,0
STU20CSE142,Harsh Vardhan,DTU,2,Delhi,"Python,ML,Data Analysis",2,0
STU19CSE024,Shruti Sen,LPU,3,Phagwara,"Python,ML,Data Analysis",2,0
STU18CSE399,Rajesh Choudhury,CU,3,Gharuan,"Python,ML,Data Analysis",2,0
STU20CSE287,Preeti Deshmukh,Sathyabama,3,Chennai,"Python,ML,Data Analysis",2,0
STU19CSE112,Deepak Yadav,Amity University,3,Noida,"Python,ML,Data Analysis",2,0
STU18CSE453,Swati Verma,Galgotias,3,Greater Noida,"Python,ML,Data Analysis",2,0
STU20CSE098,Alok Srivastava,Sharda University,3,Greater Noida,"Python,ML,Data Analysis",2,0
STU19CSE341,Kiran Goswami,LPU,3,Phagwara,"Python,ML,Data Analysis",2,0
STU18CSE206,Tarun Bhasin,CU,3,Gharuan,"Python,ML,Data Analysis",2,0
STU20CSE488,Monika Thakur,Amity University,3,Noida,"Python,ML,Data Analysis",2,0
STU19CSE175,Sanjay Dutta,Graphic Era,3,Dehradun,"Python,ML,Data Analysis",2,0
STU18CSE319,Richa Upadhyay,LPU,3,Phagwara,"Python,ML,Data Analysis",2,0
STU20CSE064,Manish Tiwari,CU,3,Gharuan,"Python,ML,Data Analysis",2,0
STU19CSE429,Pallavi Rathi,Amity University,3,Noida,"Python,ML,Data Analysis",2,0
STU18CSE181,Vineet Saxena,SRM Ramapuram,3,Chennai,"Python,ML,Data Analysis",2,0
STU20CSE355,Nidhi Shukla,LPU,3,Phagwara,"Python,ML,Data Analysis",2,0
STU19CSE260,Prateek Rastogi,CU,3,Gharuan,"Python,ML,Data Analysis",2,0
STU18CSE494,Bhavna Mahajan,Amity University,3,Noida,"Python,ML,Data Analysis",2,0
STU20CSE127,Rakesh Soni,LPU,3,Phagwara,"Python,ML,Data Analysis",2,0
STU19CSE302,Archana Prasad,CU,3,Gharuan,"Python,ML,Data Analysis",2,0
STU18CSE538,Siddharth Menon,Amity University,3,Noida,"Python,ML,Data Analysis",2,0`;

document.addEventListener('DOMContentLoaded', () => {
  checkBackendHealth();
  initEventListeners();
});

async function checkBackendHealth() {
  const badge = document.getElementById('healthBadge');
  const text = document.getElementById('healthText');
  try {
    const res = await fetch(`${BASE_URL}/`);
    if (res.ok) {
      const data = await res.json();
      badge.className = 'health-badge online';
      text.innerText = 'API ONLINE';
    } else {
      badge.className = 'health-badge offline';
      text.innerText = 'OFFLINE (RETRY)';
    }
  } catch (err) {
    badge.className = 'health-badge offline';
    text.innerText = 'OFFLINE (RETRY)';
  }
}

function initEventListeners() {
  const csvFileInput = document.getElementById('csvFileInput');
  const dropzone = document.getElementById('dropzone');
  const btnBrowse = document.getElementById('btnBrowse');
  const btnSample = document.getElementById('btnSample');
  const btnHistory = document.getElementById('btnHistory');
  const btnCloseDrawer = document.getElementById('btnCloseDrawer');

  btnBrowse.addEventListener('click', () => csvFileInput.click());

  csvFileInput.addEventListener('change', (e) => {
    if (e.target.files.length > 0) {
      uploadFile(e.target.files[0]);
    }
  });

  btnSample.addEventListener('click', () => {
    const blob = new Blob([SAMPLE_CSV], { type: 'text/csv' });
    const sampleFile = new File([blob], 'sample_hiring_data.csv', { type: 'text/csv' });
    uploadFile(sampleFile);
  });

  dropzone.addEventListener('click', () => csvFileInput.click());
  dropzone.addEventListener('dragover', (e) => {
    e.preventDefault();
    dropzone.classList.add('dragover');
  });
  dropzone.addEventListener('dragleave', () => dropzone.classList.remove('dragover'));
  dropzone.addEventListener('drop', (e) => {
    e.preventDefault();
    dropzone.classList.remove('dragover');
    if (e.dataTransfer.files.length > 0) {
      uploadFile(e.dataTransfer.files[0]);
    }
  });

  btnHistory.addEventListener('click', toggleDrawer);
  btnCloseDrawer.addEventListener('click', toggleDrawer);
}

function toggleDrawer() {
  const drawer = document.getElementById('historyDrawer');
  drawer.classList.toggle('open');
  if (drawer.classList.contains('open')) {
    fetchHistory();
  }
}

async function uploadFile(file) {
  showLoadingState(true, `Auditing dataset '${file.name}' against AI bias engine...`);

  const formData = new FormData();
  formData.append('file', file);

  try {
    const response = await fetch(`${BASE_URL}/audit`, {
      method: 'POST',
      body: formData,
    });

    const data = await response.json();
    showLoadingState(false);

    if (response.ok && data.status === 'success') {
      renderAuditReport(data);
    } else {
      showError(data.error || data.message || 'Audit execution failed.');
    }
  } catch (err) {
    showLoadingState(false);
    showError(`Network connection error: ${err.message}`);
  }
}

function showLoadingState(isLoading, message = '') {
  const dropzone = document.getElementById('dropzone');
  const loadingContainer = document.getElementById('auditLoading');
  const loadingText = document.getElementById('loadingText');
  const errorBox = document.getElementById('errorBox');

  errorBox.style.display = 'none';

  if (isLoading) {
    dropzone.style.display = 'none';
    loadingContainer.style.display = 'flex';
    loadingText.innerText = message;
  } else {
    loadingContainer.style.display = 'none';
  }
}

function showError(msg) {
  const errorBox = document.getElementById('errorBox');
  const dropzone = document.getElementById('dropzone');
  errorBox.innerText = `Error: ${msg}`;
  errorBox.style.display = 'block';
  dropzone.style.display = 'block';
}

function renderAuditReport(report) {
  document.getElementById('uploadSection').style.display = 'none';
  document.getElementById('reportSection').style.display = 'block';

  document.getElementById('reportFilename').innerText = report.filename;
  document.getElementById('reportAuditId').innerText = report.audit_id ? `Supabase Log #${report.audit_id}` : '';
  document.getElementById('metricCandidates').innerText = `${report.total_candidates_analyzed} Candidates`;
  
  const riskBadge = document.getElementById('metricRisk');
  const riskLevel = (report.overall_risk_profile || 'Moderate').toUpperCase();
  riskBadge.innerText = riskLevel;
  riskBadge.className = `risk-badge ${riskLevel === 'HIGH' ? 'risk-high' : 'risk-moderate'}`;

  document.getElementById('metricFindings').innerText = `${report.findings ? report.findings.length : 0} Vulnerabilities`;

  renderFindings(report.findings || []);
  renderRadarChart(report.bias_fingerprint || {});
}

function renderFindings(findings) {
  const container = document.getElementById('findingsContainer');
  container.innerHTML = '';

  if (findings.length === 0) {
    container.innerHTML = `<div class="dropzone-card"><p style="color:#10B981; font-weight:700;">No Disparities Detected</p></div>`;
    return;
  }

  findings.forEach((finding) => {
    const ai = finding.ai_insight || {};
    const card = document.createElement('div');
    card.className = 'cve-card';
    card.innerHTML = `
      <div class="cve-header">
        <div style="display:flex; align-items:center; gap:10px;">
          <span class="cve-pill">${finding.cve_id || 'FH-2026-001'}</span>
          <span class="sev-pill">${finding.severity_score ? finding.severity_score.toFixed(1) : '8.5'} ${finding.severity_level || 'CRITICAL'}</span>
        </div>
        <span style="color:#94A3B8; font-size:12px;">${finding.category || 'Bias Disparity'}</span>
      </div>
      <div class="cve-body">
        <div class="cve-title">${finding.title || 'Bias Vulnerability Detected'}</div>
        <div class="cve-desc">${finding.description || ''}</div>
        <div class="evidence-box">Evidence: ${finding.evidence || 'N/A'}</div>
        <div class="ai-card">
          <div class="ai-title">
            <span>✨ Gemini AI Remediation Insight</span>
            <span style="color:#94A3B8; font-weight:normal; font-size:11px;">Confidence: ${ai.confidence_percent || 85}% • Effort: ${ai.effort_level || 'Low'}</span>
          </div>
          <div style="font-size:12px; color:#E2E8F0; margin-bottom:6px;"><strong>Root Cause:</strong> ${ai.explanation || 'Analyzed'}</div>
          <div style="font-size:12px; color:#34D399;"><strong>Recommended Fix:</strong> ${ai.fix || 'Implement blinded screening'}</div>
        </div>
      </div>
    `;
    container.appendChild(card);
  });
}

function renderRadarChart(fp) {
  const canvas = document.getElementById('radarCanvas');
  const ctx = canvas.getContext('2d');
  
  canvas.width = 300;
  canvas.height = 220;

  const center = { x: 150, y: 110 };
  const radius = 70;
  const labels = ['College Tier', 'Name & Ethnicity', 'Location Tier'];
  const values = [
    fp.college_tier_bias || 5,
    fp.name_ethnicity_bias || 3,
    fp.location_tier_bias || 2
  ];

  ctx.clearRect(0, 0, canvas.width, canvas.height);

  // Draw grid
  for (let i = 1; i <= 4; i++) {
    const r = radius * (i / 4);
    ctx.beginPath();
    for (let j = 0; j < 3; j++) {
      const angle = (j * 2 * Math.PI / 3) - (Math.PI / 2);
      const x = center.x + r * Math.cos(angle);
      const y = center.y + r * Math.sin(angle);
      if (j === 0) ctx.moveTo(x, y);
      else ctx.lineTo(x, y);
    }
    ctx.closePath();
    ctx.strokeStyle = 'rgba(255,255,255,0.1)';
    ctx.stroke();
  }

  // Draw Radar Polygon
  ctx.beginPath();
  const points = [];
  for (let j = 0; j < 3; j++) {
    const angle = (j * 2 * Math.PI / 3) - (Math.PI / 2);
    const r = radius * (Math.min(10, values[j]) / 10);
    const x = center.x + r * Math.cos(angle);
    const y = center.y + r * Math.sin(angle);
    points.push({ x, y });
    if (j === 0) ctx.moveTo(x, y);
    else ctx.lineTo(x, y);
  }
  ctx.closePath();
  ctx.fillStyle = 'rgba(99, 102, 241, 0.35)';
  ctx.fill();
  ctx.strokeStyle = '#818CF8';
  ctx.lineWidth = 2;
  ctx.stroke();

  // Draw Dots
  points.forEach((pt) => {
    ctx.beginPath();
    ctx.arc(pt.x, pt.y, 4, 0, 2 * Math.PI);
    ctx.fillStyle = '#38BDF8';
    ctx.fill();
  });
}

async function fetchHistory() {
  const container = document.getElementById('historyList');
  container.innerHTML = '<p style="color:#94A3B8; text-align:center; padding:20px;">Loading Supabase logs...</p>';

  try {
    const res = await fetch(`${BASE_URL}/audits`);
    if (res.ok) {
      const data = await res.json();
      renderHistoryList(data.audits || []);
    } else {
      container.innerHTML = '<p style="color:#F87171; text-align:center; padding:20px;">Failed to load logs.</p>';
    }
  } catch (err) {
    container.innerHTML = '<p style="color:#F87171; text-align:center; padding:20px;">Error loading logs.</p>';
  }
}

function renderHistoryList(audits) {
  const container = document.getElementById('historyList');
  container.innerHTML = '';

  if (audits.length === 0) {
    container.innerHTML = '<p style="color:#94A3B8; text-align:center; padding:20px;">No audits recorded.</p>';
    return;
  }

  audits.forEach((audit) => {
    const div = document.createElement('div');
    div.style.cssText = 'background:#1E293B; border:1px solid rgba(255,255,255,0.08); padding:12px; border-radius:8px; margin-bottom:10px;';
    div.innerHTML = `
      <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:4px;">
        <span style="font-weight:700; font-size:13px; color:#fff;">${audit.filename}</span>
        <span class="risk-badge ${audit.risk_profile === 'High' ? 'risk-high' : 'risk-moderate'}" style="font-size:10px;">${audit.risk_profile}</span>
      </div>
      <div style="font-size:11px; color:#94A3B8;">Audit #${audit.id} • ${audit.total_analyzed} Candidates • ${audit.findings_count} Findings</div>
    `;
    container.appendChild(div);
  });
}

function resetToNewAudit() {
  document.getElementById('reportSection').style.display = 'none';
  document.getElementById('uploadSection').style.display = 'block';
  document.getElementById('dropzone').style.display = 'block';
}
