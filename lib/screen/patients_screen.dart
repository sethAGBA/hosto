import 'package:flutter/material.dart';

import '../models/patient.dart';
import '../services/database_service.dart';
import '../widgets/permission_scope.dart';

class PatientsScreen extends StatefulWidget {
  final Animation<double> fadeAnimation;

  const PatientsScreen({super.key, required this.fadeAnimation});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  String _search = '';
  String _filterService = 'Tous';
  String _filterStatus = 'Tous';
  final DatabaseService _databaseService = DatabaseService();
  List<Patient> _patients = [];
  bool _loading = true;
  Patient? _editingPatient;
  final Map<String, String?> _fieldErrors = {};

  final TextEditingController _dossierController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _insuranceController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bloodGroupController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _emergencyController = TextEditingController();
  DateTime? _dobValue;
  String _sexValue = 'M';
  String _statusValue = 'Stable';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    _loadPatients();
  }

  @override
  void dispose() {
    _dossierController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _roomController.dispose();
    _doctorController.dispose();
    _serviceController.dispose();
    _insuranceController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bloodGroupController.dispose();
    _allergiesController.dispose();
    _emergencyController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    setState(() => _loading = true);
    final refreshed = await _databaseService.getPatients();
    if (!mounted) return;
    setState(() {
      _patients = refreshed;
      _loading = false;
    });
  }

  String _ageLabel(int? dateOfBirth) {
    if (dateOfBirth == null) return '—';
    final dob = DateTime.fromMillisecondsSinceEpoch(dateOfBirth);
    final age = (DateTime.now().difference(dob).inDays / 365.25).floor();
    return age > 0 ? age.toString() : '—';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _patients.where((p) {
      final fullName = p.fullName.toLowerCase();
      final dossierNumber = p.dossierNumber.toLowerCase();
      final doctor = p.doctor.toLowerCase();
      final matchesSearch = _search.isEmpty ||
          fullName.contains(_search) ||
          dossierNumber.contains(_search) ||
          doctor.contains(_search);
      final matchesService = _filterService == 'Tous' || p.service == _filterService;
      final matchesStatus = _filterStatus == 'Tous' || p.status == _filterStatus;
      return matchesSearch && matchesService && matchesStatus;
    }).toList();

    return FadeTransition(
      opacity: widget.fadeAnimation,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompactHeight = constraints.maxHeight < 700;
          if (isCompactHeight) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildStatsBar(filtered.length),
                  const SizedBox(height: 20),
                  _buildFilters(),
                  const SizedBox(height: 12),
                  _buildActionsRow(),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 520,
                    child: FadeTransition(
                      opacity: _fade,
                      child: _buildTable(filtered),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildStatsBar(filtered.length),
              const SizedBox(height: 20),
              _buildFilters(),
              const SizedBox(height: 12),
              _buildActionsRow(),
              const SizedBox(height: 20),
              Expanded(
                child: FadeTransition(
                  opacity: _fade,
                  child: _buildTable(filtered),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0EA5A4), Color(0xFF14B8A6)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0EA5A4).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registre des patients',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Gestion et suivi des admissions',
                        style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: isCompact ? constraints.maxWidth : 340,
                  child: TextField(
                    onChanged: (value) => setState(() => _search = value.trim().toLowerCase()),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Rechercher par nom, dossier, médecin...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0EA5A4), size: 22),
                      suffixIcon: _search.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, color: Colors.white54, size: 18),
                              onPressed: () => setState(() => _search = ''),
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFF1F2937),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF0EA5A4), width: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsBar(int filteredCount) {
    final stats = [
      {'label': 'Total patients', 'value': '${_patients.length}', 'icon': Icons.people, 'color': Color(0xFF3B82F6)},
      {'label': 'Affichés', 'value': '$filteredCount', 'icon': Icons.filter_alt, 'color': Color(0xFF0EA5A4)},
      {'label': 'Critiques', 'value': '${_patients.where((p) => p.status == 'Critique').length}', 'icon': Icons.warning_amber_rounded, 'color': Color(0xFFEF4444)},
      {'label': 'Stables', 'value': '${_patients.where((p) => p.status == 'Stable').length}', 'icon': Icons.check_circle, 'color': Color(0xFF22C55E)},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        final cards = stats.map((stat) {
          return SizedBox(
            width: isCompact ? 220 : null,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F2937), Color(0xFF111827)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: (stat['color'] as Color).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (stat['color'] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stat['value'] as String,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        stat['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList();

        if (isCompact) {
          return Column(
            children: cards
                .map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(width: constraints.maxWidth, child: card),
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: cards
              .map(
                (card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: card,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildFilters() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        final filterRow = Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _FilterChip(
              label: 'Service',
              value: _filterService,
              options: const ['Tous', 'Medecine interne', 'Gynecologie', 'Reanimation', 'Consultation', 'Cardiologie'],
              onChanged: (value) => setState(() => _filterService = value),
            ),
            _FilterChip(
              label: 'Statut',
              value: _filterStatus,
              options: const ['Tous', 'Stable', 'Suivi', 'Critique', 'Externe'],
              onChanged: (value) => setState(() => _filterStatus = value),
            ),
            if (_filterService != 'Tous' || _filterStatus != 'Tous')
              _ActionChip(
                label: 'Réinitialiser',
                icon: Icons.refresh_rounded,
                onTap: () => setState(() {
                  _filterService = 'Tous';
                  _filterStatus = 'Tous';
                }),
                color: const Color(0xFFEF4444),
              ),
          ],
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              filterRow,
            ],
          );
        }

        return Row(
          children: [
            filterRow,
          ],
        );
      },
    );
  }

  Widget _buildActionsRow() {
    final canEdit = PermissionScope.of(context).canEdit('Patients');
    final canView = PermissionScope.of(context).canView('Patients');
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
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0EA5A4), Color(0xFF14B8A6)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0EA5A4).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: canEdit ? () => _openAdmissionDialog() : null,
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text('Nouvelle admission', style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          canEdit,
        ),
        guard(_ActionChip(label: 'Exporter', icon: Icons.file_download_outlined, onTap: () {}), canView),
        guard(_ActionChip(label: 'Attestations', icon: Icons.description_outlined, onTap: () {}), canView),
        guard(_ActionChip(label: 'Transfert', icon: Icons.swap_horiz_rounded, onTap: () {}), canEdit),
        guard(_ActionChip(label: 'Imprimer', icon: Icons.print_outlined, onTap: () {}), canView),
      ],
    );
  }

  Future<void> _openAdmissionDialog({Patient? patient}) async {
    if (patient == null) {
      _clearAdmissionForm();
      _editingPatient = null;
    } else {
      _fillAdmissionForm(patient);
      _editingPatient = patient;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isEditing = _editingPatient != null;
        return Dialog(
          backgroundColor: const Color(0xFF0B1220),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640, maxHeight: 760),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF0EA5A4), Color(0xFF14B8A6)]),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          isEditing ? 'Modifier patient' : 'Nouvelle admission',
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
                          _buildField(
                            'N° dossier',
                            _dossierController,
                            fieldKey: 'dossier',
                            hint: '00148',
                            required: true,
                          ),
                          _buildDateField(),
                        ]),
                        const SizedBox(height: 12),
                        _formRow([
                          _buildField(
                            'Prénom',
                            _firstNameController,
                            fieldKey: 'firstName',
                            hint: 'Afi',
                            required: true,
                          ),
                          _buildField(
                            'Nom',
                            _lastNameController,
                            fieldKey: 'lastName',
                            hint: 'Mensah',
                            required: true,
                          ),
                        ]),
                        const SizedBox(height: 12),
                        _formRow([
                          _buildDropdownField('Sexe', _sexValue, const ['M', 'F'], (value) {
                            setState(() => _sexValue = value);
                          }),
                          _buildDropdownField(
                            'Statut',
                            _statusValue,
                            const ['Stable', 'Suivi', 'Critique', 'Externe'],
                            (value) => setState(() => _statusValue = value),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        _formRow([
                          _buildField(
                            'Service',
                            _serviceController,
                            fieldKey: 'service',
                            hint: 'Cardiologie',
                            required: true,
                          ),
                          _buildField(
                            'Médecin',
                            _doctorController,
                            fieldKey: 'doctor',
                            hint: 'Dr Ada',
                            required: true,
                          ),
                        ]),
                        const SizedBox(height: 12),
                        _formRow([
                          _buildField('Chambre', _roomController, hint: '305-A'),
                          _buildField('Assurance', _insuranceController, hint: 'INAM'),
                        ]),
                        const SizedBox(height: 12),
                        _formRow([
                          _buildField('Téléphone', _phoneController, hint: '+228 90 00 00 00'),
                          _buildField('Adresse', _addressController, hint: 'Lomé'),
                        ]),
                        const SizedBox(height: 12),
                        _formRow([
                          _buildField('Groupe sanguin', _bloodGroupController, hint: 'O+'),
                          _buildField('Allergies', _allergiesController, hint: 'Aucune'),
                        ]),
                        const SizedBox(height: 12),
                        _buildField('Contact urgence', _emergencyController, hint: 'Famille / Tuteur'),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                    border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
                  ),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(foregroundColor: Colors.white70),
                        child: const Text('Annuler'),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _saveAdmission,
                        icon: const Icon(Icons.save),
                        label: Text(isEditing ? 'Enregistrer' : 'Créer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0EA5A4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

  Widget _formRow(List<Widget> fields) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;
        if (isCompact) {
          return Column(
            children: [
              for (int i = 0; i < fields.length; i++) ...[
                fields[i],
                if (i != fields.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (int i = 0; i < fields.length; i++) ...[
              Expanded(child: fields[i]),
              if (i != fields.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    String? hint,
    bool required = false,
    String? fieldKey,
  }) {
    final errorText = fieldKey == null ? null : _fieldErrors[fieldKey];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, required),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: fieldKey == null
              ? null
              : (_) {
                  if (_fieldErrors[fieldKey] != null) {
                    setState(() => _fieldErrors[fieldKey] = null);
                  }
                },
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
            filled: true,
            fillColor: const Color(0xFF111827),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0EA5A4), width: 1.5),
            ),
            errorText: errorText,
            errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, false),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: const Color(0xFF0F172A),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0EA5A4)),
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              items: options
                  .map((option) => DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      ))
                  .toList(),
              onChanged: (val) => onChanged(val ?? value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    final label = _dobValue == null
        ? 'Date de naissance'
        : '${_dobValue!.day.toString().padLeft(2, '0')}/${_dobValue!.month.toString().padLeft(2, '0')}/${_dobValue!.year}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Date de naissance', false),
        const SizedBox(height: 6),
        InkWell(
          onTap: _pickBirthDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: Color(0xFF0EA5A4), size: 16),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(color: _dobValue == null ? Colors.white.withOpacity(0.4) : Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dobValue ?? DateTime(now.year - 30),
      firstDate: DateTime(1920),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF0EA5A4),
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
      setState(() => _dobValue = picked);
    }
  }

  Widget _buildLabel(String label, bool required) {
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

  void _clearAdmissionForm() {
    _fieldErrors.clear();
    _dossierController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _roomController.clear();
    _doctorController.clear();
    _serviceController.clear();
    _insuranceController.clear();
    _phoneController.clear();
    _addressController.clear();
    _bloodGroupController.clear();
    _allergiesController.clear();
    _emergencyController.clear();
    _dobValue = null;
    _sexValue = 'M';
    _statusValue = 'Stable';
  }

  void _fillAdmissionForm(Patient patient) {
    _dossierController.text = patient.dossierNumber;
    _firstNameController.text = patient.firstName;
    _lastNameController.text = patient.lastName;
    _roomController.text = patient.room;
    _doctorController.text = patient.doctor;
    _serviceController.text = patient.service;
    _insuranceController.text = patient.insurance;
    _phoneController.text = patient.phone;
    _addressController.text = patient.address;
    _bloodGroupController.text = patient.bloodGroup;
    _allergiesController.text = patient.allergies;
    _emergencyController.text = patient.emergencyContact;
    _dobValue = patient.dateOfBirth != null ? DateTime.fromMillisecondsSinceEpoch(patient.dateOfBirth!) : null;
    _sexValue = patient.sex.isEmpty ? 'M' : patient.sex;
    _statusValue = patient.status.isEmpty ? 'Stable' : patient.status;
  }

  Future<void> _saveAdmission() async {
    final dossier = _dossierController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final service = _serviceController.text.trim();
    final doctor = _doctorController.text.trim();
    final room = _roomController.text.trim();
    final insurance = _insuranceController.text.trim();

    _fieldErrors['dossier'] = dossier.isEmpty ? 'Champ obligatoire' : null;
    _fieldErrors['firstName'] = firstName.isEmpty ? 'Champ obligatoire' : null;
    _fieldErrors['lastName'] = lastName.isEmpty ? 'Champ obligatoire' : null;
    _fieldErrors['service'] = service.isEmpty ? 'Champ obligatoire' : null;
    _fieldErrors['doctor'] = doctor.isEmpty ? 'Champ obligatoire' : null;

    if (_fieldErrors.values.any((error) => error != null)) {
      setState(() {});
      return;
    }

    final now = DateTime.now();
    final patient = Patient(
      id: _editingPatient?.id ?? 'pat_${now.millisecondsSinceEpoch}',
      dossierNumber: dossier,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: _dobValue?.millisecondsSinceEpoch,
      sex: _sexValue,
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      bloodGroup: _bloodGroupController.text.trim(),
      allergies: _allergiesController.text.trim(),
      emergencyContact: _emergencyController.text.trim(),
      status: _statusValue,
      room: room,
      doctor: doctor,
      service: service,
      insurance: insurance,
      createdAt: _editingPatient?.createdAt ?? now.millisecondsSinceEpoch,
      updatedAt: now.millisecondsSinceEpoch,
    );

    final wasEditing = _editingPatient != null;
    if (_editingPatient == null) {
      await _databaseService.insertPatient(patient);
    } else {
      await _databaseService.updatePatient(patient);
    }
    if (!mounted) return;
    _editingPatient = null;
    Navigator.of(context).pop();
    _loadPatients();
    await _showStatusDialog(
      title: wasEditing ? 'Patient mis à jour' : 'Patient ajouté',
      message: wasEditing
          ? 'Les informations du patient ont été mises à jour.'
          : 'Le patient a été enregistré avec succès.',
    );
  }

  

  Future<void> _openPatientDetails(Patient patient) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF0EA5A4), Color(0xFF14B8A6)]),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_search_rounded, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Dossier patient',
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
                      Text(
                        patient.fullName,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dossier #${patient.dossierNumber}',
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      _detailRow('Statut', patient.status),
                      _detailRow('Service', patient.service),
                      _detailRow('Médecin', patient.doctor),
                      _detailRow('Chambre', patient.room),
                      _detailRow('Assurance', patient.insurance),
                      _detailRow('Téléphone', patient.phone),
                      _detailRow('Adresse', patient.address),
                      _detailRow('Groupe sanguin', patient.bloodGroup),
                      _detailRow('Allergies', patient.allergies),
                      _detailRow('Contact urgence', patient.emergencyContact),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                    border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
                  ),
                  child: Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(foregroundColor: Colors.white70),
                        child: const Text('Fermer'),
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
            width: 140,
            child: Text(
              label,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeletePatient(Patient patient) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Supprimer le patient', style: TextStyle(color: Colors.white)),
          content: Text(
            'Confirmer la suppression de ${patient.fullName} ?',
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
      await _databaseService.deletePatient(patient.id);
      if (!mounted) return;
      _loadPatients();
      await _showStatusDialog(
        title: 'Patient supprimé',
        message: 'Le dossier a été supprimé avec succès.',
      );
    }
  }

  Future<void> _showStatusDialog({required String title, required String message}) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: Text(
            message,
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: Color(0xFF0EA5A4))),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTable(List<Patient> patients) {
    final content = Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: _TableHeaderRow(),
        ),
        Expanded(
          child: _loading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 44,
                        height: 44,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation(Color(0xFF0EA5A4)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Chargement des patients...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : patients.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Icon(Icons.search_off_rounded, size: 64, color: Colors.white.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun patient trouvé',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Essayez de modifier vos filtres',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: patients.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final patient = patients[index];
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 300 + (index * 50)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: _PatientRow(
                            patientId: patient.id,
                            dossierNumber: patient.dossierNumber,
                            name: patient.fullName,
                            age: _ageLabel(patient.dateOfBirth),
                            sex: patient.sex,
                            status: patient.status,
                            room: patient.room,
                            doctor: patient.doctor,
                            service: patient.service,
                            insurance: patient.insurance,
                            canEdit: PermissionScope.of(context).canEdit('Patients'),
                            canDelete: PermissionScope.of(context).canDelete('Patients'),
                            onView: () => _openPatientDetails(patient),
                            onEdit: () => _openAdmissionDialog(patient: patient),
                            onDelete: () => _confirmDeletePatient(patient),
                          ),
                        );
                      },
                    ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5A4).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF0EA5A4).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description_outlined, color: Color(0xFF0EA5A4), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Total: ${patients.length} patients',
                      style: const TextStyle(
                        color: Color(0xFF0EA5A4),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _ActionChip(label: 'Précédent', icon: Icons.chevron_left, onTap: () {}),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5A4).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '1',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              _ActionChip(label: 'Suivant', icon: Icons.chevron_right, onTap: () {}),
            ],
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        final body = Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1F2937), Color(0xFF111827)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: content,
        );

        if (!isCompact) {
          return body;
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: 900, child: body),
        );
      },
    );
  }
}

