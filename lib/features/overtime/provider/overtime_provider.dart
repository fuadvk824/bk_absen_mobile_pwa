import 'package:bk_absen/features/overtime/data/overtime_repository.dart';
import 'package:bk_absen/model/overtime_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final overtimeRepositoryProvider = Provider((ref) => OvertimeRepository());

class OvertimeState {
  final List<OvertimeModel> data;
  final int selectedPeriod;
  final bool isLoading;
  final int totalOvertimeMinutes;

  OvertimeState({
    this.data = const [],
    this.selectedPeriod = 9,
    this.isLoading = false,
    this.totalOvertimeMinutes = 0,
  });

  OvertimeState copyWith({
    List<OvertimeModel>? data,
    int? selectedPeriod,
    bool? isLoading,
    int? totalOvertimeMinutes,
  }) {
    return OvertimeState(
      data: data ?? this.data,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      isLoading: isLoading ?? this.isLoading,
      totalOvertimeMinutes: totalOvertimeMinutes ?? this.totalOvertimeMinutes,
    );
  }
}

final overtimeProvider = StateNotifierProvider<OvertimeNotifier, OvertimeState>(
  (ref) {
    return OvertimeNotifier(ref.read(overtimeRepositoryProvider));
  },
);

class OvertimeNotifier extends StateNotifier<OvertimeState> {
  final OvertimeRepository repo;

  OvertimeNotifier(this.repo)
    : super(OvertimeState(selectedPeriod: _currentPeriod())) {
    load();
  }

  static int _currentPeriod() {
    final now = DateTime.now();

    if (now.day >= 26) {
      return now.month;
    }

    final previousMonth = now.month == 1 ? 12 : now.month - 1;
    return previousMonth;
  }

  Future<void> load({int? period}) async {
    final selectedPeriod = period ?? state.selectedPeriod;

    state = state.copyWith(selectedPeriod: selectedPeriod, isLoading: true);

    try {
      final result = await repo.fetchOvertime(period: selectedPeriod);

      state = state.copyWith(
        data: result.data,
        selectedPeriod: selectedPeriod,
        totalOvertimeMinutes: result.totalOvertimeMinutes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);

      rethrow;
    }
  }

  Future<void> changePeriod(int period) async {
    if (period == state.selectedPeriod) {
      return;
    }

    await load(period: period);
  }

  Future<String> submit({
    required String date,
    required String timeFrom,
    required String timeTo,
    required String reason,
  }) async {
    final message = await repo.submitOvertime(
      date: date,
      timeFrom: timeFrom,
      timeTo: timeTo,
      reason: reason,
    );

    await load(period: state.selectedPeriod);

    return message;
  }
}
