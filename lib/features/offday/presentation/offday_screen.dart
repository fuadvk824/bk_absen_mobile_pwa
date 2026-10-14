import 'package:bk_absen/features/offday/presentation/widgets/colleague_offday_list.dart';
import 'package:bk_absen/features/offday/presentation/widgets/offday_info.dart';
import 'package:bk_absen/utils/app_colors.dart';
import 'package:bk_absen/utils/toast_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bk_absen/features/offday/presentation/widgets/offday_calendar.dart';
import 'package:bk_absen/features/offday/presentation/widgets/offday_legend.dart';
import 'package:bk_absen/features/offday/presentation/widgets/offday_reason_field.dart';
import 'package:bk_absen/features/offday/presentation/widgets/offday_submit_button.dart';
import 'package:bk_absen/features/offday/presentation/widgets/selected_offday_list.dart';
import 'package:bk_absen/features/offday/provider/offday_provider.dart';

class OffdayScreen extends ConsumerStatefulWidget {
  final String title;

  const OffdayScreen({super.key, required this.title});

  @override
  ConsumerState<OffdayScreen> createState() => _OffdayScreenState();
}

class _OffdayScreenState extends ConsumerState<OffdayScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(offdayProvider);
    final notifier = ref.read(offdayProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                widget.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.light,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const OffdayInfo(), 
          ],
        ),

        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              bottom: true,
              child: RefreshIndicator(
                onRefresh: () async {
                  await notifier.load(year: _focusedDay.year);
                },
                child: ListView(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  children: [
                    OffdayCalendar(
                      focusedDay: _focusedDay,
                      selectedDay: _selectedDay,
                      state: state,
                      notifier: notifier,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                        });
                      },
                    ),

                    const SizedBox(height: 20),
                    const OffdayLegend(),
                    const SizedBox(height: 24),

                    ColleagueOffdayList(state: state),

                    const SizedBox(height: 24),

                    SelectedOffdayList(state: state, notifier: notifier),

                    if (state.selectedChanges.isNotEmpty) ...[
                      const SizedBox(height: 20),

                      OffdayReasonField(controller: _reasonController),

                      const SizedBox(height: 16),

                      OffdaySubmitButton(
                        state: state,
                        onPressed: () => _submit(context, notifier),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _submit(BuildContext context, OffdayNotifier notifier) async {
    final reason = _reasonController.text.trim();

    if (reason.isEmpty) {
      ToastHelper.warning(context, message: 'Alasan pengajuan wajib diisi.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Pengajuan'),
          content: Text(
            'Yakin ingin mengajukan '
            '${ref.read(offdayProvider).selectedChanges.length} '
            'perubahan tanggal?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Ajukan'),
            ),
          ],
        );
      },
    );

    if (!context.mounted || confirmed != true) {
      return;
    }

    try {
      final message = await notifier.submit(reason: reason);

      if (!context.mounted) {
        return;
      }

      _reasonController.clear();

      ToastHelper.success(context, message: message);
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      if (e is DioException) {
        ToastHelper.errorFromDio(context, e);
      } else {
        ToastHelper.error(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }
}
