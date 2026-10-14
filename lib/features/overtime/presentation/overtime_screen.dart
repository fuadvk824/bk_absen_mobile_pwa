import 'package:bk_absen/features/overtime/presentation/widgets/overtime_form_bottom_sheet.dart';
import 'package:bk_absen/features/overtime/presentation/widgets/overtime_item.dart';
import 'package:bk_absen/features/overtime/provider/overtime_provider.dart';
import 'package:bk_absen/model/overtime_model.dart';
import 'package:bk_absen/model/overtime_period.dart';
import 'package:bk_absen/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class OvertimeScreen extends ConsumerStatefulWidget {
  final String title;

  const OvertimeScreen({super.key, required this.title});

  @override
  ConsumerState<OvertimeScreen> createState() => _OvertimeScreenState();
}

class _OvertimeScreenState extends ConsumerState<OvertimeScreen> {
  String selectedStatus = 'all';

  void _showOvertimeForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return OvertimeFormBottomSheet(
          onSubmit:
              ({
                required String date,
                required String timeFrom,
                required String timeTo,
                required String reason,
              }) async {
                final notifier = ref.read(overtimeProvider.notifier);

                return await notifier.submit(
                  date: date,
                  timeFrom: timeFrom,
                  timeTo: timeTo,
                  reason: reason,
                );
              },
        );
      },
    );
  }

  List<OvertimeModel> _filteredData(List<OvertimeModel> data) {
    if (selectedStatus == 'all') {
      return data;
    }

    return data
        .where(
          (item) => item.status.toLowerCase() == selectedStatus.toLowerCase(),
        )
        .toList();
  }

  String _formatTotalOvertime(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours == 0 && minutes == 0) {
      return '0j';
    }

    if (minutes == 0) {
      return '${hours}j';
    }

    if (hours == 0) {
      return '${minutes}m';
    }

    return '${hours}j ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(overtimeProvider);
    final notifier = ref.read(overtimeProvider.notifier);

    final filteredData = _filteredData(state.data);

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
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showOvertimeForm,
          ),
        ],
      ),

      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildPeriodDropdown(state),

                _buildStatusFilter(),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await notifier.load(period: state.selectedPeriod);
                    },

                    child: filteredData.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),

                            padding: const EdgeInsets.only(top: 5, bottom: 10),

                            itemCount: filteredData.length,

                            itemBuilder: (context, index) {
                              return OvertimeItem(
                                overtime: filteredData[index],
                              );
                            },
                          ),
                  ),
                ),
              ],
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
                offset: Offset(0, -bottomInset / 2),
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
                          LucideIcons.clockPlus,
                          size: 44,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        selectedStatus == 'all'
                            ? 'Belum Ada Data Lembur'
                            : 'Belum Ada Data',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        selectedStatus == 'all'
                            ? 'Belum ada pengajuan lembur yang tercatat diperiode ini.'
                            : 'Belum ada pengajuan lembur dengan status '
                                  '${_statusLabel(selectedStatus)}.',
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

  Widget _buildStatusFilter() {
    const statuses = ['all', 'approved', 'pending', 'rejected'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: statuses.map((status) {
            final isSelected = selectedStatus == status;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_statusLabel(status)),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    selectedStatus = status;
                  });
                },
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';

      case 'pending':
        return 'Pending';

      case 'rejected':
        return 'Rejected';

      default:
        return 'Semua';
    }
  }

  Widget _buildPeriodDropdown(OvertimeState state) {
    final selectedPeriod = ref.watch(
      overtimeProvider.select((state) => state.selectedPeriod),
    );

    final currentPeriod = getCurrentOvertimePeriod();
    final totalOvertimeText = _formatTotalOvertime(state.totalOvertimeMinutes);

    return Container(
      width: double.infinity,
      height: 54,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          
          Expanded(
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedPeriod,
                  isExpanded: true,
                  dropdownColor: Colors.white,

                  selectedItemBuilder: (context) {
                    return overtimePeriods.map((period) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          period.label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList();
                  },

                  items: overtimePeriods.map((period) {
                    final bool isCurrent = period.value == currentPeriod;

                    return DropdownMenuItem<int>(
                      value: period.value,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                period.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isCurrent
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            if (isCurrent)
                              const Text(
                                'Saat ini',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  onChanged: (value) {
                    if (value == null) return;

                    ref.read(overtimeProvider.notifier).changePeriod(value);
                  },
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.clock,
                  size: 17,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  totalOvertimeText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
