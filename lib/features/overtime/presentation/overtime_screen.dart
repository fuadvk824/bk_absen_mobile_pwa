import 'package:bk_absen/features/overtime/presentation/widgets/overtime_form_bottom_sheet.dart';
import 'package:bk_absen/features/overtime/presentation/widgets/overtime_item.dart';
import 'package:bk_absen/features/overtime/provider/overtime_provider.dart';
import 'package:bk_absen/model/overtime_model.dart';
import 'package:bk_absen/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          style: TextStyle(
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
                // FILTER STATUS
                _buildStatusFilter(),

                // LIST
                Expanded(
                  child: filteredData.isEmpty
                      ? Center(
                          child: Text(
                            selectedStatus == 'all'
                                ? 'Belum ada data lembur'
                                : 'Belum ada lembur dengan status ${_statusLabel(selectedStatus)}',
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await notifier.load();
                          },
                          child: ListView.builder(
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

  Widget _buildStatusFilter() {
    const statuses = ['all', 'approved', 'pending', 'rejected'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
}
