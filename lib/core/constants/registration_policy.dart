import 'package:schoolhq_ng/enum/user_role.dart';

class RegistrationPolicy {
  final bool selfRegistrationEnabled;
  final List<UserRole> allowedRoles;

  const RegistrationPolicy({
    required this.selfRegistrationEnabled,
    required this.allowedRoles,
  });

  bool isRoleAllowed(UserRole role) => allowedRoles.contains(role);

  static const sandbox = RegistrationPolicy(
    selfRegistrationEnabled: true,
    allowedRoles: [UserRole.parent, UserRole.teacher, UserRole.student],
  );
}
