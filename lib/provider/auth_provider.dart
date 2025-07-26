import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  // UserModel? _user;

  // var get user => _user;

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API
    //  _user = UserModel(id: '123', name: 'Demo User', email: email);
    notifyListeners();
  }

  void logout() {
    // _user = null;
    notifyListeners();
  }
}
