import 'package:flutter_riverpod/legacy.dart';
import 'package:schoolhq_ng/enum/user_role.dart';
import 'package:schoolhq_ng/views/auth/register/states/registration_state.dart';

class RegistrationNotifier extends StateNotifier<RegistrationState> {
  RegistrationNotifier() : super(const RegistrationState());

  void setRole(UserRole role) {
    state = state.copyWith(role: role);
  }

  void clear() {
    state = const RegistrationState();
  }
}

final registrationProvider =
    StateNotifierProvider<RegistrationNotifier, RegistrationState>(
      (ref) => RegistrationNotifier(),
    );
