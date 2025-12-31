import 'package:flutter/material.dart';
import '../widgets/permission_scope.dart';
import '../models/consultation.dart';
import '../services/database_service.dart';

class ConsultationsScreen extends StatefulWidget {
  final Animation<double> fadeAnimation;

  const ConsultationsScreen({super.key, required this.fadeAnimation});

  @override
  State<ConsultationsScreen> createState() => _ConsultationsScreenState();
}

class _ConsultationsScreenState extends State<ConsultationsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  String _view = 'Semaine';
  String _doctor = 'Tous';
  final DatabaseService _databaseService = DatabaseService();
  List<Consultation> _appointments = [];
  bool _loading = true;
  Consultation? _selectedAppointment;

  final TextEditingController _patientController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _status = 'Confirme';
  final Map<String, String?> _errors = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    _loadConsultations();
  }

  @override
  void dispose() {
    _patientController.dispose();
    _doctorController.dispose();
    _reasonController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _appointments.where((appointment) {
      if (_doctor == 'Tous') return true;
      return appointment.doctorName == _doctor;
    }).where((appointment) {
      if (query.isEmpty) return true;
      return appointment.patientName.toLowerCase().contains(query) ||
          appointment.reason.toLowerCase().contains(query) ||
          appointment.location.toLowerCase().contains(query) ||
          appointment.doctorName.toLowerCase().contains(query);
    }).toList();
    final stats = _buildStats(filtered);
    return FadeTransition(
      opacity: widget.fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
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
                  Expanded(flex: 7, child: _buildAgenda(filtered)),
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
            gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.event_available_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consultations & agenda',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
            ),
            SizedBox(height: 2),
            Text(
              'Planification, suivi et rendez-vous',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildFilters() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        final filters = Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            _FilterChip(
              label: 'Medecin',
              value: _doctor,
              options: ['Tous', ..._doctorOptions()],
              onChanged: (value) => setState(() => _doctor = value),
            ),
            _FilterChip(
              label: 'Vue',
              value: _view,
              options: const ['Jour', 'Semaine', 'Mois'],
              onChanged: (value) => setState(() => _view = value),
            ),
            _SearchField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
            ),
          ],
        );
        final legends = Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _LegendBadge(label: 'Confirme', color: Color(0xFF22C55E)),
            _LegendBadge(label: 'En attente', color: Color(0xFFF59E0B)),
            _LegendBadge(label: 'Urgent', color: Color(0xFFEF4444)),
            _LegendBadge(label: 'Annule', color: Color(0xFF94A3B8)),
          ],
        );
        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              filters,
              const SizedBox(height: 10),
              legends,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: filters),
            const SizedBox(width: 16),
            legends,
          ],
        );
      },
    );
  }

  Widget _buildActionsRow() {
    final canEdit = PermissionScope.of(context).canEdit('Consultations');
    final canView = PermissionScope.of(context).canView('Consultations');
    final canDelete = PermissionScope.of(context).canDelete('Consultations');
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
            label: 'Nouveau RDV',
            icon: Icons.add_circle_outline,
            color: const Color(0xFFF59E0B),
            onTap: () => _openAppointmentDialog(),
          ),
          canEdit,
        ),
        guard(
          _ActionButton(
            label: 'Exporter',
            icon: Icons.file_download_outlined,
            color: const Color(0xFF64748B),
            onTap: _showPlaceholderExport,
          ),
          canView,
        ),
        guard(
          _ActionButton(
            label: 'Reprogrammer',
            icon: Icons.event_repeat,
            color: const Color(0xFF3B82F6),
            onTap: _reprogramSelected,
          ),
          canEdit,
        ),
        guard(
          _ActionButton(
            label: 'Annuler RDV',
            icon: Icons.cancel_outlined,
            color: const Color(0xFFEF4444),
            onTap: () => _updateSelectedStatus('Annule'),
          ),
          canEdit,
        ),
        guard(
          _ActionButton(
            label: 'Confirmer presence',
            icon: Icons.check_circle_outline,
            color: const Color(0xFF22C55E),
            onTap: () => _updateSelectedStatus('Confirme'),
          ),
          canEdit,
        ),
        guard(
          _ActionButton(
            label: 'Supprimer',
            icon: Icons.delete_outline,
            color: const Color(0xFF94A3B8),
            onTap: _confirmDeleteSelected,
          ),
          canDelete,
        ),
      ],
    );
  }

  Widget _buildAgenda(List<Consultation> appointments) {
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
                'Agenda medical',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Text(
                _agendaLabel(),
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFFF59E0B)),
                    ),
                  )
                : ListView.separated(
                    itemCount: appointments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 300 + (index * 60)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 12 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: _AgendaTile(
                          appointment: appointment,
                          selected: _selectedAppointment?.id == appointment.id,
                          onTap: () => setState(() => _selectedAppointment = appointment),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidePanel(_ConsultationStats stats) {
    return Column(
      children: [
        _PanelCard(
          title: 'Statut du jour',
          child: Column(
            children: [
              _StatusRow(label: 'Consultations', value: '${stats.total}', color: Color(0xFFF59E0B)),
              const SizedBox(height: 10),
              _StatusRow(label: 'En attente', value: '${stats.pending}', color: Color(0xFFEF4444)),
              const SizedBox(height: 10),
              _StatusRow(label: 'Terminees', value: '${stats.done}', color: Color(0xFF22C55E)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _PanelCard(
          title: 'Rappels automatiques',
          child: Column(
            children: const [
              _AlertRow(label: 'RDV 10:00', detail: 'SMS envoye', color: Color(0xFF22C55E)),
              SizedBox(height: 10),
              _AlertRow(label: 'RDV 14:00', detail: 'Rappel en attente', color: Color(0xFFF59E0B)),
              SizedBox(height: 10),
              _AlertRow(label: 'RDV 15:00', detail: 'Email envoye', color: Color(0xFF3B82F6)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const SizedBox.shrink(),
      ],
    );
  }

  List<String> _doctorOptions() {
    final doctors = _appointments.map((a) => a.doctorName).where((d) => d.isNotEmpty).toSet().toList();
    doctors.sort();
    if (doctors.isEmpty) {
      return ['Dr Ada Mensah', 'Dr Kokou', 'Dr Afi'];
    }
    return doctors;
  }

  _ConsultationStats _buildStats(List<Consultation> list) {
    int pending = 0;
    int done = 0;
    for (final item in list) {
      if (item.status == 'En attente') {
        pending += 1;
      }
      if (item.status == 'Termine') {
        done += 1;
      }
    }
    return _ConsultationStats(total: list.length, pending: pending, done: done);
  }

  Future<void> _loadConsultations() async {
    setState(() => _loading = true);
    final list = await _databaseService.getConsultations();
    if (!mounted) return;
    setState(() {
      _appointments = list;
      _loading = false;
    });
  }

  Future<void> _openAppointmentDialog({Consultation? consultation}) async {
    _errors.clear();
    _selectedAppointment = consultation;
    _patientController.text = consultation?.patientName ?? '';
    _doctorController.text = consultation?.doctorName ?? '';
    _reasonController.text = consultation?.reason ?? '';
    _locationController.text = consultation?.location ?? '';
    _notesController.text = consultation?.notes ?? '';
    _status = consultation?.status ?? 'Confirme';
    if (consultation != null) {
      final date = DateTime.fromMillisecondsSinceEpoch(consultation.scheduledAt);
      _selectedDate = DateTime(date.year, date.month, date.day);
      _selectedTime = TimeOfDay(hour: date.hour, minute: date.minute);
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = const TimeOfDay(hour: 9, minute: 0);
    }

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
                    gradient: LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          consultation == null ? 'Nouveau RDV' : 'Modifier RDV',
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
                          _field('Patient', _patientController, key: 'patient'),
                          _field('Medecin', _doctorController, key: 'doctor'),
                        ]),
                        const SizedBox(height: 12),
                        _formRow([
                          _dateField(),
                          _timeField(),
                        ]),
                        const SizedBox(height: 12),
                        _formRow([
                          _field('Motif', _reasonController, key: 'reason'),
                          _field('Lieu', _locationController, key: 'location'),
                        ]),
                        const SizedBox(height: 12),
                        _statusDropdown(),
                        const SizedBox(height: 12),
                        _notesField(),
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
                        onPressed: _saveConsultation,
                        icon: const Icon(Icons.save),
                        label: Text(consultation == null ? 'Creer' : 'Enregistrer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
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
    final required = key != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelWithRequired(label, required),
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
              borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 1.3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _notesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelWithRequired('Notes', false),
        const SizedBox(height: 6),
        TextField(
          controller: _notesController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: InputDecoration(
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
              borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 1.3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusDropdown() {
    const options = ['Confirme', 'En attente', 'Urgent', 'Annule', 'Termine'];
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
              value: _status,
              dropdownColor: const Color(0xFF0F172A),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFF59E0B)),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
              onChanged: (value) => setState(() {
                _status = value ?? _status;
                _errors['status'] = null;
              }),
            ),
          ),
        ),
        if (_errors['status'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_errors['status'] ?? '', style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11)),
          ),
      ],
    );
  }

  Widget _dateField() {
    final label = _selectedDate == null
        ? 'Date'
        : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelWithRequired('Date', true),
        const SizedBox(height: 6),
        InkWell(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _errors['date'] != null ? const Color(0xFFEF4444) : Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: Color(0xFFF59E0B), size: 16),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(color: _selectedDate == null ? Colors.white54 : Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ),
        if (_errors['date'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_errors['date'] ?? '', style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11)),
          ),
      ],
    );
  }

  Widget _timeField() {
    final label = _selectedTime == null
        ? 'Heure'
        : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelWithRequired('Heure', true),
        const SizedBox(height: 6),
        InkWell(
          onTap: _pickTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _errors['time'] != null ? const Color(0xFFEF4444) : Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Color(0xFFF59E0B), size: 16),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(color: _selectedTime == null ? Colors.white54 : Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ),
        if (_errors['time'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_errors['time'] ?? '', style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11)),
          ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFF59E0B),
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
      setState(() {
        _selectedDate = picked;
        _errors['date'] = null;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFF59E0B),
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
      setState(() {
        _selectedTime = picked;
        _errors['time'] = null;
      });
    }
  }

  Future<void> _saveConsultation() async {
    final patient = _patientController.text.trim();
    final doctor = _doctorController.text.trim();
    final reason = _reasonController.text.trim();
    final location = _locationController.text.trim();

    _errors['patient'] = patient.isEmpty ? 'Champ obligatoire' : null;
    _errors['doctor'] = doctor.isEmpty ? 'Champ obligatoire' : null;
    _errors['reason'] = reason.isEmpty ? 'Champ obligatoire' : null;
    _errors['location'] = location.isEmpty ? 'Champ obligatoire' : null;
    _errors['date'] = _selectedDate == null ? 'Champ obligatoire' : null;
    _errors['time'] = _selectedTime == null ? 'Champ obligatoire' : null;
    _errors['status'] = _status.isEmpty ? 'Champ obligatoire' : null;

    if (_errors.values.any((value) => value != null)) {
      setState(() {});
      return;
    }

    final date = _selectedDate ?? DateTime.now();
    final time = _selectedTime ?? const TimeOfDay(hour: 9, minute: 0);
    final scheduled = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final now = DateTime.now();
    final consultation = Consultation(
      id: _selectedAppointment?.id ?? 'cons_${now.millisecondsSinceEpoch}',
      patientName: patient,
      doctorName: doctor,
      reason: reason,
      status: _status,
      location: location,
      scheduledAt: scheduled.millisecondsSinceEpoch,
      notes: _notesController.text.trim(),
      createdAt: _selectedAppointment?.createdAt ?? now.millisecondsSinceEpoch,
      updatedAt: now.millisecondsSinceEpoch,
    );

    if (_selectedAppointment == null) {
      await _databaseService.insertConsultation(consultation);
      await _showStatusDialog('RDV cree', 'La consultation a ete ajoutee.');
    } else {
      await _databaseService.updateConsultation(consultation);
      await _showStatusDialog('RDV mis a jour', 'La consultation a ete mise a jour.');
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    _selectedAppointment = null;
    _loadConsultations();
  }

  Future<void> _reprogramSelected() async {
    if (_selectedAppointment == null) {
      await _showStatusDialog('Selection requise', 'Selectionnez une consultation.');
      return;
    }
    await _openAppointmentDialog(consultation: _selectedAppointment);
  }

  Future<void> _updateSelectedStatus(String status) async {
    if (_selectedAppointment == null) {
      await _showStatusDialog('Selection requise', 'Selectionnez une consultation.');
      return;
    }
    final updated = Consultation(
      id: _selectedAppointment!.id,
      patientName: _selectedAppointment!.patientName,
      doctorName: _selectedAppointment!.doctorName,
      reason: _selectedAppointment!.reason,
      status: status,
      location: _selectedAppointment!.location,
      scheduledAt: _selectedAppointment!.scheduledAt,
      notes: _selectedAppointment!.notes,
      createdAt: _selectedAppointment!.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _databaseService.updateConsultation(updated);
    _selectedAppointment = updated;
    _loadConsultations();
    await _showStatusDialog('Statut mis a jour', 'La consultation a ete mise a jour.');
  }

  Future<void> _confirmDeleteSelected() async {
    if (_selectedAppointment == null) {
      await _showStatusDialog('Selection requise', 'Selectionnez une consultation.');
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Supprimer la consultation', style: TextStyle(color: Colors.white)),
          content: Text(
            'Cette action est irreversible. Voulez-vous continuer ?',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                await _databaseService.deleteConsultation(_selectedAppointment!.id);
                _selectedAppointment = null;
                if (!mounted) return;
                Navigator.of(context).pop();
                await _showStatusDialog('Supprime', 'La consultation a ete supprimee.');
                _loadConsultations();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _showPlaceholderExport() {
    _showStatusDialog('Export', 'L export sera disponible bientot.');
  }

  String _agendaLabel() {
    final now = DateTime.now();
    final dateLabel =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    return 'Vue $_view · $dateLabel';
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
              child: const Text('OK', style: TextStyle(color: Color(0xFFF59E0B))),
            ),
          ],
        );
      },
    );
  }

  Widget _labelWithRequired(String label, bool required) {
    if (!required) {
      return Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600));
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
}

