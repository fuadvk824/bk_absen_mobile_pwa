import 'package:bk_absen/model/calendar_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../provider/calendar_provider.dart';

class WorkCalendar extends ConsumerWidget {
  final DateTime? selectedDay;
  final bool isCalendarVisible;
  final List<CalendarItem> items;

  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final void Function(DateTime focused) onPageChanged;

  const WorkCalendar({
    super.key,
    required this.selectedDay,
    required this.isCalendarVisible,
    required this.items,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  DateTime normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final map = {
      for (final item in items) normalize(item.date): item,
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 30),
      child: isCalendarVisible
          ? Container(
              key: const ValueKey('calendar'),
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TableCalendar(
                locale: 'id_ID',

                firstDay: DateTime(2020),
                lastDay: DateTime(2030),

                focusedDay:
                    ref.read(calendarProvider.notifier).focusedDay,

                selectedDayPredicate: (day) {
                  return isSameDay(selectedDay, day);
                },

                onDaySelected: (selected, focused) {
                  onDaySelected(selected, focused);
                },

                onPageChanged: (focused) {
                  onPageChanged(focused);
                },

                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),

                calendarBuilders: CalendarBuilders(
                  todayBuilder: (context, date, focusedDay) {
                    return Center(
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${date.day}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },

                  defaultBuilder: (context, date, focusedDay) {
                    final normalizedDate = normalize(date);
                    final item = map[normalizedDate];

                    if (item == null) {
                      return null;
                    }

                    final isJadwal = item.warna == 0xff000000;

                    if (isJadwal) {
                      return Center(
                        child: Text(
                          '${date.day}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }

                    final status = item.status.trim().toLowerCase();

                    final isLibur = status == 'libur';
                    final isTidakHadir = status == 'tidak hadir';
                    final isCuti = status == 'cuti';

                    final Color statusColor;

                    if (isLibur || isTidakHadir || isCuti) {
                      statusColor = Color(item.warna);
                    } else {
                      statusColor = Colors.black;
                    }

                    final backgroundColor =
                        statusColor.withValues(alpha: 0.12);

                    return Center(
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),

                            Positioned(
                              bottom: 4,
                              child: Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },

                  markerBuilder: (context, date, events) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            )
          : const SizedBox(
              key: ValueKey('empty-calendar'),
              height: 20,
            ),
    );
  }
}