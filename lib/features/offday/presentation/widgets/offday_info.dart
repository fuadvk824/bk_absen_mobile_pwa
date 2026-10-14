import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class OffdayInfo extends StatefulWidget {
  const OffdayInfo({super.key});

  @override
  State<OffdayInfo> createState() => _OffdayInfoState();
}

class _OffdayInfoState extends State<OffdayInfo> {
  OverlayEntry? _overlayEntry;

  void _toggleInfo() {
    if (_overlayEntry != null) {
      _hideInfo();
    } else {
      _showInfo();
    }
  }

  void _showInfo() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _hideInfo,
              ),
            ),

            Positioned(
              top: position.dy + size.height + 8,
              right: 12,
              child: Material(
                color: Colors.transparent,
                child: _OffdayInfoTooltip(
                  onClose: _hideInfo,
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideInfo() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideInfo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleInfo,
        borderRadius: BorderRadius.circular(20),
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: Icon(
            LucideIcons.info,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _OffdayInfoTooltip extends StatelessWidget {
  final VoidCallback onClose;

  const _OffdayInfoTooltip({
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
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
                      'Informasi Offday',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Pengajuan hari libur awal periode',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
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
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _InfoItem(
            icon: Icons.calendar_month_outlined,
            title: 'Pilih tanggal',
            description:
                'Pilih tanggal pada kalender untuk mengajukan hari libur',
          ),

          const SizedBox(height: 12),

          _InfoItem(
            icon: Icons.edit_calendar_outlined,
            title: 'Perubahan tanggal',
            description:
                'Periksa daftar perubahan tanggal yang dipilih '
                'sebelum mengajukan permohonan.',
          ),

          const SizedBox(height: 12),

          _InfoItem(
            icon: Icons.notes_outlined,
            title: 'Aturan pengajuan',
            description:
                'Tidak boleh memilih hari libur sama dengan rekan kerja, diskusikan pemilihan hari libur'
          ),
          
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 18,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
