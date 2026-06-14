import 'package:bk_absen/utils/app_colors.dart';
import 'package:flutter/material.dart';


class InfoItem extends StatelessWidget {
  final String time;
  final String label;
  final IconData icon;
  final Color? iconColor;

  const InfoItem({
    super.key,
    required this.time,
    required this.label,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 30,
          color: iconColor ?? AppColors.primary,
        ),
        const SizedBox(height: 6),
        Text(
          time,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}