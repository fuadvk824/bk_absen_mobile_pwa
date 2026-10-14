import 'package:bk_absen/model/calendar_item_model.dart';
import 'package:bk_absen/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleItemCard extends StatelessWidget {
  final CalendarItem item;

  const ScheduleItemCard({super.key, required this.item});

  DateTime normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool isToday(DateTime date) {
    final now = normalize(DateTime.now());

    return normalize(date) == now;
  }

  bool isFuture(DateTime date) {
    final now = normalize(DateTime.now());

    return normalize(date).isAfter(now);
  }

  @override
  Widget build(BuildContext context) {
    final isLibur = item.status == 'Libur';

    final today = isToday(item.date);
    final future = isFuture(item.date);

    final label = isLibur
        ? 'Shift'
        : future
        ? 'Shift'
        : (item.totalWaktu == '--:--' ? 'Shift' : 'Total');

    final value = isLibur ? 'Off' : item.totalWaktu;

    Color bgColor;
    Color plColor;

    if (today) {
      bgColor = AppColors.primary;
      plColor = AppColors.light;
    } else {
      bgColor = AppColors.light;
      plColor = AppColors.primary;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: .15), blurRadius: 8),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),

        childrenPadding: EdgeInsets.zero,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),

        iconColor: plColor,
        collapsedIconColor: plColor,

        title: IntrinsicHeight(
          child: Row(
            children: [
              _buildDateBox(bgColor: bgColor, plColor: plColor),

              const SizedBox(width: 12),

              Expanded(
                child: _buildScheduleContent(
                  bgColor: bgColor,
                  plColor: plColor,
                  isLibur: isLibur,
                  today: today,
                  label: label,
                  value: value,
                ),
              ),
            ],
          ),
        ),

        children: [
          const Divider(),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alasan Terlambat:',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.bold, color: plColor),
                ),

                const SizedBox(height: 4),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.lateReason,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 12, color: plColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBox({required Color bgColor, required Color plColor}) {
    return Container(
      width: 60,
      decoration: BoxDecoration(
        color: plColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('EEE', 'id_ID').format(item.date),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: bgColor,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            item.date.day.toString(),
            style: TextStyle(
              fontSize: 26,
              height: 1,
              fontWeight: FontWeight.bold,
              color: bgColor,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            DateFormat('MMM', 'id_ID').format(item.date),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: bgColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleContent({
    required Color bgColor,
    required Color plColor,
    required bool isLibur,
    required bool today,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _timeBox(isLibur ? '-' : item.checkIn, 'CheckIn', plColor),

            _timeBox(isLibur ? '-' : item.checkOut, 'CheckOut', plColor),

            _timeBox(value, label, plColor),
          ],
        ),

        const Divider(),

        Text(
          DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(item.date),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: plColor,
          ),
        ),

        const SizedBox(height: 5),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: today ? plColor : Color(item.warna),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            isLibur ? 'Libur' : item.status,
            style: TextStyle(color: bgColor, fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget _timeBox(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),

        Text(label, style: TextStyle(fontSize: 10, color: color)),
      ],
    );
  }
}
