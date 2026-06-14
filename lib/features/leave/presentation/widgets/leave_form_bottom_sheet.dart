import 'dart:typed_data';
import 'package:bk_absen/features/leave/provider/leave_provider.dart';
import 'package:bk_absen/model/leave_category_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaveFormBottomSheet extends ConsumerStatefulWidget {
  final Future<String> Function({
    required int leaveCategoryId,
    required String startDate,
    required String endDate,
    required String reason,
    Uint8List? fileBytes,
    String? fileName,
  })
  onSubmit;

  const LeaveFormBottomSheet({super.key, required this.onSubmit});

  @override
  ConsumerState<LeaveFormBottomSheet> createState() =>
      _LeaveFormBottomSheetState();
}

class _LeaveFormBottomSheetState extends ConsumerState<LeaveFormBottomSheet> {
  final TextEditingController reasonController = TextEditingController();

  DateTime? selectedDate;
  DateTime? endDate;
  // File? selectedFile;
  Uint8List? selectedFileBytes;
  String? selectedFileName;

  LeaveCategoryModel? selectedCategory;

  bool isSubmitting = false;

  bool get isFormValid {
    return selectedCategory != null && selectedDate != null && endDate != null;
  }

  Future<void> _submit() async {
    String start =
        "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

    String end =
        "${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}";

    try {
      final message = await widget.onSubmit(
        leaveCategoryId: selectedCategory!.id,
        startDate: start,
        endDate: end,
        reason: reasonController.text,
        fileBytes: selectedFileBytes,
        fileName: selectedFileName,
      );
      _showSuccess(message);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showError(e.toString().replaceAll("Exception: ", ""));
    }
  }

  void _showSuccess(String message) {
    CherryToast.success(
      title: const Text("Berhasil"),
      description: Text(message),
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

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(leaveCategoryProvider);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 60,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pengajuan Cuti",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const Text(
              "Jenis Cuti",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),

            categoriesAsync.when(
              data: (categories) {
                return DropdownButtonFormField<LeaveCategoryModel>(
                  value: selectedCategory,
                  hint: const Text("Pilih jenis cuti"),

                  items: categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      enabled: cat.remainingDays > 0,
                      child: Text(
                        "${cat.leaveName} sisa (${cat.remainingDays} hari)",
                        style: TextStyle(
                          color: cat.remainingDays == 0
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedCategory = val;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text("Error: $e"),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tanggal Mulai",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
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
                        child: _dateField(
                          selectedDate?.toString().split(" ")[0],
                          "Pilih",
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tanggal Selesai",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
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
                            setState(() => endDate = picked);
                          }
                        },
                        child: _dateField(
                          endDate?.toString().split(" ")[0],
                          "Pilih",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            /// VALIDASI DATE
            if (selectedDate != null &&
                endDate != null &&
                endDate!.isBefore(selectedDate!))
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "Tanggal selesai harus setelah tanggal mulai",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            const SizedBox(height: 16),

            const Text(
              "Lampiran",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                final result = await FilePicker.platform.pickFiles(
                  withData: true,
                );

                if (result != null) {
                  final file = result.files.single;
                  final maxSize = 2 * 1024 * 1024;

                  if (file.size > maxSize) {
                    _showError("Ukuran file maksimal 2MB");
                    return;
                  }

                  setState(() {
                    selectedFileBytes = file.bytes;
                    selectedFileName = file.name;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        selectedFileName ?? "Upload file",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selectedFileName == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
                    const Icon(Icons.upload_file, size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text("Alasan", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Masukkan alasan...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
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
                onPressed: (!isFormValid || isSubmitting)
                    ? null
                    : () async {
                        // setState(() => isSubmitting = true);

                        // try {
                        //   await _submit();
                        //   _showSuccess();
                        //   if (mounted) Navigator.pop(context);
                        // } catch (e) {
                        //   _showError("Gagal mengajukan leave");
                        // }

                        // if (mounted) {
                        //   setState(() => isSubmitting = false);
                        // }
                        setState(() => isSubmitting = true);

                        await _submit();

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
      ),
    );
  }

  Widget _dateField(String? value, String hint) {
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
          const Icon(Icons.calendar_today, size: 18),
        ],
      ),
    );
  }
}
