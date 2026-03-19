import 'dart:convert';

class SchoolModel {
  final String id;
  final String name;
  final String location;
  final String logo;
  final String appUrl;

  SchoolModel({
    required this.id,
    required this.name,
    required this.location,
    this.logo = '',
    this.appUrl = '',
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      logo: (json['logo'] ?? json['logo_url'] ?? '').toString(),
      appUrl: (json['app_url'] ?? json['appUrl'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'logo': logo,
    'app_url': appUrl,
  };

  String toRawJson() => jsonEncode(toJson());

  factory SchoolModel.fromRawJson(String str) =>
      SchoolModel.fromJson(jsonDecode(str));

  static SchoolModel? fromDynamic(dynamic source) {
    if (source == null) return null;
    if (source is SchoolModel) return source;
    if (source is Map<String, dynamic>) return SchoolModel.fromJson(source);
    if (source is Map) {
      return SchoolModel.fromJson(Map<String, dynamic>.from(source));
    }
    if (source is String && source.isNotEmpty) {
      try {
        return SchoolModel.fromRawJson(source);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
