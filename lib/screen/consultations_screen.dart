import 'package:flutter/material.dart';
import '../widgets/permission_scope.dart';

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
  String _doctor = 'Dr Ada Mensah';

  final List<_Appointment> _appointments = const [
    _Appointment('09:00', 'Kofi Edem', 'Controle post-op', 'Confirme', 'Salle 2'),
    _Appointment('10:00', 'Ama Sena', 'Consultation generale', 'En attente', 'Bureau 1'),
    _Appointment('11:00', 'Disponible', '', 'Libre', ''),
    _Appointment('12:00', 'Pause', '', 'Pause', ''),
    _Appointment('14:00', 'Edem Koku', 'Suivi diabete', 'Urgent', 'Bureau 3'),
    _Appointment('15:00', 'Sena Afi', 'Premiere visite', 'Confirme', 'Bureau 2'),
    _Appointment('16:00', 'Yawa Mensah', 'Resultats analyses', 'Confirme', 'Bureau 1'),
    _Appointment('17:00', 'Disponible', '', 'Libre', ''),
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
                  Expanded(flex: 7, child: _buildAgenda()),
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
    return Row(
      children: [
        _FilterChip(
          label: 'Medecin',
          value: _doctor,
          options: const ['Dr Ada Mensah', 'Dr Kokou', 'Dr Afi'],
          onChanged: (value) => setState(() => _doctor = value),
        ),
        const SizedBox(width: 12),
        _FilterChip(
          label: 'Vue',
          value: _view,
          options: const ['Jour', 'Semaine', 'Mois'],
          onChanged: (value) => setState(() => _view = value),
        ),
        const Spacer(),
        _LegendBadge(label: 'Confirme', color: const Color(0xFF22C55E)),
        const SizedBox(width: 8),
        _LegendBadge(label: 'En attente', color: const Color(0xFFF59E0B)),
        const SizedBox(width: 8),
        _LegendBadge(label: 'Urgent', color: const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _buildActionsRow() {
    final canEdit = PermissionScope.of(context).canEdit('Consultations');
    final canView = PermissionScope.of(context).canView('Consultations');
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
        guard(_ActionButton(label: 'Nouveau RDV', icon: Icons.add_circle_outline, color: const Color(0xFFF59E0B)), canEdit),
        guard(_ActionButton(label: 'Exporter', icon: Icons.file_download_outlined, color: const Color(0xFF64748B)), canView),
        guard(_ActionButton(label: 'Reprogrammer', icon: Icons.event_repeat, color: const Color(0xFF3B82F6)), canEdit),
        guard(_ActionButton(label: 'Annuler RDV', icon: Icons.cancel_outlined, color: const Color(0xFFEF4444)), canEdit),
        guard(_ActionButton(label: 'Confirmer presence', icon: Icons.check_circle_outline, color: const Color(0xFF22C55E)), canEdit),
      ],
    );
  }

  Widget _buildAgenda() {
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
                'Mercredi 31 Decembre 2024',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _appointments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final appointment = _appointments[index];
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 300 + (index * 60)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 12 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: _AgendaTile(appointment: appointment),
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
          title: 'Statut du jour',
          child: Column(
            children: const [
              _StatusRow(label: 'Consultations', value: '12', color: Color(0xFFF59E0B)),
              SizedBox(height: 10),
              _StatusRow(label: 'En attente', value: '3', color: Color(0xFFEF4444)),
              SizedBox(height: 10),
              _StatusRow(label: 'Terminees', value: '6', color: Color(0xFF22C55E)),
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
}

class _Appointment {
  final String time;
  final String patient;
  final String reason;
  final String status;
  final String location;

  const _Appointment(this.time, this.patient, this.reason, this.status, this.location);
}

class _AgendaTile extends StatefulWidget {
  final _Appointment appointment;

  const _AgendaTile({required this.appointment});

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
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _hovered ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.35)),
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
                  widget.appointment.time,
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
                    widget.appointment.patient,
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
            if (!isPause && !isFree)
              _StatusBadge(label: widget.appointment.status, color: color)
            else
              _StatusBadge(label: widget.appointment.status, color: color),
          ],
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
      case 'Pause':
        return const Color(0xFF64748B);
      case 'Libre':
        return const Color(0xFF3B82F6);
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
