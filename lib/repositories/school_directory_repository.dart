import 'package:flint_client/flint_client.dart';
import 'package:schoolhq_ng/models/school_model.dart';

class SchoolDirectoryRepository {
  final FlintClient client;

  SchoolDirectoryRepository(this.client);

  Future<List<SchoolModel>> fetchSchools({String? query}) async {
    final trimmed = query?.trim() ?? '';
    final endpoint = trimmed.isEmpty
        ? '/schools/discovery?limit=100'
        : '/schools/discovery?limit=100&q=${Uri.encodeQueryComponent(trimmed)}';

    final response = await client.get<Map<String, dynamic>>(endpoint);

    if (!response.success || response.data == null) {
      throw Exception(response.error?.message ?? 'Failed to load schools');
    }

    final rawSchools = response.data!['schools'];
    if (rawSchools is! List) {
      return const [];
    }

    return rawSchools
        .whereType<Map>()
        .map((item) => SchoolModel.fromJson(Map<String, dynamic>.from(item)))
        .where((school) => school.id.isNotEmpty && school.name.isNotEmpty)
        .toList();
  }

  Future<SchoolModel?> fetchActiveSchoolById(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      return null;
    }

    final response = await client.get<Map<String, dynamic>>(
      '/schools/discovery/${Uri.encodeComponent(trimmedId)}',
    );

    if (!response.success || response.data == null) {
      final message = (response.error?.message ?? 'Failed to load school')
          .toLowerCase();

      if (message.contains('no longer active') ||
          message.contains('school not found')) {
        return null;
      }

      throw Exception(response.error?.message ?? 'Failed to load school');
    }

    final rawSchool = response.data!['school'];
    if (rawSchool is! Map) {
      return null;
    }

    final school = SchoolModel.fromJson(Map<String, dynamic>.from(rawSchool));
    if (school.id.isEmpty || school.name.isEmpty) {
      return null;
    }

    return school;
  }
}
