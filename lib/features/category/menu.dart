import 'package:bk_absen/features/category/payroll.dart';
import 'package:bk_absen/features/leave/presentation/leave_screen.dart';
import 'package:bk_absen/features/overtime/presentation/overtime_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bk_absen/utils/app_colors.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final Widget page;

  const MenuItem({
    required this.title,
    required this.icon,
    required this.page,
  });
}

class Menu extends StatelessWidget {
  const Menu({super.key});

  /// DATA MENU
  static const List<MenuItem> menus = [
    MenuItem(
      title: "Lembur",
      icon: LucideIcons.clockPlus,
      page: OvertimeScreen(title: 'Lembur'),
    ),
    MenuItem(
      title: "Cuti",
      icon: LucideIcons.luggage,
      page: LeaveScreen(title: 'Cuti'),
    ),
    MenuItem(
      title: "Payroll",
      icon: LucideIcons.receipt,
      page: Payroll(title: 'Payroll')
    ),
  
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// TITLE
            const Text(
              "Menu Lintune",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),

            /// GRID MENU
            Expanded(
              child: GridView.builder(
                itemCount: menus.length,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final menu = menus[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => menu.page,
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// ICON BOX
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            menu.icon,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// TITLE
                        Text(
                          menu.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}