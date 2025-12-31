import 'package:flutter/material.dart';
import '../widgets/permission_scope.dart';

class ChambresScreen extends StatefulWidget {
  final Animation<double> fadeAnimation;

  const ChambresScreen({super.key, required this.fadeAnimation});

  @override
  State<ChambresScreen> createState() => _ChambresScreenState();
}

class _ChambresScreenState extends State<ChambresScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  String _floor = 'Etage 3';
  String _type = 'Tous';

  final List<_Room> _rooms = [
    const _Room('301', 'Libre', 'Standard'),
    const _Room('302', 'Occupe', 'Standard'),
    const _Room('303', 'Libre', 'Standard'),
    const _Room('304', 'Occupe', 'Standard'),
    const _Room('305', 'Occupe', 'Standard'),
    const _Room('306', 'Libre', 'Standard'),
    const _Room('310', 'Nettoyage', 'VIP'),
    const _Room('311', 'Libre', 'VIP'),
    const _Room('312', 'Occupe', 'VIP'),
    const _Room('313', 'Libre', 'USI'),
    const _Room('314', 'Occupe', 'USI'),
    const _Room('315', 'Nettoyage', 'USI'),
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
    final filtered = _rooms.where((room) => _type == 'Tous' || room.type == _type).toList();
    final occupied = filtered.where((room) => room.status == 'Occupe').length;
    final total = filtered.length;
    final occupancy = total == 0 ? 0.0 : (occupied / total);

    return FadeTransition(
      opacity: widget.fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildStatsRow(occupied: occupied, total: total, occupancy: occupancy),
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
                  Expanded(flex: 7, child: _buildMap(filtered)),
                  const SizedBox(width: 16),
                  Expanded(flex: 5, child: _buildDetailsPanel(filtered)),
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
            gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.bed_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chambres & lits',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
            ),
            SizedBox(height: 2),
            Text(
              'Cartographie et occupation en temps reel',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildStatsRow({required int occupied, required int total, required double occupancy}) {
    return Row(
      children: [
        _StatCard(label: 'Chambres total', value: '$total', icon: Icons.hotel, color: const Color(0xFF3B82F6)),
        const SizedBox(width: 12),
        _StatCard(label: 'Occupees', value: '$occupied', icon: Icons.bedtime, color: const Color(0xFFEF4444)),
        const SizedBox(width: 12),
        _StatCard(label: 'Libres', value: '${total - occupied}', icon: Icons.check_circle, color: const Color(0xFF22C55E)),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1F2937), Color(0xFF111827)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.monitor_heart, color: Color(0xFF6366F1), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Taux d occupation',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: occupancy,
                          backgroundColor: Colors.white.withOpacity(0.08),
                          valueColor: const AlwaysStoppedAnimation(Color(0xFF6366F1)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(occupancy * 100).round()}%',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        _FilterChip(
          label: 'Etage',
          value: _floor,
          options: const ['Etage 1', 'Etage 2', 'Etage 3', 'Etage 4'],
          onChanged: (value) => setState(() => _floor = value),
        ),
        const SizedBox(width: 12),
        _FilterChip(
          label: 'Type',
          value: _type,
          options: const ['Tous', 'Standard', 'VIP', 'USI'],
          onChanged: (value) => setState(() => _type = value),
        ),
        const Spacer(),
        _LegendBadge(label: 'Libre', color: const Color(0xFF22C55E)),
        const SizedBox(width: 8),
        _LegendBadge(label: 'Occupe', color: const Color(0xFFEF4444)),
        const SizedBox(width: 8),
        _LegendBadge(label: 'Nettoyage', color: const Color(0xFFF59E0B)),
      ],
    );
  }

  Widget _buildActionsRow() {
    final canEdit = PermissionScope.of(context).canEdit('Chambres');
    final canView = PermissionScope.of(context).canView('Chambres');
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
        guard(_ActionButton(label: 'Affecter patient', icon: Icons.person_add_alt_1, color: const Color(0xFF6366F1)), canEdit),
        guard(_ActionButton(label: 'Marquer nettoyage', icon: Icons.cleaning_services, color: const Color(0xFFF59E0B)), canEdit),
        guard(_ActionButton(label: 'Liberer chambre', icon: Icons.logout_rounded, color: const Color(0xFF22C55E)), canEdit),
        guard(_ActionButton(label: 'Programmer entretien', icon: Icons.build_circle, color: const Color(0xFF6366F1)), canEdit),
        guard(_ActionButton(label: 'Historique mouvements', icon: Icons.history, color: const Color(0xFF3B82F6)), canView),
      ],
    );
  }

  Widget _buildMap(List<_Room> rooms) {
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
              Text(
                'Plan etage $_floor',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Text(
                '${rooms.length} chambres',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: rooms.map((room) => _RoomTile(room: room)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPanel(List<_Room> rooms) {
    final byType = {
      'Standard': rooms.where((r) => r.type == 'Standard').length,
      'VIP': rooms.where((r) => r.type == 'VIP').length,
      'USI': rooms.where((r) => r.type == 'USI').length,
    };

    return Column(
      children: [
        _PanelCard(
          title: 'Occupation par type',
          child: Column(
            children: byType.entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _typeColor(entry.key),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                          ),
                        ),
                        Text(
                          entry.value.toString(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        _PanelCard(
          title: 'Alertes maintenance',
          child: Column(
            children: const [
              _AlertRow(label: 'Chambre 310', detail: 'Nettoyage en cours', color: Color(0xFFF59E0B)),
              SizedBox(height: 10),
              _AlertRow(label: 'Chambre 315', detail: 'Lit a reparer', color: Color(0xFFEF4444)),
              SizedBox(height: 10),
              _AlertRow(label: 'Chambre 312', detail: 'Controle climatisation', color: Color(0xFF6366F1)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const SizedBox.shrink(),
      ],
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'VIP':
        return const Color(0xFFF59E0B);
      case 'USI':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF3B82F6);
    }
  }
}

class _Room {
  final String number;
  final String status;
  final String type;

  const _Room(this.number, this.status, this.type);
}

class _RoomTile extends StatefulWidget {
  final _Room room;

  const _RoomTile({required this.room});

  @override
  State<_RoomTile> createState() => _RoomTileState();
}

class _RoomTileState extends State<_RoomTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(widget.room.status);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: _hovered
              ? LinearGradient(
                  colors: [statusColor.withOpacity(0.25), Colors.white.withOpacity(0.04)],
                )
              : null,
          color: _hovered ? null : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withOpacity(0.4), width: _hovered ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.room.number,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Spacer(),
            Text(
              widget.room.type,
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: statusColor.withOpacity(0.4)),
              ),
              child: Text(
                widget.room.status,
                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Occupe':
        return const Color(0xFFEF4444);
      case 'Nettoyage':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF22C55E);
    }
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1F2937), Color(0xFF111827)]),
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
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
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
          Icon(label == 'Etage' ? Icons.layers : Icons.category, size: 16, color: const Color(0xFF6366F1)),
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
            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6366F1), size: 18),
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
