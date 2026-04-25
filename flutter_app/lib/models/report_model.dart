class AuditReport {
  final String status;
  final String filename;
  final int totalCandidates;
  final String overallRisk;
  final Map<String, dynamic> fingerprint;
  final List<BiasFinding> findings;

  AuditReport({
    required this.status,
    required this.filename,
    required this.totalCandidates,
    required this.overallRisk,
    required this.fingerprint,
    required this.findings,
  });

  factory AuditReport.fromJson(Map<String, dynamic> json) {
    return AuditReport(
      status: json['status'] ?? 'success',
      filename: json['filename'] ?? 'unknown',
      totalCandidates: (json['total_candidates_analyzed'] ?? 0) is int
          ? json['total_candidates_analyzed']
          : (json['total_candidates_analyzed'] as num).toInt(),
      overallRisk: json['overall_risk_profile'] ?? 'Unknown',
      fingerprint: json['bias_fingerprint'] ?? {},
      findings: (json['findings'] as List? ?? [])
          .map((f) => BiasFinding.fromJson(Map<String, dynamic>.from(f)))
          .toList(),
    );
  }
}

class BiasFinding {
  final String title;
  final String cveId;
  final double severityScore;
  final String severityLabel;
  final double disparityRatio;
  final String evidence;
  final AIInsight aiInsight;

  BiasFinding({
    required this.title,
    required this.cveId,
    required this.severityScore,
    required this.severityLabel,
    required this.disparityRatio,
    required this.evidence,
    required this.aiInsight,
  });

  factory BiasFinding.fromJson(Map<String, dynamic> json) {
    // Handle ai_insight being null or missing
    Map<String, dynamic> insightJson;
    if (json['ai_insight'] != null) {
      insightJson = Map<String, dynamic>.from(json['ai_insight']);
    } else {
      insightJson = {
        'explanation': 'AI insight unavailable.',
        'fix': 'Implement blind screening and standardized evaluation rubrics.',
        'confidence_percent': 0,
        'effort_level': 'Medium',
      };
    }

    return BiasFinding(
      title: json['title'] ?? 'Unknown Bias',
      cveId: json['cve_id'] ?? 'IN-BIAS-0000',
      severityScore: (json['severity_score'] ?? 0).toDouble(),
      severityLabel: json['severity_label'] ?? 'Unknown',
      disparityRatio: (json['disparity_ratio'] ?? 1.0).toDouble(),
      evidence: json['evidence'] ?? 'No evidence available.',
      aiInsight: AIInsight.fromJson(insightJson),
    );
  }
}

class AIInsight {
  final String explanation;
  final String fix;
  final int confidence;
  final String effort;

  AIInsight({
    required this.explanation,
    required this.fix,
    required this.confidence,
    required this.effort,
  });

  factory AIInsight.fromJson(Map<String, dynamic> json) {
    return AIInsight(
      explanation: json['explanation']?.toString() ?? 'Analysis in progress.',
      fix: json['fix']?.toString() ?? 'Standard remediation: Implement blind screening.',
      confidence: (json['confidence_percent'] ?? 0) is int
          ? json['confidence_percent']
          : (json['confidence_percent'] as num?)?.toInt() ?? 0,
      effort: json['effort_level']?.toString() ?? 'Medium',
    );
  }
}
