import 'dart:async';

import 'package:bk_absen/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Clock extends StatefulWidget {
  const Clock({super.key});

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  late Timer timer;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => now = DateTime.now());
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(now),
          style: TextStyle(color: AppColors.light,),
        ),
        Text(
          DateFormat('HH:mm:ss').format(now),
          style: TextStyle(color: AppColors.light),
        ),
      ],
    );
  }
}
