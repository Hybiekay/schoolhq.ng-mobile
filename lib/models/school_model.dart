import 'dart:convert';

class SchoolModel {
  final String id;
  final String name;
  final String location;

  SchoolModel({required this.id, required this.name, required this.location});

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'],
      name: json['name'],
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
  };

  String toRawJson() => jsonEncode(toJson());

  factory SchoolModel.fromRawJson(String str) =>
      SchoolModel.fromJson(jsonDecode(str));
}
