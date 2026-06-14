import 'package:bk_absen/model/check_in_out_model.dart';
import 'package:bk_absen/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PanelRight extends StatelessWidget {
  final CheckInOutModel? data;
  final double? distance;
  final String locationStatus;

  final bool canSubmit;
  final bool isCheckedIn;
  final bool isCheckedOut;
  final bool isSubmitLoading;

  final VoidCallback onSubmit;

  const PanelRight({
    super.key,
    required this.data,
    required this.distance,
    required this.locationStatus,
    required this.canSubmit,
    required this.isCheckedIn,
    required this.isCheckedOut,
    required this.isSubmitLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = isCheckedIn && isCheckedOut;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(
            icon: LucideIcons.clockArrowUp,
            title: "Check In",
            value: data?.checkIn ?? "-",
          ),
          const SizedBox(height: 14),
          _infoRow(
            icon: LucideIcons.clockArrowDown,
            title: "Check Out",
            value: data?.checkOut ?? "-",
          ),
          const SizedBox(height: 14),
          _infoRow(
            icon: LucideIcons.mapPinned,
            title: "Jarak Kantor",
            value: distance == null
                ? "-"
                : "${distance!.toStringAsFixed(1)} Meter",
          ),
          const SizedBox(height: 14),
          _infoRow(
            icon: LucideIcons.locateFixed,
            title: "Status",
            value: locationStatus,
          ),
          const Spacer(),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canSubmit ? onSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canSubmit ? AppColors.primary : Colors.grey,
              ),
              child: isSubmitLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      // isCheckedIn ? "Check Out" : "Check In",
                      // style: const TextStyle(
                      //   fontWeight: FontWeight.bold,
                      //   color: Colors.white,
                      // ),
                      isDone
                          ? "Sudah Absen"
                          : isCheckedIn
                              ? "Check Out"
                              : "Check In",
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _infoRow({
  required IconData icon,
  required String title,
  required String value,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ],
  );
}