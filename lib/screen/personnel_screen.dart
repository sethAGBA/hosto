import 'package:flutter/material.dart';
import '../widgets/permission_scope.dart';
import '../models/medical_staff.dart';
import '../services/database_service.dart';

class PersonnelScreen extends StatefulWidget {
  final Animation<double> fadeAnimation;

  const PersonnelScreen({super.key, required this.fadeAnimation});

  @override
  State<PersonnelScreen> createState() => _PersonnelScreenState();
}

class _PersonnelScreenState extends State<PersonnelScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  String _service = 'Tous';
  String _specialty = 'Toutes';
  String _status = 'Tous';
  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  List<MedicalStaff> _staff = [];
  bool _loading = true;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  DateTime? _hiredAt;
  String? _formStatus = 'Disponible';
  MedicalStaff? _editingStaff;
  final Map<String, String?> _errors = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    _loadStaff();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _roleController.dispose();
    _specialtyController.dispose();
    _serviceController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _staff.where((m) {
      final serviceOk = _service == 'Tous' || m.department == _service;
      final specialtyOk = _specialty == 'Toutes' || m.specialty == _specialty;
      final statusOk = _status == 'Tous' || m.status == _status;
      final searchOk = query.isEmpty ||
          m.fullName.toLowerCase().contains(query) ||
          m.email.toLowerCase().contains(query) ||
          m.phone.toLowerCase().contains(query) ||
          m.department.toLowerCase().contains(query) ||
          m.specialty.toLowerCase().contains(query);
      return serviceOk && specialtyOk && statusOk && searchOk;
    }).toList();
    final stats = _buildStats(filtered);

    return FadeTransition(
      opacity: widget.fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 12),
          _buildFilters(),
          const SizedBox(height: 12),
          _buildActionsRow(),
          const SizedBox(height: 16),
          Expanded(
            child: FadeTransition(
              opacity: _fade,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: _buildTeamList(filtered)),
                  const SizedBox(width: 16),
                  Expanded(flex: 5, child: _buildSidePanel(stats)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF16A34A)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF22C55E).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personnel medical',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
            ),
            SizedBox(height: 2),
            Text(
              'Equipe, disponibilites et planning',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _FilterChip(
          label: 'Service',
          value: _service,
          options: const ['Tous', 'Urgences', 'Maternite', 'Chirurgie', 'USI', 'Pediatrie', 'Service cardio'],
          onChanged: (value) => setState(() => _service = value),
        ),
        _FilterChip(
          label: 'Specialite',
          value: _specialty,
          options: const ['Toutes', 'Cardiologie', 'Urgences', 'Gynecologie', 'Chirurgie', 'Soins intensifs', 'Pediatrie'],
          onChanged: (value) => setState(() => _specialty = value),
        ),
        _FilterChip(
          label: 'Statut',
          value: _status,
          options: const ['Tous', 'Disponible', 'En consultation', 'En bloc', 'En garde', 'En conge'],
          onChanged: (value) => setState(() => _status = value),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      width: 360,
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: Colors.white, fontSize: 12),
        decoration: InputDecoration(
          hintText: 'Rechercher par nom, service, email...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF22C55E), size: 18),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 16),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF111827),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF22C55E), width: 1.3),
          ),
        ),
      ),
    );
  }

  Widget _buildActionsRow() {
    final canEdit = PermissionScope.of(context).canEdit('Personnel');
    Widget guard(Widget child, bool enabled) {
      return Opacity(
        opacity: enabled ? 1 : 0.4,
        child: AbsorbPointer(absorbing: !enabled, child: child),
      );
    }
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        guard(
          _ActionButton(
            label: 'Ajouter personnel',
            icon: Icons.person_add,
            color: const Color(0xFF22C55E),
            onTap: () => _openStaffDialog(),
          ),
          canEdit,
        ),
        guard(_ActionButton(label: 'Modifier planning', icon: Icons.calendar_month, color: const Color(0xFF3B82F6)), canEdit),
        guard(_ActionButton(label: 'Affecter patients', icon: Icons.assignment_ind, color: const Color(0xFFF59E0B)), canEdit),
        guard(_ActionButton(label: 'Gerer absences', icon: Icons.event_busy, color: const Color(0xFFEF4444)), canEdit),
      ],
    );
  }

  Widget _buildTeamList(List<MedicalStaff> members) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xFF22C55E)),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1F2937), Color(0xFF111827)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Equipe medicale',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Text(
                '${members.length} profils',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: members.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final member = members[index];
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 300 + (index * 60)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 12 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: _StaffCard(
                    member: member,
                    canEdit: PermissionScope.of(context).canEdit('Personnel'),
                    canDelete: PermissionScope.of(context).canDelete('Personnel'),
                    onView: () => _openStaffDetails(member),
                    onEdit: () => _openStaffDialog(staff: member),
                    onDelete: () => _confirmDeleteStaff(member),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidePanel(_StaffStats stats) {
    return Column(
      children: [
        _PanelCard(
          title: 'Planning des gardes',
          child: Column(
            children: const [
              _PlanRow(label: '08:00 - 12:00', detail: 'Dr Kokou · Urgences', color: Color(0xFFEF4444)),
              SizedBox(height: 10),
              _PlanRow(label: '12:00 - 16:00', detail: 'Dr Ada · Cardiologie', color: Color(0xFF22C55E)),
              SizedBox(height: 10),
              _PlanRow(label: '16:00 - 20:00', detail: 'Inf. Yawa · USI', color: Color(0xFF3B82F6)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _PanelCard(
          title: 'Statistiques rapides',
          child: Column(
            children: [
              _StatRow(label: 'Effectif total', value: '${stats.total}', color: Color(0xFF22C55E)),
              const SizedBox(height: 10),
              _StatRow(label: 'Disponibles', value: '${stats.available}', color: Color(0xFF3B82F6)),
              const SizedBox(height: 10),
              _StatRow(label: 'En consultation', value: '${stats.inConsultation}', color: Color(0xFFF59E0B)),
              const SizedBox(height: 10),
              _StatRow(label: 'En garde', value: '${stats.onDuty}', color: Color(0xFF6366F1)),
              const SizedBox(height: 10),
              _StatRow(label: 'En bloc', value: '${stats.inTheatre}', color: Color(0xFFEF4444)),
              const SizedBox(height: 10),
              _StatRow(label: 'En conge', value: '${stats.onLeave}', color: Color(0xFF64748B)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _PanelCard(
          title: 'Top services',
          child: Column(
            children: stats.topServices
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _StatRow(
                      label: entry.key,
                      value: '${entry.value}',
                      color: const Color(0xFF22C55E),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  _StaffStats _buildStats(List<MedicalStaff> members) {
    int available = 0;
    int inConsultation = 0;
    int onDuty = 0;
    int inTheatre = 0;
    int onLeave = 0;
    final serviceCounts = <String, int>{};
    for (final staff in members) {
      switch (staff.status) {
        case 'Disponible':
          available += 1;
          break;
        case 'En consultation':
          inConsultation += 1;
          break;
        case 'En bloc':
          inTheatre += 1;
          break;
        case 'En garde':
          onDuty += 1;
          break;
        case 'En conge':
          onLeave += 1;
          break;
        default:
          break;
      }
      final service = staff.department.isEmpty ? 'Non affecte' : staff.department;
      serviceCounts[service] = (serviceCounts[service] ?? 0) + 1;
    }
    final sortedServices = serviceCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return _StaffStats(
      total: members.length,
      available: available,
      inConsultation: inConsultation,
      onDuty: onDuty,
      inTheatre: inTheatre,
      onLeave: onLeave,
      topServices: sortedServices.take(3).toList(),
    );
  }

  Future<void> _loadStaff() async {
    setState(() => _loading = true);
    final staff = await _databaseService.getPersonnel();
    if (!mounted) return;
    setState(() {
      _staff = staff;
      _loading = false;
    });
  }

  Future<void> _openStaffDialog({MedicalStaff? staff}) async {
    _errors.clear();
    _editingStaff = staff;
    _firstNameController.text = staff?.firstName ?? '';
    _lastNameController.text = staff?.lastName ?? '';
    _roleController.text = staff?.role ?? '';
    _specialtyController.text = staff?.specialty ?? '';
    _serviceController.text = staff?.department ?? '';
    _phoneController.text = staff?.phone ?? '';
    _emailController.text = staff?.email ?? '';
    _hiredAt = staff?.hiredAt != null ? DateTime.fromMillisecondsSinceEpoch(staff!.hiredAt!) : null;
    _formStatus = staff?.status ?? 'Disponible';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620, maxHeight: 760),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF16A34A)]),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          staff == null ? 'Ajouter personnel' : 'Modifier personnel',
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _formRow([
                          _field('Prenom', _firstNameController, key: 'first'),
                          _field('Nom', _lastNameController, key: 'last'),
                        ]),
                        const SizedBox(height: 12),
                        _formRow([
                          _field('Role', _roleController, key: 'role'),
                          _field('Specialite', _specialtyController, key: 'specialty'),
                        ]),
                        const SizedBox(height: 12),
                        _formRow([
                          _field('Service', _serviceController, key: 'service'),
                          _statusDropdown(),
                        ]),
                        const SizedBox(height: 12),
                        _formRow([
                          _field('Telephone', _phoneController),
                          _field('Email', _emailController),
                        ]),
                        const SizedBox(height: 12),
                        _hiredDateField(),
                      ],
                    ),
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
                        onPressed: _saveStaff,
                        icon: const Icon(Icons.save),
                        label: Text(staff == null ? 'Creer' : 'Enregistrer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
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

  Widget _formRow(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;
        if (isCompact) {
          return Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }
        return Row(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              Expanded(child: children[i]),
              if (i != children.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _field(String label, TextEditingController controller, {String? key}) {
    final error = key == null ? null : _errors[key];
    final isRequired = key != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelWithRequired(label, isRequired),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: key == null
              ? null
              : (_) {
                  if (_errors[key] != null) {
                    setState(() => _errors[key] = null);
                  }
                },
          style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: InputDecoration(
            errorText: error,
            errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
            filled: true,
            fillColor: const Color(0xFF111827),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF22C55E), width: 1.3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusDropdown() {
    const options = ['Disponible', 'En consultation', 'En bloc', 'En garde', 'En conge'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelWithRequired('Statut', true),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _errors['status'] != null ? const Color(0xFFEF4444) : Colors.white.withOpacity(0.08)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _formStatus,
              dropdownColor: const Color(0xFF0F172A),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF22C55E)),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
              onChanged: (value) {
                setState(() {
                  _formStatus = value ?? _formStatus;
                  _errors['status'] = null;
                });
              },
            ),
          ),
        ),
        if (_errors['status'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _errors['status'] ?? '',
              style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
            ),
          ),
      ],
    );
  }

  Widget _hiredDateField() {
    final label = _hiredAt == null
        ? 'Date embauche'
        : '${_hiredAt!.day.toString().padLeft(2, '0')}/${_hiredAt!.month.toString().padLeft(2, '0')}/${_hiredAt!.year}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelWithRequired('Date embauche', false),
        const SizedBox(height: 6),
        InkWell(
          onTap: _pickHireDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: Color(0xFF22C55E), size: 16),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(color: _hiredAt == null ? Colors.white54 : Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickHireDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _hiredAt ?? DateTime(now.year - 1),
      firstDate: DateTime(1990),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF22C55E),
              surface: Color(0xFF0B1220),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0B1220),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      setState(() => _hiredAt = picked);
    }
  }

  Future<void> _saveStaff() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final role = _roleController.text.trim();
    final specialty = _specialtyController.text.trim();
    final service = _serviceController.text.trim();

    _errors['first'] = firstName.isEmpty ? 'Champ obligatoire' : null;
    _errors['last'] = lastName.isEmpty ? 'Champ obligatoire' : null;
    _errors['role'] = role.isEmpty ? 'Champ obligatoire' : null;
    _errors['specialty'] = specialty.isEmpty ? 'Champ obligatoire' : null;
    _errors['service'] = service.isEmpty ? 'Champ obligatoire' : null;
    _errors['status'] = _formStatus == null ? 'Champ obligatoire' : null;

    if (_errors.values.any((value) => value != null)) {
      setState(() {});
      return;
    }

    final now = DateTime.now();
    final staff = MedicalStaff(
      id: _editingStaff?.id ?? 'staff_${now.millisecondsSinceEpoch}',
      firstName: firstName,
      lastName: lastName,
      role: role,
      specialty: specialty,
      department: service,
      status: _formStatus ?? 'Disponible',
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      hiredAt: _hiredAt?.millisecondsSinceEpoch,
      createdAt: _editingStaff?.createdAt ?? now.millisecondsSinceEpoch,
      updatedAt: now.millisecondsSinceEpoch,
    );

    if (_editingStaff == null) {
      await _databaseService.insertPersonnel(staff);
      await _showStatusDialog('Personnel ajoute', 'Le membre a ete enregistre.');
    } else {
      await _databaseService.updatePersonnel(staff);
      await _showStatusDialog('Personnel mis a jour', 'Les informations ont ete mises a jour.');
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    _editingStaff = null;
    _loadStaff();
  }

  Future<void> _confirmDeleteStaff(MedicalStaff staff) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Supprimer personnel', style: TextStyle(color: Colors.white)),
          content: Text(
            'Confirmer la suppression de ${staff.fullName} ?',
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
      await _databaseService.deletePersonnel(staff.id);
      await _showStatusDialog('Personnel supprime', 'Le membre a ete supprime.');
      _loadStaff();
    }
  }

  Future<void> _openStaffDetails(MedicalStaff staff) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(staff.fullName, style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Role', staff.role),
              _detailRow('Specialite', staff.specialty),
              _detailRow('Service', staff.department),
              _detailRow('Statut', staff.status),
              _detailRow('Telephone', staff.phone),
              _detailRow('Email', staff.email),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer', style: TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
          ),
          Expanded(
            child: Text(value.isEmpty ? '--' : value, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _labelWithRequired(String label, bool required) {
    if (!required) {
      return Text(
        label,
        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600),
      );
    }
    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600),
        children: [
          TextSpan(text: label),
          const TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
        ],
      ),
    );
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
              child: const Text('OK', style: TextStyle(color: Color(0xFF22C55E))),
            ),
          ],
        );
      },
    );
  }
}

