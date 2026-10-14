import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../bottom_navbar.dart';
import '../features/auth/presentation/auth_login_screen.dart';
import '../features/auth/provider/auth_provider.dart';

class AppRouter extends ConsumerStatefulWidget {
  const AppRouter({super.key});

  @override
  ConsumerState<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends ConsumerState<AppRouter> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return authState.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),

      error: (_, _) => const AuthLoginScreen(),

      data: (user) {
        if (user == null) {
          return const AuthLoginScreen();
        }

        return const BottomNavbar();
      },
    );
  }
}
