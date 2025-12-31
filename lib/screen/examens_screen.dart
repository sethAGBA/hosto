import 'package:flutter/material.dart';

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

  final List<_Exam> _exams = const [
    _Exam('31/12', 'Kofi Amen', 'NFS', 'Urgent', 'En cours'),
    _Exam('31/12', 'Ama Koffi', 'Radiologie', 'Normal', 'En attente'),
    _Exam('31/12', 'Edem Togo', 'Scanner', 'Urgent', 'Termine'),
    _Exam('31/12', 'Sena Ablavi', 'Glycemie', 'Routine', 'En cours'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _exams.where((e) {
      final typeOk = _type == 'Tous' || e.type == _type;
      final priorityOk = _priority == 'Tous' || e.priority == _priority;
      final tabOk = _tab == 'Tous' || e.status == _tab;
      return typeOk && priorityOk && tabOk;
    }).toList();

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
                  Expanded(flex: 5, child: _buildSidePanel()),
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
          options: const ['Tous', 'NFS', 'Radiologie', 'Scanner', 'Glycemie'],
          onChanged: (value) => setState(() => _type = value),
        ),
        _FilterChip(
          label: 'Priorite',
          value: _priority,
          options: const ['Tous', 'Routine', 'Normal', 'Urgent'],
          onChanged: (value) => setState(() => _priority = value),
        ),
      ],
    );
  }

  Widget _buildActionsRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _ActionButton(label: 'Programmer examen', icon: Icons.calendar_month, color: const Color(0xFF0EA5E9)),
        _ActionButton(label: 'Saisir resultats', icon: Icons.edit_note, color: const Color(0xFF22C55E)),
        _ActionButton(label: 'Valider', icon: Icons.verified_outlined, color: const Color(0xFFF59E0B)),
        _ActionButton(label: 'Imprimer', icon: Icons.print_outlined, color: const Color(0xFF64748B)),
      ],
    );
  }

  Widget _buildExamList(List<_Exam> exams) {
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
            child: ListView.separated(
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
                  child: _ExamCard(exam: exam),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidePanel() {
    return Column(
      children: [
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
}

class _Exam {
  final String date;
  final String patient;
  final String type;
  final String priority;
  final String status;

  const _Exam(this.date, this.patient, this.type, this.priority, this.status);
}

class _ExamCard extends StatefulWidget {
  final _Exam exam;

  const _ExamCard({required this.exam});

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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color.withOpacity(0.4), color.withOpacity(0.1)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  widget.exam.date,
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
                    widget.exam.patient,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.exam.type} · ${widget.exam.priority}',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                  ),
                ],
              ),
            ),
            _StatusBadge(label: widget.exam.status, color: color),
          ],
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
      default:
        return Colors.white70;
    }
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

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _ActionButton({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: TextButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: color, size: 18),
        label: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ),
    );
  }
}
