import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/network/api_client.dart';
import 'core/routes/routes.dart';
import 'core/service/notification_services.dart';
import 'core/util/app_color.dart';
import 'core/util/storage.dart';
import 'firebase_options.dart';
import 'screens/cart/controller/cart_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Firebase must init before anything else
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Notifications
  await NotificationService.instance.initialize(navigatorKey: navigatorKey);

  await Store.init();
  log('token123 ${Store.userToken}');

  Get.put<FittorConnect>(FittorConnect());

  // Register CartService permanently so it lives for the entire app session.
  // This allows it to own global polling and be found by CartController,
  // RestaurantDetailViewController, and HomeController without re-creation.
  final cartService = Get.put<CartService>(CartService(), permanent: true);

  // Start polling only when a user is logged in.
  // If the user is on the splash/login screen, Store.userToken will be empty
  // and startGlobalPolling() will no-op safely. Call it again from wherever
  // you navigate after login (e.g. AuthController.onLoginSuccess).
  if (Store.userToken.isNotEmpty) {
    cartService.startGlobalPolling();
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
      theme: ThemeData(
        fontFamily: GoogleFonts.urbanist().fontFamily,
        scaffoldBackgroundColor: AppColor.scaffoldColor,
        appBarTheme: const AppBarTheme(
          surfaceTintColor: AppColor.transparent,
          backgroundColor: AppColor.scaffoldColor,
          elevation: 0,
        ),
      ),
      getPages: Routes.routes,
      initialRoute: Routes.initialRoute,
    );
  }
}
