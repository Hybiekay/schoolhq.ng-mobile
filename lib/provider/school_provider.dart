import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/school_model.dart';

class SchoolProvider with ChangeNotifier {
  static const _storageKey = 'selected_school';
  List<SchoolModel> schools = [];
  SchoolModel? _school;

  SchoolModel? get school => _school;

  bool get isSelected => _school != null;

  Future<void> loadSelectedSchool() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr != null) {
      _school = SchoolModel.fromRawJson(jsonStr);
      notifyListeners();
    }
  }

  Future<void> selectSchool(SchoolModel school) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, school.toRawJson());
    _school = school;
    notifyListeners();
  }

  Future<void> clearSelectedSchool() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    _school = null;
    notifyListeners();
  }

  Future<void> fetchSchools() async {}
}
