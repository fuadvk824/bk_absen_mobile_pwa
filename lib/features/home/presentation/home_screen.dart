import 'package:bk_absen/features/home/provider/attendance_provider.dart';
import 'package:bk_absen/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool isPreparing = false;

  Future<void> _handleActionTap() async {
    final notifier = ref.read(attendanceProvider.notifier);
    final state = ref.read(attendanceProvider);

    if (isPreparing) return;

    if (state.attendance?.isOff == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Hari ini libur")));
      return;
    }

    setState(() => isPreparing = true);

    try {
      await Future.wait([
        Future.delayed(const Duration(milliseconds: 800)),

        // contoh real preload (optional, uncomment kalau mau)
        // availableCameras(),
        // Geolocator.getCurrentPosition(),
        // API call / fetch data awal
      ]);

      if (!mounted) return;

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const CheckInOutScreen()),
      );

      if (result == true) {
        await notifier.load();
      }
    } catch (e) {
      debugPrint("Error prepare: $e");

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => isPreparing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceProvider);
    final notifier = ref.read(attendanceProvider.notifier);

    //tambahan
    final isOff = state.attendance?.isOff == true;
    final hasShift = state.attendance?.hasShift == true;
    //tambahan

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
            await notifier.load();
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
                      // onTap: _handleActionTap,

                      //tambahan
                      // onTap: isOff ? null : _handleActionTap,
                      onTap: (isOff || !hasShift) ? null : _handleActionTap,
                      //tambahan
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
