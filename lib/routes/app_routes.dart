import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schoolhq_ng/routes/route_names.dart';
import 'package:schoolhq_ng/views/auth/register_screen.dart';

import '../views/splash/splash_screen.dart';
import '../views/onboarding/onboarding_screen.dart';
import '../views/auth/select_school_screen.dart';
import '../views/auth/login_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.selectSchool,
        builder: (_, __) => const SelectSchoolScreen(),
      ),
      GoRoute(path: RouteNames.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: RouteNames.register,
        redirect: (_, __) => RouteNames.registerRole,
        routes: [
          GoRoute(
            path: RouteNames.registerDetailsSegment,
            name: 'register-details',
            builder: (_, __) => const RegistrationScreen(step: 1),
          ),
          GoRoute(
            path: RouteNames.registerRoleSegment,
            name: 'register-role', // Named route for context.goNamed()
            builder: (_, __) => const RegistrationScreen(step: 0),
          ),
        ],
      ),
      // GoRoute(
      //   path: RouteNames.registerRoleSegment,
      //   name: 'register-role', // Named route for context.goNamed()
      //   builder: (_, __) => const RegistrationScreen(step: 0),
      // ),
      // GoRoute(
      //   path: RouteNames.registerDetailsSegment,
      //   name: 'register-details',
      //   builder: (_, __) => const RegistrationScreen(step: 1),
      // ),
      GoRoute(
        path: RouteNames.registerSecuritySegment,
        name: 'register-security',
        builder: (_, __) => const RegistrationScreen(step: 2),
      ),
    ],
  );
});