class _TableHeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HeaderCell('', 0.6),
        _HeaderCell('N° DOSSIER', 1.0),
        _HeaderCell('PATIENT', 1.8),
        _HeaderCell('AGE/SEXE', 0.9),
        _HeaderCell('STATUT', 1.1),
        _HeaderCell('CHAMBRE', 0.9),
        _HeaderCell('MÉDECIN', 1.3),
        _HeaderCell('ACTIONS', 1.0),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final double flex;

  const _HeaderCell(this.label, this.flex);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: (flex * 10).round(),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _PatientRow extends StatefulWidget {
  final String patientId;
  final String dossierNumber;
  final String name;
  final String age;
  final String sex;
  final String status;
  final String room;
  final String doctor;
  final String service;
  final String insurance;
  final bool canEdit;
  final bool canDelete;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PatientRow({
    required this.patientId,
    required this.dossierNumber,
    required this.name,
    required this.age,
    required this.sex,
    required this.status,
    required this.room,
    required this.doctor,
    required this.service,
    required this.insurance,
    required this.canEdit,
    required this.canDelete,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_PatientRow> createState() => _PatientRowState();
}

class _PatientRowState extends State<_PatientRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(widget.status);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: _hovered
              ? LinearGradient(
                  colors: [
                    const Color(0xFF0EA5A4).withOpacity(0.08),
                    Colors.white.withOpacity(0.04),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: _hovered ? null : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovered ? const Color(0xFF0EA5A4).withOpacity(0.3) : Colors.white.withOpacity(0.05),
            width: _hovered ? 2 : 1,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF0EA5A4).withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor.withOpacity(0.3), statusColor.withOpacity(0.15)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.4), width: 2),
                ),
                child: Center(
                  child: Text(
                    widget.name.substring(0, 1),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5A4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF0EA5A4).withOpacity(0.2)),
                ),
                  child: Text(
                    '#${widget.dossierNumber}',
                    style: const TextStyle(
                      color: Color(0xFF0EA5A4),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.local_hospital_rounded, size: 12, color: Colors.white.withOpacity(0.4)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.service,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 9,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.sex == 'M' ? Icons.male : Icons.female,
                      color: widget.sex == 'M' ? const Color(0xFF3B82F6) : const Color(0xFFEC4899),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.age} ans',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 11,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor.withOpacity(0.2), statusColor.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.4), width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 9,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bed_rounded, size: 12, color: Colors.white.withOpacity(0.6)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.room,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 13,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.doctor,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.health_and_safety_rounded, size: 11, color: Colors.white.withOpacity(0.4)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.insurance,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 10,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                    _IconButton(
                      icon: Icons.visibility_outlined,
                      color: const Color(0xFF0EA5A4),
                      tooltip: 'Voir',
                      onTap: widget.onView,
                    ),
                    const SizedBox(width: 6),
                    _IconButton(
                      icon: Icons.edit_outlined,
                      color: const Color(0xFF3B82F6),
                      tooltip: 'Modifier',
                      onTap: widget.canEdit ? widget.onEdit : null,
                      enabled: widget.canEdit,
                    ),
                    const SizedBox(width: 6),
                    _IconButton(
                      icon: Icons.delete_outline,
                      color: const Color(0xFFEF4444),
                      tooltip: 'Supprimer',
                      onTap: widget.canDelete ? widget.onDelete : null,
                      enabled: widget.canDelete,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Critique':
        return const Color(0xFFEF4444);
      case 'Stable':
        return const Color(0xFF22C55E);
      case 'Suivi':
        return const Color(0xFFF59E0B);
      case 'Externe':
        return const Color(0xFF3B82F6);
      default:
        return Colors.white70;
    }
  }
}

