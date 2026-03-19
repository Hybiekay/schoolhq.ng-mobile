class RouteNames {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const selectSchool = '/select-school';
  static const schoolInactive = '/school-inactive';
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
  static const courses = '/courses';
  static const tests = '/tests';
  static const exams = '/exams';
  static const teacherDashboard = '/teacher-dashboard';
  static const attendance = '/attendance';
  static const timetable = '/timetable';
  static const calendar = '/calendar';
  static const profile = '/profile';
  static const examDetail = '/exams/:examId';
  static const examAttempt = '/exams/attempt/:attemptId';

  static String examDetailPath(String examId) => '/exams/$examId';
  static String examAttemptPath(String attemptId) => '/exams/attempt/$attemptId';
}
