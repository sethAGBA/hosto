import 'package:flutter/material.dart';
import '../widgets/permission_scope.dart';
import '../models/emergency_box.dart';
import '../models/emergency_visit.dart';
import '../services/database_service.dart';

class UrgencesScreen extends StatefulWidget {
  final Animation<double> fadeAnimation;

  const UrgencesScreen({super.key, required this.fadeAnimation});

  @override
  State<UrgencesScreen> createState() => _UrgencesScreenState();
}

class _UrgencesScreenState extends State<UrgencesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  String _filter = 'Tous';
  final DatabaseService _databaseService = DatabaseService();
  List<EmergencyVisit> _visits = [];
  List<EmergencyBox> _boxes = [];
  bool _loading = true;
  EmergencyVisit? _selectedVisit;

  final TextEditingController _patientController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _priority = 'Jaune';
  String _status = 'En attente';
  final Map<String, String?> _errors = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    _loadUrgences();
  }

  @override
  void dispose() {
    _patientController.dispose();
    _ageController.dispose();
    _reasonController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waiting = _visits.where((v) => v.status == 'En attente').toList();
    final filtered = waiting.where((v) {
      if (_filter == 'Tous') return true;
      return v.priority == _filter;
    }).toList();
    final stats = _buildStats(waiting);

    return FadeTransition(
      opacity: widget.fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildKpiRow(stats),
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
                  Expanded(flex: 6, child: _buildWaitingList(filtered)),
                  const SizedBox(width: 16),
                  Expanded(flex: 4, child: _buildBoxes()),
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
            gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service des urgences',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
            ),
            SizedBox(height: 2),
            Text(
              'Tri, prise en charge et orientation',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildKpiRow(_UrgenceStats stats) {
    return Row(
      children: [
        _StatCard(
          label: 'Patients en attente',
          value: '${stats.waitingCount}',
          icon: Icons.people_alt_rounded,
          color: const Color(0xFFEF4444),
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Temps attente moyen',
          value: '${stats.averageWait} min',
          icon: Icons.schedule_rounded,
          color: const Color(0xFFF59E0B),
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Boxes occupes',
          value: '${stats.occupiedBoxes}/${stats.totalBoxes}',
          icon: Icons.local_hospital_rounded,
          color: const Color(0xFF3B82F6),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        _FilterChip(
          label: 'Priorite',
          value: _filter,
          options: const ['Tous', 'Rouge', 'Orange', 'Jaune', 'Vert'],
          onChanged: (value) => setState(() => _filter = value),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildActionsRow() {
    final canEdit = PermissionScope.of(context).canEdit('Urgences');
    final canView = PermissionScope.of(context).canView('Urgences');
    final canDelete = PermissionScope.of(context).canDelete('Urgences');
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
            label: 'Nouvel arrivant',
            icon: Icons.add_circle_outline,
            color: const Color(0xFFEF4444),
            onTap: () => _openArrivalDialog(),
          ),
          canEdit,
        ),
        guard(
          _ActionButton(
            label: 'Modifier tri',
            icon: Icons.edit_note,
            color: const Color(0xFFF59E0B),
            onTap: _editSelected,
          ),
          canEdit,
        ),
        guard(
          _ActionButton(
            label: 'Appeler suivant',
            icon: Icons.campaign_outlined,
            color: const Color(0xFF0EA5A4),
            onTap: _callNextPatient,
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
        guard(
          _ActionButton(
            label: 'Exporter',
            icon: Icons.file_download_outlined,
            color: const Color(0xFF64748B),
            onTap: _showExportInfo,
          ),
          canView,
        ),
      ],
    );
  }

  Widget _buildWaitingList(List<EmergencyVisit> patients) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F2937), Color(0xFF111827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Salle d attente',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Text(
                  '${patients.length} patients',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFFEF4444)),
                    ),
                  )
                : patients.isEmpty
                ? Center(
                    child: Text(
                      'Aucun patient',
                      style: TextStyle(color: Colors.white.withOpacity(0.6)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: patients.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final patient = patients[index];
                      final wait = _formatWait(patient.arrivalAt);
                      final arrival = _formatTime(patient.arrivalAt);
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 300 + (index * 60)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 12 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: _WaitingCard(
                          selected: _selectedVisit?.id == patient.id,
                          onTap: () => setState(() => _selectedVisit = patient),
                          name: patient.patientName,
                          age: patient.age,
                          reason: patient.reason,
                          wait: wait,
                          arrival: arrival,
                          priority: patient.priority,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxes() {
    return Column(
      children: [
        _BoxesHeader(),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: _boxes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final box = _boxes[index];
              return _BoxCard(
                label: box.label,
                status: box.status,
                patient: box.patientName,
                priority: box.priority,
                onTap: () => _handleBoxTap(box),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _loadUrgences() async {
    setState(() => _loading = true);
    final visits = await _databaseService.getEmergencyVisits();
    final boxes = await _databaseService.getEmergencyBoxes();
    if (!mounted) return;
    setState(() {
      _visits = visits;
      _boxes = boxes;
      _loading = false;
    });
  }

  _UrgenceStats _buildStats(List<EmergencyVisit> waiting) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final waits = waiting
        .map((v) => ((now - v.arrivalAt) / 60000).round())
        .where((m) => m >= 0)
        .toList();
    final avg = waits.isEmpty ? 0 : (waits.reduce((a, b) => a + b) / waits.length).round();
    final occupied = _boxes.where((b) => !_isBoxAvailable(b.status)).length;
    return _UrgenceStats(
      waitingCount: waiting.length,
      averageWait: avg,
      occupiedBoxes: occupied,
      totalBoxes: _boxes.length,
    );
  }

  Future<void> _openArrivalDialog({EmergencyVisit? visit}) async {
    _errors.clear();
    _selectedVisit = visit;
    _patientController.text = visit?.patientName ?? '';
    _ageController.text = visit?.age.toString() ?? '';
    _reasonController.text = visit?.reason ?? '';
    _priority = visit?.priority ?? 'Jaune';
    _status = visit?.status ?? 'En attente';
    if (visit != null) {
      final date = DateTime.fromMillisecondsSinceEpoch(visit.arrivalAt);
      _selectedDate = DateTime(date.year, date.month, date.day);
      _selectedTime = TimeOfDay(hour: date.hour, minute: date.minute);
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.fromDateTime(DateTime.now());
    }

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
                    gradient: LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          visit == null ? 'Nouvel arrivant' : 'Modifier tri',
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
                          _field('Age', _ageController, key: 'age', keyboardType: TextInputType.number),
                        ]),
                        const SizedBox(height: 12),
                        _formRow([
                          _field('Motif', _reasonController, key: 'reason'),
                          _priorityDropdown(),
                        ]),
                        const SizedBox(height: 12),
                        _formRow([
                          _dateField(),
                          _timeField(),
                        ]),
                        const SizedBox(height: 12),
                        _statusDropdown(),
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
                        onPressed: _saveArrival,
                        icon: const Icon(Icons.save),
                        label: Text(visit == null ? 'Creer' : 'Enregistrer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
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

  Future<void> _saveArrival() async {
    final patient = _patientController.text.trim();
    final age = int.tryParse(_ageController.text.trim()) ?? 0;
    final reason = _reasonController.text.trim();

    _errors['patient'] = patient.isEmpty ? 'Champ obligatoire' : null;
    _errors['age'] = age <= 0 ? 'Champ obligatoire' : null;
    _errors['reason'] = reason.isEmpty ? 'Champ obligatoire' : null;
    _errors['priority'] = _priority.isEmpty ? 'Champ obligatoire' : null;
    _errors['status'] = _status.isEmpty ? 'Champ obligatoire' : null;
    _errors['date'] = _selectedDate == null ? 'Champ obligatoire' : null;
    _errors['time'] = _selectedTime == null ? 'Champ obligatoire' : null;

    if (_errors.values.any((value) => value != null)) {
      setState(() {});
      return;
    }

    final date = _selectedDate ?? DateTime.now();
    final time = _selectedTime ?? TimeOfDay.fromDateTime(DateTime.now());
    final arrival = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final now = DateTime.now();
    final visit = EmergencyVisit(
      id: _selectedVisit?.id ?? 'urg_${now.millisecondsSinceEpoch}',
      patientName: patient,
      age: age,
      reason: reason,
      priority: _priority,
      status: _status,
      arrivalAt: arrival.millisecondsSinceEpoch,
      boxLabel: _selectedVisit?.boxLabel,
      createdAt: _selectedVisit?.createdAt ?? now.millisecondsSinceEpoch,
      updatedAt: now.millisecondsSinceEpoch,
    );

    if (_selectedVisit == null) {
      await _databaseService.insertEmergencyVisit(visit);
      await _showStatusDialog('Arrivant ajoute', 'Le patient a ete enregistre.');
    } else {
      await _databaseService.updateEmergencyVisit(visit);
      await _showStatusDialog('Mise a jour', 'Le tri a ete mis a jour.');
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    _selectedVisit = null;
    _loadUrgences();
  }

  Future<void> _editSelected() async {
    if (_selectedVisit == null) {
      await _showStatusDialog('Selection requise', 'Selectionnez un patient.');
      return;
    }
    await _openArrivalDialog(visit: _selectedVisit);
  }

  Future<void> _callNextPatient() async {
    final waiting = _visits.where((v) => v.status == 'En attente').toList();
    if (waiting.isEmpty) {
      await _showStatusDialog('Aucun patient', 'Aucun patient en attente.');
      return;
    }
    final available = _boxes.where((b) => _isBoxAvailable(b.status)).toList();
    if (available.isEmpty) {
      await _showStatusDialog('Boxes pleins', 'Aucun box disponible.');
      return;
    }
    waiting.sort((a, b) {
      final prio = _priorityRank(a.priority).compareTo(_priorityRank(b.priority));
      if (prio != 0) return prio;
      return a.arrivalAt.compareTo(b.arrivalAt);
    });
    final next = waiting.first;
    final box = available.first;

    final updatedVisit = EmergencyVisit(
      id: next.id,
      patientName: next.patientName,
      age: next.age,
      reason: next.reason,
      priority: next.priority,
      status: 'En prise en charge',
      arrivalAt: next.arrivalAt,
      boxLabel: box.label,
      createdAt: next.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    final updatedBox = EmergencyBox(
      id: box.id,
      label: box.label,
      status: 'Occupe',
      patientName: next.patientName,
      priority: next.priority,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _databaseService.updateEmergencyVisit(updatedVisit);
    await _databaseService.updateEmergencyBox(updatedBox);
    _selectedVisit = updatedVisit;
    _loadUrgences();
    await _showStatusDialog('Appel patient', '${next.patientName} dirige vers ${box.label}.');
  }

  Future<void> _confirmDeleteSelected() async {
    if (_selectedVisit == null) {
      await _showStatusDialog('Selection requise', 'Selectionnez un patient.');
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Supprimer patient', style: TextStyle(color: Colors.white)),
          content: Text(
            'Confirmez la suppression du passage aux urgences.',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                await _databaseService.deleteEmergencyVisit(_selectedVisit!.id);
                _selectedVisit = null;
                if (!mounted) return;
                Navigator.of(context).pop();
                await _showStatusDialog('Supprime', 'Le patient a ete retire.');
                _loadUrgences();
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

  Future<void> _handleBoxTap(EmergencyBox box) async {
    if (_isBoxAvailable(box.status)) {
      await _showStatusDialog('Box libre', '${box.label} est disponible.');
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(box.label, style: const TextStyle(color: Colors.white)),
          content: Text(
            'Liberer le box pour un nouveau patient ?',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                final linked = _visits.where((v) => v.boxLabel == box.label && v.status == 'En prise en charge').toList();
                if (linked.isNotEmpty) {
                  final visit = linked.first;
                  final updatedVisit = EmergencyVisit(
                    id: visit.id,
                    patientName: visit.patientName,
                    age: visit.age,
                    reason: visit.reason,
                    priority: visit.priority,
                    status: 'Termine',
                    arrivalAt: visit.arrivalAt,
                    boxLabel: visit.boxLabel,
                    createdAt: visit.createdAt,
                    updatedAt: DateTime.now().millisecondsSinceEpoch,
                  );
                  await _databaseService.updateEmergencyVisit(updatedVisit);
                }
                final updatedBox = EmergencyBox(
                  id: box.id,
                  label: box.label,
                  status: 'Libre',
                  patientName: null,
                  priority: 'Vert',
                  updatedAt: DateTime.now().millisecondsSinceEpoch,
                );
                await _databaseService.updateEmergencyBox(updatedBox);
                if (!mounted) return;
                Navigator.of(context).pop();
                _loadUrgences();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Liberer'),
            ),
          ],
        );
      },
    );
  }

  bool _isBoxAvailable(String status) {
    final lower = status.toLowerCase();
    return lower.contains('libre') || lower.contains('disponible');
  }

  int _priorityRank(String priority) {
    switch (priority) {
      case 'Rouge':
        return 0;
      case 'Orange':
        return 1;
      case 'Jaune':
        return 2;
      case 'Vert':
        return 3;
      default:
        return 4;
    }
  }

  String _formatWait(int arrivalAt) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final minutes = ((now - arrivalAt) / 60000).round();
    return '${minutes < 0 ? 0 : minutes} min';
  }

  String _formatTime(int epoch) {
    if (epoch == 0) return '--:--';
    final date = DateTime.fromMillisecondsSinceEpoch(epoch);
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
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

  Widget _field(
    String label,
    TextEditingController controller, {
    String? key,
    TextInputType? keyboardType,
  }) {
    final error = key == null ? null : _errors[key];
    final required = key != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelWithRequired(label, required),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
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
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _priorityDropdown() {
    const options = ['Rouge', 'Orange', 'Jaune', 'Vert'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelWithRequired('Priorite', true),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _errors['priority'] != null ? const Color(0xFFEF4444) : Colors.white.withOpacity(0.08)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _priority,
              dropdownColor: const Color(0xFF0F172A),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFEF4444)),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
              onChanged: (value) => setState(() {
                _priority = value ?? _priority;
                _errors['priority'] = null;
              }),
            ),
          ),
        ),
        if (_errors['priority'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_errors['priority'] ?? '', style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11)),
          ),
      ],
    );
  }

  Widget _statusDropdown() {
    const options = ['En attente', 'En prise en charge', 'Termine'];
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
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFEF4444)),
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
                const Icon(Icons.calendar_today_outlined, color: Color(0xFFEF4444), size: 16),
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
                const Icon(Icons.access_time, color: Color(0xFFEF4444), size: 16),
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
              primary: Color(0xFFEF4444),
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
      initialTime: _selectedTime ?? TimeOfDay.fromDateTime(DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFEF4444),
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

  Future<void> _showExportInfo() async {
    await _showStatusDialog('Export', 'L export sera disponible bientot.');
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
              child: const Text('OK', style: TextStyle(color: Color(0xFFEF4444))),
            ),
          ],
        );
      },
    );
  }
}

