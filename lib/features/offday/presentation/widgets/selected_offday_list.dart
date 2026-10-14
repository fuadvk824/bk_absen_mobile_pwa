import 'package:flutter/material.dart';

import 'package:bk_absen/features/offday/provider/offday_provider.dart';
import 'package:bk_absen/features/offday/presentation/widgets/selected_offday_item.dart';

class SelectedOffdayList extends StatelessWidget {
  const SelectedOffdayList({
    super.key,
    required this.state,
    required this.notifier,
  });

  final OffdayState state;
  final OffdayNotifier notifier;

  @override
  Widget build(BuildContext context) {
    if (state.selectedChanges.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.touch_app_outlined,
              color: Colors.grey,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Belum ada tanggal yang dipilih.',
              ),
            ),
          ],
        ),
      );
    }

    final selectedDays = notifier.allDays
        .where(
          (day) => state.selectedChanges.containsKey(day.id),
        )
        .toList()
      ..sort(
        (a, b) => a.workDate.compareTo(b.workDate),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Tanggal yang dipilih',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: notifier.clearChanges,
              child: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...selectedDays.map(
          (day) => SelectedOffdayItem(
            day: day,
            notifier: notifier,
          ),
        ),
      ],
    );
  }
}
