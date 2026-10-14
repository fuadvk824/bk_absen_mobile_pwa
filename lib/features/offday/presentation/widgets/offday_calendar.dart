import 'package:bk_absen/utils/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:bk_absen/features/offday/provider/offday_provider.dart';
import 'package:bk_absen/features/offday/presentation/widgets/offday_calendar_day.dart';

class OffdayCalendar extends StatelessWidget {
  const OffdayCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.state,
    required this.notifier,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  final DateTime focusedDay;
  final DateTime? selectedDay;
  final OffdayState state;
  final OffdayNotifier notifier;

  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  final void Function(DateTime focusedDay) onPageChanged;

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Future<void> _handleDaySelected(
    BuildContext context,
    DateTime selectedDay,
    DateTime newFocusedDay,
  ) async {
    final date = _dateKey(selectedDay);
    final day = notifier.getDay(date);

    if (day == null) {
      return;
    }

    if (notifier.isColleagueOffday(date)) {
      final colleagues = notifier.colleaguesOffOn(date);

      final names = colleagues
          .map((colleague) => colleague.employeeName)
          .where((name) => name.isNotEmpty)
          .join(', ');

      final message = names.isEmpty
          ? 'Tanggal $date sudah menjadi hari libur rekan kerja.'
          : 'Tanggal $date merupakan hari libur '
                'rekan kerja: $names.';

      ToastHelper.info(
        context,
        message: '$message Silakan pilih tanggal lain.',
      );

      return;
    }

    if (day.hasPendingRequest) {
      final requestId = day.pendingRequest?.id;

      if (requestId == null) {
        ToastHelper.info(context, message: 'Data pengajuan tidak ditemukan.');
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Hapus Pengajuan Offday?'),
          content: Text(
            'Tanggal $date memiliki pengajuan yang masih pending.\n\n'
            'Apakah kamu yakin ingin menghapus pengajuan ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed != true || !context.mounted) {
        return;
      }

      try {
        await notifier.deletePendingRequest(requestId);

        if (!context.mounted) return;

        ToastHelper.info(
          context,
          message: 'Pengajuan tanggal $date berhasil dihapus.',
        );
      } catch (e) {
        if (!context.mounted) return;

        ToastHelper.warning(context, message: 'Gagal menghapus pengajuan: $e');
      }

      return;
    }

    if (!notifier.canSelectOffday(day)) {
      ToastHelper.warning(
        context,
        message:
            'Maksimal 6 hari libur. '
            'Kuota tersisa: ${notifier.remainingOffDays} hari.',
      );
      return;
    }

    final success = notifier.toggleDay(day);

    if (!success) {
      ToastHelper.warning(
        context,
        message:
            'Maksimal 6 hari libur. '
            'Kuota tersisa: ${notifier.remainingOffDays} hari.',
      );
      return;
    }

    onDaySelected(selectedDay, newFocusedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 3),
            color: Colors.black.withValues(alpha: .06),
          ),
        ],
      ),
      child: TableCalendar(
        locale: 'id_ID',
        firstDay: DateTime(state.selectedYear, 1, 1),
        lastDay: DateTime(state.selectedYear, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) {
          return selectedDay != null && isSameDay(selectedDay, day);
        },

        onDaySelected: (selectedDay, focusedDay) {
          _handleDaySelected(context, selectedDay, focusedDay);
        },
        onPageChanged: onPageChanged,
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,

          leftChevronIcon: Icon(Icons.chevron_left),

          rightChevronIcon: Icon(Icons.chevron_right),
        ),

        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(fontWeight: FontWeight.w600),

          weekendStyle: TextStyle(fontWeight: FontWeight.w600),
        ),

        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
          isTodayHighlighted: true,
          markersMaxCount: 0,

          defaultDecoration: BoxDecoration(),
          weekendDecoration: BoxDecoration(),
          selectedDecoration: BoxDecoration(),
          todayDecoration: BoxDecoration(),
        ),

        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return OffdayCalendarDay(
              context: context,
              date: day,
              notifier: notifier,
              state: state,
            );
          },

          todayBuilder: (context, day, focusedDay) {
            return OffdayCalendarDay(
              context: context,
              date: day,
              notifier: notifier,
              state: state,
              isToday: true,
            );
          },

          selectedBuilder: (context, day, focusedDay) {
            return OffdayCalendarDay(
              context: context,
              date: day,
              notifier: notifier,
              state: state,
              isSelected: true,
            );
          },
        ),
      ),
    );
  }
}
