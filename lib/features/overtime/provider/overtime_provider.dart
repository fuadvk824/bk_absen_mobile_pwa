import 'package:bk_absen/features/overtime/data/overtime_repository.dart';
import 'package:bk_absen/model/overtime_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final overtimeRepositoryProvider = Provider((ref) => OvertimeRepository());

class OvertimeState {
  final List<OvertimeModel> data;
  final bool isLoading;

  OvertimeState({this.data = const [], this.isLoading = false});

  OvertimeState copyWith({List<OvertimeModel>? data, bool? isLoading}) {
    return OvertimeState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final overtimeProvider = StateNotifierProvider<OvertimeNotifier, OvertimeState>(
  (ref) => OvertimeNotifier(ref.read(overtimeRepositoryProvider)),
);

class OvertimeNotifier extends StateNotifier<OvertimeState> {
  final OvertimeRepository repo;

  OvertimeNotifier(this.repo) : super(OvertimeState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);

    final result = await repo.fetchOvertime();

    state = state.copyWith(data: result, isLoading: false);
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

    await load();
    return message;
  }
}
