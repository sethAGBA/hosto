import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/permission_service.dart';

class PermissionController {
  final UserRole role;
  final Map<String, Map<String, bool>> permissions;
  final Map<String, Map<String, bool>> _fallback;

  PermissionController({
    required this.role,
    required this.permissions,
  }) : _fallback = PermissionService.defaultPermissionsForRole(role);

  bool canView(String module) {
    return permissions[module]?['view'] ?? _fallback[module]?['view'] ?? true;
  }

  bool canEdit(String module) {
    return permissions[module]?['edit'] ?? _fallback[module]?['edit'] ?? false;
  }

  bool canDelete(String module) {
    return permissions[module]?['delete'] ?? _fallback[module]?['delete'] ?? false;
  }
}

class PermissionScope extends InheritedWidget {
  final PermissionController controller;

  const PermissionScope({
    super.key,
    required this.controller,
    required super.child,
  });

  static PermissionController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PermissionScope>();
    return scope?.controller ??
        PermissionController(
          role: UserRole.admin,
          permissions: PermissionService.defaultPermissionsForRole(UserRole.admin),
        );
  }

  @override
  bool updateShouldNotify(PermissionScope oldWidget) => controller != oldWidget.controller;
}
