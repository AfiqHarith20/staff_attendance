import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:staff_attendance/api/api_client.dart';
import 'package:staff_attendance/apps/controllers/other_controller/other_controller.dart';
import 'package:staff_attendance/apps/routes/api_routes.dart';
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

class _BottomNavScreenState extends State<BottomNavScreen>
    with WidgetsBindingObserver {
  static const List<Widget> _pages = [
    DashboardScreen(),
    MyAttendanceScreen(),
    OtherScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissionsFromApi();
    }
  }

  Future<void> _refreshPermissionsFromApi() async {
    try {
      final response = await ApiClient.instance.get(ApiList.currentUser);
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      final isAdmin = data['is_admin'] as bool? ?? false;
      final rawPerms = data['permissions'];
      final perms = rawPerms is List
          ? rawPerms.map((e) => e.toString()).toList()
          : <String>[];
      final box = GetStorage();
      await box.write('is_admin', isAdmin);
      await box.write('user_permissions', perms);
      if (Get.isRegistered<OtherController>()) {
        Get.find<OtherController>().refreshPermissions();
      }
    } catch (_) {
      // non-blocking — permissions stay as-is until next successful refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;

    final nav = Get.find<BottomNavController>();
    return Obx(() {
      final isWide = MediaQuery.of(context).size.width >= 700;
      final pages = _pages;
      final destinations = [
        _NavItem(Icons.home_rounded, 'home'.tr),
        _NavItem(Icons.fact_check_rounded, 'attendance'.tr),
        _NavItem(Icons.apps_rounded, 'other'.tr),
        _NavItem(Icons.person_rounded, 'profile'.tr),
      ];

      if (nav.index.value >= pages.length) {
        nav.setIndex(0);
      }

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
          child: pages[nav.index.value],
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
                trailing: null,
                destinations: destinations
                    .map(
                      (item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.icon, color: primary),
                        label: Text(item.label),
                      ),
                    )
                    .toList(),
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
          items: destinations
              .map(
                (item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                ),
              )
              .toList(),
        ),
      );
    });
  }

}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem(this.icon, this.label);
}
