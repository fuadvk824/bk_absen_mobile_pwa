import 'dart:io';
import 'dart:typed_data';

import 'package:bk_absen/features/leave/presentation/widgets/leave_form_bottom_sheet.dart';
import 'package:bk_absen/features/leave/presentation/widgets/leave_item.dart';
import 'package:bk_absen/features/leave/provider/leave_provider.dart';
import 'package:bk_absen/model/leave_balance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bk_absen/utils/app_colors.dart';

class LeaveScreen extends ConsumerStatefulWidget {
  final String title;

  const LeaveScreen({super.key, required this.title});

  @override
  ConsumerState<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends ConsumerState<LeaveScreen> {
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController leaveNameController = TextEditingController();

  File? selectedFile;
  DateTime? selectedDate;
  DateTime? endDate;

  void _showLeaveForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return LeaveFormBottomSheet(
          onSubmit:
              ({
                required int leaveCategoryId,
                required String startDate,
                required String endDate,
                required String reason,
                Uint8List? fileBytes,
                String? fileName,
              }) async {
                final notifier = ref.read(leaveProvider.notifier);

                final message = await notifier.submit(
                  leaveCategoryId: leaveCategoryId,
                  startDate: startDate,
                  endDate: endDate,
                  reason: reason,
                  fileBytes: fileBytes,
                  fileName: fileName,
                );

                return message;
               
              },
        );
      },
    );
  }

  Widget _buildFilePreview(String? url) {
    if (url == null || url.isEmpty) {
      return const Icon(Icons.insert_drive_file, color: Colors.white);
    }

    String lower = url.toLowerCase();

    if (lower.endsWith(".jpg") ||
        lower.endsWith(".jpeg") ||
        lower.endsWith(".png")) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(url, fit: BoxFit.cover, width: 60, height: 80),
      );
    }

    if (lower.endsWith(".pdf")) {
      return const Icon(Icons.picture_as_pdf, color: Colors.white, size: 30);
    }

    if (lower.endsWith(".doc") || lower.endsWith(".docx")) {
      return const Icon(Icons.description, color: Colors.white, size: 30);
    }

    return const Icon(Icons.insert_drive_file, color: Colors.white);
  }

  Future<void> openFile(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Tidak bisa membuka file");
    }
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
        iconTheme: const IconThemeData(color: AppColors.light),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.light),
            onPressed: _showLeaveForm,
          ),
        ],
      ),

      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await notifier.load();
              },
              child: Column(
                children: [
                  if (state.balances.isNotEmpty) _buildBalances(state.balances),

                  Expanded(
                    child: state.data.isEmpty
                        ? const Center(child: Text("Belum ada data cuti"))
                        : ListView.builder(
                            itemCount: state.data.length,
                            itemBuilder: (context, index) {
                              final leave = state.data[index];

                              return LeaveItemWidget(
                                leave: leave,
                                onOpenFile: openFile,
                                filePreviewBuilder: _buildFilePreview,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBalances(List<LeaveBalanceModel> balances) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: balances.length,
        itemBuilder: (context, index) {
          final b = balances[index];

          return Container(
            width: 150,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: b.remainingDays <= 2 ? Colors.red : AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  b.leaveName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
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
                Text(
                  "${b.usedDays}/${b.totalQuota}",
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
