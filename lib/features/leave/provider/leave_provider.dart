import 'dart:typed_data';

import 'package:bk_absen/model/leave_balance.dart';
import 'package:bk_absen/model/leave_category_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bk_absen/model/leave_model.dart';
import 'package:bk_absen/features/leave/data/leave_repository.dart';

final leaveRepositoryProvider = Provider((ref) => LeaveRepository());

final leaveCategoryProvider = FutureProvider<List<LeaveCategoryModel>>((
  ref,
) async {
  final repo = ref.read(leaveRepositoryProvider);
  return repo.fetchCategories();
});

class LeaveState {
  final List<LeaveModel> data;
  final List<LeaveBalanceModel> balances;
  final bool isLoading;
  final String? error;

  LeaveState({
    this.data = const [],
    this.balances = const [],
    this.isLoading = false,
    this.error,
  });

  LeaveState copyWith({
    List<LeaveModel>? data,
    List<LeaveBalanceModel>? balances,
    bool? isLoading,
    String? error,
  }) {
    return LeaveState(
      data: data ?? this.data,
      balances: balances ?? this.balances,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final leaveProvider = StateNotifierProvider<LeaveNotifier, LeaveState>(
  (ref) => LeaveNotifier(ref.read(leaveRepositoryProvider)),
);

class LeaveNotifier extends StateNotifier<LeaveState> {
  final LeaveRepository repo;

  LeaveNotifier(this.repo) : super(LeaveState()) {
    load();
  }

  Future<void> load() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await repo.fetchLeaves();

      state = state.copyWith(
        data: result.leaves,
        balances: result.balances,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<String> submit({
    required int leaveCategoryId,
    required String startDate,
    required String endDate,
    required String reason,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    try {
      final message = await repo.submitLeave(
        leaveCategoryId: leaveCategoryId,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        fileBytes: fileBytes,
        fileName: fileName,
      );

      await load();
       return message;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
