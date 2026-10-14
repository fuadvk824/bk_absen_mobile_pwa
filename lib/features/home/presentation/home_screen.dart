import 'package:bk_absen/core/network/server_checker.dart';
import 'package:bk_absen/features/home/provider/attendance_provider.dart';
import 'package:bk_absen/offline/models/offline_attendance_model.dart';
import 'package:bk_absen/offline/provider/sync_provider.dart';
import 'package:bk_absen/utils/app_colors.dart';
import 'package:bk_absen/utils/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'check_in_out_screen.dart';
import 'widgets/action_button_section.dart';
import 'widgets/header_section.dart';
import 'widgets/info_section.dart';
import 'widgets/time_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  bool isPreparing = false;
  bool _serverAvailable = false;
  bool _isRefreshing = false;
  bool _checkingServer = false;

  late final Box<OfflineAttendanceModel> _offlineBox;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _offlineBox = Hive.box<OfflineAttendanceModel>('offline_attendance');

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await _refreshConnectionState();

      if (!mounted) return;

      await ref.read(syncManagerProvider).sync();

      if (!mounted) return;

      await _refreshConnectionState();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await _refreshConnectionState();

      if (!mounted) return;

      await ref.read(syncManagerProvider).sync();

      if (!mounted) return;

      await _refreshConnectionState();
    }
  }

  /// Mengecek apakah server /health aktif.
  Future<void> _refreshConnectionState() async {
    if (_checkingServer) return;

    _checkingServer = true;

    try {
      final alive = await ServerChecker.isAlive();

      if (!mounted) return;

      setState(() {
        _serverAvailable = alive;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _serverAvailable = false;
      });
    } finally {
      _checkingServer = false;
    }
  }

  bool _shouldShowRefreshBanner(Box<OfflineAttendanceModel> box) {
    return box.isNotEmpty && _serverAvailable;
  }

  Future<void> _handleActionTap() async {
    final notifier = ref.read(attendanceProvider.notifier);
    final state = ref.read(attendanceProvider);

    if (isPreparing) return;

    if (state.attendance?.isOff == true) {
      ToastHelper.warning(context, message: 'Hari ini libur');
      return;
    }

    if (state.attendance?.hasShift == false) {
      ToastHelper.warning(context, message: 'Tidak ada shift hari ini');
      return;
    }

    setState(() {
      isPreparing = true;
    });

    try {
      await Future.wait([Future.delayed(const Duration(milliseconds: 800))]);

      if (!mounted) return;

      await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const CheckInOutScreen()),
      );

      if (!mounted) return;

      await notifier.load();
    } catch (e) {
      if (mounted) {
        ToastHelper.error(context, message: 'Terjadi kesalahan: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          isPreparing = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await _refreshConnectionState();

      if (!mounted) return;

      await ref.read(syncManagerProvider).sync();

      if (!mounted) return;

      await _refreshConnectionState();

      if (!mounted) return;

      // Pastikan data attendance ikut diperbarui
      await ref.read(attendanceProvider.notifier).load();
    } catch (e) {
      if (mounted) {
        ToastHelper.error(context, message: 'Gagal melakukan sinkronisasi: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final bottomSafe = mediaQuery.padding.bottom;
    final screenHeight = mediaQuery.size.height;

    final state = ref.watch(attendanceProvider);
    final notifier = ref.read(attendanceProvider.notifier);

    final isOff = state.attendance?.isOff ?? false;
    final hasShift = state.attendance?.hasShift ?? true;

    final date = DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).format(DateTime.now());

    final responsiveTopSpace = (screenHeight * 0.025).clamp(12.0, 24.0);

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SizedBox(
          height: screenHeight,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<Box<OfflineAttendanceModel>>(
          valueListenable: _offlineBox.listenable(),
          builder: (context, box, _) {
            final showRefreshBanner = _shouldShowRefreshBanner(box);

            return RefreshIndicator(
              onRefresh: _handleRefresh,

              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: HeaderSection(
                      user: state.user,
                      onRefresh: _handleRefresh,
                      isRefreshing: _isRefreshing,
                    ),
                  ),

                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: responsiveTopSpace,
                        bottom: bottomSafe + 30,
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                            children: [
                              TimeSection(
                                time: notifier.getShiftTime(),
                                date: date,
                              ),

                              const Spacer(),

                              ActionButtonSection(
                                label: notifier.getButton(),
                                isLoading: isPreparing,
                                onTap: (isOff || !hasShift)
                                    ? null
                                    : _handleActionTap,
                              ),

                              const Spacer(),

                              InfoSection(attendance: state.attendance),
                            ],
                          ),

                          if (showRefreshBanner)
                            Positioned(
                              top: -responsiveTopSpace,
                              left: 0,
                              right: 0,
                              child: _RefreshBanner(onRefresh: _handleRefresh),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RefreshBanner extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _RefreshBanner({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      child: InkWell(
        onTap: onRefresh,
        child: Container(
          width: double.infinity,
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(color: Color(0xFFFFF3CD)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sync_rounded,
                size: 18,
                color: Color(0xFF856404),
              ),

              const SizedBox(width: 8),

              const Flexible(
                child: Text(
                  'Mohon refresh untuk menyinkronkan data',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: Color(0xFF856404),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF856404).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Refresh',
                  style: TextStyle(
                    color: Color(0xFF856404),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
