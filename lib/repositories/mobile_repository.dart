import 'package:flint_client/flint_client.dart';
import 'package:hive/hive.dart';
import 'package:schoolhq_ng/core/hive/hive_key.dart';

class MobileRepository {
  final FlintClient client;

  MobileRepository(this.client);

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    final response = await client.get<Map<String, dynamic>>(
      path,
      queryParameters: query,
      headers: _authHeaders(),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error?.message ?? 'Request failed');
    }

    return Map<String, dynamic>.from(response.data!);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final response = await client.post<Map<String, dynamic>>(
      path,
      body: body,
      queryParameters: query,
      headers: _authHeaders(),
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error?.message ?? 'Request failed');
    }

    return Map<String, dynamic>.from(response.data!);
  }

  Future<Map<String, dynamic>> fetchProfile(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return getJson('/mobile/student/profile');
      case 'parent':
        return getJson('/mobile/parent/profile');
      default:
        throw Exception('Role $role is not supported in mobile MVP.');
    }
  }

  Future<Map<String, dynamic>> fetchDashboard(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return getJson('/mobile/student/dashboard');
      case 'parent':
        return getJson('/mobile/parent/dashboard');
      default:
        throw Exception('Role $role is not supported in mobile MVP.');
    }
  }

  Future<Map<String, dynamic>> fetchTimetable(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return getJson('/mobile/student/timetable');
      default:
        return Future.value({
          'today_timetable': <Map<String, dynamic>>[],
          'weekly_timetable': <Map<String, dynamic>>[],
          'exam_timetable': <Map<String, dynamic>>[],
          'calendar_highlights': <Map<String, dynamic>>[],
        });
    }
  }

  Future<Map<String, dynamic>> fetchCalendar(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return getJson('/mobile/student/calendar');
      default:
        return Future.value({
          'upcoming': <Map<String, dynamic>>[],
          'events': <Map<String, dynamic>>[],
          'holidays': <Map<String, dynamic>>[],
        });
    }
  }

  Future<Map<String, dynamic>> fetchAttendance(String role, {String? childId}) {
    switch (role.toLowerCase()) {
      case 'student':
        return getJson('/mobile/student/attendance');
      case 'parent':
        if (childId == null || childId.isEmpty) {
          throw Exception('Parent attendance requires a child selection.');
        }
        return getJson('/mobile/parent/children/$childId/attendance');
      default:
        throw Exception('Role $role is not supported in mobile MVP.');
    }
  }

  Future<Map<String, dynamic>> fetchExams(String role, {String? childId}) {
    switch (role.toLowerCase()) {
      case 'student':
        return getJson('/mobile/student/exams');
      case 'parent':
        if (childId == null || childId.isEmpty) {
          throw Exception('Parent exams require a child selection.');
        }
        return getJson('/mobile/parent/children/$childId/exams');
      default:
        throw Exception('Role $role is not supported in mobile MVP.');
    }
  }

  Future<Map<String, dynamic>> fetchStudentExam(String examId) {
    return getJson('/mobile/student/exams/$examId');
  }

  Future<Map<String, dynamic>> startStudentExam(String examId) {
    return postJson('/mobile/student/exams/$examId/start');
  }

  Future<Map<String, dynamic>> fetchStudentExamAttempt(String attemptId) {
    return getJson('/mobile/student/exam-attempts/$attemptId');
  }

  Future<Map<String, dynamic>> saveStudentExamAnswer({
    required String attemptId,
    required String questionId,
    required String answer,
  }) {
    return postJson(
      '/mobile/student/exam-attempts/$attemptId/answer',
      body: {'question_id': questionId, 'answer': answer},
    );
  }

  Future<Map<String, dynamic>> submitStudentExamAttempt({
    required String attemptId,
    required List<Map<String, String>> answers,
  }) {
    return postJson(
      '/mobile/student/exam-attempts/$attemptId/submit',
      body: {'answers': answers},
    );
  }

  Future<Map<String, dynamic>> fetchChildren() {
    return getJson('/mobile/parent/children');
  }

  Future<Map<String, dynamic>> fetchSessionsMeta() {
    return getJson('/mobile/meta/sessions');
  }

  Future<Map<String, dynamic>> fetchFees(
    String role, {
    String? childId,
    String? sessionId,
    String? termId,
  }) {
    final query = <String, String>{
      if (sessionId != null && sessionId.isNotEmpty) 'session_id': sessionId,
      if (termId != null && termId.isNotEmpty) 'term_id': termId,
    };

    switch (role.toLowerCase()) {
      case 'student':
        return getJson(
          '/mobile/student/fees',
          query: query.isEmpty ? null : query,
        );
      case 'parent':
        if (childId == null || childId.isEmpty) {
          throw Exception('Parent fees require a child selection.');
        }
        return getJson(
          '/mobile/parent/children/$childId/fees',
          query: query.isEmpty ? null : query,
        );
      default:
        throw Exception('Role $role is not supported in mobile MVP.');
    }
  }

  Future<Map<String, dynamic>> fetchTermResults(
    String role, {
    String? childId,
    String? sessionId,
    String? termId,
  }) {
    final query = <String, String>{
      if (sessionId != null && sessionId.isNotEmpty) 'session_id': sessionId,
      if (termId != null && termId.isNotEmpty) 'term_id': termId,
    };

    switch (role.toLowerCase()) {
      case 'student':
        return getJson(
          '/mobile/student/results/term',
          query: query.isEmpty ? null : query,
        );
      case 'parent':
        if (childId == null || childId.isEmpty) {
          throw Exception('Parent term results require a child selection.');
        }
        return getJson(
          '/mobile/parent/children/$childId/results/term',
          query: query.isEmpty ? null : query,
        );
      default:
        throw Exception('Role $role is not supported in mobile MVP.');
    }
  }

  Future<Map<String, dynamic>> fetchSessionResults(
    String role, {
    String? childId,
    String? sessionId,
  }) {
    final query = <String, String>{
      if (sessionId != null && sessionId.isNotEmpty) 'session_id': sessionId,
    };

    switch (role.toLowerCase()) {
      case 'student':
        return getJson(
          '/mobile/student/results/session',
          query: query.isEmpty ? null : query,
        );
      case 'parent':
        if (childId == null || childId.isEmpty) {
          throw Exception('Parent session results require a child selection.');
        }
        return getJson(
          '/mobile/parent/children/$childId/results/session',
          query: query.isEmpty ? null : query,
        );
      default:
        throw Exception('Role $role is not supported in mobile MVP.');
    }
  }

  Future<Map<String, dynamic>> logout() {
    return postJson('/mobile/auth/logout');
  }

  Map<String, String> _authHeaders() {
    final token = Hive.box(HiveKey.boxApp).get(HiveKey.token);
    if (token is! String || token.isEmpty) {
      throw Exception('No authentication token found.');
    }

    return {'Authorization': 'Bearer $token', 'Accept': 'application/json'};
  }
}
