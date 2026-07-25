import 'package:flutter/material.dart';
import '../models/audit_models.dart';
import 'bias_radar_chart.dart';

class AuditResultsView extends StatelessWidget {
  final AuditReport report;
  final VoidCallback onNewAudit;

  const AuditResultsView({
    Key? key,
    required this.report,
    required this.onNewAudit,
  }) : super(key: key);

  Color _getSeverityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'CRITICAL':
        return const Color(0xFFEF4444); // Red
      case 'HIGH':
        return const Color(0xFFF97316); // Orange
      case 'MEDIUM':
      case 'MODERATE':
        return const Color(0xFFF59E0B); // Amber
      case 'LOW':
      default:
        return const Color(0xFF10B981); // Emerald
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHighRisk = report.overallRiskProfile.toLowerCase() == 'high' ||
        report.overallRiskProfile.toLowerCase() == 'critical';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Action Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.verified_outlined,
                      color: Color(0xFF34D399), size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audit Analysis Report: ${report.filename}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (report.auditId != null)
                      Text(
                        'Supabase PostgreSQL Audit Log #${report.auditId}',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: onNewAudit,
              icon: const Icon(Icons.upload_file_outlined, size: 16),
              label: const Text('Audit Another CSV'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF334155),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Summary Metric Cards Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 700;
            return GridView.count(
              crossAxisCount: isMobile ? 2 : 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 1.6 : 2.2,
              children: [
                _buildSummaryCard(
                  'Total Analyzed',
                  '${report.totalCandidatesAnalyzed} Candidates',
                  Icons.groups_outlined,
                  const Color(0xFF38BDF8),
                ),
                _buildSummaryCard(
                  'Overall Risk Profile',
                  report.overallRiskProfile.toUpperCase(),
                  Icons.security_outlined,
                  _getSeverityColor(report.overallRiskProfile),
                  isBadge: true,
                ),
                _buildSummaryCard(
                  'Vulnerabilities Found',
                  '${report.findings.length} Disparities',
                  Icons.bug_report_outlined,
                  isHighRisk ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                ),
                _buildSummaryCard(
                  'Audit Status',
                  'Verified & Logged',
                  Icons.cloud_done_outlined,
                  const Color(0xFF10B981),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 28),

        // Main Layout: Findings List + Sidebar Radar Chart
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 900) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side: Detailed CVE Vulnerability Findings (60% width)
                  Expanded(
                    flex: 6,
                    child: _buildFindingsList(),
                  ),
                  const SizedBox(width: 24),
                  // Right side: Radar Chart & Security Summary (4% width)
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        BiasRadarChart(fingerprint: report.biasFingerprint),
                        const SizedBox(height: 16),
                        _buildPentestSummaryCard(),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  BiasRadarChart(fingerprint: report.biasFingerprint),
                  const SizedBox(height: 20),
                  _buildFindingsList(),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color accentColor,
      {bool isBadge = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          isBadge
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: accentColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildFindingsList() {
    if (report.findings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 48),
              SizedBox(height: 12),
              Text(
                'No Disparities Detected!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'The candidate selection ratios fall within acceptable statistical thresholds.',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.terminal_outlined, color: Color(0xFF6366F1), size: 20),
            SizedBox(width: 8),
            Text(
              'DETECTED BIAS VULNERABILITIES (CVE REPORTS)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: report.findings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final finding = report.findings[index];
            final sevColor = _getSeverityColor(finding.severityLevel);
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: sevColor.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: sevColor.withOpacity(0.08),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // CVE ID Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: sevColor.withOpacity(0.6),
                            ),
                          ),
                          child: Text(
                            finding.cveId,
                            style: TextStyle(
                              color: sevColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Severity Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: sevColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${finding.severityScore.toStringAsFixed(1)} ${finding.severityLevel.toUpperCase()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          finding.category,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Card Body
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          finding.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          finding.description,
                          style: const TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Evidence Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.find_in_page_outlined,
                                  color: Color(0xFF38BDF8), size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Evidence: ${finding.evidence}',
                                  style: const TextStyle(
                                    color: Color(0xFF38BDF8),
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Gemini AI Remediation Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6366F1).withOpacity(0.12),
                                const Color(0xFF8B5CF6).withOpacity(0.12),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.auto_awesome,
                                      color: Color(0xFFA5B4FC), size: 18),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Gemini AI Remediation Plan',
                                    style: TextStyle(
                                      color: Color(0xFFA5B4FC),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Confidence: ${finding.aiInsight.confidencePercent}% • Effort: ${finding.aiInsight.effortLevel}',
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Root Cause: ${finding.aiInsight.explanation}',
                                style: const TextStyle(
                                  color: Color(0xFFE2E8F0),
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Fix Action: ',
                                    style: TextStyle(
                                      color: Color(0xFF34D399),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      finding.aiInsight.fix,
                                      style: const TextStyle(
                                        color: Color(0xFF34D399),
                                        fontSize: 12,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPentestSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF38BDF8), size: 18),
              SizedBox(width: 8),
              Text(
                'COMPLIANCE & RISK STANDARD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'FairHire uses standardized 80% selection ratio thresholds (EEOC Four-Fifths Rule) and pentest-style scoring to identify systemically biased filters before candidates are impacted.',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
