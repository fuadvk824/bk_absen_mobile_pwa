import 'package:flutter/material.dart';

class OffdayLegend extends StatelessWidget {
  const OffdayLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20,
      runSpacing: 8,
      children: const [
        _LegendItem(
          color: Colors.black,
          text: 'Masuk',
        ),
        _LegendItem(
          color: Colors.red,
          text: 'Libur',
        ),
        _LegendItem(
          color: Colors.blue,
          text: 'Pending',
        ),
        _LegendItem(
          color: Colors.red,
          text: 'Libur rekan',
          isBorder: true,
        ),
        _LegendItem(
          color: Colors.orange,
          text: 'Pending rekan',
          isBorder: true,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.text,
    this.isBorder = false,
  });

  final Color color;
  final String text;
  final bool isBorder;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isBorder ? Colors.transparent : color,
            shape: BoxShape.circle,
            border: isBorder
                ? Border.all(
                    color: color,
                    width: 2,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
