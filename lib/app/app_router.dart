import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../bottom_navbar.dart';

import '../features/auth/presentation/auth_login_screen.dart';
import '../features/auth/presentation/update_password_screen.dart';
import '../features/auth/provider/auth_provider.dart';

import '../features/update/presentation/update_dialog.dart';
import '../features/update/services/update_service.dart';

class AppRouter extends ConsumerStatefulWidget {
  const AppRouter({super.key});

  @override
  ConsumerState<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends ConsumerState<AppRouter> {
  final updateService = UpdateService();

  bool checkedUpdate = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkUpdate();
    });
  }

  Future<void> checkUpdate() async {
    if (checkedUpdate) return;

    checkedUpdate = true;

    try {
      final latest = await updateService.getLatestVersion();

      final currentVersion = updateService.getCurrentVersion();

      if (!mounted) return;

      if (currentVersion != latest.version) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => UpdateDialog(
            currentVersion: currentVersion,
            latestVersion: latest.version,
            message: latest.message,
          ),
        );
      }
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return authState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      error: (_, _) => const AuthLoginScreen(),

      data: (user) {
        if (user == null) {
          return const AuthLoginScreen();
        }

        if (user.keyStatus == 'new') {
          return const ForceChangePasswordScreen();
        }

        return const BottomNavbar();
      },
    );
  }
}
