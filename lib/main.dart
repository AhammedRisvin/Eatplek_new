import 'dart:developer';

import 'package:fittor/fittor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/network/api_client.dart';
import 'core/routes/routes.dart';
import 'core/util/app_color.dart';
import 'core/util/storage.dart';

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
  await Store.init();
  log('token123 ${Store.userToken}');
  Get.put<FittorConnect>(FittorConnect());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget with FittorAppMixin {
  const MyApp({super.key});
  @override
  Widget responsive(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
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
