import 'package:flint_client/flint_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';
import 'package:schoolhq_ng/core/hive/hive_key.dart';
import 'package:schoolhq_ng/core/constants/registration_policy.dart';
import 'package:schoolhq_ng/core/network/school_urls.dart';
import 'package:schoolhq_ng/enum/user_role.dart';

import '../repositories/auth_repository.dart';
import 'chat_realtime_provider.dart';
import 'school_provider.dart';

/// Create global FlintClient instance
final flintClientProvider = Provider<FlintClient>((ref) {
  final selectedSchool = ref.watch(schoolProvider);
  final baseUrl = resolveSchoolApiBaseUrl(selectedSchool);
  return FlintClient(baseUrl: baseUrl, timeout: const Duration(seconds: 15));
});

/// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(flintClientProvider));
});

final registrationPolicyProvider = Provider<RegistrationPolicy>((ref) {
  // Sandbox behavior requested: self registration is enabled.
  // Replace with API-driven policy when backend exposes this setting.
  return RegistrationPolicy.sandbox;
});

/// Auth State Provider (true = logged in)
final authProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(ref),
);

class AuthController extends StateNotifier<bool> {
  final Ref ref;

  AuthController(this.ref) : super(false) {
    _loadToken();
  }

  /// Load session from Hive on app start
  void _loadToken() {
    final token = Hive.box(HiveKey.boxApp).get(HiveKey.token);
    if (token is String && token.isNotEmpty) {
      state = true;
    }
  }

  Future<bool> restoreSession() async {
    final box = Hive.box(HiveKey.boxApp);
    final token = box.get(HiveKey.token);

    if (token is! String || token.isEmpty) {
      await logout();
      return false;
    }

    try {
      final data = await ref.read(authRepositoryProvider).fetchCurrentUser();
      final user = _extractUser(data);
      final role = _extractRole(data);

      if (user != null) {
        box.put(HiveKey.userProfile, user);
      }
      if (role != null && role.isNotEmpty) {
        box.put(HiveKey.userRole, role);
      }

      state = true;
      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }

  /// Login Action
  Future<void> login(String login, String password) async {
    final authRepo = ref.read(authRepositoryProvider);

    final data = await authRepo.login(login, password);

    final token = data["access_token"] ?? data["token"];
    if (token == null) throw Exception("Invalid token");

    // Save token
    final box = Hive.box(HiveKey.boxApp);
    box.put(HiveKey.token, token);
    final role = _extractRole(data) ?? UserRole.student.name;
    box.put(HiveKey.userRole, role);
    final user = data['user'];
    if (user != null) {
      box.put(HiveKey.userProfile, user);
    }
    _storeSchool(box, data['school']);

    state = true;
  }

  Future<void> syncBranding() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final data = await authRepo.fetchBranding();
      final box = Hive.box(HiveKey.boxApp);
      _storeSchool(box, data['school']);
    } catch (_) {
      // Keep the last saved school branding or fallback when the API is unavailable.
    }
  }

  /// Logout Action
  ///
  /// Normal logout keeps the selected school in Hive so users can return
  /// to the same school login screen. Pass `clearSchool: true` only when
  /// the user explicitly wants to remove the saved school.
  Future<void> logout({bool clearSchool = false}) async {
    await ref.read(chatRealtimeServiceProvider).disconnect();
    final box = Hive.box(HiveKey.boxApp);
    box.delete(HiveKey.token);
    box.delete(HiveKey.userRole);
    box.delete(HiveKey.userProfile);
    box.delete(HiveKey.selectedParentChildId);
    if (clearSchool) {
      ref.read(schoolProvider.notifier).clearSelection();
    }
    state = false;
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    String? studentId,
  }) async {
    final policy = ref.read(registrationPolicyProvider);
    if (!policy.selfRegistrationEnabled || !policy.isRoleAllowed(role)) {
      throw Exception('Registration is currently disabled for this role');
    }

    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      password: password,
      role: role,
      studentId: studentId,
    );
  }

  String? _extractRole(Map<String, dynamic> data) {
    final role = data['role'];
    if (role is String && role.isNotEmpty) return role.toLowerCase();

    final user = data['user'];
    if (user is Map<String, dynamic>) {
      final userRole = user['role'];
      if (userRole is String && userRole.isNotEmpty) {
        return userRole.toLowerCase();
      }
    }
    return null;
  }

  Map<String, dynamic>? _extractUser(Map<String, dynamic> data) {
    final user = data['user'];
    if (user is Map<String, dynamic>) {
      return Map<String, dynamic>.from(user);
    }
    if (user is Map) {
      return Map<String, dynamic>.from(user);
    }
    return null;
  }

  void _storeSchool(Box box, dynamic school) {
    final selectedSchool = box.get(HiveKey.selectedSchool);
    final selectedMap = selectedSchool is Map<String, dynamic>
        ? Map<String, dynamic>.from(selectedSchool)
        : selectedSchool is Map
        ? Map<String, dynamic>.from(selectedSchool)
        : <String, dynamic>{};

    final incomingMap = school is Map<String, dynamic>
        ? Map<String, dynamic>.from(school)
        : school is Map
        ? Map<String, dynamic>.from(school)
        : <String, dynamic>{};

    if (incomingMap.isEmpty && selectedMap.isEmpty) {
      return;
    }

    final merged = <String, dynamic>{...selectedMap, ...incomingMap};

    // Keep the selected school's app URL as the primary request target unless
    // the backend explicitly returns another usable app_url.
    final selectedAppUrl =
        (selectedMap['app_url'] ?? selectedMap['appUrl'] ?? '').toString();
    final incomingAppUrl =
        (incomingMap['app_url'] ?? incomingMap['appUrl'] ?? '').toString();

    if (selectedAppUrl.isNotEmpty && incomingAppUrl.isEmpty) {
      merged['app_url'] = selectedAppUrl;
    }

    if (selectedMap.isEmpty) {
      box.put(HiveKey.selectedSchool, merged);
    }
    box.put(HiveKey.userSchool, merged);
  }
}
