import 'dart:typed_data';

import 'package:bk_absen/features/leave/presentation/widgets/leave_form_bottom_sheet.dart';
import 'package:bk_absen/features/leave/presentation/widgets/leave_item.dart';
import 'package:bk_absen/features/leave/provider/leave_provider.dart';
import 'package:bk_absen/model/leave_balance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bk_absen/utils/app_colors.dart';

class LeaveScreen extends ConsumerStatefulWidget {
  final String title;

  const LeaveScreen({super.key, required this.title});

  @override
  ConsumerState<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends ConsumerState<LeaveScreen> {
  void _showLeaveForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return LeaveFormBottomSheet(
          onSubmit:
              ({
                required int leaveCategoryId,
                required String startDate,
                required String endDate,
                required String reason,
                String? fileName,
                Uint8List? fileBytes,
              }) async {
                final notifier = ref.read(leaveProvider.notifier);

                return notifier.submit(
                  leaveCategoryId: leaveCategoryId,
                  startDate: startDate,
                  endDate: endDate,
                  reason: reason,
                  fileName: fileName,
                  fileBytes: fileBytes,
                );
              },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaveProvider);
    final notifier = ref.read(leaveProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: AppColors.light,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(
          color: AppColors.light,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: AppColors.light,
            ),
            onPressed: _showLeaveForm,
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await notifier.load();
              },
              child: Column(
                children: [
                  if (state.balances.isNotEmpty)
                    _buildBalances(state.balances),

                  Expanded(
                    child: state.data.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            physics:
                                const AlwaysScrollableScrollPhysics(),
                            itemCount: state.data.length,
                            itemBuilder: (context, index) {
                              final leave = state.data[index];

                              return LeaveItemWidget(
                                leave: leave,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bottomInset = MediaQuery.of(context).padding.bottom;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            width: double.infinity,
            height: constraints.maxHeight,
            child: Center(
              child: Transform.translate(
                offset: Offset(
                  0,
                  -bottomInset / 2,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF016E0A,
                          ).withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.calendarX,
                          size: 44,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Belum Ada Data Cuti',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Belum ada pengajuan cuti yang tercatat.',
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
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalances(List<LeaveBalanceModel> balances) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: balances.length,
        itemBuilder: (context, index) {
          final b = balances[index];

          return Container(
            width: 150,
            margin: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 10,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: b.remainingDays == 0
                  ? AppColors.dark
                  : AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    b.leaveName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "${b.remainingDays} hari",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  "${b.usedDays}/${b.totalQuota}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
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