import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bk_absen/model/leave_model.dart';
import 'package:bk_absen/utils/app_colors.dart';
import 'package:bk_absen/utils/toast_helper.dart';

class LeaveItemWidget extends StatelessWidget {
  final LeaveModel leave;

  const LeaveItemWidget({super.key, required this.leave});

  Color _getStatusColor() {
    return Color(leave.warna);
  }

  Future<void> _openFile(BuildContext context) async {
    final fileUrl = leave.file;

    if (fileUrl == null || fileUrl.trim().isEmpty) {
      ToastHelper.warning(
        context,
        message: 'File untuk pengajuan cuti ini tidak tersedia',
      );
      return;
    }

    try {
      final uri = Uri.tryParse(fileUrl);

      if (uri == null || !uri.hasScheme) {
        throw Exception('URL file tidak valid');
      }

      /*
       * Flutter Web / PWA:
       *
       * Langsung buka file menggunakan browser,
       * sama seperti tombol download pada LeavePdf.
       *
       * Tidak menggunakan:
       * - File()
       * - path_provider
       * - open_filex
       * - SfPdfViewer
       */

      final launched = await launchUrl(uri, webOnlyWindowName: '_blank');

      if (!launched) {
        throw Exception('Browser gagal membuka file');
      }
    } catch (e) {
      debugPrint('LEAVE FILE ERROR: $e');

      if (!context.mounted) return;

      ToastHelper.error(context, message: 'Gagal membuka file');
    }
  }

  int _getLeaveDuration() {
    try {
      final start = DateTime.parse(leave.startDate);
      final end = DateTime.parse(leave.endDate);

      return end.difference(start).inDays + 1;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = leave.file != null && leave.file!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: .15), blurRadius: 8),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        childrenPadding: EdgeInsets.zero,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),

        title: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 60,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Cuti',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      _getLeaveDuration().toString(),
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 2),

                    const Text(
                      'Hari',
                      style: TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              leave.startDate,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const Text('Start', style: TextStyle(fontSize: 10)),
                          ],
                        ),

                        Column(
                          children: [
                            Text(
                              leave.endDate,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const Text('End', style: TextStyle(fontSize: 10)),
                          ],
                        ),

                        Column(
                          children: [
                            Text(
                              leave.status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(),
                              ),
                            ),
                            const Text(
                              'Status',
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    const Divider(),

                    Center(
                      child: Text(
                        leave.leaveName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        children: [
          const Divider(),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alasan:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                Text(
                  leave.reason ?? '-',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),

                const SizedBox(height: 12),

                const Text(
                  'File:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),

                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: hasFile ? () => _openFile(context) : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: hasFile
                          ? AppColors.primary.withValues(alpha: .08)
                          : Colors.grey.withValues(alpha: .08),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          hasFile
                              ? Icons.picture_as_pdf
                              : Icons.insert_drive_file_outlined,
                          size: 18,
                          color: hasFile ? AppColors.primary : Colors.grey,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          hasFile ? 'Lihat File' : 'File tidak tersedia',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: hasFile ? AppColors.primary : Colors.grey,
                          ),
                        ),
                      ],
                    ),
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
