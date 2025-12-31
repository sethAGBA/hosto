import 'package:flutter/material.dart';

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

  final List<_StaffMember> _staff = const [
    _StaffMember('Dr Ada Mensah', 'Cardiologie', 'Disponible', 'Service cardio'),
    _StaffMember('Dr Kokou', 'Urgences', 'En consultation', 'Urgences'),
    _StaffMember('Dr Afi', 'Gynecologie', 'Disponible', 'Maternite'),
    _StaffMember('Dr Mensah', 'Chirurgie', 'En bloc', 'Chirurgie'),
    _StaffMember('Inf. Yawa', 'Soins intensifs', 'En garde', 'USI'),
    _StaffMember('Inf. Sena', 'Pediatrie', 'En conge', 'Pediatrie'),
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
    final filtered = _staff.where((m) {
      final serviceOk = _service == 'Tous' || m.service == _service;
      final specialtyOk = _specialty == 'Toutes' || m.specialty == _specialty;
      final statusOk = _status == 'Tous' || m.status == _status;
      return serviceOk && specialtyOk && statusOk;
    }).toList();

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
                  Expanded(flex: 6, child: _buildTeamList(filtered)),
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

  Widget _buildActionsRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _ActionButton(label: 'Ajouter personnel', icon: Icons.person_add, color: const Color(0xFF22C55E)),
        _ActionButton(label: 'Modifier planning', icon: Icons.calendar_month, color: const Color(0xFF3B82F6)),
        _ActionButton(label: 'Affecter patients', icon: Icons.assignment_ind, color: const Color(0xFFF59E0B)),
        _ActionButton(label: 'Gerer absences', icon: Icons.event_busy, color: const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _buildTeamList(List<_StaffMember> members) {
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
                  child: _StaffCard(member: member),
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
            children: const [
              _StatRow(label: 'Consultations/jour', value: '32', color: Color(0xFFF59E0B)),
              SizedBox(height: 10),
              _StatRow(label: 'Satisfaction', value: '87%', color: Color(0xFF22C55E)),
              SizedBox(height: 10),
              _StatRow(label: 'Interventions', value: '9', color: Color(0xFF6366F1)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StaffMember {
  final String name;
  final String specialty;
  final String status;
  final String service;

  const _StaffMember(this.name, this.specialty, this.status, this.service);
}

class _StaffCard extends StatefulWidget {
  final _StaffMember member;

  const _StaffCard({required this.member});

  @override
  State<_StaffCard> createState() => _StaffCardState();
}

class _StaffCardState extends State<_StaffCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(widget.member.status);
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
                widget.member.name.substring(0, 1),
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.member.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.member.specialty} · ${widget.member.service}',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _StatusBadge(label: widget.member.status, color: color),
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
