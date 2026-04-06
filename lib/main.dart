import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_attendance/apps/routes/routes.dart';
import 'package:staff_attendance/apps/themes/app_colors.dart';
import 'package:staff_attendance/apps/themes/app_themes.dart';
import 'package:staff_attendance/apps/controllers/theme_controller/theme_controller.dart';
import 'package:staff_attendance/language/String.dart';

import 'firebase_options.dart';
import 'core/services/storage_service.dart';
import 'core/bindings/app_bindings.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  await GetStorage.init();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    print('❌ Firebase init failed: $e');
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await _initFCM();

  runApp(const MyApp());
}

Future<void> _initFCM() async {
  try {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await messaging.getToken();
      if (token != null) {
        await StorageService.saveFcmToken(token);
      }
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      await StorageService.saveFcmToken(token);
    });
  } catch (e) {
    print('⚠️ FCM init failed: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Handle notification that launched app from terminated state
      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) _handleNotificationTap(message);
      });

      // Handle notification tap from background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    });
  }

  void _handleNotificationTap(RemoteMessage message) {
    final route = message.data['route'] as String?;
    if (route != null && route.isNotEmpty) {
      Get.toNamed(route);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      useInheritedMediaQuery: true,
      designSize: const Size(414, 896),
      builder: (_, child) => GetMaterialApp(
        title: 'Attendance App',
        // Translations (GetX)
        translations: AppTranslations(),
        // Do not hardcode `locale` here; `LocaleController` will call
        // `Get.updateLocale(...)` during startup to restore persisted locale.
        fallbackLocale: const Locale('en', 'US'),
        debugShowCheckedModeBanner: false,
        navigatorKey: Get.key,
        // Provide base themes for the app. Actual animated switching is
        // handled by the AnimatedTheme widget in the inner builder so
        // theme changes lerp smoothly.
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        // Keep themeMode controlled by ThemeController for semantics
        // but visual transitions are animated below.
        themeMode: ThemeMode.light,
        initialBinding: AppBindings(),
        initialRoute: Routes.splash,
        getPages: Routes.list,
        builder: (context, widget) {
          ScreenUtil.init(context);
          // AnimatedTheme needs to run after bindings are initialized,
          // so use an Obx/Reactive lookup here (ThemeController is
          // registered in AppBindings).
          return Obx(() {
            final themeCtrl = Get.find<ThemeController>();
            final activeTheme = themeCtrl.isDark
                ? AppTheme.dark
                : AppTheme.light;

            return AnimatedTheme(
              data: activeTheme,
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeInOut,
              child: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.0)),
                child: widget!,
              ),
            );
          });
        },
      ),
    );
  }
}
