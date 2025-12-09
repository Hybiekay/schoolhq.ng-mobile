import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';
import 'package:flint_client/flint_client.dart';

import '../repositories/auth_repository.dart';

/// Create global FlintClient instance
final flintClientProvider = Provider<FlintClient>((ref) {
  return FlintClient(
    baseUrl: "https://api.schoolhq.ng/api",
    timeout: const Duration(seconds: 15),
  );
});

/// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(flintClientProvider));
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
    final token = Hive.box('app').get('token');
    if (token != null) {
      // Attach token to client for authenticated requests
      final client = ref.read(flintClientProvider);
      // client.requestInterceptor("Authorization", "Bearer $token");

      state = true;
    }
  }

  /// Login Action
  Future<void> login(String email, String password) async {
    final authRepo = ref.read(authRepositoryProvider);

    final data = await authRepo.login(email, password);

    final token = data["token"];
    if (token == null) throw Exception("Invalid token");

    // Save token
    Hive.box('app').put('token', token);

    // Attach token to client
    // ref.read(flintClientProvider).setHeader("Authorization", "Bearer $token");

    state = true;
  }

  /// Logout Action
  void logout() {
    Hive.box('app').delete('token');
    state = false;
  }
}
