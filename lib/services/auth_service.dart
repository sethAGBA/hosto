import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import 'database_service.dart';

class AuthService {
  static User? _currentUser;

  static User? get currentUser => _currentUser;

  static Future<bool> checkLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id');
      if (userId == null) return false;
      final user = await DatabaseService().getUserById(userId);
      if (user == null || !user.isActive) return false;
      _currentUser = user;
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    final user = await DatabaseService().getUserByEmail(email);
    if (user == null || !user.isActive) return false;
    final hash = sha256.convert(utf8.encode(password)).toString();
    if (hash != user.passwordHash) return false;

    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('current_user_id', user.id);
    } else {
      await prefs.remove('current_user_id');
    }
    await prefs.setBool('remember_me', rememberMe);
    if (rememberMe) {
      await prefs.setString('remember_email', email);
    } else {
      await prefs.remove('remember_email');
    }
    return true;
  }

  static Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
  }
}
