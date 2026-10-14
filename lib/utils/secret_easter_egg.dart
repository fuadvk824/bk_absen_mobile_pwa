import 'package:bk_absen/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

Future<void> showSecretEasterEgg(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: .92),
    builder: (_) => const _SecretDialog(),
  );
}

class _SecretDialog extends StatefulWidget {
  const _SecretDialog();

  @override
  State<_SecretDialog> createState() => _SecretDialogState();
}

class _SecretDialogState extends State<_SecretDialog> {
  final List<String> _messages = [
    '> Initializing...',
    '> Searching for hidden module...',
    '> Module found.',
    '> Checking authorization...',
    '> Authorization: UNKNOWN',
    '> Bypassing...',
    '> ████████████████████ 100%',
    '',
    '> ACCESS GRANTED.',
  ];

  int _visibleMessages = 0;
  bool _showFinalMessage = false;

  @override
  void initState() {
    super.initState();
    _startSequence();
  }

  Future<void> _startSequence() async {
    for (int i = 0; i < _messages.length; i++) {
      await Future.delayed(Duration(milliseconds: i < 3 ? 700 : 500));

      if (!mounted) return;

      setState(() {
        _visibleMessages = i + 1;
      });
    }

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _showFinalMessage = true;
    });

    await _reportEasterEggViewed();
  }

  Future<void> _reportEasterEggViewed() async {
    try {
      final versionResponse = await DioClient.dio.get('/app-version');

      final versionData = versionResponse.data;
      final appVersion = versionData['version']?.toString();

      if (appVersion == null || appVersion.isEmpty) {
        debugPrint('Easter Egg report failed: versi tidak tersedia');
        return;
      }

      final response = await DioClient.dio.post(
        '/easter-egg/viewed',
        data: {'app_version': appVersion, 'platform': 'apk'},
      );

      debugPrint(
        'Easter Egg reported: ${response.statusCode}, '
        'version=$appVersion',
      );
    } on DioException catch (e) {
      debugPrint(
        'Easter Egg report failed: '
        '${e.response?.statusCode} - ${e.message}',
      );
    } catch (e) {
      debugPrint('Easter Egg report error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF050505),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.greenAccent.withValues(alpha: .35)),
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent.withValues(alpha: .08),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 20),

            _buildTerminal(),

            if (_showFinalMessage) _buildSecretMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildDot(Colors.redAccent),
        const SizedBox(width: 6),
        _buildDot(Colors.amber),
        const SizedBox(width: 6),
        _buildDot(Colors.greenAccent),

        const Spacer(),

        Text(
          'CLASSIFIED',
          style: TextStyle(
            color: Colors.redAccent.withValues(alpha: .8),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildTerminal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(_visibleMessages, (index) {
          final isLast = index == _messages.length - 1;

          return Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Text(
              _messages[index],
              style: TextStyle(
                color: isLast
                    ? Colors.greenAccent
                    : Colors.greenAccent.withValues(alpha: .7),
                fontSize: 12,
                fontFamily: 'monospace',
                fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }),

        if (!_showFinalMessage)
          const Text(
            '▋',
            style: TextStyle(
              color: Colors.greenAccent,
              fontFamily: 'monospace',
            ),
          ),
      ],
    );
  }

  Widget _buildSecretMessage() {
    return Column(
      children: [
        const SizedBox(height: 20),

        Center(
          child: Column(
            children: [
              const Text('👁', style: TextStyle(fontSize: 36)),

              const SizedBox(height: 12),

              const Text(
                'YOU FOUND IT.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'You weren\'t supposed to find this.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.greenAccent.withValues(alpha: .9),
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Tidak ada fitur rahasia.\n'
                'Tidak ada bonus.\n'
                'Tidak ada kenaikan gaji.\n\n',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .65),
                  fontSize: 12,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                '👀 Tapi sekarang kamu tahu...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.greenAccent,
              side: BorderSide(color: Colors.greenAccent.withValues(alpha: .4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'KEMBALI BEKERJA',
              style: TextStyle(fontSize: 11, letterSpacing: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}
