import 'package:flutter/material.dart';

class HeaderBar extends StatelessWidget {
  final bool isBackendHealthy;
  final bool isCheckingBackend;
  final VoidCallback onRefreshHealth;
  final VoidCallback onOpenHistory;

  const HeaderBar({
    Key? key,
    required this.isBackendHealthy,
    required this.isCheckingBackend,
    required this.onRefreshHealth,
    required this.onOpenHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.9),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo + Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'FairHire',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF6366F1).withOpacity(0.4),
                          ),
                        ),
                        child: const Text(
                          'AI BIAS AUDITOR',
                          style: TextStyle(
                            color: Color(0xFFA5B4FC),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Pentest-Style Bias Vulnerability Auditor for Automated Hiring Systems',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Actions & Backend Status Badge
          Row(
            children: [
              // History Button
              InkWell(
                onTap: onOpenHistory,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.history_outlined,
                          color: Color(0xFFCBD5E1), size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Audit History',
                        style: TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Backend Health Badge
              Tooltip(
                message: isBackendHealthy
                    ? 'Connected to live Supabase PostgreSQL API (fairhire-backend-f8mp.onrender.com)'
                    : 'Click to retry server health check',
                child: InkWell(
                  onTap: onRefreshHealth,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isBackendHealthy
                          ? const Color(0xFF059669).withOpacity(0.15)
                          : const Color(0xFFDC2626).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isBackendHealthy
                            ? const Color(0xFF10B981).withOpacity(0.4)
                            : const Color(0xFFEF4444).withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCheckingBackend
                                ? Colors.amber
                                : (isBackendHealthy
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444)),
                            boxShadow: [
                              if (isBackendHealthy)
                                BoxShadow(
                                  color:
                                      const Color(0xFF10B981).withOpacity(0.6),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isCheckingBackend
                              ? 'Checking...'
                              : (isBackendHealthy
                                  ? 'API ONLINE'
                                  : 'OFFLINE (RETRY)'),
                          style: TextStyle(
                            color: isBackendHealthy
                                ? const Color(0xFF34D399)
                                : const Color(0xFFF87171),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
