import 'package:bk_absen/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ActionButtonSection extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  const ActionButtonSection({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  State<ActionButtonSection> createState() => _ActionButtonSectionState();
}

class _ActionButtonSectionState extends State<ActionButtonSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final int waveCount = 3;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ActionButtonSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    //  start looping
    if (widget.isLoading && !_controller.isAnimating) {
      _controller.repeat();
    }

    if (!widget.isLoading && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  void _handleTap() {
    if (widget.isLoading) return;

    HapticFeedback.vibrate(); 
    _controller.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted && !widget.isLoading) {
        _controller.reset();
      }
    });

    // tetap panggil parent (biar logic jalan)
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          ///  WAVE ANIMATION
          Positioned.fill(
            child: IgnorePointer(
              child: OverflowBox(
                maxWidth: double.infinity,
                maxHeight: double.infinity,

               
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    //  BELUM LOADING → JANGAN TAMPILKAN WAVE SAMA SEKALI
                    if (!widget.isLoading) {
                      return const SizedBox.shrink();
                    }

                    return Stack(
                      alignment: Alignment.center,
                      children: List.generate(waveCount, (index) {
                        final rawProgress = (_controller.value - (index * 0.2))
                            .clamp(0.0, 1.0);

                        if (rawProgress <= 0 || rawProgress >= 1) {
                          return const SizedBox.shrink();
                        }

                        final progress = Curves.easeOut.transform(rawProgress);

                        final size = 120 + (progress * 500);
                      
                        final opacity = (1 - progress).clamp(0.0, 1.0);

                        return Opacity(
                          opacity: opacity,
                          child: Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.secondary.withValues(
                                alpha: 0.25,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
          ),

          ///  BACKGROUND CIRCLES
          _buildOuterCircle(220),
          _buildOuterCircle(200),
          _buildOuterCircle(180),

          ///  MAIN BUTTON
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              // onTap: widget.isLoading ? null : _handleTap,
              onTap: _handleTap,
              child: _buildMainButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton() {
    return Container(
      height: 110,
      width: 110,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF1F5F9), Color(0xFFF8FAFC)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(6, 6),
            blurRadius: 12,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-6, -6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFF8FAFC),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.touch_app_rounded,
              size: 30,
              color: Colors.black87,
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOuterCircle(double size) {
    return Container(
      height: size,
      width: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF4F6FA),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            offset: Offset(6, 6),
            blurRadius: 16,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-6, -6),
            blurRadius: 16,
          ),
        ],
      ),
    );
  }
}
