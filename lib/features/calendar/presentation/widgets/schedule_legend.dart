import 'package:bk_absen/model/calendar_legend_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ScheduleLegend extends StatefulWidget {
  final List<CalendarLegend> legend;

  const ScheduleLegend({super.key, required this.legend});

  @override
  State<ScheduleLegend> createState() => _ScheduleLegendState();
}

class _ScheduleLegendState extends State<ScheduleLegend> {
  OverlayEntry? _overlayEntry;

  void _toggleLegend() {
    if (_overlayEntry != null) {
      _hideLegend();
    } else {
      _showLegend();
    }
  }

  void _showLegend() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _hideLegend,
              ),
            ),

            Positioned(
              right: 12,
              top: position.dy + size.height + 8,
              child: Material(
                color: Colors.transparent,
                child: _ScheduleLegendTooltip(
                  legend: widget.legend,
                  onClose: _hideLegend,
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideLegend() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideLegend();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleLegend,
        borderRadius: BorderRadius.circular(20),
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: Icon(LucideIcons.info, size: 17, color: Colors.black87),
        ),
      ),
    );
  }
}

class _ScheduleLegendTooltip extends StatelessWidget {
  final List<CalendarLegend> legend;
  final VoidCallback onClose;

  const _ScheduleLegendTooltip({required this.legend, required this.onClose});

  Color _getColor(String status) {
    for (final item in legend) {
      if (item.status.trim().toLowerCase() == status.trim().toLowerCase()) {
        return Color(item.warna);
      }
    }

    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final liburColor = _getColor('Tidak Hadir');
    final cutiColor = _getColor('Cuti');

    return Container(
      width: 290,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keterangan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Arti warna pada jadwal kerja',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.grey),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const _LegendItem(
            color: Colors.black,
            title: 'Hari Ini',
            today: true,
          ),

          _LegendItem(
            color: liburColor,
            title: 'Libur / Tidak Hadir',
            background: true,
          ),

          const _LegendItem(
            color: Colors.black,
            title: 'Masuk',
            background: true,
          ),

          _LegendItem(color: cutiColor, title: 'Cuti', background: true),

          const _LegendItem(
            color: Colors.black,
            title: 'Ada Jadwal, Belum Terlaksana',
            background: false,
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String title;
  final bool background;
  final bool today;

  const _LegendItem({
    required this.color,
    required this.title,
    this.background = true,
    this.today = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: Center(
              child: today
                  ? Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '31',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: background
                            ? color.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: background
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '31',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              '31',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