class _AgendaTile extends StatefulWidget {
  final Consultation appointment;
  final bool selected;
  final VoidCallback onTap;

  const _AgendaTile({required this.appointment, required this.selected, required this.onTap});

  @override
  State<_AgendaTile> createState() => _AgendaTileState();
}

class _AgendaTileState extends State<_AgendaTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(widget.appointment.status);
    final isPause = widget.appointment.status == 'Pause';
    final isFree = widget.appointment.status == 'Libre';
    final timeLabel = _formatTime(widget.appointment.scheduledAt);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _hovered ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.selected ? const Color(0xFFF59E0B) : color.withOpacity(0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color.withOpacity(0.4), color.withOpacity(0.1)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    timeLabel,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.appointment.patientName,
                      style: TextStyle(
                        color: Colors.white.withOpacity(isPause ? 0.5 : 1),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    if (widget.appointment.reason.isNotEmpty)
                      Text(
                        widget.appointment.reason,
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                      ),
                    if (widget.appointment.location.isNotEmpty)
                      Text(
                        widget.appointment.location,
                        style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 10),
                      ),
                  ],
                ),
              ),
              _StatusBadge(label: widget.appointment.status, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Urgent':
        return const Color(0xFFEF4444);
      case 'En attente':
        return const Color(0xFFF59E0B);
      case 'Confirme':
        return const Color(0xFF22C55E);
      case 'Annule':
        return const Color(0xFF94A3B8);
      case 'Termine':
        return const Color(0xFF14B8A6);
      case 'Pause':
        return const Color(0xFF64748B);
      case 'Libre':
        return const Color(0xFF3B82F6);
      default:
        return Colors.white70;
    }
  }

  String _formatTime(int epoch) {
    if (epoch == 0) return '--:--';
    final date = DateTime.fromMillisecondsSinceEpoch(epoch);
    final hour = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$hour:$min';
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
        label.toUpperCase(),
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

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatusRow({required this.label, required this.value, required this.color});

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

class _AlertRow extends StatelessWidget {
  final String label;
  final String detail;
  final Color color;

  const _AlertRow({required this.label, required this.detail, required this.color});

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

class _LegendBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
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
          Icon(label == 'Medecin' ? Icons.medical_services : Icons.view_agenda, size: 16, color: const Color(0xFFF59E0B)),
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
            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFF59E0B), size: 18),
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

class _ConsultationStats {
  final int total;
  final int pending;
  final int done;

  const _ConsultationStats({required this.total, required this.pending, required this.done});
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 300),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 12),
        decoration: const InputDecoration(
          hintText: 'Rechercher patient, medecin...',
          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          prefixIcon: Icon(Icons.search, color: Color(0xFFF59E0B), size: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}
