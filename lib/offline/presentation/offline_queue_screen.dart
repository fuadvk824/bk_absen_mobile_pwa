import 'package:bk_absen/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/offline_attendance_model.dart';

class OfflineQueueScreen extends StatelessWidget {
  const OfflineQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Box<OfflineAttendanceModel> box = Hive.box<OfflineAttendanceModel>(
      'offline_attendance',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Queue',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            Text(
              'Attendance Synchronization',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      body: ValueListenableBuilder<Box<OfflineAttendanceModel>>(
        valueListenable: box.listenable(),
        builder: (context, box, _) {
          final items = box.values.toList();

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (items.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      // Beri ruang agar pusat visual tidak tertutup bottom navbar.
                      padding: const EdgeInsets.only(bottom: 100),
                      child: const _EmptyState(),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, i) {
                        final item = items[i];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _OfflineAttendanceCard(item: item, index: i),
                        );
                      }, childCount: items.length),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OfflineAttendanceCard extends StatelessWidget {
  final OfflineAttendanceModel item;
  final int index;

  const _OfflineAttendanceCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final bool synced = item.synced;

    final Color statusColor = synced ? Colors.green : Colors.orange;

    final Color statusBackground = synced
        ? Colors.green.shade50
        : Colors.orange.shade50;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF016E0A).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    item.type.toLowerCase().contains('in')
                        ? Icons.login_rounded
                        : Icons.logout_rounded,
                    color: const Color(0xFF016E0A),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.type,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '#${index + 1} • ${item.employeeId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 6),

                      Text(
                        synced ? 'Synced' : 'Pending',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Divider(height: 1, color: Colors.grey.shade200),

            const SizedBox(height: 14),

            // Information
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.flag_outlined,
                    label: 'Status',
                    value: item.status,
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.sync_problem_outlined,
                    label: 'Retry',
                    value: '${item.retryCount}x',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.location_on_outlined,
                    label: 'Distance',
                    value: '${item.distance}',
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.access_time_outlined,
                    label: 'Created',
                    value: _formatDate(item.createdAt),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');

    final String month = date.month.toString().padLeft(2, '0');

    final String hour = date.hour.toString().padLeft(2, '0');

    final String minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} $hour:$minute';
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF016E0A).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_done_outlined,
                size: 44,
                 color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Queue Kosong',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 8),

            Text(
              'Tidak ada antrian data untuk disinkronkan',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