class _UrgenceStats {
  final int waitingCount;
  final int averageWait;
  final int occupiedBoxes;
  final int totalBoxes;

  const _UrgenceStats({
    required this.waitingCount,
    required this.averageWait,
    required this.occupiedBoxes,
    required this.totalBoxes,
  });
}

class _BoxesHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: const Row(
        children: [
          Icon(Icons.meeting_room_rounded, color: Colors.white70, size: 18),
          SizedBox(width: 8),
          Text(
            'Boxes et dechocage',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _WaitingCard extends StatefulWidget {
  final String name;
  final int age;
  final String reason;
  final String wait;
  final String arrival;
  final String priority;
  final bool selected;
  final VoidCallback onTap;

  const _WaitingCard({
    required this.name,
    required this.age,
    required this.reason,
    required this.wait,
    required this.arrival,
    required this.priority,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_WaitingCard> createState() => _WaitingCardState();
}

class _WaitingCardState extends State<_WaitingCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(widget.priority);
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
            border: Border.all(color: widget.selected ? const Color(0xFFEF4444) : color.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.4), color.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    widget.name.substring(0, 1),
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.age} ans · ${widget.reason}',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _PriorityPill(label: widget.priority, color: color),
                  const SizedBox(height: 6),
                  Text(
                    'Attente ${widget.wait}',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                  ),
                  Text(
                    'Arrive ${widget.arrival}',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'Rouge':
        return const Color(0xFFEF4444);
      case 'Orange':
        return const Color(0xFFF59E0B);
      case 'Jaune':
        return const Color(0xFFFBBF24);
      case 'Vert':
        return const Color(0xFF22C55E);
      default:
        return Colors.white70;
    }
  }
}

class _BoxCard extends StatefulWidget {
  final String label;
  final String status;
  final String? patient;
  final String priority;
  final VoidCallback onTap;

  const _BoxCard({
    required this.label,
    required this.status,
    required this.patient,
    required this.priority,
    required this.onTap,
  });

  @override
  State<_BoxCard> createState() => _BoxCardState();
}

class _BoxCardState extends State<_BoxCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(widget.priority);
    final isAvailable = widget.status.toLowerCase().contains('libre') ||
        widget.status.toLowerCase().contains('disponible');
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hovered ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.meeting_room_rounded, color: color, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const Spacer(),
                  _StatusPill(
                    label: widget.status,
                    color: isAvailable ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.patient ?? 'Aucun patient',
                style: TextStyle(
                  color: widget.patient == null ? Colors.white.withOpacity(0.5) : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isAvailable ? 'Pret a recevoir' : 'En prise en charge',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'Rouge':
        return const Color(0xFFEF4444);
      case 'Orange':
        return const Color(0xFFF59E0B);
      case 'Jaune':
        return const Color(0xFFFBBF24);
      case 'Vert':
        return const Color(0xFF22C55E);
      default:
        return Colors.white70;
    }
  }
}

class _PriorityPill extends StatelessWidget {
  final String label;
  final Color color;

  const _PriorityPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1F2937), Color(0xFF111827)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                ),
              ],
            ),
          ],
        ),
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
          const Icon(Icons.filter_alt_rounded, size: 16, color: Color(0xFFEF4444)),
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
            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFEF4444), size: 18),
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
