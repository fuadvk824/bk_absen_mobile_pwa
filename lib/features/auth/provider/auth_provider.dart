import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../model/user_model.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(
      (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
    );

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository repo;

  AuthNotifier(this.repo) : super(const AsyncValue.loading()) {
    loadUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      await repo.login(email, password);
      await loadUser(); // reuse method
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
  
  Future<void> loadUser() async {
    final user = await repo.me();
    state = AsyncValue.data(user);
  }

  Future<void> logout() async {
    await repo.logout();
    state = const AsyncValue.data(null);
  }
}
