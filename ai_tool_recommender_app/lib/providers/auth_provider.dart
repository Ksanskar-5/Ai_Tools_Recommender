import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Offline-capable auth provider — stores credentials locally.
/// No backend required.
class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _loading = false;

  AuthProvider();

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get loading => _loading;

  Future<void> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt('user_id');
      final email = prefs.getString('email');
      if (id != null && email != null) {
        _user = AppUser(id: id, email: email, token: 'local');
        notifyListeners();
      }
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }

  Future<void> login(String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      // Offline: accept any login and store locally
      await Future.delayed(const Duration(milliseconds: 400));
      _user = AppUser(id: email.hashCode, email: email, token: 'local');
      await _persist();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signup(String name, String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      _user = AppUser(id: email.hashCode, email: email, token: 'local');
      await _persist();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> _persist() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _user!.token);
    await prefs.setInt('user_id', _user!.id);
    await prefs.setString('email', _user!.email);
  }
}
