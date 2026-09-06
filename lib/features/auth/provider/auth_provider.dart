import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/user_model.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

final authLoadingProvider = StateProvider<bool>((ref) => false);

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(
      (ref) => AuthNotifier(ref.read(authRepositoryProvider), ref),
    );

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository repo;
  final Ref ref;

  AuthNotifier(this.repo, this.ref) : super(const AsyncValue.loading()) {
    loadUser();
  }

  Future<String?> login(String email, String password) async {
    ref.read(authLoadingProvider.notifier).state = true;

    try {
      final user = await repo.login(email, password);
      state = AsyncValue.data(user);

      return null;
    } catch (e) {
      state = const AsyncValue.data(null);

      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> loadUser() async {
    try {
      final user = await repo.me();

      state = AsyncValue.data(user);
    } catch (_) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> logout() async {
    await repo.logout();

    if (!mounted) return;

    state = const AsyncValue.data(null);
  }
}
