class RouteNames {
  // Base routes
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const selectSchool = '/select-school';
  static const login = '/login';
  static const home = '/home';
  static const register = '/register';

  // Registration sub-routes - using static properties
  static const String registerRole = '/register/role';
  static const String registerDetails = '/register/details';
  static const String registerSecurity = '/register/security';

  // Optional: You can also create a method to get registration route by step
  static String getRegistrationRoute(int step) {
    switch (step) {
      case 0:
        return registerRole;
      case 1:
        return registerDetails;
      case 2:
        return registerSecurity;
      default:
        return registerRole;
    }
  }

  // Optional: You can also have just the path segments for nested routes
  static const registerRoleSegment = 'role';
  static const registerDetailsSegment = 'details';
  static const registerSecuritySegment = 'security';
}
