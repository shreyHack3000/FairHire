import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BiasFingerprintChart extends StatelessWidget {
  final Map<String, dynamic> data;

  const BiasFingerprintChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              fillColor: const Color(0xFFEF4444).withOpacity(0.4),
              borderColor: const Color(0xFFEF4444),
              entryRadius: 3,
              dataEntries: [
                RadarEntry(value: (data['Institutional Pedigree Bias'] ?? 0).toDouble()),
                RadarEntry(value: (data['Socio-Cultural Identity Bias'] ?? 0).toDouble()),
                RadarEntry(value: (data['Geographic Access Bias'] ?? 0).toDouble()),
                const RadarEntry(value: 0), // Placeholder for v2
                const RadarEntry(value: 0), // Placeholder for v2
              ],
            ),
          ],
          radarBackgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          radarShape: RadarShape.circle,
          getTitle: (index, angle) {
            switch (index) {
              case 0: return RadarChartTitle(text: 'Institutional');
              case 1: return RadarChartTitle(text: 'Cultural');
              case 2: return RadarChartTitle(text: 'Geographic');
              case 3: return RadarChartTitle(text: 'Gender (v2)');
              case 4: return RadarChartTitle(text: 'Experience (v2)');
              default: return const RadarChartTitle(text: '');
            }
          },
          tickCount: 5,
          ticksTextStyle: const TextStyle(color: Colors.white24, fontSize: 10),
          gridBorderData: const BorderSide(color: Colors.white12, width: 1),
        ),
      ),
    );
  }
}
