import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
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

  /// VALIDASI WAKTU
  bool get isTimeValid {
    if (startTime == null || endTime == null) return false;

    final start = startTime!.hour * 60 + startTime!.minute;
    final end = endTime!.hour * 60 + endTime!.minute;

    return end > start;
  }

  /// VALIDASI FORM
  bool get isFormValid {
    return selectedDate != null &&
        startTime != null &&
        endTime != null &&
        isTimeValid &&
        reasonController.text.trim().isNotEmpty;
  }

  /// SUBMIT DATA
  Future<void> _submit() async {
    String date =
        "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

    String timeFrom =
        "${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}";

    String timeTo =
        "${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}";

    await widget.onSubmit(
      date: date,
      timeFrom: timeFrom,
      timeTo: timeTo,
      reason: reasonController.text,
    );
  }

  /// CUSTOM NOTIF (tanpa snackbar)
  void _showSuccess(String message) {
    CherryToast.success(
      title: const Text("Berhasil"),
      description: const Text("Pengajuan lembur dikirim"),
      animationType: AnimationType.fromTop,
      animationDuration: const Duration(milliseconds: 700),
    ).show(context);
  }

  void _showError(String message) {
    CherryToast.error(
      title: Text(message),
      animationType: AnimationType.fromTop,
      animationDuration: const Duration(milliseconds: 700),
    ).show(context);
  }

  String? formatTime(TimeOfDay? time) {
    if (time == null) return null;

    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return "$hour:$minute";
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
            "Pengajuan Lembur",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          /// TANGGAL
          const Text("Tanggal", style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          InkWell(
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                firstDate: DateTime(2024),
                lastDate: DateTime(2100),
                initialDate: DateTime.now(),
              );

              if (picked != null) {
                setState(() => selectedDate = picked);
              }
            },
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
                    selectedDate == null
                        ? "Pilih tanggal"
                        : selectedDate.toString().split(" ")[0],
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

          /// JAM (GRID BIAR RAPI)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Jam Mulai",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (context, child) {
                            return MediaQuery(
                              data: MediaQuery.of(
                                context,
                              ).copyWith(alwaysUse24HourFormat: true),
                              child: child!,
                            );
                          },
                        );

                        if (picked != null) {
                          setState(() => startTime = picked);
                        }
                      },
                      child: _timeField(
                        context,
                        formatTime(startTime),
                        "Mulai",
                      ),
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
                      "Jam Selesai",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (context, child) {
                            return MediaQuery(
                              data: MediaQuery.of(
                                context,
                              ).copyWith(alwaysUse24HourFormat: true),
                              child: child!,
                            );
                          },
                        );

                        if (picked != null) {
                          setState(() => endTime = picked);
                        }
                      },
                      child: _timeField(
                        context,
                        formatTime(endTime),
                        "Selesai",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          /// ERROR VALIDASI
          if (!isTimeValid && startTime != null && endTime != null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                "Jam selesai harus lebih dari jam mulai",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),

          const SizedBox(height: 16),

          /// ALASAN
          const Text("Alasan", style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(
            controller: reasonController,
            decoration: InputDecoration(
              hintText: "Masukkan alasan lembur...",
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

          /// BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: (!isFormValid || isSubmitting)
                  ? null
                  : () async {
                      setState(() => isSubmitting = true);

                      try {
                        await _submit();
                        _showSuccess("Pengajuan berhasil");
                        if (mounted) Navigator.pop(context);
                      } catch (e) {
                        _showError("Gagal mengajukan");
                      }

                      if (mounted) {
                        setState(() => isSubmitting = false);
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Ajukan"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeField(BuildContext context, String? value, String hint) {
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
            value ?? hint,
            style: TextStyle(color: value == null ? Colors.grey : Colors.black),
          ),
          const Icon(Icons.access_time, size: 18),
        ],
      ),
    );
  }
}
