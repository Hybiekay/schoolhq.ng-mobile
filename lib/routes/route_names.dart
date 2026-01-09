class RouteNames {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const selectSchool = '/select-school';
  static const login = '/login';

  static const register = '/register';

  // child segments (NO leading slash)
  static const registerRoleSegment = 'role';
  static const registerDetailsSegment = 'details';
  static const registerSecuritySegment = 'security';

  // full paths (optional helpers)
  static const registerRole = '/register/role';
  static const registerDetails = '/register/details';
  static const registerSecurity = '/register/security';

  static const home = '/home';
}
