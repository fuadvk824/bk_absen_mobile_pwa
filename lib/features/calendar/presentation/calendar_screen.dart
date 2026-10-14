import 'package:bk_absen/model/calendar_item_model.dart';
import 'package:bk_absen/model/calendar_legend_model.dart';
import 'package:bk_absen/utils/app_colors.dart';
import 'package:bk_absen/utils/secret_easter_egg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../provider/calendar_provider.dart';
import 'widgets/schedule_list.dart';
import 'widgets/work_calendar.dart';
import 'widgets/schedule_legend.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime? selectedDay;
  bool isCalendarVisible = true;

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(calendarProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(calendarProvider.notifier).refresh();
        },
        child: asyncData.when(
          loading: () => _buildLoading(context),
          error: (error, stack) => _buildError(context),
          data: (calendar) {
            return _buildContent(context, calendar);
          },
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height:
              MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
          child: const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height:
              MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.cloudOff,
                    size: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tidak Dapat Mengambil Data',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pastikan koneksi internet tersedia, '
                    'kemudian coba muat ulang halaman ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(calendarProvider.notifier).refresh();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, CalendarResponse calendar) {
    final List<CalendarItem> items = calendar.items;
    final List<CalendarLegend> legend = calendar.legend;

    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Work Schedule',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),

              ScheduleLegend(legend: legend),
            ],
          ),

          WorkCalendar(
            selectedDay: selectedDay,
            isCalendarVisible: isCalendarVisible,
            onDaySelected: (selected, focused) {
              setState(() {
                selectedDay = selected;
              });

              ref.read(calendarProvider.notifier).changeMonth(focused);
            },
            onPageChanged: (focused) {
              ref.read(calendarProvider.notifier).changeMonth(focused);
            },
            items: items,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 
                GestureDetector(
                  onTap: () {
                    showSecretEasterEgg(context);
                  },
                  child: const Text(
                    'Your Schedule',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),

                InkWell(
                  onTap: () {
                    setState(() {
                      isCalendarVisible = !isCalendarVisible;
                    });
                  },
                  child: Row(
                    children: [
                      Text(isCalendarVisible ? 'Show All' : 'Show Calendar'),
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

          Expanded(
            child: ScheduleList(
              items: items,
              isCalendarVisible: isCalendarVisible,
              bottomSafe: bottomSafe,
            ),
          ),
        ],
      ),
    );
  }
}
