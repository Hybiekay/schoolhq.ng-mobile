import 'package:schoolhq_ng/enum/user_role.dart';

class RegistrationState {
  final UserRole? role;

  const RegistrationState({this.role});

  RegistrationState copyWith({UserRole? role}) {
    return RegistrationState(role: role ?? this.role);
  }
}