class _IconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;
  final bool enabled;

  const _IconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    this.onTap,
    this.enabled = true,
  });

  @override
  State<_IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<_IconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _hovered && widget.enabled ? widget.color.withOpacity(0.2) : widget.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered && widget.enabled ? widget.color.withOpacity(0.5) : widget.color.withOpacity(0.25),
              width: _hovered && widget.enabled ? 2 : 1,
            ),
          ),
          child: GestureDetector(
            onTap: widget.enabled ? widget.onTap : null,
            child: Opacity(
              opacity: widget.enabled ? 1 : 0.4,
              child: Icon(widget.icon, color: widget.color, size: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatefulWidget {
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
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: _hovered
              ? const LinearGradient(
                  colors: [Color(0xFF1F2937), Color(0xFF111827)],
                )
              : null,
          color: _hovered ? null : const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovered ? const Color(0xFF0EA5A4).withOpacity(0.4) : Colors.white.withOpacity(0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.label == 'Service' ? Icons.business_center : Icons.check_circle_outline,
              size: 16,
              color: const Color(0xFF0EA5A4),
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.label}: ',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            DropdownButton<String>(
              value: widget.value,
              dropdownColor: const Color(0xFF1F2937),
              underline: const SizedBox.shrink(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0EA5A4), size: 18),
              items: widget.options
                  .map((opt) => DropdownMenuItem(
                        value: opt,
                        child: Text(opt),
                      ))
                  .toList(),
              onChanged: (val) => widget.onChanged(val ?? widget.value),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final chipColor = widget.color ?? Colors.white70;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? chipColor.withOpacity(0.15) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered ? chipColor.withOpacity(0.4) : Colors.white.withOpacity(0.1),
              width: _hovered ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: chipColor, size: 16),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: _hovered ? Colors.white : Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
