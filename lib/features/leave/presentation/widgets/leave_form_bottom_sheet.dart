import 'dart:typed_data';

import 'package:bk_absen/features/leave/provider/leave_provider.dart';
import 'package:bk_absen/model/leave_category_model.dart';
import 'package:bk_absen/utils/toast_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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

  PlatformFile? selectedFile;

  LeaveCategoryModel? selectedCategory;

  bool isSubmitting = false;

  bool get isFormValid {
    return selectedCategory != null &&
        selectedDate != null &&
        endDate != null &&
        !endDate!.isBefore(selectedDate!);
  }

  Future<void> _submit() async {
    if (!isFormValid) {
      return;
    }

    final startDateStr =
        "${selectedDate!.year}-"
        "${selectedDate!.month.toString().padLeft(2, '0')}-"
        "${selectedDate!.day.toString().padLeft(2, '0')}";

    final endDateStr =
        "${endDate!.year}-"
        "${endDate!.month.toString().padLeft(2, '0')}-"
        "${endDate!.day.toString().padLeft(2, '0')}";

    try {
      final message = await widget.onSubmit(
        leaveCategoryId: selectedCategory!.id,
        startDate: startDateStr,
        endDate: endDateStr,
        reason: reasonController.text,
        fileBytes: selectedFile?.bytes,
        fileName: selectedFile?.name,
      );

      if (!mounted) return;

      ToastHelper.success(context, title: 'Berhasil', message: message);

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ToastHelper.error(
        context,
        title: 'Gagal',
        message: e.toString().replaceAll("Exception: ", ""),
      );
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        withData: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      );

      if (!mounted) return;

      if (result == null) {
        return;
      }

      final pickedFile = result.files.single;

      const maxSize = 2 * 1024 * 1024;

      if (pickedFile.size > maxSize) {
        ToastHelper.error(
          context,
          title: 'Gagal',
          message: 'Ukuran file maksimal 2MB',
        );
        return;
      }

      if (pickedFile.bytes == null) {
        ToastHelper.error(
          context,
          title: 'Gagal',
          message: 'File tidak dapat dibaca',
        );
        return;
      }

      setState(() {
        selectedFile = pickedFile;
      });
    } catch (e) {
      if (!mounted) return;

      ToastHelper.error(
        context,
        title: 'Gagal',
        message: 'Tidak dapat memilih file',
      );

      debugPrint('PICK LEAVE FILE ERROR: $e');
    }
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
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
                  initialValue: selectedCategory,
                  isExpanded: true,
                  hint: const Text("Pilih jenis cuti"),
                  items: categories.map((cat) {
                    return DropdownMenuItem<LeaveCategoryModel>(
                      value: cat,
                      enabled: cat.remainingDays > 0,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              cat.leaveName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: cat.remainingDays == 0
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Text(
                            "(${cat.remainingDays} hari)",
                            style: TextStyle(
                              color: cat.remainingDays == 0
                                  ? Colors.grey
                                  : Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ],
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
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2100),
                            initialDate: selectedDate ?? DateTime.now(),
                          );

                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;

                              if (endDate != null &&
                                  endDate!.isBefore(picked)) {
                                endDate = null;
                              }
                            });
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
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: selectedDate ?? DateTime(2024),
                            lastDate: DateTime(2100),
                            initialDate:
                                endDate ?? selectedDate ?? DateTime.now(),
                          );

                          if (picked != null) {
                            setState(() {
                              endDate = picked;
                            });
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
              onTap: _pickFile,
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
                        selectedFile == null
                            ? "Upload file"
                            : selectedFile!.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selectedFile == null
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
                        setState(() {
                          isSubmitting = true;
                        });

                        await _submit();

                        if (mounted) {
                          setState(() {
                            isSubmitting = false;
                          });
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
