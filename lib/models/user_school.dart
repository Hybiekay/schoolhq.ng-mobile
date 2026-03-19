import 'dart:convert';

import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/models/school_model.dart';

class UserSchool {
  final String id;
  final String name;
  final String logo;
  final String email;
  final String phone;
  final String address;

  const UserSchool({
    required this.id,
    required this.name,
    required this.logo,
    this.email = '',
    this.phone = '',
    this.address = '',
  });

  factory UserSchool.fallback() {
    return const UserSchool(id: '', name: 'SchoolHQ', logo: AppImages.logo);
  }

  factory UserSchool.fromMap(Map<String, dynamic> map) {
    return UserSchool(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? 'SchoolHQ').toString(),
      logo: (map['logo'] ?? map['logo_url'] ?? AppImages.logo).toString(),
      email: (map['email'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      address: (map['address'] ?? '').toString(),
    );
  }

  factory UserSchool.fromSchoolModel(SchoolModel school) {
    return UserSchool(
      id: school.id,
      name: school.name,
      logo: school.logo.isEmpty ? AppImages.logo : school.logo,
    );
  }

  static UserSchool fromDynamic(dynamic source) {
    if (source == null) return UserSchool.fallback();

    if (source is UserSchool) return source;

    if (source is SchoolModel) return UserSchool.fromSchoolModel(source);

    if (source is Map<String, dynamic>) return UserSchool.fromMap(source);

    if (source is Map) {
      return UserSchool.fromMap(Map<String, dynamic>.from(source));
    }

    if (source is String && source.isNotEmpty) {
      try {
        final decoded = jsonDecode(source);
        if (decoded is Map<String, dynamic>) return UserSchool.fromMap(decoded);
        if (decoded is Map) {
          return UserSchool.fromMap(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {
        // Not JSON, keep fallback.
      }
    }

    return UserSchool.fallback();
  }
}
