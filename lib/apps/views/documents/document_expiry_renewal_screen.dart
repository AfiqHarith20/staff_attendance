import 'package:flutter/material.dart';
import 'package:staff_attendance/widgets/app_page_widgets.dart';

class DocumentExpiryRenewalScreen extends StatelessWidget {
  const DocumentExpiryRenewalScreen({super.key});

  static const _documents = [
    (
      'Medical Certificate',
      'Uploaded on 20 Jul 2026',
      'Valid',
      'No action',
      Color(0xFF16A34A),
    ),
    (
      'Driver License',
      'Expires on 18 Sep 2026',
      'Expiring soon',
      'Renew within 56 days',
      Color(0xFFF59E0B),
    ),
    (
      'Work Permit',
      'Expires on 12 Aug 2026',
      'Urgent',
      'Renew within 19 days',
      Color(0xFFDC2626),
    ),
    (
      'Professional Certificate',
      'Expires on 30 Nov 2026',
      'Upcoming',
      'Plan renewal training',
      Color(0xFF185FA5),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            const AppPageHeader(title: 'Document Expiry & Renewal'),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stay ahead of expiring documents',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Track which files are still valid, which ones are expiring soon, and what should be re-uploaded for HR review.',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            for (final doc in _documents)
              AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: doc.$5.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.description_rounded,
                        color: doc.$5,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  doc.$1,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              AppStatusBadge(label: doc.$3, color: doc.$5),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            doc.$2,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            doc.$4,
                            style: TextStyle(
                              color: doc.$5,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.upload_file_rounded,
                                size: 18,
                              ),
                              label: const Text('Upload renewal'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
