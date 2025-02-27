import 'dart:io';
import 'package:chat_babakcode/providers/auth_provider.dart';
import 'package:chat_babakcode/providers/home_provider.dart';
import 'package:chat_babakcode/providers/login_provider.dart';
import 'package:chat_babakcode/providers/global_setting_provider.dart';
import 'package:chat_babakcode/providers/profile_provider.dart';
import 'package:chat_babakcode/providers/security_provider.dart';
import 'package:chat_babakcode/ui/pages/profile/profile_user_page.dart';
import 'package:chat_babakcode/ui/pages/splash/splash_page.dart';
import 'package:chat_babakcode/utils/firebase_maager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'constants/app_constants.dart';
import 'providers/chat_provider.dart';
import 'providers/search_user_provider.dart';
import 'utils/notification_controller.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  Hive.init('./');
  if (!kIsWeb) {
    if (Platform.isAndroid || Platform.isIOS) {
      await Hive.initFlutter();
      await FirebaseManager.initFirebaseOnPhone();
    }
  }else{
    await FirebaseManager.initFirebaseOnWeb();
  }

  // final box = await Hive.openLazyBox<Map>('rooms');
  await Hive.openBox<Map>('room');
  await Hive.openBox<Map>('user');
  await Hive.openBox<Map>('chat');


  await Hive.openBox('me');
  await Hive.openBox('setting');

  // Always initialize Awesome Notifications
  await NotificationController.initializeLocalNotifications();

  runApp(const _Provider());
}

class _Provider extends StatelessWidget {
  const _Provider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (c) => GlobalSettingProvider(),
        ),
        ChangeNotifierProvider(create: (context) => Auth()),
        // ChangeNotifierProvider(create: (c) => LoginProvider()),
        ChangeNotifierProxyProvider<Auth, LoginProvider>(
          update: (context, auth, loginPrevious) =>
              loginPrevious!..initAuth(auth),
          create: (c) => LoginProvider(),
        ),
        ChangeNotifierProxyProvider<Auth, ChatProvider>(
          create: (c) => ChatProvider(),
          update: (context, auth, previous) => previous!..initAuth(auth),
        ),
        ChangeNotifierProxyProvider<ChatProvider, SecurityProvider>(
          create: (c) => SecurityProvider(),
          update: (context, chatProvider, previous) => previous!..initChatProvider(chatProvider),
        ),
        ChangeNotifierProxyProvider<ChatProvider, SearchUserProvider>(
          create: (c) => SearchUserProvider(),
          update: (context, chatProvider, previous) => previous!..initChatProvider(chatProvider),
        ),
        ChangeNotifierProvider(
          create: (c) => HomeProvider(),
        ),
        ChangeNotifierProxyProvider<ChatProvider , ProfileProvider>(create: (context) => ProfileProvider(), update: (context, value, previous) => previous!..initChatProvider(value),)
      ],
      child: const MyApp(),
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final shared = context.watch<GlobalSettingProvider>();
    return MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Business Chat',
        themeMode: (shared.settingBox.get('dark') == null)
            ? ThemeMode.system
            : shared.isDarkTheme
                ? ThemeMode.dark
                : ThemeMode.light,
        darkTheme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFF0C1D2F),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: AppConstants.textColor[100],
            selectionColor: AppConstants.blueAccent,
            selectionHandleColor: AppConstants.blueAccent,
          ),
          cardColor: const Color(0xFF1B416B),
          appBarTheme: AppBarTheme(
              iconTheme: IconThemeData(
                  color: AppConstants.textColor[100], opacity: 0.8),
              actionsIconTheme: IconThemeData(
                  color: AppConstants.textColor[100], opacity: 0.8),
              backgroundColor: AppConstants.textColor[900],
              titleTextStyle:
                  TextStyle(fontSize: 14, color: AppConstants.textColor[100]),
              elevation: 10),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: AppConstants.primarySwatch,
            brightness: Brightness.dark,
          ).copyWith(
            secondary: AppConstants.primarySwatch[50],
          ),
        ),
        theme: ThemeData(
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: AppConstants.textColor[900],
            selectionColor: AppConstants.blueAccent,
            selectionHandleColor: AppConstants.blueAccent,
          ),
          scaffoldBackgroundColor: const Color.fromARGB(255, 218, 241, 255),
          cardColor: const Color.fromARGB(255, 181, 225, 255),
          appBarTheme: AppBarTheme(
            iconTheme:
                IconThemeData(color: AppConstants.textColor[900], opacity: 0.8),
            actionsIconTheme:
                IconThemeData(color: AppConstants.textColor[900], opacity: 0.8),
            backgroundColor: AppConstants.scaffoldLightBackground,
            elevation: 10,
            shadowColor: AppConstants.textColor[50]!.withOpacity(.2),
            titleTextStyle:
                TextStyle(fontSize: 14, color: AppConstants.textColor[900]),
          ),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: AppConstants.primarySwatch,
            brightness: Brightness.light,
          ).copyWith(secondary: AppConstants.primarySwatch[50]),
        ),
        home: const SplashPage());
  }
}
