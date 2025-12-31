import 'package:flutter/material.dart';

class PharmacieScreen extends StatefulWidget {
  final Animation<double> fadeAnimation;

  const PharmacieScreen({super.key, required this.fadeAnimation});

  @override
  State<PharmacieScreen> createState() => _PharmacieScreenState();
}

class _PharmacieScreenState extends State<PharmacieScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  String _filter = 'Tous';
  bool _showLowStock = false;
  bool _showExpiry = false;

  final List<_Drug> _drugs = const [
    _Drug("Paracetamol 500mg", 2500, 500, '03/2026', false),
    _Drug('Amoxicilline 1g', 120, 200, '02/2025', true),
    _Drug('Ibuprofene 400mg', 1800, 300, '06/2026', false),
    _Drug('Morphine 10mg', 45, 50, '01/2025', true),
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
    final filtered = _drugs.where((d) {
      if (_filter == 'Stock faible' && !d.lowStock) return false;
      if (_showLowStock && !d.lowStock) return false;
      if (_showExpiry && !d.expiringSoon) return false;
      return true;
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
                  Expanded(flex: 7, child: _buildStockTable(filtered)),
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
            gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.medication_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pharmacie & stocks',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
            ),
            SizedBox(height: 2),
            Text(
              'Inventaire, dispensation et alertes',
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
          label: 'Categorie',
          value: _filter,
          options: const ['Tous', 'Stock faible', 'Consommables'],
          onChanged: (value) => setState(() => _filter = value),
        ),
        _ToggleChip(
          label: 'Stock faible',
          value: _showLowStock,
          onChanged: (value) => setState(() => _showLowStock = value),
        ),
        _ToggleChip(
          label: 'Peremption proche',
          value: _showExpiry,
          onChanged: (value) => setState(() => _showExpiry = value),
        ),
      ],
    );
  }

  Widget _buildActionsRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _ActionButton(label: 'Nouvelle entree', icon: Icons.add_circle_outline, color: const Color(0xFF10B981)),
        _ActionButton(label: 'Dispensation', icon: Icons.qr_code_scanner, color: const Color(0xFF3B82F6)),
        _ActionButton(label: 'Approvisionner', icon: Icons.local_shipping, color: const Color(0xFFF59E0B)),
        _ActionButton(label: 'Exporter', icon: Icons.file_download_outlined, color: const Color(0xFF64748B)),
      ],
    );
  }

  Widget _buildStockTable(List<_Drug> drugs) {
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
                'Stock medicaments',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Text(
                '${drugs.length} produits',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: drugs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final drug = drugs[index];
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 300 + (index * 60)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 12 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: _DrugRow(drug: drug),
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
          title: 'Alertes stock',
          child: Column(
            children: const [
              _AlertRow(label: '12 medicaments sous seuil', detail: 'Reapprovisionnement', color: Color(0xFFEF4444)),
              SizedBox(height: 10),
              _AlertRow(label: '5 lots peremption proche', detail: '< 3 mois', color: Color(0xFFF59E0B)),
              SizedBox(height: 10),
              _AlertRow(label: 'Commande #CMD-2024-089', detail: 'En attente', color: Color(0xFF3B82F6)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _PanelCard(
          title: 'Resume inventaire',
          child: Column(
            children: const [
              _StatRow(label: 'Valeur stock', value: '24.5 M', color: Color(0xFF10B981)),
              SizedBox(height: 10),
              _StatRow(label: 'Sorties/jour', value: '180', color: Color(0xFF3B82F6)),
              SizedBox(height: 10),
              _StatRow(label: 'Retours', value: '12', color: Color(0xFFF59E0B)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Drug {
  final String name;
  final int stock;
  final int min;
  final String expiry;
  final bool lowStock;

  const _Drug(this.name, this.stock, this.min, this.expiry, this.lowStock);

  bool get expiringSoon => expiry.contains('2025');
}

class _DrugRow extends StatefulWidget {
  final _Drug drug;

  const _DrugRow({required this.drug});

  @override
  State<_DrugRow> createState() => _DrugRowState();
}

class _DrugRowState extends State<_DrugRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.drug.lowStock ? const Color(0xFFEF4444) : const Color(0xFF22C55E);
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
            Expanded(
              flex: 5,
              child: Text(
                widget.drug.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${widget.drug.stock}',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${widget.drug.min}',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Icon(
                    widget.drug.expiringSoon ? Icons.warning_amber_rounded : Icons.check_circle,
                    size: 14,
                    color: widget.drug.expiringSoon ? const Color(0xFFF59E0B) : const Color(0xFF22C55E),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.drug.expiry,
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _IconButton(icon: Icons.visibility_outlined, color: const Color(0xFF10B981)),
                  const SizedBox(width: 6),
                  _IconButton(icon: Icons.edit_outlined, color: const Color(0xFF3B82F6)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconButton({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Icon(icon, color: color, size: 16),
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
          const Icon(Icons.category_outlined, size: 16, color: Color(0xFF10B981)),
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
            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF10B981), size: 18),
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

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleChip({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final color = value ? const Color(0xFF10B981) : Colors.white70;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF10B981).withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: value ? const Color(0xFF10B981) : Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(value ? Icons.check_circle : Icons.circle_outlined, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
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
