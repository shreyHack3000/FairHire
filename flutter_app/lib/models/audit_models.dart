class AiInsight {
  final String explanation;
  final String fix;
  final int confidencePercent;
  final String effortLevel;

  AiInsight({
    required this.explanation,
    required this.fix,
    required this.confidencePercent,
    required this.effortLevel,
  });

  factory AiInsight.fromJson(Map<String, dynamic> json) {
    return AiInsight(
      explanation: json['explanation']?.toString() ?? 'Analysis pending.',
      fix: json['fix']?.toString() ?? 'Review candidate evaluation metrics.',
      confidencePercent: (json['confidence_percent'] is num)
          ? (json['confidence_percent'] as num).toInt()
          : 85,
      effortLevel: json['effort_level']?.toString() ?? 'Low',
    );
  }
}

class AuditFinding {
  final String cveId;
  final double severityScore;
  final String severityLevel;
  final String category;
  final String title;
  final String description;
  final String evidence;
  final AiInsight aiInsight;

  AuditFinding({
    required this.cveId,
    required this.severityScore,
    required this.severityLevel,
    required this.category,
    required this.title,
    required this.description,
    required this.evidence,
    required this.aiInsight,
  });

  factory AuditFinding.fromJson(Map<String, dynamic> json) {
    return AuditFinding(
      cveId: json['cve_id']?.toString() ?? 'FH-2026-000',
      severityScore: (json['severity_score'] is num)
          ? (json['severity_score'] as num).toDouble()
          : 5.0,
      severityLevel: json['severity_level']?.toString() ?? 'MEDIUM',
      category: json['category']?.toString() ?? 'General Bias',
      title: json['title']?.toString() ?? 'Detected Disparity',
      description: json['description']?.toString() ?? 'Potential bias detected in dataset.',
      evidence: json['evidence']?.toString() ?? 'N/A',
      aiInsight: json['ai_insight'] != null
          ? AiInsight.fromJson(Map<String, dynamic>.from(json['ai_insight']))
          : AiInsight(
              explanation: 'Insight unavailable.',
              fix: 'Contact administrator.',
              confidencePercent: 50,
              effortLevel: 'Low',
            ),
    );
  }
}

class BiasFingerprint {
  final double collegeTierBias;
  final double nameEthnicityBias;
  final double locationTierBias;

  BiasFingerprint({
    required this.collegeTierBias,
    required this.nameEthnicityBias,
    required this.locationTierBias,
  });

  factory BiasFingerprint.fromJson(Map<String, dynamic> json) {
    return BiasFingerprint(
      collegeTierBias: (json['college_tier_bias'] is num)
          ? (json['college_tier_bias'] as num).toDouble()
          : 0.0,
      nameEthnicityBias: (json['name_ethnicity_bias'] is num)
          ? (json['name_ethnicity_bias'] as num).toDouble()
          : 0.0,
      locationTierBias: (json['location_tier_bias'] is num)
          ? (json['location_tier_bias'] as num).toDouble()
          : 0.0,
    );
  }
}

class AuditReport {
  final String status;
  final String filename;
  final int totalCandidatesAnalyzed;
  final String overallRiskProfile;
  final BiasFingerprint biasFingerprint;
  final List<AuditFinding> findings;
  final int? auditId;

  AuditReport({
    required this.status,
    required this.filename,
    required this.totalCandidatesAnalyzed,
    required this.overallRiskProfile,
    required this.biasFingerprint,
    required this.findings,
    this.auditId,
  });

  factory AuditReport.fromJson(Map<String, dynamic> json) {
    var rawFindings = json['findings'] as List? ?? [];
    List<AuditFinding> findingsList = rawFindings
        .map((f) => AuditFinding.fromJson(Map<String, dynamic>.from(f)))
        .toList();

    return AuditReport(
      status: json['status']?.toString() ?? 'success',
      filename: json['filename']?.toString() ?? 'uploaded_dataset.csv',
      totalCandidatesAnalyzed: (json['total_candidates_analyzed'] is num)
          ? (json['total_candidates_analyzed'] as num).toInt()
          : 0,
      overallRiskProfile: json['overall_risk_profile']?.toString() ?? 'Moderate',
      biasFingerprint: json['bias_fingerprint'] != null
          ? BiasFingerprint.fromJson(Map<String, dynamic>.from(json['bias_fingerprint']))
          : BiasFingerprint(collegeTierBias: 5.0, nameEthnicityBias: 3.0, locationTierBias: 2.0),
      findings: findingsList,
      auditId: json['audit_id'] is num ? (json['audit_id'] as num).toInt() : null,
    );
  }
}

class AuditHistoryItem {
  final int id;
  final String filename;
  final int totalAnalyzed;
  final String riskProfile;
  final int findingsCount;
  final String? createdAt;

  AuditHistoryItem({
    required this.id,
    required this.filename,
    required this.totalAnalyzed,
    required this.riskProfile,
    required this.findingsCount,
    this.createdAt,
  });

  factory AuditHistoryItem.fromJson(Map<String, dynamic> json) {
    return AuditHistoryItem(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      filename: json['filename']?.toString() ?? 'dataset.csv',
      totalAnalyzed: (json['total_analyzed'] is num)
          ? (json['total_analyzed'] as num).toInt()
          : 0,
      riskProfile: json['risk_profile']?.toString() ?? 'Moderate',
      findingsCount: (json['findings_count'] is num)
          ? (json['findings_count'] as num).toInt()
          : 0,
      createdAt: json['created_at']?.toString(),
    );
  }
}
