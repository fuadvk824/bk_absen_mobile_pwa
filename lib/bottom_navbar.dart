import 'dart:ui';
import 'package:bk_absen/features/auth/presentation/auth_login_screen.dart';
import 'package:bk_absen/features/auth/provider/auth_provider.dart';
import 'package:bk_absen/features/calendar/presentation/calendar_screen.dart';
import 'package:bk_absen/features/category/koperasi.dart';
import 'package:bk_absen/features/category/menu.dart';
import 'package:bk_absen/features/category/profile.dart';
import 'package:bk_absen/features/home/presentation/home_screen.dart';

import 'package:bk_absen/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BottomNavbar extends ConsumerStatefulWidget {
  const BottomNavbar({super.key});

  @override
  ConsumerState<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends ConsumerState<BottomNavbar> {
  int _currentIndex = 0;
  late PageController _pageController;

  late final List<Widget> _pages;

  final List<Map<String, dynamic>> _items = const [
    {"icon": LucideIcons.house, "label": "Home"},
    {"icon": LucideIcons.calendarRange, "label": "Schedule"},
    {"icon": LucideIcons.layoutGrid, "label": "Category"},
    {"icon": LucideIcons.landmark, "label": "Co-op"},
    {"icon": LucideIcons.user, "label": "Profile"},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _pages = [
      HomeScreen(),
      CalendarScreen(),
      Menu(),
      Koperasi(),
      Profile(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Animasi slide saat tap navbar
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    if (auth.value == null) {
      return const AuthLoginScreen();
    }
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xffF8FAFC),

      /// SWIPE PAGE VIEW
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),

      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 24, right: 24, bottom: bottomSafe + 30),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 10,
                    offset: const Offset(0, 0),
                  ),
                ],
                border: BoxBorder.all(color: AppColors.light, width: 1),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  _items.length,
                  (index) => _buildNavItem(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final bool isActive = _currentIndex == index;
    final item = _items[index];

    return GestureDetector(
      onTap: () => _onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 14 : 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? const Color.fromARGB(255, 129, 243, 21)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(
              item["icon"],
              color: isActive ? Colors.white : Colors.white,
              size: 24,
            ),
            
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isActive
                  ? Row(
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          item["label"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
