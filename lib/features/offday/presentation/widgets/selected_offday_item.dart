import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:bk_absen/model/offday_schedule_model.dart';
import 'package:bk_absen/features/offday/provider/offday_provider.dart';

class SelectedOffdayItem extends StatelessWidget {
  const SelectedOffdayItem({
    super.key,
    required this.day,
    required this.notifier,
  });

  final OffdayScheduleDayModel day;
  final OffdayNotifier notifier;

  DateTime _parseDate(String date) {
    final parts = date.split('-');

    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = notifier.getDisplayStatus(day);
    final isOff = status == 'libur';
    final date = _parseDate(day.workDate);

    final formattedDate = DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isOff
            ? Colors.red.withValues(alpha: .06)
            : Colors.black.withValues(alpha: .04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOff
              ? Colors.red.withValues(alpha: .2)
              : Colors.black.withValues(alpha: .12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: isOff ? Colors.red : Colors.black,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isOff ? 'Masuk -> Libur' : 'Libur -> Masuk',
                  style: TextStyle(
                    color: isOff ? Colors.red : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Batalkan pilihan',
            onPressed: () {
              notifier.toggleDay(day);
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
