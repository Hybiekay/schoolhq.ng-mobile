import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';
import 'package:schoolhq_ng/models/school_model.dart';

final schoolProvider = StateNotifierProvider<SchoolController, SchoolModel?>((
  ref,
) {
  return SchoolController();
});

class SchoolController extends StateNotifier<SchoolModel?> {
  SchoolController() : super(null) {
    _loadSchool();
  }

  void _loadSchool() {
    final selected = Hive.box('app').get('selectedSchool');
    state = selected;
  }

  void selectSchool(SchoolModel school) {
    Hive.box('app').put('selectedSchool', school);
    state = school;
  }

  bool get hasSelected => state != null;
}
