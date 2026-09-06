import 'package:bk_absen/utils/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:bk_absen/features/home/provider/attendance_provider.dart';
import 'package:bk_absen/offline/provider/sync_provider.dart';
import 'package:bk_absen/utils/app_colors.dart';

import 'widgets/header_section.dart';
import 'widgets/time_section.dart';
import 'widgets/action_button_section.dart';
import 'widgets/info_section.dart';
import 'check_in_out_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  bool isPreparing = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(syncManagerProvider).sync();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await ref.read(syncManagerProvider).sync();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _handleActionTap() async {
    final notifier = ref.read(attendanceProvider.notifier);

    final state = ref.read(attendanceProvider);

    if (isPreparing) return;

    if (state.attendance?.isOff == true) {
      ToastHelper.warning(context, message: "Hari ini libur");
      return;
    }

    if (state.attendance?.hasShift == false) {
      ToastHelper.warning(context, message: "Tidak ada shift hari ini");

      return;
    }

    setState(() {
      isPreparing = true;
    });

    try {
      await Future.wait([
        Future.delayed(const Duration(milliseconds: 800)),

        // contoh real preload (optional, uncomment kalau mau)
        // availableCameras(),
        // Geolocator.getCurrentPosition(),
        // API call / fetch data awal
      ]);

      if (!mounted) return;

      await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const CheckInOutScreen()),
      );

      await notifier.load();
    } catch (e) {
      if (mounted) {
        ToastHelper.error(context, message: "Terjadi kesalahan: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          isPreparing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceProvider);

    final notifier = ref.read(attendanceProvider.notifier);

    final isOff = state.attendance?.isOff ?? false;

    final hasShift = state.attendance?.hasShift ?? true;

    final date = DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).format(DateTime.now());

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(syncManagerProvider).sync();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              HeaderSection(user: state.user),

              const SizedBox(height: 40),

              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TimeSection(time: notifier.getShiftTime(), date: date),

                    const SizedBox(height: 60),

                    ActionButtonSection(
                      label: notifier.getButton(),
                      isLoading: isPreparing,
                      onTap: (isOff || !hasShift) ? null : _handleActionTap,
                    ),

                    const SizedBox(height: 60),

                    InfoSection(attendance: state.attendance),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
