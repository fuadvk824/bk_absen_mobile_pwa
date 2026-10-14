import 'package:bk_absen/features/offday/data/offday_repository.dart';
import 'package:bk_absen/model/colleague_pending_request_model.dart';
import 'package:bk_absen/model/colleague_schedule_model.dart';
import 'package:bk_absen/model/offday_request_model.dart';
import 'package:bk_absen/model/offday_schedule_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final offdayRepositoryProvider = Provider((ref) => OffdayRepository());

class OffdayState {
  final List<OffdayScheduleModel> schedules;
  final List<ColleagueScheduleModel> colleagueOffdays;
  final List<ColleaguePendingScheduleModel> colleaguePendingRequests;

  final Map<int, String> selectedChanges;
  final List<OffdayRequestModel> requests;

  final int selectedYear;
  final bool isLoading;
  final bool isSubmitting;

  final String periodStart;
  final String periodEnd;

  OffdayState({
    this.schedules = const [],
    this.colleagueOffdays = const [],
    this.colleaguePendingRequests = const [],
    this.selectedChanges = const {},
    this.requests = const [],
    required this.selectedYear,
    this.isLoading = false,
    this.isSubmitting = false,
    this.periodStart = '',
    this.periodEnd = '',
  });

  OffdayState copyWith({
    List<OffdayScheduleModel>? schedules,
    List<ColleagueScheduleModel>? colleagueOffdays,
    List<ColleaguePendingScheduleModel>? colleaguePendingRequests,
    Map<int, String>? selectedChanges,
    List<OffdayRequestModel>? requests,
    int? selectedYear,
    bool? isLoading,
    bool? isSubmitting,
    String? periodStart,
    String? periodEnd,
  }) {
    return OffdayState(
      schedules: schedules ?? this.schedules,
      colleagueOffdays: colleagueOffdays ?? this.colleagueOffdays,
      colleaguePendingRequests:
          colleaguePendingRequests ?? this.colleaguePendingRequests,
      selectedChanges: selectedChanges ?? this.selectedChanges,
      requests: requests ?? this.requests,
      selectedYear: selectedYear ?? this.selectedYear,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
    );
  }
}

final offdayProvider = StateNotifierProvider<OffdayNotifier, OffdayState>((
  ref,
) {
  return OffdayNotifier(ref.read(offdayRepositoryProvider));
});

class OffdayNotifier extends StateNotifier<OffdayState> {
  final OffdayRepository repo;

  OffdayNotifier(this.repo)
    : super(OffdayState(selectedYear: DateTime.now().year)) {
    load();
  }

  static const int maxOffDays = 6;

