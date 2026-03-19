import 'package:flint_client/flint_client.dart';
import 'package:schoolhq_ng/enum/user_role.dart';

class AuthRepository {
  final FlintClient client;

  AuthRepository(this.client);

  Future<Map<String, dynamic>> login(String login, String password) async {
    final response = await client.post<Map<String, dynamic>>(
      '/mobile/auth/login',
      body: {"login": login, "password": password, "device_name": "mobile_app"},
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error?.message ?? "Login failed");
    }

    return Map<String, dynamic>.from(response.data!); // token + user data
  }

  Future<Map<String, dynamic>> fetchBranding() async {
    final response = await client.get<Map<String, dynamic>>(
      '/mobile/meta/branding',
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error?.message ?? "Branding fetch failed");
    }

    return Map<String, dynamic>.from(response.data!);
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    String? studentId,
  }) async {
    final endpoint = switch (role) {
      UserRole.student => '/students',
      UserRole.teacher => '/teachers',
      UserRole.parent => '/parents',
      UserRole.staff => '/teachers',
    };

    final payload = <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role.name,
      if (role == UserRole.student && studentId != null && studentId.isNotEmpty)
        'admission_number': studentId,
    };

    final response = await client.post(endpoint, body: payload);
    if (!response.success || response.data == null) {
      throw Exception(response.error?.message ?? 'Registration failed');
    }

    return response.data!;
  }
}
