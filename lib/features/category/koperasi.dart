import 'package:flutter/material.dart';
import 'package:bk_absen/utils/app_colors.dart';

class Koperasi extends StatelessWidget {
  const Koperasi({super.key});

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Center(child: Text('Menu koperasi, pending...'))),
    );
  }
}
