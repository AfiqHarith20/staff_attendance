import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_attendance/apps/themes/app_colors.dart';
import 'package:staff_attendance/apps/views/home/dashboard_screen/dashboard_screen.dart';
import 'package:staff_attendance/apps/views/home/my_attendance_screen/my_attendance_screen.dart';
import 'package:staff_attendance/apps/views/home/other_screen/other_screen.dart';
import 'package:staff_attendance/apps/views/home/profile_screen/profile_screen.dart';
import 'package:staff_attendance/apps/controllers/bottom_nav_controller/bottom_nav_controller.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  final _pages = const [
    DashboardScreen(),
    MyAttendanceScreen(),
    OtherScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Ensure BottomNavController is registered and apply incoming argument if present
    if (!Get.isRegistered<BottomNavController>()) {
      Get.put(BottomNavController());
    }
    final ctrl = Get.find<BottomNavController>();
    final arg = Get.arguments;
    if (arg is int && arg >= 0 && arg < _pages.length) {
      ctrl.setIndex(arg);
    } else if (arg is Map && arg['tabIndex'] is int) {
      final tabIndex = arg['tabIndex'] as int;
      if (tabIndex >= 0 && tabIndex < _pages.length) {
        ctrl.setIndex(tabIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;

    final nav = Get.find<BottomNavController>();
    return Obx(() {
      final isWide = MediaQuery.of(context).size.width >= 700;

      Widget content = AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );
          final slide =
              Tween<Offset>(
                begin: const Offset(0.03, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );
          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(nav.index.value),
          child: _pages[nav.index.value],
        ),
      );

      if (isWide) {
        // Use a NavigationRail on wider screens (web/desktop/tablet)
        final extended = MediaQuery.of(context).size.width >= 1000;
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: nav.index.value,
                onDestinationSelected: (v) => nav.setIndex(v),
                groupAlignment: -1.0,
                extended: extended,
                selectedIconTheme: IconThemeData(color: primary),
                unselectedIconTheme: IconThemeData(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                labelType: extended
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                destinations: [
                  NavigationRailDestination(
                    icon: const Icon(Icons.home_rounded),
                    selectedIcon: Icon(Icons.home_rounded, color: primary),
                    label: Text('home'.tr),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.fact_check_rounded),
                    selectedIcon: Icon(
                      Icons.fact_check_rounded,
                      color: primary,
                    ),
                    label: Text('attendance'.tr),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.layers_rounded),
                    selectedIcon: Icon(Icons.layers_rounded, color: primary),
                    label: Text('other'.tr),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.person_rounded),
                    selectedIcon: Icon(Icons.person_rounded, color: primary),
                    label: Text('profile'.tr),
                  ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: content),
            ],
          ),
        );
      }

      // Default mobile / narrow layout with BottomNavigationBar
      return Scaffold(
        body: content,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: nav.index.value,
          onTap: (v) => nav.setIndex(v),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primary,
          unselectedItemColor: Theme.of(context).textTheme.bodyMedium?.color,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded),
              label: 'home'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.fact_check_rounded),
              label: 'attendance'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.layers_rounded),
              label: 'other'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_rounded),
              label: 'profile'.tr,
            ),
          ],
        ),
      );
    });
  }
}
