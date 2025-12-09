import 'package:flint_client/flint_client.dart';

class AuthRepository {
  final FlintClient client;

  AuthRepository(this.client);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await client.post(
      '/auth/login',
      body: {"email": email, "password": password},
    );

    if (!response.success || response.data == null) {
      throw Exception(response.error?.message ?? "Login failed");
    }

    return response.data; // token + user data
  }
}
