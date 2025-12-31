import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../models/user.dart';
import '../services/notification_service.dart';
import '../widgets/menu_item_widget.dart';
import 'coming_soon_screen.dart';
import 'dashboard_screen.dart';
import 'patients_screen.dart';
import 'urgences_screen.dart';
import 'chambres_screen.dart';
import 'consultations_screen.dart';
import 'personnel_screen.dart';
import 'examens_screen.dart';
import 'pharmacie_screen.dart';
import 'facturation_screen.dart';
import 'reporting_screen.dart';
import 'comptabilite_screen.dart';
import 'parametres_screen.dart';
import 'assurances_screen.dart';
import 'interventions_screen.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../services/permission_service.dart';
import '../widgets/permission_scope.dart';
import 'access_denied_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  final PermissionService _permissionService = PermissionService();
  final ValueNotifier<int> _admissionTrigger = ValueNotifier(0);
  int selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  PermissionController _permissionController = PermissionController(
    role: UserRole.admin,
    permissions: PermissionService.defaultPermissionsForRole(UserRole.admin),
  );
  bool _loadingPermissions = true;
  List<MenuItem> _visibleMenuItems = [];

  final List<MenuItem> _menuItems = const [
    MenuItem(
      icon: Icons.dashboard_rounded,
      title: 'Tableau de bord',
      gradient: LinearGradient(colors: [Color(0xFF0EA5A4), Color(0xFF14B8A6)]),
    ),
    MenuItem(
      icon: Icons.people_alt_rounded,
      title: 'Patients',
      gradient: LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
    ),
    MenuItem(
      icon: Icons.local_hospital_rounded,
      title: 'Personnel medical',
      gradient: LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF16A34A)]),
    ),
    MenuItem(
      icon: Icons.bed_rounded,
      title: 'Chambres & lits',
      gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
    ),
    MenuItem(
      icon: Icons.event_available_rounded,
      title: 'Consultations',
      gradient: LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
    ),
    MenuItem(
      icon: Icons.science_rounded,
      title: 'Examens & labo',
      gradient: LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)]),
    ),
    MenuItem(
      icon: Icons.medication_rounded,
      title: 'Pharmacie & stocks',
      gradient: LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
    ),
    MenuItem(
      icon: Icons.warning_amber_rounded,
      title: 'Urgences',
      gradient: LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
    ),
    MenuItem(
      icon: Icons.local_hospital_outlined,
      title: 'Interventions',
      gradient: LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
    ),
    MenuItem(
      icon: Icons.receipt_long_rounded,
      title: 'Facturation',
      gradient: LinearGradient(colors: [Color(0xFFF97316), Color(0xFFEA580C)]),
    ),
    MenuItem(
      icon: Icons.health_and_safety_rounded,
      title: 'Assurances',
      gradient: LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
    ),
    MenuItem(
      icon: Icons.account_balance_rounded,
      title: 'Comptabilite',
      gradient: LinearGradient(colors: [Color(0xFF64748B), Color(0xFF475569)]),
    ),
    MenuItem(
      icon: Icons.query_stats_rounded,
      title: 'Reporting',
      gradient: LinearGradient(colors: [Color(0xFF14B8A6), Color(0xFF0F766E)]),
    ),
    MenuItem(
      icon: Icons.settings_rounded,
      title: 'Parametres',
      gradient: LinearGradient(colors: [Color(0xFF6B7280), Color(0xFF4B5563)]),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
    _notificationService.addListener(_onNotificationsChanged);
    _visibleMenuItems = _menuItems;
    _loadPermissions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notificationService.removeListener(_onNotificationsChanged);
    _admissionTrigger.dispose();
    super.dispose();
  }

  void _onNotificationsChanged() {
    setState(() {});
  }

  Future<void> _loadPermissions() async {
    final role = AuthService.currentUser?.role ?? UserRole.admin;
    final permissions = await _permissionService.loadForRole(role);
    final controller = PermissionController(role: role, permissions: permissions);
    final visible = _menuItems.where((item) => controller.canView(_moduleKeyForTitle(item.title))).toList();
    if (!mounted) return;
    setState(() {
      _permissionController = controller;
      _visibleMenuItems = visible;
      _loadingPermissions = false;
      if (selectedIndex >= _visibleMenuItems.length) {
        selectedIndex = 0;
      }
    });
  }

  void _openAdmissionForm() {
    final index = _visibleMenuItems.indexWhere((item) => item.title == 'Patients');
    if (index == -1) {
      _requestAccess();
      return;
    }
    setState(() {
      selectedIndex = index;
    });
    _animationController.reset();
    _animationController.forward();
    _admissionTrigger.value += 1;
    _notificationService.showNotification(
      NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: 'Nouvelle admission',
        details: 'Ouverture du formulaire de pre-admission.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canEditPatients = _permissionController.canEdit('Patients');
    return PermissionScope(
      controller: _permissionController,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: canEditPatients ? _openAdmissionForm : null,
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Nouvelle admission'),
          backgroundColor: const Color(0xFF0EA5A4),
          foregroundColor: Colors.white,
        ),
        body: Row(
          children: [
            _buildSidebar(),
            Expanded(child: _buildMainArea()),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B2F2E), Color(0xFF133B3A)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF0EA5A4)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0EA5A4).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/icon/icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Res Hopital',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Gestion clinique & administrative',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                itemCount: _visibleMenuItems.length,
                itemBuilder: (context, index) {
                  final item = _visibleMenuItems[index];
                  return AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, (1 - _fadeAnimation.value) * 40 * (index + 1)),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: MenuItemWidget(
                              item: item,
                              isSelected: selectedIndex == index,
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                });
                                _animationController.reset();
                                _animationController.forward();
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          _buildUserProfile(),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildMainArea() {
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: _buildContent(),
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2E2E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 700;
          return Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _visibleMenuItems.isEmpty ? 'Acces limite' : _visibleMenuItems[selectedIndex].title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isCompact) ...[
                _buildSearchBar(),
                const SizedBox(width: 16),
                _buildQuickActions(),
              ] else ...[
                _buildSearchButton(),
                const SizedBox(width: 12),
                _buildNotificationButton(_notificationService.notifications.isNotEmpty),
              ],
              const SizedBox(width: 12),
              _buildLogoutIcon(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 320,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Rechercher patient, personnel, chambre...',
          hintStyle: TextStyle(color: Colors.white54, fontSize: 13),
          prefixIcon: Icon(Icons.search, color: Colors.white54, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final hasNotifications = _notificationService.notifications.isNotEmpty;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Row(
            children: [
              const Icon(Icons.favorite_rounded, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Text(
                'Occupation 78%',
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildNotificationButton(hasNotifications),
      ],
    );
  }

  Widget _buildNotificationButton(bool hasNotifications) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
          ),
          if (hasNotifications)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: const Center(
        child: Icon(Icons.search, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildBottomBar() {
    final urgentCount = _notificationService.notifications.length;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.circle, color: Color(0xFF22C55E), size: 10),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Services stables · Lits libres: 23 · Temps attente moyen: 28 min',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: urgentCount > 0 ? const Color(0xFFEF4444) : Colors.white24,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                urgentCount > 0 ? '$urgentCount alertes urgentes' : 'Aucune alerte urgente',
                style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutIcon() {
    return GestureDetector(
      onTap: _confirmLogout,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Deconnexion',
              style: TextStyle(color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: _confirmLogout,
            child: const Text('Confirmer', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text('Confirmer la deconnexion', style: TextStyle(color: Colors.white)),
          content: const Text('Voulez-vous vraiment vous deconnecter ?', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              onPressed: () async {
                Navigator.of(context).pop();
                await AuthService.logout();
                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Se deconnecter', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserProfile() {
    final user = AuthService.currentUser;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFF0EA5A4),
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Utilisateur',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  user?.email ?? '--',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loadingPermissions) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xFF0EA5A4)),
        ),
      );
    }
    if (_visibleMenuItems.isEmpty) {
      return AccessDeniedScreen(
        title: 'ce module',
        onBack: () => setState(() => selectedIndex = 0),
        onRequestAccess: _requestAccess,
      );
    }
    final selectedItem = _visibleMenuItems[selectedIndex];
    final module = _moduleKeyForTitle(selectedItem.title);
    if (!_permissionController.canView(module)) {
      return AccessDeniedScreen(
        title: selectedItem.title,
        onBack: () => setState(() => selectedIndex = 0),
        onRequestAccess: _requestAccess,
      );
    }
    if (selectedItem.title == 'Tableau de bord') {
      return DashboardScreen(fadeAnimation: _fadeAnimation);
    }
    if (selectedItem.title == 'Patients') {
      return PatientsScreen(fadeAnimation: _fadeAnimation, admissionTrigger: _admissionTrigger);
    }
    if (selectedItem.title == 'Urgences') {
      return UrgencesScreen(fadeAnimation: _fadeAnimation);
    }
    if (selectedItem.title == 'Chambres & lits') {
      return ChambresScreen(fadeAnimation: _fadeAnimation);
    }
    if (selectedItem.title == 'Consultations') {
      return ConsultationsScreen(fadeAnimation: _fadeAnimation);
    }
    if (selectedItem.title == 'Personnel medical') {
      return PersonnelScreen(fadeAnimation: _fadeAnimation);
    }
    if (selectedItem.title == 'Examens & labo') {
      return ExamensScreen(fadeAnimation: _fadeAnimation);
    }
    if (selectedItem.title == 'Pharmacie & stocks') {
      return PharmacieScreen(fadeAnimation: _fadeAnimation);
    }
    if (selectedItem.title == 'Facturation') {
      return FacturationScreen(fadeAnimation: _fadeAnimation);
    }
    if (selectedItem.title == 'Reporting') {
      return ReportingScreen(fadeAnimation: _fadeAnimation);
    }
    if (selectedItem.title == 'Comptabilite') {
      return ComptabiliteScreen(fadeAnimation: _fadeAnimation);
    }
    if (selectedItem.title == 'Parametres') {
      return ParametresScreen(fadeAnimation: _fadeAnimation);
    }
    if (selectedItem.title == 'Assurances') {
      return AssurancesScreen(fadeAnimation: _fadeAnimation);
    }
    if (selectedItem.title == 'Interventions') {
      return InterventionsScreen(fadeAnimation: _fadeAnimation);
    }
    return ComingSoonScreen(screenName: selectedItem.title, gradient: selectedItem.gradient);
  }

  void _requestAccess() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text('Demande envoyee', style: TextStyle(color: Colors.white)),
          content: Text(
            'Votre demande a ete transmise a un administrateur.',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String _moduleKeyForTitle(String title) {
    switch (title) {
      case 'Tableau de bord':
        return 'Tableau de bord';
      case 'Patients':
        return 'Patients';
      case 'Personnel medical':
        return 'Personnel';
      case 'Chambres & lits':
        return 'Chambres';
      case 'Consultations':
        return 'Consultations';
      case 'Examens & labo':
        return 'Examens';
      case 'Pharmacie & stocks':
        return 'Pharmacie';
      case 'Urgences':
        return 'Urgences';
      case 'Interventions':
        return 'Interventions';
      case 'Facturation':
        return 'Facturation';
      case 'Assurances':
        return 'Assurances';
      case 'Comptabilite':
        return 'Comptabilite';
      case 'Reporting':
        return 'Reporting';
      case 'Parametres':
        return 'Parametres';
      default:
        return title;
    }
  }
}
