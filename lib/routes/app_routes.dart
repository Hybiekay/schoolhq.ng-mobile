import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schoolhq_ng/home_shell.dart';
import 'package:schoolhq_ng/providers/auth_provider.dart';
import 'package:schoolhq_ng/routes/route_names.dart';
import 'package:schoolhq_ng/views/auth/register_screen.dart';
import 'package:schoolhq_ng/views/auth/school_inactive_screen.dart';
import 'package:schoolhq_ng/views/home/attendance_screen.dart';
import 'package:schoolhq_ng/views/home/calendar_screen.dart';
import 'package:schoolhq_ng/views/home/courses_screen.dart';
import 'package:schoolhq_ng/views/home/exams_screen.dart';
import 'package:schoolhq_ng/views/home/games_screen.dart';
import 'package:schoolhq_ng/views/home/games/math_sprint_screen.dart';
import 'package:schoolhq_ng/views/home/home_screen.dart';
import 'package:schoolhq_ng/views/home/message_conversation_screen.dart';
import 'package:schoolhq_ng/views/home/messages_screen.dart';
import 'package:schoolhq_ng/views/home/notifications_screen.dart';
import 'package:schoolhq_ng/views/home/profile_screen.dart';
import 'package:schoolhq_ng/views/home/student_classes_screen.dart';
import 'package:schoolhq_ng/views/home/student_exam_attempt_screen.dart';
import 'package:schoolhq_ng/views/home/student_exam_detail_screen.dart';
import 'package:schoolhq_ng/views/home/teacher_dashboard_screen.dart';
import 'package:schoolhq_ng/views/home/timetable_screen.dart';
import 'package:schoolhq_ng/views/home/tests_screen.dart';

import '../views/splash/splash_screen.dart';
import '../views/onboarding/onboarding_screen.dart';
import '../views/auth/select_school_screen.dart';
import '../views/auth/login_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  String? registrationGuard() {
    final policy = ref.read(registrationPolicyProvider);
    if (!policy.selfRegistrationEnabled || policy.allowedRoles.isEmpty) {
      return RouteNames.login;
    }
    return null;
  }

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
      GoRoute(
        path: RouteNames.schoolInactive,
        builder: (_, __) => const SchoolInactiveScreen(),
      ),
      GoRoute(path: RouteNames.login, builder: (_, __) => const LoginScreen()),

      /// ================= REGISTER FLOW =================
      GoRoute(
        path: RouteNames.register,
        redirect: (_, __) {
          final blocked = registrationGuard();
          return blocked ?? RouteNames.registerRole;
        },
      ),

      GoRoute(
        path: RouteNames.registerRole, // role
        name: 'register-role',
        redirect: (_, __) => registrationGuard(),
        builder: (_, __) => const RegistrationScreen(step: 0),
      ),
      GoRoute(
        path: RouteNames.registerDetails, // details
        name: 'register-details',
        redirect: (_, __) => registrationGuard(),
        builder: (_, __) => const RegistrationScreen(step: 1),
      ),
      GoRoute(
        path: RouteNames.registerSecurity, // security
        name: 'register-security',
        redirect: (_, __) => registrationGuard(),
        builder: (_, __) => const RegistrationScreen(step: 2),
      ),
      GoRoute(
        path: RouteNames.examDetail,
        builder: (_, state) => StudentExamDetailScreen(
          examId: state.pathParameters['examId'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.examAttempt,
        builder: (_, state) => StudentExamAttemptScreen(
          attemptId: state.pathParameters['attemptId'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.messageConversation,
        builder: (_, state) => MessageConversationScreen(
          conversationId: state.pathParameters['conversationId'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.mathSprint,
        builder: (_, __) => const MathSprintScreen(),
      ),

      ShellRoute(
        builder: (_, __, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: RouteNames.attendance,
            builder: (_, __) => const AttendanceScreen(),
          ),
          GoRoute(
            path: RouteNames.timetable,
            builder: (_, __) => const TimetableScreen(),
          ),
          GoRoute(
            path: RouteNames.calendar,
            builder: (_, __) => const CalendarScreen(),
          ),
          GoRoute(
            path: RouteNames.teacherDashboard,
            builder: (_, __) => const TeacherDashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.courses,
            builder: (_, __) => const CoursesScreen(),
          ),
          GoRoute(
            path: RouteNames.classes,
            builder: (_, __) => const StudentClassesScreen(),
          ),
          GoRoute(
            path: RouteNames.tests,
            builder: (_, __) => const TestsScreen(),
          ),
          GoRoute(
            path: RouteNames.exams,
            builder: (_, __) => const ExamsScreen(),
          ),
          GoRoute(
            path: RouteNames.notifications,
            builder: (_, __) => const NotificationsScreen(),
          ),
          GoRoute(
            path: RouteNames.messages,
            builder: (_, __) => const MessagesScreen(),
          ),
          GoRoute(
            path: RouteNames.games,
            builder: (_, __) => const GamesScreen(),
          ),
          GoRoute(
            path: RouteNames.profile,
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
