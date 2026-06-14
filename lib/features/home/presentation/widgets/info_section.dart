import 'package:bk_absen/model/check_in_out_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'info_item.dart';

class InfoSection extends StatelessWidget {
  final CheckInOutModel? attendance;

  const InfoSection({super.key, this.attendance});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InfoItem(
            time: attendance?.checkIn ?? "--:--",
            label: "Check In",
            icon: LucideIcons.clock8,
          ),
        ),
        Expanded(
          child: InfoItem(
            time: attendance?.checkOut ?? "--:--",
            label: "Check Out",
            icon: LucideIcons.clock5, 
          ),
        ),
        Expanded(
          child: InfoItem(
            time: attendance?.totalWaktu ?? "--:--",
            label: "Total Jam",
            icon: LucideIcons.clockCheck, 
          ),
        ),
      ],
    );
  }
}