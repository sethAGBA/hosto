import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/permission_service.dart';
import '../widgets/permission_scope.dart';

class ParametresScreen extends StatefulWidget {
  final Animation<double> fadeAnimation;

  const ParametresScreen({super.key, required this.fadeAnimation});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();

  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _orgAddressController = TextEditingController();
  final TextEditingController _orgEmailController = TextEditingController();
  final TextEditingController _orgPhoneController = TextEditingController();
  final TextEditingController _securityPasswordMinController = TextEditingController();
  final TextEditingController _securitySessionController = TextEditingController();
  final TextEditingController _securityIpController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();
  final TextEditingController _userSearchController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _loadingUsers = true;
  List<User> _users = [];
  User? _editingUser;
  bool _userActive = true;
  UserRole _userRole = UserRole.staff;
  final Map<String, String?> _userErrors = {};
  String _roleFilter = 'Tous';
  String _statusFilter = 'Tous';
  int _userPage = 1;
  final int _userPageSize = 6;
  UserRole _permissionsRole = UserRole.admin;
  Map<String, Map<String, bool>> _permissions = {};
  bool _loadingAudit = true;
  List<Map<String, Object?>> _auditLogs = [];
  final Map<String, String> _defaults = const {
    'org.name': 'Res Hopital',
    'org.address': 'Lome, Tokoin',
    'org.email': 'contact@reshopital.local',
    'org.phone': '+228 90 00 00 00',
    'security.password_min': '10 caracteres',
    'security.session_expiry': '8h',
    'security.ip_policy': 'LAN uniquement',
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    _tabController = TabController(length: 6, vsync: this);
    _loadSettings();
    _loadUsers();
    _loadAuditLogs();
  }

