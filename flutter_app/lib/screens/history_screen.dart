import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock historical data for the prototype story (Improving scores)
    final List<Map<String, dynamic>> mockHistory = [
      {
        'date': '2025-04-10',
        'company': 'Tech Solutions Inc.',
        'score': 8.4,
        'label': 'HIGH',
        'candidates': 120,
      },
      {
        'date': '2025-03-15',
        'company': 'Global HR',
        'score': 6.1,
        'label': 'MEDIUM',
        'candidates': 85,
      },
      {
        'date': '2025-02-01',
        'company': 'Startup X',
        'score': 3.2,
        'label': 'LOW',
        'candidates': 45,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AUDIT HISTORY'),
      ),
      body: Center(
        child: Container(
          width: 800,
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Previous Audits',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('Track your organization\'s progress in mitigating algorithmic bias.'),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: mockHistory.length,
                  itemBuilder: (context, index) {
                    final item = mockHistory[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: _getColor(item['label']),
                          child: Text(
                            item['score'].toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(item['company'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${item['date']} • ${item['candidates']} candidates analyzed'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildPill(item['label']),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () {
                          // In a real app, this would fetch the report details
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Report details would open here.')),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor(label).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getColor(label).withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: _getColor(label), fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getColor(String label) {
    switch (label) {
      case 'HIGH': return const Color(0xFFEF4444);
      case 'MEDIUM': return Colors.orange;
      case 'LOW': return const Color(0xFF22C55E);
      default: return Colors.grey;
    }
  }
}
