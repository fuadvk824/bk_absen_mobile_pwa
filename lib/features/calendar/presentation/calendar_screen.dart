import 'package:bk_absen/model/calendar_item_model.dart';
import 'package:bk_absen/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../provider/calendar_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime? selectedDay;
  bool isCalendarVisible = true;

  DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  bool isToday(DateTime d) {
    final now = normalize(DateTime.now());
    return normalize(d) == now;
  }

  bool isFuture(DateTime d) {
    final now = normalize(DateTime.now());
    return normalize(d).isAfter(now);
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(calendarProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text("Error: $e")),

        data: (items) => _buildContent(context, items),
      ),
    );
  }

  /// ================= MAIN CONTENT =================
  Widget _buildContent(BuildContext context, List<CalendarItem> items) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(calendarProvider);
        },
        child: Column(
          children: [
            const SizedBox(height: 10),

            const Text(
              "Work Schedule",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            /// ================= CALENDAR =================
            _buildCalendar(items),

            /// ================= HEADER =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Your Schedule",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        isCalendarVisible = !isCalendarVisible;
                      });
                    },
                    child: Row(
                      children: [
                        Text(isCalendarVisible ? "Show All" : "Show Calendar"),
                        const SizedBox(width: 5),
                        Icon(
                          isCalendarVisible
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// ================= LIST =================
            Expanded(child: _buildList(items, bottomSafe)),
          ],
        ),
      ),
    );
  }

  /// ================= CALENDAR =================
  Widget _buildCalendar(List<CalendarItem> items) {
    final map = {for (var e in items) normalize(e.date): e};

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isCalendarVisible
          ? Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TableCalendar(
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                focusedDay: ref.read(calendarProvider.notifier).focusedDay,

                selectedDayPredicate: (day) {
                  return isSameDay(selectedDay, day);
                },

                onDaySelected: (selected, focused) {
                  setState(() {
                    selectedDay = selected;
                  });

                  ref.read(calendarProvider.notifier).changeMonth(focused);
                },

                onPageChanged: (focused) {
                  ref.read(calendarProvider.notifier).changeMonth(focused);
                },

                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),

                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, date, _) {
                    final d = normalize(date);

                    if (map.containsKey(d)) {
                      final item = map[d]!;

                      final isLibur = item.status.toLowerCase() == "libur";

                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${date.day}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(item.warna),
                              ),
                            ),
                            if (isLibur)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                height: 2,
                                width: 16,
                                decoration: BoxDecoration(
                                  color: Color(item.warna),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                          ],
                        ),
                      );
                    }

                    return null;
                  },
                ),
              ),
            )
          : const SizedBox(height: 20),
    );
  }

  /// ================= LIST =================
  Widget _buildList(List<CalendarItem> items, double bottomSafe) {
    if (items.isEmpty) {
      return const Center(child: Text("Tidak ada data"));
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
        filtered = items
            .where(
              (e) => !e.date.isBefore(
                DateTime(today.year, today.month, today.day),
              ),
            )
            .take(7)
            .toList();
      } else {
        final startOfMonth = DateTime(focused.year, focused.month, 1);

        filtered = items
            .where((e) => !e.date.isBefore(startOfMonth))
            .take(7)
            .toList();
      }
    }

    return ListView.builder(
      padding:
          const EdgeInsets.symmetric(horizontal: 16) +
          EdgeInsets.only(bottom: bottomSafe),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final item = filtered[i];
        return _itemCard(item);
      },
    );
  }

  /// ================= ITEM =================
  Widget _itemCard(CalendarItem item) {
    //tambahn
    final isLibur = item.status == "Libur";
    //tambahn
    final today = isToday(item.date);
    final future = isFuture(item.date);

    //tambahan
    final label = isLibur
        ? "Shift"
        : future
        ? "Shift"
        : (item.totalWaktu == '--:--' ? "Shift" : "Total");

    final value = isLibur ? "Off" : item.totalWaktu;
    //tambahan

    Color bgColor;
    Color plColor;

    if (today) {
      bgColor = AppColors.primary;
      plColor = AppColors.light;
    } else if (future) {
      bgColor = AppColors.light;
      plColor = AppColors.primary;
    } else {
      bgColor = AppColors.light;
      plColor = AppColors.primary;
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: .15), blurRadius: 8),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            /// DATE
            Container(
              width: 60,
              decoration: BoxDecoration(
                color: plColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.date.day.toString(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: bgColor,
                    ),
                  ),
                  Text(
                    DateFormat('EEE').format(item.date),
                    style: TextStyle(fontSize: 12, color: bgColor),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            /// DETAIL
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // _timeBox(item.checkIn, "CheckIn", plColor),
                      // _timeBox(item.checkOut, "CheckOut", plColor),
                      // _timeBox(item.totalWaktu, (future ? "Shift" : "Total"), plColor),

                      //tambahan
                      _timeBox(
                        isLibur ? "-" : item.checkIn,
                        "CheckIn",
                        plColor,
                      ),
                      _timeBox(
                        isLibur ? "-" : item.checkOut,
                        "CheckOut",
                        plColor,
                      ),
                      // _timeBox(
                      //   isLibur ? "Libur" : item.totalWaktu,
                      //   "Shift",
                      //   plColor,
                      // ),
                      _timeBox(value, label, plColor),
                      //tambahan
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: today ? plColor : Color(item.warna),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // child: Text(
                    //   item.status,
                    //   style: TextStyle(color: bgColor, fontSize: 10),
                    // ),
                    //tambahan
                    child: Text(
                      isLibur ? "Libur" : item.status,
                      style: TextStyle(color: bgColor, fontSize: 10),
                    ),
                    //tambahan
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
            fontSize: 18,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: color)),
      ],
    );
  }
}
