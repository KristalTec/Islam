import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'presentation/screens/main_navigation_screen.dart';

class IslamOnlineApp extends StatelessWidget {
  const IslamOnlineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Islam Online',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // RTL support for Kurdish/Arabic
      locale: const Locale('ar'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('ckb'), // Central Kurdish (Sorani)
        Locale('en'),
      ],
      home: const MainNavigationScreen(),
    );
  }
}
