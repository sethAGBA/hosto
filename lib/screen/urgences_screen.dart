import 'package:flutter/material.dart';

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

  final List<Map<String, dynamic>> _patients = [
    {
      'name': 'Kofi Edem',
      'age': 35,
      'reason': 'Trauma',
      'wait': '10 min',
      'priority': 'Rouge',
      'arrival': '14:20',
    },
    {
      'name': 'Ama Sena',
      'age': 67,
      'reason': 'Douleur thorax',
      'wait': '25 min',
      'priority': 'Orange',
      'arrival': '14:05',
    },
    {
      'name': 'Edem Koku',
      'age': 28,
      'reason': 'Fievre',
      'wait': '40 min',
      'priority': 'Jaune',
      'arrival': '13:50',
    },
    {
      'name': 'Sena Afi',
      'age': 22,
      'reason': 'Entorse',
      'wait': '60 min',
      'priority': 'Vert',
      'arrival': '13:30',
    },
  ];

  final List<Map<String, dynamic>> _boxes = [
    {'label': 'Box 1', 'status': 'Occupe', 'patient': 'Ama Mensah', 'priority': 'Rouge'},
    {'label': 'Box 2', 'status': 'Libre', 'patient': null, 'priority': 'Vert'},
    {'label': 'Box 3', 'status': 'Occupe', 'patient': 'Yawa Koffi', 'priority': 'Jaune'},
    {'label': 'Dechocage', 'status': 'Disponible', 'patient': null, 'priority': 'Rouge'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
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
    final filtered = _patients.where((p) {
      if (_filter == 'Tous') return true;
      return p['priority'] == _filter;
    }).toList();

    return FadeTransition(
      opacity: widget.fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildKpiRow(),
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

  Widget _buildKpiRow() {
    return Row(
      children: [
        _StatCard(
          label: 'Patients en attente',
          value: '${_patients.length}',
          icon: Icons.people_alt_rounded,
          color: const Color(0xFFEF4444),
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Temps attente moyen',
          value: '45 min',
          icon: Icons.schedule_rounded,
          color: const Color(0xFFF59E0B),
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Boxes occupes',
          value: '2/4',
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
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _ActionButton(label: 'Nouvel arrivant', icon: Icons.add_circle_outline, color: const Color(0xFFEF4444)),
        _ActionButton(label: 'Appeler suivant', icon: Icons.campaign_outlined, color: const Color(0xFF0EA5A4)),
        _ActionButton(label: 'Exporter', icon: Icons.file_download_outlined, color: const Color(0xFF64748B)),
      ],
    );
  }

  Widget _buildWaitingList(List<Map<String, dynamic>> patients) {
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
            child: patients.isEmpty
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
                          name: patient['name'] as String,
                          age: patient['age'] as int,
                          reason: patient['reason'] as String,
                          wait: patient['wait'] as String,
                          arrival: patient['arrival'] as String,
                          priority: patient['priority'] as String,
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
                label: box['label'] as String,
                status: box['status'] as String,
                patient: box['patient'] as String?,
                priority: box['priority'] as String,
              );
            },
          ),
        ),
      ],
    );
  }
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

  const _WaitingCard({
    required this.name,
    required this.age,
    required this.reason,
    required this.wait,
    required this.arrival,
    required this.priority,
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

  const _BoxCard({
    required this.label,
    required this.status,
    required this.patient,
    required this.priority,
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