class _StaffCard extends StatefulWidget {
  final MedicalStaff member;
  final bool canEdit;
  final bool canDelete;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StaffCard({
    required this.member,
    required this.canEdit,
    required this.canDelete,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_StaffCard> createState() => _StaffCardState();
}

class _StaffCardState extends State<_StaffCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(widget.member.status);
    final initial = widget.member.fullName.isNotEmpty ? widget.member.fullName.substring(0, 1) : '?';
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _hovered ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.2),
              child: Text(
                initial,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.member.fullName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.member.specialty} · ${widget.member.department}',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _StatusBadge(label: widget.member.status, color: color),
            const SizedBox(width: 10),
            _ActionIcon(
              icon: Icons.visibility_outlined,
              color: const Color(0xFF22C55E),
              onTap: widget.onView,
              enabled: true,
            ),
            const SizedBox(width: 6),
            _ActionIcon(
              icon: Icons.edit_outlined,
              color: const Color(0xFF3B82F6),
              onTap: widget.onEdit,
              enabled: widget.canEdit,
            ),
            const SizedBox(width: 6),
            _ActionIcon(
              icon: Icons.delete_outline,
              color: const Color(0xFFEF4444),
              onTap: widget.onDelete,
              enabled: widget.canDelete,
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Disponible':
        return const Color(0xFF22C55E);
      case 'En consultation':
        return const Color(0xFFF59E0B);
      case 'En bloc':
        return const Color(0xFFEF4444);
      case 'En garde':
        return const Color(0xFF3B82F6);
      case 'En conge':
        return const Color(0xFF64748B);
      default:
        return Colors.white70;
    }
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
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
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StaffStats {
  final int total;
  final int available;
  final int inConsultation;
  final int onDuty;
  final int inTheatre;
  final int onLeave;
  final List<MapEntry<String, int>> topServices;

  const _StaffStats({
    required this.total,
    required this.available,
    required this.inConsultation,
    required this.onDuty,
    required this.inTheatre,
    required this.onLeave,
    required this.topServices,
  });
}

class _PlanRow extends StatelessWidget {
  final String label;
  final String detail;
  final Color color;

  const _PlanRow({required this.label, required this.detail, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          detail,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
        ),
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
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
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
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(label == 'Service' ? Icons.apartment : Icons.badge, size: 16, color: const Color(0xFF22C55E)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
          ),
          DropdownButton<String>(
            value: value,
            dropdownColor: const Color(0xFF1F2937),
            underline: const SizedBox.shrink(),
            style: const TextStyle(color: Colors.white, fontSize: 12),
            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF22C55E), size: 18),
            items: options
                .map((opt) => DropdownMenuItem(
                      value: opt,
                      child: Text(opt),
                    ))
                .toList(),
            onChanged: (val) => onChanged(val ?? value),
          ),
        ],
      ),
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
