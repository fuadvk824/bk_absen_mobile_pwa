import 'package:bk_absen/model/calendar_item_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bk_absen/features/calendar/data/calendar_repository.dart';

///  REPOSITORY PROVIDER
final calendarRepositoryProvider =
    Provider((ref) => CalendarRepository());

///  MAIN PROVIDER
final calendarProvider =
    AsyncNotifierProvider<CalendarNotifier, List<CalendarItem>>(
  CalendarNotifier.new,
);

class CalendarNotifier extends AsyncNotifier<List<CalendarItem>> {
  late final repo = ref.read(calendarRepositoryProvider);

  DateTime focusedDay = DateTime.now();

  @override
  Future<List<CalendarItem>> build() async {
    return fetch();
  }

  Future<List<CalendarItem>> fetch() async {
    return await repo.fetch(
      year: focusedDay.year,
      month: focusedDay.month,
    );
  }

  void changeMonth(DateTime date) {
    focusedDay = date;
    ref.invalidateSelf(); // auto reload
  }
}