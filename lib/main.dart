import 'dart:async';
import 'dart:io';
import 'package:buff_lisa/Providers/user_notifier.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:buff_lisa/0_ScreenSignIn/login_logic.dart';
import 'package:buff_lisa/0_ScreenSignIn/secure.dart';
import 'package:buff_lisa/10_UploadOffline/upload_offline_logic.dart';
import 'package:buff_lisa/1_BottomNavigationBar/navbar_logic.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'Files/DTOClasses/groupDTO.dart';
import 'Files/DTOClasses/pinDTO.dart';
import 'Files/Other/global.dart' as global;

/// global key for enabling different routes on startup
final navigatorKey = GlobalKey<NavigatorState>();

/// THIS IS THE START OF THE PROGRAMM
/// binding Widgets before initialization is required by multiple packages
/// initializes access to env variables
/// checks if user is logged in on this device by checking device storage
Future<void> main() async {
  if (!kIsWeb) WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  global.cameras = await availableCameras();
  await dotenv.load();
  await Hive.initFlutter();
  Hive.registerAdapter(GroupDTOAdapter());
  Hive.registerAdapter(PinDTOAdapter());
  runApp(MyApp(isLoggedIn: await Secure.tryLocalLogin()));
}

class MyApp extends StatelessWidget {

  /// true: user is already logged in on this device: direct route to [BottomNavigationWidget]
  /// false: user is not logged in on this device: redirect to [LoginScreen]
  final bool isLoggedIn;

  ///Constructor
  const MyApp({super.key, required this.isLoggedIn});


  @override
  Widget build(BuildContext context) {
    /// App orientation can only be portrait mode (no landscape)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    /// Statusbar color (where time and notification are displayed) is set to transparent
    /// app will not use the space if not set specifically in widget
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    /// create [ClusterNotifier] used to save all important information
    return MultiProvider(
            providers: [
              ChangeNotifierProvider.value(
                value: ClusterNotifier(),
              ),
              ChangeNotifierProvider.value(
                value: ThemeProvider(),
              ),
              ChangeNotifierProvider.value(
                value: UserNotifier(),
              ),
            ],
            builder: (context, child) => MaterialApp (
                  theme: Provider.of<ThemeProvider>(context).getTheme,
                  title: 'Mona App',
                  initialRoute: isLoggedIn ? '/home' : '/login',
                  routes: {
                    '/login': (context) => const LoginScreen(),
                    '/home': (context) => const BottomNavigationWidget()
                  },
                navigatorKey: navigatorKey, // Setting a global key for navigator
            )
    );
  }
}

