import 'package:flutter/material.dart';
import '../widgets/permission_scope.dart';
import '../models/exam_analysis.dart';
import '../services/database_service.dart';

class ExamensScreen extends StatefulWidget {
  final Animation<double> fadeAnimation;

  const ExamensScreen({super.key, required this.fadeAnimation});

  @override
  State<ExamensScreen> createState() => _ExamensScreenState();
}

class _ExamensScreenState extends State<ExamensScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  String _tab = 'En attente';
  String _type = 'Tous';
  String _priority = 'Tous';
  String _query = '';
  final DatabaseService _databaseService = DatabaseService();
  List<ExamAnalysis> _exams = [];
  bool _loading = true;
  ExamAnalysis? _selectedExam;

  final TextEditingController _patientController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _status = 'En attente';
  String _priorityForm = 'Normal';
  final Map<String, String?> _errors = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    _loadExamAnalyses();
  }

  @override
  void dispose() {
    _patientController.dispose();
    _doctorController.dispose();
    _typeController.dispose();
    _resultController.dispose();
    _notesController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _exams.where((e) {
      final typeOk = _type == 'Tous' || e.examType == _type;
      final priorityOk = _priority == 'Tous' || e.priority == _priority;
      final tabOk = _tab == 'Tous' || e.status == _tab;
      final q = _query.trim().toLowerCase();
      final queryOk = q.isEmpty ||
          e.patientName.toLowerCase().contains(q) ||
          e.examType.toLowerCase().contains(q) ||
          e.priority.toLowerCase().contains(q) ||
          e.requesterName.toLowerCase().contains(q) ||
          e.id.toLowerCase().contains(q);
      return typeOk && priorityOk && tabOk && queryOk;
    }).toList();

    final stats = _buildStats(filtered);

    return FadeTransition(
      opacity: widget.fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildTabs(),
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
                  Expanded(flex: 7, child: _buildExamList(filtered)),
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
            gradient: const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0EA5E9).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.science_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Examens & laboratoire',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
            ),
            SizedBox(height: 2),
            Text(
              'Demande, realisation et resultats',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildTabs() {
    final tabs = ['En attente', 'En cours', 'Termine'];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: tabs.map((tab) {
        final isSelected = _tab == tab;
        return GestureDetector(
          onTap: () => setState(() => _tab = tab),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF0EA5E9).withOpacity(0.2) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? const Color(0xFF0EA5E9) : Colors.white.withOpacity(0.1)),
            ),
            child: Text(
              tab,
              style: TextStyle(
                color: isSelected ? const Color(0xFF0EA5E9) : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _FilterChip(
          label: 'Type',
          value: _type,
          options: const ['Tous', 'NFS', 'Radiologie', 'Scanner', 'Glycemie', 'IRM', 'ECG'],
          onChanged: (value) => setState(() => _type = value),
        ),
        _FilterChip(
          label: 'Priorite',
          value: _priority,
          options: const ['Tous', 'Routine', 'Normal', 'Urgent'],
          onChanged: (value) => setState(() => _priority = value),
        ),
        _SearchField(
          onChanged: (value) => setState(() => _query = value),
        ),
      ],
    );
  }

  Widget _buildActionsRow() {
    final canEdit = PermissionScope.of(context).canEdit('Examens');
    final canView = PermissionScope.of(context).canView('Examens');
    final canDelete = PermissionScope.of(context).canDelete('Examens');
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
            label: 'Programmer examen',
            icon: Icons.calendar_month,
            color: const Color(0xFF0EA5E9),
            onTap: _openExamDialog,
          ),
          canEdit,
        ),
        guard(
          _ActionButton(
            label: 'Saisir resultats',
            icon: Icons.edit_note,
            color: const Color(0xFF22C55E),
            onTap: _editSelected,
          ),
          canEdit,
        ),
        guard(
          _ActionButton(
            label: 'Valider',
            icon: Icons.verified_outlined,
            color: const Color(0xFFF59E0B),
            onTap: () => _updateSelectedStatus('Termine'),
          ),
          canEdit,
        ),
        guard(
          _ActionButton(
            label: 'Imprimer',
            icon: Icons.print_outlined,
            color: const Color(0xFF64748B),
            onTap: _showExportInfo,
          ),
          canView,
        ),
        guard(
          _ActionButton(
            label: 'Supprimer',
            icon: Icons.delete_outline,
            color: const Color(0xFF94A3B8),
            onTap: _confirmDelete,
          ),
          canDelete,
        ),
      ],
    );
  }

  Widget _buildExamList(List<ExamAnalysis> exams) {
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
                'Demandes d examens',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Text(
                '${exams.length} elements',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFF0EA5E9)),
                    ),
                  )
                : ListView.separated(
                    itemCount: exams.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final exam = exams[index];
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 300 + (index * 60)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 12 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: _ExamCard(
                          exam: exam,
                          selected: _selectedExam?.id == exam.id,
                          onTap: () => setState(() => _selectedExam = exam),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          _buildDetailPanel(_selectedExam),
        ],
      ),
    );
  }

  Widget _buildSidePanel(_ExamStats stats) {
    return Column(
      children: [
        _PanelCard(
          title: 'Statut du jour',
          child: Column(
            children: [
              _MetricRow(label: 'Examens', value: '${stats.total}', color: const Color(0xFF0EA5E9)),
              const SizedBox(height: 10),
              _MetricRow(label: 'En attente', value: '${stats.pending}', color: const Color(0xFFF59E0B)),
              const SizedBox(height: 10),
              _MetricRow(label: 'En cours', value: '${stats.running}', color: const Color(0xFF22C55E)),
              const SizedBox(height: 10),
              _MetricRow(label: 'Termines', value: '${stats.done}', color: const Color(0xFF6366F1)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _PanelCard(
          title: 'Workflow',
          child: Column(
            children: const [
              _StepRow(label: 'Demande', detail: 'Enregistrement', color: Color(0xFF0EA5E9)),
              SizedBox(height: 10),
              _StepRow(label: 'Realisation', detail: 'Prelevement', color: Color(0xFFF59E0B)),
              SizedBox(height: 10),
              _StepRow(label: 'Resultats', detail: 'Saisie', color: Color(0xFF22C55E)),
              SizedBox(height: 10),
              _StepRow(label: 'Validation', detail: 'Biologiste', color: Color(0xFF6366F1)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _PanelCard(
          title: 'Alertes laboratoire',
          child: Column(
            children: const [
              _AlertRow(label: 'Leucocytes eleves', detail: 'Kofi Amen', color: Color(0xFFEF4444)),
              SizedBox(height: 10),
              _AlertRow(label: 'Resultat critique', detail: 'Edem Togo', color: Color(0xFFF59E0B)),
              SizedBox(height: 10),
              _AlertRow(label: 'Validation en attente', detail: 'Ama Koffi', color: Color(0xFF3B82F6)),
            ],
          ),
        ),
      ],
    );
  }

  _ExamStats _buildStats(List<ExamAnalysis> exams) {
    int pending = 0;
    int running = 0;
    int done = 0;
    for (final exam in exams) {
      if (exam.status == 'En attente') pending += 1;
      if (exam.status == 'En cours') running += 1;
      if (exam.status == 'Termine') done += 1;
    }
    return _ExamStats(total: exams.length, pending: pending, running: running, done: done);
  }

  Widget _buildDetailPanel(ExamAnalysis? exam) {
    if (exam == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF94A3B8), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Selectionnez une demande pour voir les details.',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0B1220), Color(0xFF111827)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details examen',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 12),
          _DetailRow(label: 'Code', value: exam.id),
          _DetailRow(label: 'Patient', value: exam.patientName),
          _DetailRow(label: 'Medecin', value: exam.requesterName),
          _DetailRow(label: 'Type', value: exam.examType),
          _DetailRow(label: 'Priorite', value: exam.priority),
          _DetailRow(label: 'Horaire', value: _formatTime(exam.scheduledAt)),
        ],
      ),
    );
  }

  Future<void> _loadExamAnalyses() async {
    setState(() => _loading = true);
    final list = await _databaseService.getExamAnalyses();
    if (!mounted) return;
    setState(() {
      _exams = list;
      _loading = false;
    });
  }

  Future<void> _openExamDialog({ExamAnalysis? exam}) async {
    _errors.clear();
    _selectedExam = exam;
    _patientController.text = exam?.patientName ?? '';
    _doctorController.text = exam?.requesterName ?? '';
    _typeController.text = exam?.examType ?? '';
    _resultController.text = exam?.resultSummary ?? '';
    _notesController.text = exam?.notes ?? '';
    _status = exam?.status ?? 'En attente';
    _priorityForm = exam?.priority ?? 'Normal';
    if (exam != null) {
      final date = DateTime.fromMillisecondsSinceEpoch(exam.scheduledAt);
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
                    gradient: LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)]),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          exam == null ? 'Nouvel examen' : 'Modifier examen',
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
                          _field('Type examen', _typeController, key: 'type'),
                          _priorityDropdown(),
                        ]),
                        const SizedBox(height: 12),
                        _formRow([
                          _dateField(),
                          _timeField(),
                        ]),
                        const SizedBox(height: 12),
                        _statusDropdown(),
                        const SizedBox(height: 12),
                        _field('Resume resultat', _resultController, key: 'result'),
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
                        onPressed: _saveExam,
                        icon: const Icon(Icons.save),
                        label: Text(exam == null ? 'Creer' : 'Enregistrer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0EA5E9),
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
              borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 1.3),
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
              borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 1.3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _priorityDropdown() {
    const options = ['Routine', 'Normal', 'Urgent'];
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
              value: _priorityForm,
              dropdownColor: const Color(0xFF0F172A),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0EA5E9)),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
              onChanged: (value) => setState(() {
                _priorityForm = value ?? _priorityForm;
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
    const options = ['En attente', 'En cours', 'Termine', 'Annule'];
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
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0EA5E9)),
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
                const Icon(Icons.calendar_today_outlined, color: Color(0xFF0EA5E9), size: 16),
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
                const Icon(Icons.access_time, color: Color(0xFF0EA5E9), size: 16),
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
              primary: Color(0xFF0EA5E9),
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
              primary: Color(0xFF0EA5E9),
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

  Future<void> _saveExam() async {
    final patient = _patientController.text.trim();
    final doctor = _doctorController.text.trim();
    final type = _typeController.text.trim();
    final result = _resultController.text.trim();

    _errors['patient'] = patient.isEmpty ? 'Champ obligatoire' : null;
    _errors['doctor'] = doctor.isEmpty ? 'Champ obligatoire' : null;
    _errors['type'] = type.isEmpty ? 'Champ obligatoire' : null;
    _errors['priority'] = _priorityForm.isEmpty ? 'Champ obligatoire' : null;
    _errors['status'] = _status.isEmpty ? 'Champ obligatoire' : null;
    _errors['date'] = _selectedDate == null ? 'Champ obligatoire' : null;
    _errors['time'] = _selectedTime == null ? 'Champ obligatoire' : null;
    _errors['result'] = result.isEmpty ? 'Champ obligatoire' : null;

    if (_errors.values.any((value) => value != null)) {
      setState(() {});
      return;
    }

    final date = _selectedDate ?? DateTime.now();
    final time = _selectedTime ?? const TimeOfDay(hour: 9, minute: 0);
    final scheduled = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final now = DateTime.now();
    final exam = ExamAnalysis(
      id: _selectedExam?.id ?? 'exam_${now.millisecondsSinceEpoch}',
      patientName: patient,
      requesterName: doctor,
      examType: type,
      priority: _priorityForm,
      status: _status,
      scheduledAt: scheduled.millisecondsSinceEpoch,
      completedAt: _status == 'Termine' ? now.millisecondsSinceEpoch : _selectedExam?.completedAt,
      resultSummary: result,
      notes: _notesController.text.trim(),
      createdAt: _selectedExam?.createdAt ?? now.millisecondsSinceEpoch,
      updatedAt: now.millisecondsSinceEpoch,
    );

    if (_selectedExam == null) {
      await _databaseService.insertExamAnalysis(exam);
      await _showStatusDialog('Examen cree', 'La demande a ete ajoutee.');
    } else {
      await _databaseService.updateExamAnalysis(exam);
      await _showStatusDialog('Examen mis a jour', 'La demande a ete mise a jour.');
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    _selectedExam = null;
    _loadExamAnalyses();
  }

  Future<void> _editSelected() async {
    if (_selectedExam == null) {
      await _showStatusDialog('Selection requise', 'Selectionnez un examen.');
      return;
    }
    await _openExamDialog(exam: _selectedExam);
  }

  Future<void> _updateSelectedStatus(String status) async {
    if (_selectedExam == null) {
      await _showStatusDialog('Selection requise', 'Selectionnez un examen.');
      return;
    }
    final updated = ExamAnalysis(
      id: _selectedExam!.id,
      patientName: _selectedExam!.patientName,
      requesterName: _selectedExam!.requesterName,
      examType: _selectedExam!.examType,
      priority: _selectedExam!.priority,
      status: status,
      scheduledAt: _selectedExam!.scheduledAt,
      completedAt: status == 'Termine' ? DateTime.now().millisecondsSinceEpoch : _selectedExam!.completedAt,
      resultSummary: _selectedExam!.resultSummary,
      notes: _selectedExam!.notes,
      createdAt: _selectedExam!.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _databaseService.updateExamAnalysis(updated);
    _selectedExam = updated;
    _loadExamAnalyses();
    await _showStatusDialog('Statut mis a jour', 'L examen a ete mis a jour.');
  }

  Future<void> _confirmDelete() async {
    if (_selectedExam == null) {
      await _showStatusDialog('Selection requise', 'Selectionnez un examen.');
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Supprimer examen', style: TextStyle(color: Colors.white)),
          content: Text(
            'Confirmez la suppression de la demande.',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                await _databaseService.deleteExamAnalysis(_selectedExam!.id);
                _selectedExam = null;
                if (!mounted) return;
                Navigator.of(context).pop();
                await _showStatusDialog('Supprime', 'La demande a ete supprimee.');
                _loadExamAnalyses();
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

  Future<void> _showExportInfo() async {
    await _showStatusDialog('Impression', 'Le module impression sera disponible bientot.');
  }

  String _formatTime(int epoch) {
    if (epoch == 0) return '--:--';
    final date = DateTime.fromMillisecondsSinceEpoch(epoch);
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
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
              child: const Text('OK', style: TextStyle(color: Color(0xFF0EA5E9))),
            ),
          ],
        );
      },
    );
  }
}

