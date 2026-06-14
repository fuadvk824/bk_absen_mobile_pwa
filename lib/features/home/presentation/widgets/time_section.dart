import 'package:flutter/material.dart';

class TimeSection extends StatelessWidget {
  final String time;
  final String date;

  const TimeSection({super.key, required this.time, required this.date});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          time,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(date, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}
