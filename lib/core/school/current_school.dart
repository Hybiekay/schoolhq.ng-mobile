import 'package:hive/hive.dart';
import 'package:schoolhq_ng/core/hive/hive_key.dart';
import 'package:schoolhq_ng/models/user_school.dart';

UserSchool currentSchool() {
  final appBox = Hive.box(HiveKey.boxApp);
  final primary = appBox.get(HiveKey.userSchool);
  if (primary != null) {
    return UserSchool.fromDynamic(primary);
  }

  final selected = appBox.get(HiveKey.selectedSchool);
  if (selected != null) {
    return UserSchool.fromDynamic(selected);
  }

  return UserSchool.fallback();
}