class _ExamCard extends StatefulWidget {
  final ExamAnalysis exam;
  final bool selected;
  final VoidCallback onTap;

  const _ExamCard({required this.exam, required this.selected, required this.onTap});

  @override
  State<_ExamCard> createState() => _ExamCardState();
}

class _ExamCardState extends State<_ExamCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(widget.exam.status);
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
            border: Border.all(color: widget.selected ? const Color(0xFF0EA5E9) : color.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color.withOpacity(0.4), color.withOpacity(0.1)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _formatTime(widget.exam.scheduledAt),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.exam.patientName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.exam.examType} · ${widget.exam.priority}',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.exam.id,
                      style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 10),
                    ),
                  ],
                ),
              ),
              _StatusBadge(label: widget.exam.status, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'En attente':
        return const Color(0xFFF59E0B);
      case 'En cours':
        return const Color(0xFF0EA5E9);
      case 'Termine':
        return const Color(0xFF22C55E);
      case 'Annule':
        return const Color(0xFF94A3B8);
      default:
        return Colors.white70;
    }
  }

  String _formatTime(int epoch) {
    if (epoch == 0) return '--:--';
    final date = DateTime.fromMillisecondsSinceEpoch(epoch);
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
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

class _StepRow extends StatelessWidget {
  final String label;
  final String detail;
  final Color color;

  const _StepRow({required this.label, required this.detail, required this.color});

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
          Icon(label == 'Type' ? Icons.science_outlined : Icons.flag_outlined, size: 16, color: const Color(0xFF0EA5E9)),
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
            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0EA5E9), size: 18),
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

class _ExamStats {
  final int total;
  final int pending;
  final int running;
  final int done;

  const _ExamStats({required this.total, required this.pending, required this.running, required this.done});
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
        ),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchField({required this.onChanged});

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
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 12),
        decoration: const InputDecoration(
          hintText: 'Rechercher patient, code...',
          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          prefixIcon: Icon(Icons.search, color: Color(0xFF0EA5E9), size: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
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
