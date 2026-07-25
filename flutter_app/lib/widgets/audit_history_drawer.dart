import 'package:flutter/material.dart';
import '../models/audit_models.dart';

class AuditHistoryDrawer extends StatelessWidget {
  final List<AuditHistoryItem> historyItems;
  final bool isLoading;
  final VoidCallback onRefresh;
  final Function(AuditHistoryItem item)? onSelectAudit;

  const AuditHistoryDrawer({
    Key? key,
    required this.historyItems,
    required this.isLoading,
    required this.onRefresh,
    this.onSelectAudit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0F172A),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.storage_outlined,
                      color: Color(0xFF6366F1), size: 22),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audit History Log',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Supabase PostgreSQL Database',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh,
                        color: Color(0xFF94A3B8), size: 20),
                    onPressed: onRefresh,
                    tooltip: 'Refresh Supabase Audits',
                  ),
                ],
              ),
            ),

            // Audit List
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                      ),
                    )
                  : (historyItems.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.folder_open_outlined,
                                    color: Color(0xFF64748B), size: 40),
                                SizedBox(height: 12),
                                Text(
                                  'No Historical Audits Yet',
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: historyItems.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = historyItems[index];
                            final isHighRisk =
                                item.riskProfile.toLowerCase() == 'high';

                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.08),
                                ),
                              ),
                              child: ListTile,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.filename,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isHighRisk
                                          ? const Color(0xFFEF4444)
                                              .withOpacity(0.2)
                                          : const Color(0xFFF59E0B)
                                              .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.riskProfile.toUpperCase(),
                                      style: TextStyle(
                                        color: isHighRisk
                                            ? const Color(0xFFF87171)
                                            : const Color(0xFFFBBF24),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  'Audit #${item.id} • ${item.totalAnalyzed} Candidates • ${item.findingsCount} Findings',
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              onTap: onSelectAudit != null
                                  ? () => onSelectAudit!(item)
                                  : null,
                            );
                          },
                        )),
            ),
          ],
        ),
      ),
    );
  }
}
