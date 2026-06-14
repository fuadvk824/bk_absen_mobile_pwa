import 'package:flutter/material.dart';
import 'package:bk_absen/utils/app_colors.dart';

class Payroll extends StatelessWidget {
  final String title;

  const Payroll({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Center(child: Text('Menu Payroll, pending...'))),
    );
  }
}