  Future<void> load({int? year}) async {
    final selectedYear = year ?? state.selectedYear;

    state = state.copyWith(selectedYear: selectedYear, isLoading: true);

    try {
      final result = await repo.fetchSchedule(year: selectedYear);

      state = state.copyWith(
        schedules: result.data,
        colleagueOffdays: result.colleagueOffdays,
        colleaguePendingRequests: result.colleaguePendingRequests,
        periodStart: result.periodStart,
        periodEnd: result.periodEnd,
        selectedYear: selectedYear,
        isLoading: false,
        selectedChanges: {},
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> changeYear(int year) async {
    if (year == state.selectedYear) {
      return;
    }

    await load(year: year);
  }

  List<OffdayScheduleDayModel> get allDays {
    return state.schedules.expand((schedule) => schedule.days).toList();
  }

  OffdayScheduleDayModel? getDay(String date) {
    try {
      return allDays.firstWhere((day) => day.workDate == date);
    } catch (_) {
      return null;
    }
  }

  bool isWithinOffdayPeriod(OffdayScheduleDayModel day) {
    final date = day.workDate;

    if (date.isEmpty || state.periodStart.isEmpty || state.periodEnd.isEmpty) {
      return false;
    }

    return date.compareTo(state.periodStart) >= 0 &&
        date.compareTo(state.periodEnd) <= 0;
  }

  String getDisplayStatus(OffdayScheduleDayModel day) {
    return state.selectedChanges[day.id] ?? (day.isOff ? 'libur' : 'masuk');
  }

  bool isOff(OffdayScheduleDayModel day) {
    return getDisplayStatus(day) == 'libur';
  }

  bool isWork(OffdayScheduleDayModel day) {
    return getDisplayStatus(day) == 'masuk';
  }

  bool isPending(OffdayScheduleDayModel day) {
    return day.hasPendingRequest;
  }

  bool isColleagueOffday(String date) {
    return state.colleagueOffdays.any(
      (colleague) => colleague.offdays.any((offday) => offday.workDate == date),
    );
  }

  bool isColleaguePendingRequest(String date) {
    return state.colleaguePendingRequests.any(
      (colleague) =>
          colleague.pendingRequests.any((request) => request.date == date),
    );
  }

  bool hasColleagueOffday(String date) {
    return isColleagueOffday(date);
  }

  List<ColleagueScheduleModel> colleaguesOffOn(String date) {
    return state.colleagueOffdays.where((colleague) {
      return colleague.offdays.any((offday) => offday.workDate == date);
    }).toList();
  }

  int get totalOffDays {
    return allDays.where((day) {
      if (!isWithinOffdayPeriod(day)) {
        return false;
      }
 
      if (day.hasPendingRequest) {
        return true;
      }

      return getDisplayStatus(day) == 'libur';
    }).length;
  }

  int get remainingOffDays {
    final remaining = maxOffDays - totalOffDays;
    return remaining < 0 ? 0 : remaining;
  }

  bool canSelectOffday(OffdayScheduleDayModel day) {
    if (!isWithinOffdayPeriod(day)) {
      return false;
    }

    if (day.hasPendingRequest) {
      return false;
    }

    final currentStatus = getDisplayStatus(day);

    if (currentStatus == 'libur') {
      return true;
    }

    return totalOffDays < maxOffDays;
  }

  bool toggleDay(OffdayScheduleDayModel day) {
    if (!isWithinOffdayPeriod(day)) {
      return false;
    }

    if (day.hasPendingRequest) {
      return false;
    }

    final originalStatus = day.isOff ? 'libur' : 'masuk';

    final currentStatus = state.selectedChanges[day.id] ?? originalStatus;

    final newStatus = currentStatus == 'libur' ? 'masuk' : 'libur';

    if (newStatus == 'libur' && totalOffDays >= maxOffDays) {
      return false;
    }

    final changes = Map<int, String>.from(state.selectedChanges);

    if (newStatus == originalStatus) {
      changes.remove(day.id);
    } else {
      changes[day.id] = newStatus;
    }

    state = state.copyWith(selectedChanges: changes);

    return true;
  }

  bool get hasChanges {
    return state.selectedChanges.isNotEmpty;
  }

  int get totalChanges {
    return state.selectedChanges.length;
  }

  Future<String> submit({required String reason}) async {
    if (state.selectedChanges.isEmpty) {
      throw Exception('Belum ada perubahan jadwal.');
    }

    if (reason.trim().isEmpty) {
      throw Exception('Alasan pengajuan wajib diisi.');
    }

    if (totalOffDays > maxOffDays) {
      throw Exception(
        'Maksimal $maxOffDays hari libur dalam periode '
        '${state.periodStart} sampai ${state.periodEnd}.',
      );
    }

    for (final entry in state.selectedChanges.entries) {
      final day = getDay(
        allDays.firstWhere((item) => item.id == entry.key).workDate,
      );

      if (day == null || !isWithinOffdayPeriod(day)) {
        throw Exception(
          'Ada tanggal yang berada di luar periode pengajuan libur.',
        );
      }

      if (day.hasPendingRequest) {
        throw Exception('Ada tanggal yang masih memiliki pengajuan pending.');
      }
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final changes = state.selectedChanges.entries.map((entry) {
        return {'work_schedule_day_id': entry.key, 'status': entry.value};
      }).toList();

      final result = await repo.submitOffday(
        reason: reason.trim(),
        changes: changes,
      );

      await load(year: state.selectedYear);

      state = state.copyWith(isSubmitting: false);

      return result.message;
    } catch (e) {
      state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }

  Future<void> deletePendingRequest(int requestId) async {
    final repository = OffdayRepository();

    await repository.deleteRequest(requestId);

    await load(year: state.selectedYear);
  }
 
  void clearChanges() {
    state = state.copyWith(selectedChanges: {});
  }
}
