import 'package:bk_absen/model/calendar_legend_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bk_absen/features/calendar/data/calendar_repository.dart';

final calendarRepositoryProvider = Provider(
  (ref) => CalendarRepository(),
);

final calendarProvider = AsyncNotifierProvider<
    CalendarNotifier,
    CalendarResponse>(
  CalendarNotifier.new,
);

class CalendarNotifier extends AsyncNotifier<CalendarResponse> {
  late final repo = ref.read(calendarRepositoryProvider);

  DateTime focusedDay = DateTime.now();

  @override
  Future<CalendarResponse> build() async {
    return fetch();
  }

  Future<CalendarResponse> fetch() async {
    return await repo.fetch(
      year: focusedDay.year,
      month: focusedDay.month,
    );
  }

  void changeMonth(DateTime date) {
    focusedDay = date;
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    try {
      final data = await fetch();
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}