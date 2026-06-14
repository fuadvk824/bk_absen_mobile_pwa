import 'package:flutter/material.dart';
import 'package:bk_absen/model/leave_model.dart';
import 'package:bk_absen/utils/app_colors.dart';

class LeaveItemWidget extends StatelessWidget {
  final LeaveModel leave;
  final Function(String url) onOpenFile;
  final Widget Function(String? url) filePreviewBuilder;

  const LeaveItemWidget({
    super.key,
    required this.leave,
    required this.onOpenFile,
    required this.filePreviewBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: .15), blurRadius: 8),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                if (leave.file != null && leave.file!.isNotEmpty) {
                  onOpenFile(leave.file!);
                }
              },
              child: Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: filePreviewBuilder(leave.file)),
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _dateColumn(leave.startDate, "Start"),
                      _dateColumn(leave.endDate, "End"),
                      _statusColumn(leave),
                    ],
                  ),
                  const Divider(),
                  Column(
                    children: [
                      Text(
                        leave.leaveName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        leave.reason ?? "-",
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateColumn(String date, String label) {
    return Column(
      children: [
        Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _statusColumn(LeaveModel leave) {
    return Column(
      children: [
        Text(
          leave.status,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(leave.warna),
          ),
        ),
        const Text("Status", style: TextStyle(fontSize: 10)),
      ],
    );
  }
}
