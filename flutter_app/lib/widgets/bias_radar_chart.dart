import 'dart:math';
import 'package:flutter/material.dart';
import '../models/audit_models.dart';

class BiasRadarChart extends StatelessWidget {
  final BiasFingerprint fingerprint;

  const BiasRadarChart({Key? key, required this.fingerprint}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar, color: Color(0xFF818CF8), size: 20),
              const SizedBox(width: 8),
              const Text(
                'BIAS FINGERPRINT RADAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Score range 0 - 10',
                  style: TextStyle(color: Color(0xFFA5B4FC), fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            width: double.infinity,
            child: CustomPaint(
              painter: _RadarChartPainter(fingerprint: fingerprint),
            ),
          ),
          const SizedBox(height: 12),
          // Legend / Score Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricChip('College Tier', fingerprint.collegeTierBias, const Color(0xFFEF4444)),
              _buildMetricChip('Name & Ethnicity', fingerprint.nameEthnicityBias, const Color(0xFFF59E0B)),
              _buildMetricChip('Location Tier', fingerprint.locationTierBias, const Color(0xFF10B981)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final BiasFingerprint fingerprint;

  _RadarChartPainter({required this.fingerprint});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2.6;

    final labels = ['College Tier', 'Name & Ethnicity', 'Location Tier'];
    final values = [
      fingerprint.collegeTierBias.clamp(0.0, 10.0),
      fingerprint.nameEthnicityBias.clamp(0.0, 10.0),
      fingerprint.locationTierBias.clamp(0.0, 10.0),
    ];

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final axisPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Concentric grid circles / polygons
    for (int i = 1; i <= 4; i++) {
      final currentRadius = radius * (i / 4);
      final gridPath = Path();
      for (int j = 0; j < 3; j++) {
        final angle = (j * 2 * pi / 3) - (pi / 2);
        final x = center.dx + currentRadius * cos(angle);
        final y = center.dy + currentRadius * sin(angle);
        if (j == 0) {
          gridPath.moveTo(x, y);
        } else {
          gridPath.lineTo(x, y);
        }
      }
      gridPath.close();
      canvas.drawPath(gridPath, gridPaint);
    }

    // Axes & Values
    final polygonPath = Path();
    final points = <Offset>[];

    for (int j = 0; j < 3; j++) {
      final angle = (j * 2 * pi / 3) - (pi / 2);
      final axisX = center.dx + radius * cos(angle);
      final axisY = center.dy + radius * sin(angle);
      canvas.drawLine(center, Offset(axisX, axisY), axisPaint);

      // Value point
      final valRadius = radius * (values[j] / 10.0);
      final vx = center.dx + valRadius * cos(angle);
      final vy = center.dy + valRadius * sin(angle);
      points.add(Offset(vx, vy));

      if (j == 0) {
        polygonPath.moveTo(vx, vy);
      } else {
        polygonPath.lineTo(vx, vy);
      }
    }
    polygonPath.close();

    // Draw Filled Radar Area
    final fillPaint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.35)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF818CF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawPath(polygonPath, fillPaint);
    canvas.drawPath(polygonPath, borderPaint);

    // Draw value points
    final pointPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.fill;

    for (var pt in points) {
      canvas.drawCircle(pt, 4.5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.fingerprint != fingerprint;
  }
}
