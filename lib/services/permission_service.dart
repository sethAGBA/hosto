import 'dart:convert';

import '../models/user.dart';
import 'database_service.dart';

class PermissionService {
  final DatabaseService _databaseService = DatabaseService();

  Future<Map<String, Map<String, bool>>> loadForRole(UserRole role) async {
    final defaults = defaultPermissionsForRole(role);
    final key = 'permissions.${role.name}';
    final stored = await _databaseService.getSettings([key]);
    final raw = stored[key];
    if (raw == null || raw.isEmpty) {
      return defaults;
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final merged = <String, Map<String, bool>>{};
    for (final entry in defaults.entries) {
      final storedPerms = decoded[entry.key] as Map<String, dynamic>?;
      final storedView = storedPerms?['view'];
      final storedEdit = storedPerms?['edit'];
      final storedDelete = storedPerms?['delete'];
      final fallbackView = entry.value['view'] ?? false;
      final fallbackEdit = entry.value['edit'] ?? false;
      final fallbackDelete = entry.value['delete'] ?? false;
      merged[entry.key] = {
        'view': storedView is bool ? storedView : fallbackView,
        'edit': storedEdit is bool ? storedEdit : fallbackEdit,
        'delete': storedDelete is bool ? storedDelete : fallbackDelete,
      };
    }
    for (final entry in decoded.entries) {
      if (merged.containsKey(entry.key)) continue;
      final perms = entry.value as Map<String, dynamic>;
      merged[entry.key] = {
        'view': perms['view'] == true,
        'edit': perms['edit'] == true,
        'delete': perms['delete'] == true,
      };
    }
    return merged;
  }

  static Map<String, Map<String, bool>> defaultPermissionsForRole(UserRole role) {
    final baseModules = [
      'Tableau de bord',
      'Patients',
      'Personnel',
      'Chambres',
      'Consultations',
      'Examens',
      'Pharmacie',
      'Urgences',
      'Facturation',
      'Reporting',
      'Comptabilite',
      'Parametres',
      'Assurances',
      'Interventions',
    ];
    final defaults = <String, Map<String, bool>>{};
    for (final module in baseModules) {
      defaults[module] = {
        'view': true,
        'edit': role == UserRole.admin,
        'delete': role == UserRole.admin,
      };
    }
    if (role == UserRole.comptable) {
      defaults['Facturation'] = {'view': true, 'edit': true, 'delete': false};
      defaults['Comptabilite'] = {'view': true, 'edit': true, 'delete': false};
    }
    if (role == UserRole.medecin || role == UserRole.infirmier) {
      defaults['Patients'] = {'view': true, 'edit': true, 'delete': false};
      defaults['Consultations'] = {'view': true, 'edit': true, 'delete': false};
      defaults['Examens'] = {'view': true, 'edit': true, 'delete': false};
    }
    if (role == UserRole.pharmacien) {
      defaults['Pharmacie'] = {'view': true, 'edit': true, 'delete': false};
    }
    if (role == UserRole.secretaire) {
      defaults['Patients'] = {'view': true, 'edit': true, 'delete': false};
      defaults['Consultations'] = {'view': true, 'edit': true, 'delete': false};
      defaults['Facturation'] = {'view': true, 'edit': false, 'delete': false};
    }
    return defaults;
  }
}
