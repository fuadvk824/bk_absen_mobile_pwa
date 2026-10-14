import 'package:flutter/material.dart';
import 'package:bk_absen/features/offday/provider/offday_provider.dart';

class OffdayCalendarDay extends StatelessWidget {
  const OffdayCalendarDay({
    super.key,
    required this.context,
    required this.date,
    required this.notifier,
    required this.state,
    this.isToday = false,
    this.isSelected = false,
  });

  final BuildContext context;
  final DateTime date;
  final OffdayNotifier notifier;
  final OffdayState state;
  final bool isToday;
  final bool isSelected;

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  @override
  Widget build(BuildContext _) {
    final dateKey = _dateKey(date);
    final day = notifier.getDay(dateKey);

    if (day == null) {
      return Center(
        child: Text(
          '${date.day}',
          style: TextStyle(color: Colors.grey.shade400),
        ),
      );
    }

    final isOff = notifier.isOff(day);
    final isChanged = state.selectedChanges.containsKey(day.id);
    final isPending = day.hasPendingRequest;

    final hasColleagueOffday = notifier.isColleagueOffday(dateKey);
    final hasColleaguePending = notifier.isColleaguePendingRequest(dateKey);

    final textColor = isPending
        ? Colors.blue
        : isOff
            ? Colors.red
            : Colors.black;

    final backgroundColor = isChanged
        ? (isOff
            ? Colors.red.withValues(alpha: .12)
            : Colors.black.withValues(alpha: .08))
        : Colors.transparent;

    Color? borderColor;

    if (hasColleagueOffday && hasColleaguePending) {
      borderColor = null;
    } else if (hasColleagueOffday) {
      borderColor = Colors.red;
    } else if (hasColleaguePending) {
      borderColor = Colors.orange;
    }  
    return Center(
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: borderColor != null
              ? Border.all(color: borderColor, width: 2)
              : null,
        ),
        child: CustomPaint(
          foregroundPainter: hasColleagueOffday && hasColleaguePending
              ? const _DualBorderPainter(
                  firstColor: Colors.red,
                  secondColor: Colors.orange,
                )
              : null,
          child: Center(
            child: Text(
              '${date.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: isChanged ? FontWeight.w800 : FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DualBorderPainter extends CustomPainter {
  const _DualBorderPainter({
    required this.firstColor,
    required this.secondColor,
  });

  final Color firstColor;
  final Color secondColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final radius = (size.shortestSide / 2) - 1.5;

    final firstPaint = Paint()
      ..color = firstColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final secondPaint = Paint()
      ..color = secondColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      3.14159,
      false,
      firstPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.5708,
      3.14159,
      false,
      secondPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DualBorderPainter oldDelegate) {
    return oldDelegate.firstColor != firstColor ||
        oldDelegate.secondColor != secondColor;
  }
}
