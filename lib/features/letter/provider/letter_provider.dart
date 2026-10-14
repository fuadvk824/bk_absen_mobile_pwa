import 'package:bk_absen/features/letter/data/letter_repository.dart';
import 'package:bk_absen/model/letter_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final letterRepositoryProvider = Provider<LetterRepository>(
  (ref) => LetterRepository(),
);

class LetterState {
  final List<LetterModel> data;
  final bool isLoading;

  LetterState({this.data = const [], this.isLoading = false});

  LetterState copyWith({List<LetterModel>? data, bool? isLoading}) {
    return LetterState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final letterProvider = StateNotifierProvider<LetterNotifier, LetterState>(
  (ref) => LetterNotifier(ref.read(letterRepositoryProvider)),
);

class LetterNotifier extends StateNotifier<LetterState> {
  final LetterRepository repo;

  LetterNotifier(this.repo) : super(LetterState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await repo.fetchLetters();

      state = state.copyWith(data: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);

      rethrow;
    }
  }

  Future<String?> markAsRead(int letterId) async {
    try {
      final pdfUrl = await repo.markAsRead(letterId);

      state = state.copyWith(
        data: state.data.map((letter) {
          if (letter.id == letterId) {
            return letter.copyWith(
              isRead: true,
              readAt: DateTime.now().toIso8601String(),
              pdfUrl: pdfUrl ?? letter.pdfUrl,
            );
          }

          return letter;
        }).toList(),
      );

      return pdfUrl;
    } catch (e) {
      // debugPrint('Gagal menandai surat sebagai dibaca: $e');
      return null;
    }
  }
}
