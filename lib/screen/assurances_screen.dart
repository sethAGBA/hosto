import 'package:flutter/material.dart';

class AssurancesScreen extends StatefulWidget {
  final Animation<double> fadeAnimation;

  const AssurancesScreen({super.key, required this.fadeAnimation});

  @override
  State<AssurancesScreen> createState() => _AssurancesScreenState();
}

class _AssurancesScreenState extends State<AssurancesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  String _status = 'Tous';
  String _coverage = 'Tous';

  final List<_Convention> _conventions = const [
    _Convention('INAM', '70% actes', 'Actif', 'Plafond 1 500 000'),
    _Convention('CNSS', '60% actes', 'Actif', 'Plafond 900 000'),
    _Convention('Privee', '50% actes', 'Actif', 'Plafond 2 500 000'),
    _Convention('Mutuelle Sante', '80% actes', 'En revue', 'Plafond 1 200 000'),
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
    final filtered = _conventions.where((c) {
      final statusOk = _status == 'Tous' || c.status == _status;
      final coverageOk = _coverage == 'Tous' || c.coverage == _coverage;
      return statusOk && coverageOk;
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
                  Expanded(flex: 7, child: _buildConventionList(filtered)),
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
            gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assurances & conventions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
            ),
            SizedBox(height: 2),
            Text(
              'Couvertures, accords et teletransmission',
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
          label: 'Statut',
          value: _status,
          options: const ['Tous', 'Actif', 'En revue', 'Suspendu'],
          onChanged: (value) => setState(() => _status = value),
        ),
        _FilterChip(
          label: 'Couverture',
          value: _coverage,
          options: const ['Tous', '50% actes', '60% actes', '70% actes', '80% actes'],
          onChanged: (value) => setState(() => _coverage = value),
        ),
      ],
    );
  }

  Widget _buildActionsRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _ActionButton(label: 'Nouvelle convention', icon: Icons.add_circle_outline, color: const Color(0xFF3B82F6)),
        _ActionButton(label: 'Verifier droits', icon: Icons.check_circle_outline, color: const Color(0xFF22C55E)),
        _ActionButton(label: 'Teletransmettre', icon: Icons.send_outlined, color: const Color(0xFFF59E0B)),
        _ActionButton(label: 'Exporter', icon: Icons.file_download_outlined, color: const Color(0xFF64748B)),
      ],
    );
  }

  Widget _buildConventionList(List<_Convention> items) {
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
          const Text(
            'Conventions actives',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 300 + (index * 60)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 12 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: _ConventionCard(convention: item),
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
          title: 'Verification couverture',
          child: Column(
            children: const [
              _StatRow(label: 'Droits valides', value: '92%', color: Color(0xFF22C55E)),
              SizedBox(height: 10),
              _StatRow(label: 'Refus', value: '4%', color: Color(0xFFEF4444)),
              SizedBox(height: 10),
              _StatRow(label: 'En attente', value: '4%', color: Color(0xFFF59E0B)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _PanelCard(
          title: 'Alertes',
          child: Column(
            children: const [
              _AlertRow(label: 'CNSS', detail: 'Plafond atteint', color: Color(0xFFEF4444)),
              SizedBox(height: 10),
              _AlertRow(label: 'INAM', detail: 'Accord prealable', color: Color(0xFFF59E0B)),
              SizedBox(height: 10),
              _AlertRow(label: 'Mutuelle', detail: 'Convention en revue', color: Color(0xFF3B82F6)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Convention {
  final String name;
  final String coverage;
  final String status;
  final String plafond;

  const _Convention(this.name, this.coverage, this.status, this.plafond);
}

class _ConventionCard extends StatefulWidget {
  final _Convention convention;

  const _ConventionCard({required this.convention});

  @override
  State<_ConventionCard> createState() => _ConventionCardState();
}

class _ConventionCardState extends State<_ConventionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(widget.convention.status);
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
                  widget.convention.name,
                  textAlign: TextAlign.center,
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
                    widget.convention.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.convention.coverage} · ${widget.convention.plafond}',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                  ),
                ],
              ),
            ),
            _StatusBadge(label: widget.convention.status, color: color),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Actif':
        return const Color(0xFF22C55E);
      case 'En revue':
        return const Color(0xFFF59E0B);
      case 'Suspendu':
        return const Color(0xFFEF4444);
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
          Icon(label == 'Statut' ? Icons.flag_outlined : Icons.shield_outlined, size: 16, color: const Color(0xFF3B82F6)),
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
            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF3B82F6), size: 18),
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
