import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'models/user.dart';
import 'screen/login_screen.dart';
import 'screen/main_screen.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await DatabaseService().init();

  final users = await DatabaseService().getUsers();
  if (users.isEmpty) {
    final defaultAdmin = User(
      id: 'admin',
      name: 'Admin',
      email: 'admin@reshopital.local',
      passwordHash: sha256.convert(utf8.encode('admin123')).toString(),
      role: UserRole.admin,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
      isActive: true,
    );
    await DatabaseService().insertUser(defaultAdmin);
  }

  Widget initialScreen;
  if (await AuthService.checkLoggedIn()) {
    initialScreen = const MainScreen();
  } else {
    initialScreen = const LoginScreen();
  }

  Future.microtask(() async {
    try {
      final sync = SyncService();
      await sync.runOnce();
      sync.startPeriodic(interval: const Duration(minutes: 5));
    } catch (_) {}
  });

  runApp(ResHopitalApp(initialScreen: initialScreen));
}