  @override
  void dispose() {
    _orgNameController.dispose();
    _orgAddressController.dispose();
    _orgEmailController.dispose();
    _orgPhoneController.dispose();
    _securityPasswordMinController.dispose();
    _securitySessionController.dispose();
    _securityIpController.dispose();
    _userNameController.dispose();
    _userEmailController.dispose();
    _userPasswordController.dispose();
    _userSearchController.dispose();
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.fadeAnimation,
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Expanded(
            child: FadeTransition(
              opacity: _fade,
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        Padding(padding: const EdgeInsets.all(16), child: _buildEntrepriseTab()),
                        Padding(padding: const EdgeInsets.all(16), child: _buildUtilisateursTab()),
                        Padding(padding: const EdgeInsets.all(16), child: _buildTemplatesTab()),
                        Padding(padding: const EdgeInsets.all(16), child: _buildSecuriteTab()),
                        Padding(padding: const EdgeInsets.all(16), child: _buildCloudTab()),
                        Padding(padding: const EdgeInsets.all(16), child: _buildParametresEtendusTab()),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Parametres & Administration',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Configuration systeme et gestion des utilisateurs',
            style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              indicator: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                borderRadius: BorderRadius.circular(12),
              ),
              tabs: const [
                Tab(icon: Icon(Icons.business), text: 'Entreprise'),
                Tab(icon: Icon(Icons.people), text: 'Utilisateurs'),
                Tab(icon: Icon(Icons.description), text: 'Templates'),
                Tab(icon: Icon(Icons.security), text: 'Securite'),
                Tab(icon: Icon(Icons.cloud), text: 'Cloud'),
                Tab(icon: Icon(Icons.settings_applications), text: 'Parametres etendus'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntrepriseTab() {
    final canEditSettings = PermissionScope.of(context).canEdit('Parametres');
    return _buildTabShell(
      main: ListView(
        children: [
          _buildTabActions(
            onSave: _saveEntrepriseSettings,
            onReset: _resetEntrepriseSettings,
            enabled: canEditSettings,
          ),
          const SizedBox(height: 16),
          const _SectionTitle('Profil etablissement'),
          _SettingField(label: 'Nom etablissement', controller: _orgNameController, enabled: canEditSettings),
          _SettingField(label: 'Adresse', controller: _orgAddressController, enabled: canEditSettings),
          _SettingField(label: 'Email principal', controller: _orgEmailController, enabled: canEditSettings),
          _SettingField(label: 'Telephone', controller: _orgPhoneController, enabled: canEditSettings),
          SizedBox(height: 16),
          _SectionTitle('Documents & branding'),
          _SettingRow(label: 'Logo', value: 'assets/icon/icon.png'),
          _SettingRow(label: 'Cachet numerique', value: 'Actif'),
          _SettingRow(label: 'Templates PDF', value: '3 modeles'),
          SizedBox(height: 16),
          _SectionTitle('Organisation'),
          _SettingRow(label: 'Departements', value: '12 services'),
          _SettingRow(label: 'Nomenclature actes', value: 'CCAM / NGAP'),
          _SettingRow(label: 'Tarifs standards', value: 'A jour'),
        ],
      ),
      side: Column(
        children: const [
          _PanelCard(
            title: 'Statut etablissement',
            child: Column(
              children: [
                _StatRow(label: 'Services actifs', value: '12', color: Color(0xFF3B82F6)),
                SizedBox(height: 10),
                _StatRow(label: 'Documents valides', value: '8/10', color: Color(0xFF22C55E)),
                SizedBox(height: 10),
                _StatRow(label: 'Maintenance', value: 'RAS', color: Color(0xFF64748B)),
              ],
            ),
          ),
          SizedBox(height: 12),
          _PanelCard(
            title: 'Notifications',
            child: Column(
              children: [
                _AlertRow(label: 'Audit ISO en cours', detail: 'Q2', color: Color(0xFFF59E0B)),
                SizedBox(height: 10),
                _AlertRow(label: 'Licences', detail: 'Valides', color: Color(0xFF22C55E)),
                SizedBox(height: 10),
                _AlertRow(label: 'Mise a jour', detail: 'v1.3.0', color: Color(0xFF3B82F6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilisateursTab() {
    return _buildTabShell(
      main: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestion des utilisateurs',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildUserFilters(),
          const SizedBox(height: 12),
          _buildUserActions(),
          const SizedBox(height: 12),
          Expanded(
            child: _loadingUsers
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
                    ),
                  )
                : _buildUsersTable(),
          ),
        ],
      ),
      side: Column(
        children: const [
          _PanelCard(
            title: 'Acces & roles',
            child: Column(
              children: [
                _StatRow(label: 'Comptes actifs', value: '24', color: Color(0xFF22C55E)),
                SizedBox(height: 10),
                _StatRow(label: 'Comptes verrouilles', value: '2', color: Color(0xFFEF4444)),
                SizedBox(height: 10),
                _StatRow(label: 'Invitations', value: '3', color: Color(0xFFF59E0B)),
              ],
            ),
          ),
          SizedBox(height: 12),
          _PanelCard(
            title: 'Activite recente',
            child: Column(
              children: [
                _AlertRow(label: 'Ajout compte', detail: 'Dr Mensah', color: Color(0xFF3B82F6)),
                SizedBox(height: 10),
                _AlertRow(label: 'Changement role', detail: '3 actions', color: Color(0xFFF59E0B)),
                SizedBox(height: 10),
                _AlertRow(label: 'Connexion admin', detail: 'Il y a 2h', color: Color(0xFF22C55E)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesTab() {
    return _buildTabShell(
      main: ListView(
        children: const [
          _SectionTitle('Documents medicaux'),
          _SettingRow(label: 'Ordonnances', value: '4 modeles'),
          _SettingRow(label: 'Certificats', value: '3 modeles'),
          _SettingRow(label: 'Comptes rendus', value: '2 modeles'),
          SizedBox(height: 16),
          _SectionTitle('Facturation'),
          _SettingRow(label: 'Factures', value: 'Template par assureur'),
          _SettingRow(label: 'Recus', value: 'Standard'),
          _SettingRow(label: 'Attestations', value: 'Personnalisees'),
          SizedBox(height: 16),
          _SectionTitle('Signature'),
          _SettingRow(label: 'Signature electronique', value: 'Active'),
          _SettingRow(label: 'Cachet numerique', value: 'Actif'),
        ],
      ),
      side: Column(
        children: const [
          _PanelCard(
            title: 'Workflow edition',
            child: Column(
              children: [
                _StatRow(label: 'Modeles valides', value: '9', color: Color(0xFF22C55E)),
                SizedBox(height: 10),
                _StatRow(label: 'A revoir', value: '2', color: Color(0xFFF59E0B)),
                SizedBox(height: 10),
                _StatRow(label: 'Brouillons', value: '1', color: Color(0xFF3B82F6)),
              ],
            ),
          ),
          SizedBox(height: 12),
          _PanelCard(
            title: 'Stockage',
            child: Column(
              children: [
                _AlertRow(label: 'Bibliotheque PDF', detail: '2.4 Go', color: Color(0xFF64748B)),
                SizedBox(height: 10),
                _AlertRow(label: 'Dernier upload', detail: "Aujourd'hui", color: Color(0xFF22C55E)),
                SizedBox(height: 10),
                _AlertRow(label: 'Export mensuel', detail: 'Planifie', color: Color(0xFFF59E0B)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuriteTab() {
    final canEditSettings = PermissionScope.of(context).canEdit('Parametres');
    return _buildTabShell(
      main: ListView(
        children: [
          _buildTabActions(
            onSave: _saveSecuritySettings,
            onReset: _resetSecuritySettings,
            enabled: canEditSettings,
          ),
          const SizedBox(height: 16),
          const _SectionTitle('Authentification'),
          _SettingField(label: 'Mot de passe minimum', controller: _securityPasswordMinController, enabled: canEditSettings),
          _SettingRow(label: 'Complexite', value: 'Majuscule + chiffre'),
          _SettingRow(label: '2FA', value: 'Active'),
          SizedBox(height: 16),
          _SectionTitle('Chiffrement & acces'),
          _SettingRow(label: 'Chiffrement donnees', value: 'AES-256'),
          _SettingField(label: 'Sessions', controller: _securitySessionController, enabled: canEditSettings),
          _SettingField(label: 'IP autorisees', controller: _securityIpController, enabled: canEditSettings),
          SizedBox(height: 16),
          _SectionTitle('Journalisation'),
          _SettingRow(label: 'Audit trail', value: 'Conserve 24 mois'),
          _SettingRow(label: 'Export logs', value: 'Hebdomadaire'),
        ],
      ),
      side: Column(
        children: const [
          _PanelCard(
            title: 'Audit & securite',
            child: Column(
              children: [
                _StatRow(label: 'Dernier audit', value: 'J-3', color: Color(0xFFF59E0B)),
                SizedBox(height: 10),
                _StatRow(label: 'Chiffrement', value: 'AES-256', color: Color(0xFF3B82F6)),
                SizedBox(height: 10),
                _StatRow(label: 'Incidents', value: '0', color: Color(0xFF22C55E)),
              ],
            ),
          ),
          SizedBox(height: 12),
          _PanelCard(
            title: 'Alertes',
            child: Column(
              children: [
                _AlertRow(label: 'Acces anormal', detail: 'Aucun', color: Color(0xFF22C55E)),
                SizedBox(height: 10),
                _AlertRow(label: 'Mots de passe', detail: 'Rotation 90j', color: Color(0xFFF59E0B)),
                SizedBox(height: 10),
                _AlertRow(label: 'Connexions', detail: 'OK', color: Color(0xFF3B82F6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudTab() {
    return _buildTabShell(
      main: ListView(
        children: const [
          _SectionTitle('Synchronisation'),
          _SettingRow(label: 'Etat connexion', value: 'Deconnecte'),
          _SettingRow(label: 'Projet Cloud', value: 'reshopital-prod'),
          _SettingRow(label: 'Mode offline', value: 'Actif'),
          SizedBox(height: 16),
          _SectionTitle('Services'),
          _SettingRow(label: 'Auth', value: 'Desactive'),
          _SettingRow(label: 'Firestore', value: 'Desactive'),
          _SettingRow(label: 'Storage', value: 'Desactive'),
          SizedBox(height: 16),
          _SectionTitle('Webhooks'),
          _SettingRow(label: 'Notifications', value: 'A configurer'),
          _SettingRow(label: 'Rapports', value: 'A configurer'),
        ],
      ),
      side: Column(
        children: const [
          _PanelCard(
            title: 'Etat services',
            child: Column(
              children: [
                _AlertRow(label: 'Auth', detail: 'Off', color: Color(0xFF64748B)),
                SizedBox(height: 10),
                _AlertRow(label: 'Firestore', detail: 'Off', color: Color(0xFF64748B)),
                SizedBox(height: 10),
                _AlertRow(label: 'Storage', detail: 'Off', color: Color(0xFF64748B)),
              ],
            ),
          ),
          SizedBox(height: 12),
          _PanelCard(
            title: 'Derniere synchro',
            child: Column(
              children: [
                _StatRow(label: 'Date', value: 'Aucune', color: Color(0xFFF59E0B)),
                SizedBox(height: 10),
                _StatRow(label: 'Latence', value: '--', color: Color(0xFF3B82F6)),
                SizedBox(height: 10),
                _StatRow(label: 'Etat', value: 'Inactif', color: Color(0xFF64748B)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParametresEtendusTab() {
    return _buildTabShell(
      main: ListView(
        children: const [
          _SectionTitle('Parametres avances'),
          _SettingRow(label: 'Mode multi-etablissements', value: 'Desactive'),
          _SettingRow(label: 'Modules externes', value: '0 actif'),
          _SettingRow(label: 'API interne', value: 'Active'),
          SizedBox(height: 16),
          _SectionTitle('Conformite'),
          _SettingRow(label: 'RGPD', value: 'Conforme'),
          _SettingRow(label: 'Audit trail', value: 'Actif'),
          _SettingRow(label: 'Archivage', value: 'Automatique'),
        ],
      ),
      side: Column(
        children: [
          const _PanelCard(
            title: 'Modules',
            child: Column(
              children: [
                _StatRow(label: 'Extensions', value: '2', color: Color(0xFF3B82F6)),
                SizedBox(height: 10),
                _StatRow(label: 'Integrations', value: '1', color: Color(0xFFF59E0B)),
                SizedBox(height: 10),
                _StatRow(label: 'Licences', value: 'OK', color: Color(0xFF22C55E)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _PanelCard(
            title: 'Journal d\'audit',
            child: _buildAuditPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabShell({required Widget main, required Widget side}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        final mainPanel = _SectionPanel(child: main);
        final sidePanel = _SectionPanel(child: side);
        if (isCompact) {
          return Column(
            children: [
              Expanded(child: mainPanel),
              const SizedBox(height: 16),
              Expanded(child: sidePanel),
            ],
          );
        }
        return Row(
          children: [
            Expanded(flex: 6, child: mainPanel),
            const SizedBox(width: 16),
            Expanded(flex: 5, child: sidePanel),
          ],
        );
      },
    );
  }

  Widget _buildUsersTable() {
    final canEditUsers = PermissionScope.of(context).canEdit('Parametres');
    final canDeleteUsers = PermissionScope.of(context).canDelete('Parametres');
    final filtered = _filteredUsers();
    final totalPages = (filtered.length / _userPageSize).ceil().clamp(1, 9999);
    final currentPage = _userPage.clamp(1, totalPages);
    final pageStart = (currentPage - 1) * _userPageSize;
    final pageEnd = (pageStart + _userPageSize).clamp(0, filtered.length);
    final paged = filtered.sublist(pageStart, pageEnd);

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'Aucun utilisateur enregistre',
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w600),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: paged.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final user = paged[index];
              return _UserRow(
                name: user.name,
                email: user.email,
                role: _roleLabel(user.role),
                active: user.isActive,
                onView: () => _openUserDetails(user),
                onEdit: canEditUsers ? () => _openUserDialog(editingUser: user) : null,
                onDelete: canDeleteUsers ? () => _confirmDeleteUser(user) : null,
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _PaginationBar(
          currentPage: currentPage,
          totalPages: totalPages,
          totalItems: filtered.length,
          onPrev: currentPage > 1 ? () => setState(() => _userPage = currentPage - 1) : null,
          onNext: currentPage < totalPages ? () => setState(() => _userPage = currentPage + 1) : null,
        ),
      ],
    );
  }

  Widget _buildUserFilters() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: 320,
          child: TextField(
            controller: _userSearchController,
            onChanged: (_) => setState(() => _userPage = 1),
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Rechercher par nom ou email',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6366F1), size: 18),
              suffixIcon: _userSearchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54, size: 16),
                      onPressed: () {
                        _userSearchController.clear();
                        setState(() => _userPage = 1);
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF0F172A),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.3),
              ),
            ),
          ),
        ),
        _FilterDropdown(
          label: 'Role',
          value: _roleFilter,
          options: ['Tous', ..._roleOptions().map(_roleLabel).toList()],
          onChanged: (value) => setState(() {
            _roleFilter = value;
            _userPage = 1;
          }),
        ),
        _FilterDropdown(
          label: 'Statut',
          value: _statusFilter,
          options: const ['Tous', 'Actif', 'Inactif'],
          onChanged: (value) => setState(() {
            _statusFilter = value;
            _userPage = 1;
          }),
        ),
      ],
    );
  }

  Widget _buildUserActions() {
    final canEditUsers = PermissionScope.of(context).canEdit('Parametres');
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _ActionButton(
          label: 'Nouvel utilisateur',
          icon: Icons.person_add_alt_1,
          color: const Color(0xFF22C55E),
          onTap: canEditUsers ? _openUserDialog : null,
        ),
        _ActionButton(
          label: 'Permissions par role',
          icon: Icons.admin_panel_settings,
          color: const Color(0xFF8B5CF6),
          onTap: canEditUsers ? _openRolePermissionsDialog : null,
        ),
        _ActionButton(
          label: 'Exporter',
          icon: Icons.file_download_outlined,
          color: const Color(0xFF3B82F6),
          onTap: () {},
        ),
        _ActionButton(
          label: 'Inviter',
          icon: Icons.mail_outline,
          color: const Color(0xFFF59E0B),
          onTap: () {},
        ),
      ],
    );
  }

  List<User> _filteredUsers() {
    final query = _userSearchController.text.trim().toLowerCase();
    return _users.where((user) {
      final matchesSearch = query.isEmpty ||
          user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);
      final matchesRole = _roleFilter == 'Tous' || _roleLabel(user.role) == _roleFilter;
      final matchesStatus =
          _statusFilter == 'Tous' || (_statusFilter == 'Actif' ? user.isActive : !user.isActive);
      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  Widget _buildTabActions({required VoidCallback onSave, required VoidCallback onReset, bool enabled = true}) {
    return Row(
      children: [
        const Spacer(),
        _ActionButton(
          label: _saving ? 'Enregistrement...' : 'Enregistrer',
          icon: Icons.save,
          color: const Color(0xFF22C55E),
          onTap: _saving || !enabled ? null : onSave,
        ),
        const SizedBox(width: 8),
        _ActionButton(
          label: 'Annuler',
          icon: Icons.cancel_outlined,
          color: const Color(0xFFEF4444),
          onTap: _saving || !enabled ? null : onReset,
        ),
      ],
    );
  }

  Future<void> _loadSettings() async {
    setState(() => _loading = true);
    final values = await _databaseService.getSettings(_defaults.keys.toList());
    final merged = {..._defaults, ...values};
    _orgNameController.text = merged['org.name'] ?? '';
    _orgAddressController.text = merged['org.address'] ?? '';
    _orgEmailController.text = merged['org.email'] ?? '';
    _orgPhoneController.text = merged['org.phone'] ?? '';
    _securityPasswordMinController.text = merged['security.password_min'] ?? '';
    _securitySessionController.text = merged['security.session_expiry'] ?? '';
    _securityIpController.text = merged['security.ip_policy'] ?? '';
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _loadUsers() async {
    setState(() => _loadingUsers = true);
    final users = await _databaseService.getUsers();
    if (!mounted) return;
    setState(() {
      _users = users;
      _loadingUsers = false;
      _userPage = 1;
    });
  }

  Future<void> _loadAuditLogs() async {
    setState(() => _loadingAudit = true);
    final logs = await _databaseService.getAuditLogs(limit: 8);
    if (!mounted) return;
    setState(() {
      _auditLogs = logs;
      _loadingAudit = false;
    });
  }

  Widget _buildAuditPanel() {
    if (_loadingAudit) {
      return const Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
          ),
        ),
      );
    }
    if (_auditLogs.isEmpty) {
      return Text(
        'Aucun log disponible.',
        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
      );
    }

    return Column(
      children: _auditLogs.map((log) {
        final action = (log['action'] as String?) ?? 'action';
        final target = (log['target'] as String?) ?? '--';
        final createdAt = (log['created_at'] as int?) ?? 0;
        final payload = (log['payload'] as String?) ?? '';
        String actor = '--';
        String ip = '--';
        if (payload.isNotEmpty) {
          try {
            final decoded = jsonDecode(payload) as Map<String, dynamic>;
            actor = decoded['actor_email'] as String? ?? actor;
            ip = decoded['ip'] as String? ?? ip;
          } catch (_) {
            // Ignore malformed payloads.
          }
        }
        final timestamp = _formatDate(DateTime.fromMillisecondsSinceEpoch(createdAt));
        return _AuditEntry(
          title: action,
          subtitle: 'Cible: $target • Acteur: $actor • IP: $ip',
          timestamp: timestamp,
        );
      }).toList(),
    );
  }

  Future<void> _openUserDialog({User? editingUser, bool viewOnly = false}) async {
    _userErrors.clear();
    _editingUser = editingUser;
    _userActive = editingUser?.isActive ?? true;
    _userRole = editingUser?.role ?? UserRole.staff;
    _userNameController.text = editingUser?.name ?? '';
    _userEmailController.text = editingUser?.email ?? '';
    _userPasswordController.clear();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          viewOnly
                              ? 'Profil utilisateur'
                              : editingUser == null
                                  ? 'Nouvel utilisateur'
                                  : 'Modifier utilisateur',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _UserField(
                        label: 'Nom complet',
                        controller: _userNameController,
                        errorText: _userErrors['name'],
                        enabled: !viewOnly,
                        onChanged: (_) => _clearUserError('name'),
                      ),
                      const SizedBox(height: 12),
                      _UserField(
                        label: 'Email',
                        controller: _userEmailController,
                        errorText: _userErrors['email'],
                        enabled: !viewOnly,
                        onChanged: (_) => _clearUserError('email'),
                      ),
                      const SizedBox(height: 12),
                      _UserField(
                        label: editingUser == null ? 'Mot de passe' : 'Mot de passe (optionnel)',
                        controller: _userPasswordController,
                        errorText: _userErrors['password'],
                        enabled: !viewOnly,
                        obscure: true,
                        onChanged: (_) => _clearUserError('password'),
                      ),
                      const SizedBox(height: 12),
                      _UserDropdown(
                        label: 'Role',
                        value: _userRole,
                        enabled: !viewOnly,
                        options: _roleOptions(),
                        onChanged: (value) => setState(() => _userRole = value),
                      ),
                      const SizedBox(height: 12),
                      _UserToggle(
                        label: 'Compte actif',
                        value: _userActive,
                        enabled: !viewOnly,
                        onChanged: (value) => setState(() => _userActive = value),
                      ),
                    ],
                  ),
                ),
                if (!viewOnly)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                      border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
                    ),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _saveUser,
                          icon: const Icon(Icons.save),
                          label: Text(editingUser == null ? 'Creer' : 'Enregistrer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openUserDetails(User user) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Profil utilisateur',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(user.email, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                      const SizedBox(height: 16),
                      _detailRow('Role', _roleLabel(user.role)),
                      _detailRow('Statut', user.isActive ? 'Actif' : 'Inactif'),
                      _detailRow('Cree le', _formatDate(user.createdAt)),
                      _detailRow('Derniere connexion', _formatDate(user.lastLogin)),
                      const SizedBox(height: 16),
                      const Text(
                        'Historique recent',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _historyItem('Connexion', "Aujourd'hui 09:12"),
                      _historyItem('Modification profil', 'Hier 18:40'),
                      _historyItem('Changement role', 'Il y a 3 jours'),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                    border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
                  ),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Fermer', style: TextStyle(color: Colors.white70)),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _openUserDialog(editingUser: user);
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Modifier'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '--' : value,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: Color(0xFF6366F1), shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          Text(value, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
        ],
      ),
    );
  }

  Future<void> _openRolePermissionsDialog() async {
    _permissions = await _loadRolePermissions(_permissionsRole);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Permissions par role',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _UserDropdown(
                    label: 'Role',
                    value: _permissionsRole,
                    options: _roleOptions(),
                    onChanged: (value) async {
                      _permissionsRole = value;
                      _permissions = await _loadRolePermissions(_permissionsRole);
                      if (mounted) setState(() {});
                    },
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: _permissions.entries.map((entry) {
                      final module = entry.key;
                      final perms = entry.value;
                      return _PermissionRow(
                        module: module,
                        canView: perms['view'] ?? false,
                        canEdit: perms['edit'] ?? false,
                        canDelete: perms['delete'] ?? false,
                        onChanged: (view, edit, del) {
                          setState(() {
                            _permissions[module] = {'view': view, 'edit': edit, 'delete': del};
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                    border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
                  ),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await _saveRolePermissions(_permissionsRole, _permissions);
                          if (!mounted) return;
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Enregistrer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, Map<String, bool>>> _loadRolePermissions(UserRole role) async {
    final key = 'permissions.${role.name}';
    final data = await _databaseService.getSettings([key]);
    final raw = data[key];
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((module, perms) {
        final permMap = perms as Map<String, dynamic>;
        return MapEntry(
          module,
          {
            'view': permMap['view'] == true,
            'edit': permMap['edit'] == true,
            'delete': permMap['delete'] == true,
          },
        );
      });
    }
    return _defaultPermissionsForRole(role);
  }

  Future<void> _saveRolePermissions(UserRole role, Map<String, Map<String, bool>> permissions) async {
    final key = 'permissions.${role.name}';
    await _databaseService.setSetting(key, jsonEncode(permissions));
    final actorId = AuthService.currentUser?.id ?? 'system';
    final actorEmail = AuthService.currentUser?.email ?? 'system';
    await _databaseService.insertAuditLog(
      actorId: actorId,
      action: 'permissions.update',
      target: role.name,
      payload: jsonEncode({
        'actor_email': actorEmail,
        'ip': 'local',
        'permissions': permissions,
      }),
    );
    await _showStatusDialog('Permissions sauvegardees', 'Les permissions ont ete mises a jour.');
    _loadAuditLogs();
  }

  Map<String, Map<String, bool>> _defaultPermissionsForRole(UserRole role) {
    return PermissionService.defaultPermissionsForRole(role);
  }

  Future<void> _saveUser() async {
    final name = _userNameController.text.trim();
    final email = _userEmailController.text.trim();
    final password = _userPasswordController.text;

    _userErrors['name'] = name.isEmpty ? 'Champ obligatoire' : null;
    _userErrors['email'] = email.isEmpty ? 'Champ obligatoire' : null;
    if (_editingUser == null && password.isEmpty) {
      _userErrors['password'] = 'Mot de passe requis';
    } else {
      _userErrors['password'] = null;
    }

    if (_userErrors.values.any((error) => error != null)) {
      setState(() {});
      return;
    }

    final existing = await _databaseService.getUserByEmail(email);
    if (existing != null && existing.id != _editingUser?.id) {
      _userErrors['email'] = 'Email deja utilise';
      setState(() {});
      return;
    }

    final now = DateTime.now();
    if (_editingUser != null && _editingUser!.role == UserRole.admin) {
      final activeAdmins = _users.where((user) => user.role == UserRole.admin && user.isActive && user.id != _editingUser!.id).length;
      final demotingAdmin = _userRole != UserRole.admin;
      final deactivatingAdmin = !_userActive;
      if ((demotingAdmin || deactivatingAdmin) && activeAdmins == 0) {
        await _showStatusDialog(
          'Action interdite',
          'Au moins un administrateur actif est requis.',
        );
        return;
      }
    }

    final passwordHash = password.isEmpty && _editingUser != null
        ? _editingUser!.passwordHash
        : sha256.convert(utf8.encode(password)).toString();

    final user = User(
      id: _editingUser?.id ?? 'usr_${now.millisecondsSinceEpoch}',
      name: name,
      email: email,
      passwordHash: passwordHash,
      role: _userRole,
      createdAt: _editingUser?.createdAt ?? now,
      lastLogin: _editingUser?.lastLogin ?? now,
      isActive: _userActive,
    );

    if (_editingUser == null) {
      await _databaseService.insertUser(user);
      await _showStatusDialog('Utilisateur cree', 'Le compte a ete ajoute avec succes.');
    } else {
      await _databaseService.updateUser(user);
      await _showStatusDialog('Utilisateur mis a jour', 'Le compte a ete mis a jour avec succes.');
    }

    _editingUser = null;
    if (!mounted) return;
    Navigator.of(context).pop();
    _loadUsers();
  }

  void _clearUserError(String key) {
    if (_userErrors[key] != null) {
      setState(() => _userErrors[key] = null);
    }
  }

  Future<void> _confirmDeleteUser(User user) async {
    if (AuthService.currentUser?.id == user.id) {
      await _showStatusDialog('Action interdite', 'Vous ne pouvez pas supprimer votre propre compte.');
      return;
    }
    if (user.role == UserRole.admin && user.isActive) {
      final activeAdmins = _users.where((u) => u.role == UserRole.admin && u.isActive).length;
      if (activeAdmins <= 1) {
        await _showStatusDialog('Action interdite', 'Au moins un administrateur actif est requis.');
        return;
      }
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Supprimer utilisateur', style: TextStyle(color: Colors.white)),
          content: Text(
            'Confirmer la suppression de ${user.name} ?',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Supprimer', style: TextStyle(color: Color(0xFFEF4444))),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _databaseService.deleteUser(user.id);
      await _showStatusDialog('Utilisateur supprime', 'Le compte a ete supprime.');
      _loadUsers();
    }
  }
  Future<void> _saveEntrepriseSettings() async {
    await _saveSettings({
      'org.name': _orgNameController.text.trim(),
      'org.address': _orgAddressController.text.trim(),
      'org.email': _orgEmailController.text.trim(),
      'org.phone': _orgPhoneController.text.trim(),
    });
  }

  Future<void> _saveSecuritySettings() async {
    await _saveSettings({
      'security.password_min': _securityPasswordMinController.text.trim(),
      'security.session_expiry': _securitySessionController.text.trim(),
      'security.ip_policy': _securityIpController.text.trim(),
    });
  }

  Future<void> _saveSettings(Map<String, String> values) async {
    setState(() => _saving = true);
    await _databaseService.setSettings(values);
    if (!mounted) return;
    setState(() => _saving = false);
    await _showStatusDialog('Parametres sauvegardes', 'Les informations ont ete mises a jour.');
  }

  void _resetEntrepriseSettings() {
    _orgNameController.text = _defaults['org.name'] ?? '';
    _orgAddressController.text = _defaults['org.address'] ?? '';
    _orgEmailController.text = _defaults['org.email'] ?? '';
    _orgPhoneController.text = _defaults['org.phone'] ?? '';
  }

  void _resetSecuritySettings() {
    _securityPasswordMinController.text = _defaults['security.password_min'] ?? '';
    _securitySessionController.text = _defaults['security.session_expiry'] ?? '';
    _securityIpController.text = _defaults['security.ip_policy'] ?? '';
  }

  Future<void> _showStatusDialog(String title, String message) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: Text(message, style: TextStyle(color: Colors.white.withOpacity(0.7))),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: Color(0xFF6366F1))),
            ),
          ],
        );
      },
    );
  }

  List<UserRole> _roleOptions() {
    return [
      UserRole.admin,
      UserRole.medecin,
      UserRole.infirmier,
      UserRole.pharmacien,
      UserRole.comptable,
      UserRole.secretaire,
      UserRole.laborantin,
      UserRole.radiologue,
      UserRole.staff,
    ];
  }
}

String _roleLabel(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return 'Administrateur';
    case UserRole.medecin:
      return 'Medecin';
    case UserRole.infirmier:
      return 'Infirmier';
    case UserRole.pharmacien:
      return 'Pharmacien';
    case UserRole.comptable:
      return 'Comptable';
    case UserRole.secretaire:
      return 'Secretaire';
    case UserRole.laborantin:
      return 'Laborantin';
    case UserRole.radiologue:
      return 'Radiologue';
    case UserRole.staff:
      return 'Personnel';
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String value;

  const _SettingRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SettingField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;

  const _SettingField({required this.label, required this.controller, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            enabled: enabled,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0F172A),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? errorText;
  final bool enabled;
  final bool obscure;
  final ValueChanged<String>? onChanged;

  const _UserField({
    required this.label,
    required this.controller,
    this.errorText,
    this.enabled = true,
    this.obscure = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: obscure,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0F172A),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.4),
            ),
            errorText: errorText,
            errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class _UserDropdown extends StatelessWidget {
  final String label;
  final UserRole value;
  final List<UserRole> options;
  final ValueChanged<UserRole> onChanged;
  final bool enabled;

  const _UserDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<UserRole>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF0B1220),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6366F1)),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              items: options
                  .map(
                    (role) => DropdownMenuItem(
                      value: role,
                      child: Text(_roleLabel(role)),
                    ),
                  )
                  .toList(),
              onChanged: enabled ? (val) => onChanged(val ?? value) : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _UserToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  const _UserToggle({required this.label, required this.value, required this.onChanged, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
        ),
        Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeColor: const Color(0xFF22C55E),
        ),
      ],
    );
  }
}

class _UserRow extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final bool active;
  final VoidCallback onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _UserRow({
    required this.name,
    required this.email,
    required this.role,
    required this.active,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = active ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor.withOpacity(0.25), statusColor.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.4), width: 1.5),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(email, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              role,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
          const SizedBox(width: 12),
          _UserAction(icon: Icons.visibility_outlined, color: const Color(0xFF3B82F6), onTap: onView),
          const SizedBox(width: 6),
          _UserAction(icon: Icons.edit_outlined, color: const Color(0xFF22C55E), onTap: onEdit),
          const SizedBox(width: 6),
          _UserAction(icon: Icons.delete_outline, color: const Color(0xFFEF4444), onTap: onDelete),
        ],
      ),
    );
  }
}

class _UserAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _UserAction({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
      ),
    );
  }
}

class _AuditEntry extends StatelessWidget {
  final String title;
  final String subtitle;
  final String timestamp;

  const _AuditEntry({required this.title, required this.subtitle, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Color(0xFF6366F1), shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
              ],
            ),
          ),
          Text(timestamp, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final String module;
  final bool canView;
  final bool canEdit;
  final bool canDelete;
  final void Function(bool view, bool edit, bool del) onChanged;

  const _PermissionRow({
    required this.module,
    required this.canView,
    required this.canEdit,
    required this.canDelete,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              module,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          _PermissionToggle(
            label: 'Voir',
            value: canView,
            onChanged: (val) => onChanged(val, canEdit, canDelete),
          ),
          _PermissionToggle(
            label: 'Editer',
            value: canEdit,
            onChanged: (val) => onChanged(canView, val, canDelete),
          ),
          _PermissionToggle(
            label: 'Supprimer',
            value: canDelete,
            onChanged: (val) => onChanged(canView, canEdit, val),
          ),
        ],
      ),
    );
  }
}

class _PermissionToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PermissionToggle({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF22C55E),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF0B1220),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6366F1), size: 18),
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          items: options.map((opt) => DropdownMenuItem(value: opt, child: Text('$label: $opt'))).toList(),
          onChanged: (val) => onChanged(val ?? value),
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Total: $totalItems utilisateurs',
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        _PaginationButton(label: 'Precedent', icon: Icons.chevron_left, onTap: onPrev),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$currentPage / $totalPages',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        _PaginationButton(label: 'Suivant', icon: Icons.chevron_right, onTap: onNext),
      ],
    );
  }
}

String _formatDate(DateTime date) {
  if (date.millisecondsSinceEpoch == 0) return '--';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

class _PaginationButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _PaginationButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoPill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
class _PanelCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _PanelCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1F2937), Color(0xFF111827)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SectionPanel extends StatelessWidget {
  final Widget child;

  const _SectionPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1F2937), Color(0xFF111827)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: child,
    );
  }
}

class _AlertRow extends StatelessWidget {
  final String label;
  final String detail;
  final Color color;

  const _AlertRow({required this.label, required this.detail, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        Text(detail, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
          ),
        ),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({required this.label, required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color, size: 18),
        label: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ),
    );
  }
}
