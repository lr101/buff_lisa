import 'package:buff_lisa/1_ScreenSignIn/login.dart';
import 'package:buff_lisa/1_ScreenSignIn/secure.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter_native_splash/flutter_native_splash.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  WidgetsFlutterBinding.ensureInitialized();
  if (defaultTargetPlatform == TargetPlatform.android) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }
  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

Future initialization(BuildContext? context) async {
  await Future.delayed(const Duration(seconds: 3));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    return  MaterialApp(
      title: 'Flutter Google Maps Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
      },
      navigatorKey: navigatorKey, // Setting a global key for navigator
    );
  }
}

