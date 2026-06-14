import 'package:bk_absen/features/overtime/presentation/widgets/overtime_form_bottom_sheet.dart';
import 'package:bk_absen/features/overtime/presentation/widgets/overtime_item.dart';
import 'package:bk_absen/features/overtime/provider/overtime_provider.dart';
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
  final TextEditingController reasonController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(overtimeProvider);
    final notifier = ref.read(overtimeProvider.notifier);

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
          : state.data.isEmpty
          ? const Center(child: Text("Belum ada data lembur"))
          : RefreshIndicator(
              onRefresh: () async {
                await notifier.load();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ListView.builder(
                  itemCount: state.data.length,
                  itemBuilder: (context, index) {
                    return OvertimeItem(overtime: state.data[index]);
                  },
                ),
              ),
            ),
    );
  }
}
