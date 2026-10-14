import 'package:flutter/material.dart';
import 'package:bk_absen/features/offday/provider/offday_provider.dart';

class OffdaySubmitButton extends StatelessWidget {
  const OffdaySubmitButton({
    super.key,
    required this.state,
    required this.onPressed,
  });

  final OffdayState state;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: state.isSubmitting ? null : onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: state.isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Ajukan ${state.selectedChanges.length} Tanggal',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
