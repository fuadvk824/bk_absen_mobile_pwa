import 'package:bk_absen/utils/toast_helper.dart';
import 'package:flutter/material.dart';

class OvertimeFormBottomSheet extends StatefulWidget {
  final Future<String> Function({
    required String date,
    required String timeFrom,
    required String timeTo,
    required String reason,
  })
  onSubmit;

  const OvertimeFormBottomSheet({super.key, required this.onSubmit});

  @override
  State<OvertimeFormBottomSheet> createState() =>
      _OvertimeFormBottomSheetState();
}

class _OvertimeFormBottomSheetState extends State<OvertimeFormBottomSheet> {
  final TextEditingController reasonController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();

    reasonController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  bool get isTimeValid {
    if (startTime == null || endTime == null) return false;

    final start = startTime!.hour * 60 + startTime!.minute;
    final end = endTime!.hour * 60 + endTime!.minute;

    return end > start;
  }

  bool get isFormValid {
    return selectedDate != null &&
        startTime != null &&
        endTime != null &&
        isTimeValid &&
        reasonController.text.trim().isNotEmpty;
  }

  String get formattedDate {
    final date = selectedDate!;

    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String formatTime(TimeOfDay? time) {
    if (time == null) return '';

    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    final timeFrom = formatTime(startTime);
    final timeTo = formatTime(endTime);

    try {
      setState(() => isSubmitting = true);

      await widget.onSubmit(
        date: formattedDate,
        timeFrom: timeFrom,
        timeTo: timeTo,
        reason: reasonController.text.trim(),
      );

      if (!mounted) return;

      ToastHelper.success(
        context,
        title: 'Berhasil',
        message: 'Pengajuan lembur berhasil dikirim',
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ToastHelper.error(
        context,
        title: 'Gagal',
        message: 'Gagal mengajukan lembur',
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
      initialDate: selectedDate ?? DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: startTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        startTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: endTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        endTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 60,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengajuan Lembur',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),
          const Text('Tanggal', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),

          InkWell(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate == null ? 'Pilih tanggal' : formattedDate,
                    style: TextStyle(
                      color: selectedDate == null ? Colors.grey : Colors.black,
                    ),
                  ),
                  const Icon(Icons.calendar_today, size: 18),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jam Mulai',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),

                    const SizedBox(height: 6),

                    InkWell(
                      onTap: _pickStartTime,
                      child: _timeField(formatTime(startTime), 'Mulai'),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jam Selesai',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),

                    const SizedBox(height: 6),

                    InkWell(
                      onTap: _pickEndTime,
                      child: _timeField(formatTime(endTime), 'Selesai'),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (!isTimeValid && startTime != null && endTime != null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Jam selesai harus lebih dari jam mulai',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),

          const SizedBox(height: 16),
          const Text('Alasan', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),

          TextField(
            controller: reasonController,
            decoration: InputDecoration(
              hintText: 'Masukkan alasan lembur...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: (!isFormValid || isSubmitting) ? null : _submit,
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Ajukan'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeField(String value, String hint) {
    final hasValue = value.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            hasValue ? value : hint,
            style: TextStyle(color: hasValue ? Colors.black : Colors.grey),
          ),
          const Icon(Icons.access_time, size: 18),
        ],
      ),
    );
  }
}
