import 'package:flint_client/flint_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';
import 'package:schoolhq_ng/core/hive/hive_key.dart';
import 'package:schoolhq_ng/core/network/school_urls.dart';
import 'package:schoolhq_ng/models/school_model.dart';
import 'package:schoolhq_ng/repositories/school_directory_repository.dart';

final schoolProvider = StateNotifierProvider<SchoolController, SchoolModel?>((
  ref,
) {
  return SchoolController();
});

final schoolDirectoryClientProvider = Provider<FlintClient>((ref) {
  return FlintClient(
    baseUrl: resolveDashboardApiBaseUrl(),
    timeout: const Duration(seconds: 15),
  );
});

final schoolDirectoryRepositoryProvider = Provider<SchoolDirectoryRepository>((
  ref,
) {
  return SchoolDirectoryRepository(ref.read(schoolDirectoryClientProvider));
});

final schoolDirectoryProvider = FutureProvider<List<SchoolModel>>((ref) async {
  final schools = await ref
      .read(schoolDirectoryRepositoryProvider)
      .fetchSchools();
  schools.sort(
    (left, right) =>
        left.name.toLowerCase().compareTo(right.name.toLowerCase()),
  );
  return schools;
});

final schoolDirectorySearchProvider = FutureProvider.autoDispose
    .family<List<SchoolModel>, String>((ref, query) async {
      final schools = await ref
          .read(schoolDirectoryRepositoryProvider)
          .fetchSchools(query: query);
      schools.sort(
        (left, right) =>
            left.name.toLowerCase().compareTo(right.name.toLowerCase()),
      );
      return schools;
    });

class SchoolController extends StateNotifier<SchoolModel?> {
  SchoolController() : super(null) {
    _loadSchool();
  }

  void _loadSchool() {
    final box = Hive.box(HiveKey.boxApp);
    final selected = box.get(HiveKey.selectedSchool);
    final fallback = selected ?? box.get(HiveKey.userSchool);
    final school = SchoolModel.fromDynamic(fallback);

    if (school != null && school.id.isNotEmpty) {
      if (selected == null) {
        box.put(HiveKey.selectedSchool, school.toJson());
      }
      state = school;
      return;
    }

    state = null;
  }

  void selectSchool(SchoolModel school) {
    final box = Hive.box(HiveKey.boxApp);
    box.put(HiveKey.selectedSchool, school.toJson());
    box.put(HiveKey.userSchool, school.toJson());
    state = school;
  }

  void clearSelection() {
    final box = Hive.box(HiveKey.boxApp);
    box.delete(HiveKey.selectedSchool);
    box.delete(HiveKey.userSchool);
    state = null;
  }

  bool get hasSelected => state != null;
}
