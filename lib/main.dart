import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/network/api_client.dart';
import 'core/routes/routes.dart';
import 'core/service/notification_services.dart';
import 'core/util/app_color.dart';
import 'core/util/storage.dart';
import 'firebase_options.dart';
import 'screens/cart/controller/cart_service.dart';
import 'screens/profile/controller/profile_controller.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Portrait-only — EatPlek UI is not designed for landscape ────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Status bar styling ───────────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // ── Suppress non-critical image 404 errors in debug ─────────────────────
  if (kDebugMode) {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('HttpException') &&
          details.exception.toString().contains('Invalid statusCode: 404')) {
        debugPrint('Image loading error suppressed: ${details.exception}');
        return;
      }
      FlutterError.presentError(details);
    };
  }

  // ── flutter_animate global defaults ─────────────────────────────────────
  Animate.restartOnHotReload = true;

  // ── Firebase must init before anything else ──────────────────────────────
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ── Notifications ────────────────────────────────────────────────────────
  await NotificationService.instance.initialize(navigatorKey: navigatorKey);

  await Store.init();
  log('token: ${Store.userToken.isNotEmpty ? '[present]' : '[empty]'}');

  // ── Core services ────────────────────────────────────────────────────────
  Get.put<FittorConnect>(FittorConnect());

  // ProfileController registered permanently so userName is available
  // on HomeView header immediately without a second API call
  Get.put<ProfileController>(ProfileController(), permanent: true);

  // CartService registered permanently — found by CartController,
  // RestaurantDetailViewController, and HomeController.
  // Polling is NOT started here — it starts only when CartView is opened
  // (CartService.onCartViewEntered) and stops when CartView is closed
  // (CartService.onCartViewExited). This eliminates unnecessary API calls
  // on every other screen.
  Get.put<CartService>(CartService(), permanent: true);

  // One-shot fetch to populate the bottom nav badge count on startup
  if (Store.userToken.isNotEmpty) {
    Get.find<CartService>().fetchCartItemCount();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget with FittorAppMixin {
  const MyApp({super.key});

  @override
  Widget responsive(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'EatPlek',
      theme: ThemeData(
        fontFamily: GoogleFonts.urbanist().fontFamily,
        scaffoldBackgroundColor: AppColor.scaffoldColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor.appPrimary,
          primary: AppColor.appPrimary,
        ),
        appBarTheme: const AppBarTheme(
          surfaceTintColor: AppColor.transparent,
          backgroundColor: AppColor.scaffoldColor,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        // Disable all ink splash effects globally — we use custom ripples
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      getPages: Routes.routes,
      initialRoute: Routes.initialRoute,
      // Smooth default page transition
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
