import 'package:flutter/material.dart';
import 'package:fairhire_app/models/report_model.dart';
import 'package:fairhire_app/widgets/bias_fingerprint.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? rawReport = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    if (rawReport == null) {
      return const Scaffold(body: Center(child: Text('No data found')));
    }

    final report = AuditReport.fromJson(rawReport);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AUDIT REPORT'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, report),
            const SizedBox(height: 40),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: report.findings.map((f) => _buildFindingCard(context, f)).toList(),
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildRadarSection(context, report),
                      const SizedBox(height: 24),
                      _buildStatsCard(context, report),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuditReport report) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXECUTIVE SUMMARY',
                  style: GoogleFonts.dmMono(
                    color: const Color(0xFFEF4444),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Analysis of ${report.filename} detected significant hiring disparities. The overall risk profile is classified as ${report.overallRisk.toUpperCase()}.',
                  style: const TextStyle(fontSize: 18, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          _buildScorePill(report.overallRisk),
        ],
      ),
    );
  }

  Widget _buildScorePill(String risk) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: risk == 'High' ? const Color(0xFFEF4444) : Colors.orange,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        risk.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildFindingCard(BuildContext context, BiasFinding finding) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(finding.title, style: Theme.of(context).textTheme.titleLarge),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    finding.cveId,
                    style: GoogleFonts.dmMono(color: const Color(0xFFEF4444), fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSeverityBar(finding.severityScore, finding.severityLabel),
            const SizedBox(height: 24),
            Text('EVIDENCE', style: GoogleFonts.dmMono(color: Colors.white54, fontSize: 10)),
            const SizedBox(height: 8),
            Text(finding.evidence, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Text('REMEDIATION PLAN', style: GoogleFonts.dmMono(color: Colors.blue, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(finding.aiInsight.fix, style: const TextStyle(fontSize: 14, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBar(double score, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Severity Score: ${score.toStringAsFixed(1)}/10', style: const TextStyle(fontSize: 12)),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: score / 10,
          backgroundColor: Colors.white10,
          color: score > 7 ? const Color(0xFFEF4444) : Colors.orange,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }

  Widget _buildRadarSection(BuildContext context, AuditReport report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('BIAS FINGERPRINT', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            BiasFingerprintChart(data: report.fingerprint),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, AuditReport report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AUDIT METADATA', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildStatRow('Candidates Analyzed', report.totalCandidates.toString()),
            _buildStatRow('Detection Modules', '3 Active / 2 Pending'),
            _buildStatRow('Compliance Standard', 'ISO/IEC 24028 (AI Robustness)'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
