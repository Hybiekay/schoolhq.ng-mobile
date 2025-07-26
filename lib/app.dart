import 'package:flutter/material.dart';
import 'package:schoolhq_ng/views/auth/login_screen.dart';
import 'package:schoolhq_ng/views/auth/select_school_screen.dart';
import 'package:schoolhq_ng/views/onboarding/onboarding_screen.dart';
import 'package:schoolhq_ng/views/splash/splash_screen.dart';
import 'routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SchoolHQ',
      theme: ThemeData(primarySwatch: Colors.indigo),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.selectSchool: (_) => const SelectSchoolScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        // AppRoutes.home: (_) => const HomeScreen(),
      },
    );
  }
}
