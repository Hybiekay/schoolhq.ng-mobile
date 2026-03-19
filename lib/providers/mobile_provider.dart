import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';
import 'package:schoolhq_ng/core/hive/hive_key.dart';
import 'package:schoolhq_ng/providers/auth_provider.dart';
import 'package:schoolhq_ng/repositories/mobile_repository.dart';

final mobileRepositoryProvider = Provider<MobileRepository>((ref) {
  return MobileRepository(ref.read(flintClientProvider));
});

final currentUserRoleProvider = Provider<String>((ref) {
  final raw = Hive.box(
    HiveKey.boxApp,
  ).get(HiveKey.userRole, defaultValue: 'student');
  return (raw is String && raw.isNotEmpty) ? raw.toLowerCase() : 'student';
});

final parentSelectedChildIdProvider =
    StateNotifierProvider<ParentSelectedChildController, String?>((ref) {
      return ParentSelectedChildController();
    });

class ParentSelectedChildController extends StateNotifier<String?> {
  ParentSelectedChildController() : super(_initialValue());

  static String? _initialValue() {
    final raw = Hive.box(HiveKey.boxApp).get(HiveKey.selectedParentChildId);
    return raw is String && raw.isNotEmpty ? raw : null;
  }

  void set(String? childId) {
    state = childId;
    final box = Hive.box(HiveKey.boxApp);
    if (childId == null || childId.isEmpty) {
      box.delete(HiveKey.selectedParentChildId);
    } else {
      box.put(HiveKey.selectedParentChildId, childId);
    }
  }
}

final mobileDashboardProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final role = ref.watch(currentUserRoleProvider);
  return ref.read(mobileRepositoryProvider).fetchDashboard(role);
});

final mobileTimetableProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final role = ref.watch(currentUserRoleProvider);
  return ref.read(mobileRepositoryProvider).fetchTimetable(role);
});

final mobileCalendarProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final role = ref.watch(currentUserRoleProvider);
  return ref.read(mobileRepositoryProvider).fetchCalendar(role);
});

final mobileProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final role = ref.watch(currentUserRoleProvider);
  return ref.read(mobileRepositoryProvider).fetchProfile(role);
});

final parentChildrenProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final role = ref.watch(currentUserRoleProvider);
  if (role != 'parent') return const [];

  final data = await ref.read(mobileRepositoryProvider).fetchChildren();
  final children = (data['children'] as List?) ?? const [];
  final parsed = children
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();

  final selected = ref.read(parentSelectedChildIdProvider);
  if (parsed.isNotEmpty &&
      (selected == null ||
          !parsed.any((c) => c['id']?.toString() == selected))) {
    ref
        .read(parentSelectedChildIdProvider.notifier)
        .set(parsed.first['id']?.toString());
  }

  return parsed;
});

final mobileAttendanceProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final role = ref.watch(currentUserRoleProvider);
  String? childId;
  if (role == 'parent') {
    final children = await ref.watch(parentChildrenProvider.future);
    childId = ref.watch(parentSelectedChildIdProvider);
    childId ??= children.isNotEmpty ? children.first['id']?.toString() : null;
    if (childId == null || childId.isEmpty) {
      return {'records': [], 'summary': <String, dynamic>{}, 'child': null};
    }
  }
  return ref
      .read(mobileRepositoryProvider)
      .fetchAttendance(role, childId: childId);
});

final mobileExamsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final role = ref.watch(currentUserRoleProvider);
  String? childId;
  if (role == 'parent') {
    final children = await ref.watch(parentChildrenProvider.future);
    childId = ref.watch(parentSelectedChildIdProvider);
    childId ??= children.isNotEmpty ? children.first['id']?.toString() : null;
    if (childId == null || childId.isEmpty) {
      return {'exams': [], 'child': null};
    }
  }
  return ref.read(mobileRepositoryProvider).fetchExams(role, childId: childId);
});

final mobileExamDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, examId) async {
      return ref.read(mobileRepositoryProvider).fetchStudentExam(examId);
    });

final resultsSelectedSessionIdProvider = StateProvider<String?>((ref) => null);
final resultsSelectedTermIdProvider = StateProvider<String?>((ref) => null);

final mobileSessionsMetaProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final data = await ref.read(mobileRepositoryProvider).fetchSessionsMeta();
  final sessions = (data['sessions'] as List?) ?? const [];
  final parsed = sessions
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();

  final selectedSession = ref.read(resultsSelectedSessionIdProvider);
  if (parsed.isNotEmpty &&
      (selectedSession == null ||
          !parsed.any((s) => s['id']?.toString() == selectedSession))) {
    final current = parsed.firstWhere(
      (s) => s['is_current'] == true,
      orElse: () => parsed.first,
    );
    ref.read(resultsSelectedSessionIdProvider.notifier).state = current['id']
        ?.toString();

    final terms = ((current['terms'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    if (terms.isNotEmpty) {
      final currentTerm = terms.firstWhere(
        (t) => t['is_current'] == true,
        orElse: () => terms.first,
      );
      ref.read(resultsSelectedTermIdProvider.notifier).state = currentTerm['id']
          ?.toString();
    }
  }

  return parsed;
});

final mobileFeesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final role = ref.watch(currentUserRoleProvider);
  final sessionId = ref.watch(resultsSelectedSessionIdProvider);
  final termId = ref.watch(resultsSelectedTermIdProvider);

  String? childId;
  if (role == 'parent') {
    childId = await _resolveParentChildId(ref);
    if (childId == null || childId.isEmpty) {
      return {'items': [], 'summary': <String, dynamic>{}, 'child': null};
    }
  }

  return ref
      .read(mobileRepositoryProvider)
      .fetchFees(role, childId: childId, sessionId: sessionId, termId: termId);
});

final mobileTermResultsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final role = ref.watch(currentUserRoleProvider);
  final sessionId = ref.watch(resultsSelectedSessionIdProvider);
  final termId = ref.watch(resultsSelectedTermIdProvider);

  String? childId;
  if (role == 'parent') {
    childId = await _resolveParentChildId(ref);
    if (childId == null || childId.isEmpty) {
      return {'results': [], 'student': null};
    }
  }

  return ref
      .read(mobileRepositoryProvider)
      .fetchTermResults(
        role,
        childId: childId,
        sessionId: sessionId,
        termId: termId,
      );
});

final mobileSessionResultsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final role = ref.watch(currentUserRoleProvider);
  final sessionId = ref.watch(resultsSelectedSessionIdProvider);

  String? childId;
  if (role == 'parent') {
    childId = await _resolveParentChildId(ref);
    if (childId == null || childId.isEmpty) {
      return {'results': [], 'student': null};
    }
  }

  return ref
      .read(mobileRepositoryProvider)
      .fetchSessionResults(role, childId: childId, sessionId: sessionId);
});

Future<String?> _resolveParentChildId(Ref ref) async {
  final children = await ref.watch(parentChildrenProvider.future);
  String? childId = ref.watch(parentSelectedChildIdProvider);
  childId ??= children.isNotEmpty ? children.first['id']?.toString() : null;
  return childId;
}
