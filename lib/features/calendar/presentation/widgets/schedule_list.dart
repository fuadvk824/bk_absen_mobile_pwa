import 'package:bk_absen/model/calendar_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/calendar_provider.dart';
import 'schedule_item_card.dart';

class ScheduleList extends ConsumerWidget {
  final List<CalendarItem> items;
  final bool isCalendarVisible;
  final double bottomSafe;

  const ScheduleList({
    super.key,
    required this.items,
    required this.isCalendarVisible,
    required this.bottomSafe,
  });

  DateTime normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    final today = DateTime.now();

    final focused = ref.read(calendarProvider.notifier).focusedDay;

    final isCurrentMonth =
        focused.month == today.month && focused.year == today.year;

    List<CalendarItem> filtered;

    if (!isCalendarVisible) {
      filtered = items;
    } else {
      if (isCurrentMonth) {
        final todayDate = DateTime(today.year, today.month, today.day);

        filtered = items
            .where((item) => !item.date.isBefore(todayDate))
            .take(7)
            .toList();
      } else {
        final startOfMonth = DateTime(focused.year, focused.month, 1);

        filtered = items
            .where((item) => !item.date.isBefore(startOfMonth))
            .take(7)
            .toList();
      }
    }

    return ListView.builder(
      padding:
          const EdgeInsets.symmetric(horizontal: 16) +
          EdgeInsets.only(bottom: bottomSafe),
      itemCount: filtered.length,
      itemBuilder: (_, index) {
        final item = filtered[index];

        return ScheduleItemCard(item: item);
      },
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: double.infinity,
          height: constraints.maxHeight,
          child: const Align(
            alignment: Alignment(0, -0.5),
            child: Text(
              'Tidak ada data',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        );
      },
    );
  }
}
