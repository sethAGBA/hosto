import 'package:flutter/material.dart';

class ParametresScreen extends StatefulWidget {
  final Animation<double> fadeAnimation;

  const ParametresScreen({super.key, required this.fadeAnimation});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  String _section = 'Etablissement';

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
                  Expanded(flex: 6, child: _buildSettingsPanel()),
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
            gradient: const LinearGradient(colors: [Color(0xFF6B7280), Color(0xFF4B5563)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B7280).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.settings_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parametres & administration',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
            ),
            SizedBox(height: 2),
            Text(
              'Configuration, securite et sauvegardes',
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildFilters() {
    final sections = ['Etablissement', 'Utilisateurs', 'Securite', 'Sauvegardes'];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: sections.map((section) {
        final isSelected = _section == section;
        return GestureDetector(
          onTap: () => setState(() => _section = section),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF6B7280).withOpacity(0.2) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? const Color(0xFF6B7280) : Colors.white.withOpacity(0.1)),
            ),
            child: Text(
              section,
              style: TextStyle(
                color: isSelected ? const Color(0xFF6B7280) : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionsRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _ActionButton(label: 'Enregistrer', icon: Icons.save, color: const Color(0xFF22C55E)),
        _ActionButton(label: 'Annuler', icon: Icons.cancel_outlined, color: const Color(0xFFEF4444)),
        _ActionButton(label: 'Exporter config', icon: Icons.file_download_outlined, color: const Color(0xFF3B82F6)),
      ],
    );
  }

  Widget _buildSettingsPanel() {
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
          Text(
            'Section: $_section',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: const [
                _SettingRow(label: 'Nom etablissement', value: 'Res Hopital'),
                _SettingRow(label: 'Adresse', value: 'Lome, Tokoin'),
                _SettingRow(label: 'Logo', value: 'logo_hopital.png'),
                _SettingRow(label: 'Fuseau horaire', value: 'UTC+0'),
                _SettingRow(label: 'Langue', value: 'Francais'),
              ],
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
          title: 'Securite',
          child: Column(
            children: const [
              _StatRow(label: '2FA actif', value: 'Oui', color: Color(0xFF22C55E)),
              SizedBox(height: 10),
              _StatRow(label: 'Roles configures', value: '6', color: Color(0xFF3B82F6)),
              SizedBox(height: 10),
              _StatRow(label: 'Dernier audit', value: 'J-3', color: Color(0xFFF59E0B)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _PanelCard(
          title: 'Sauvegardes',
          child: Column(
            children: const [
              _AlertRow(label: 'Backup quotidien', detail: 'OK', color: Color(0xFF22C55E)),
              SizedBox(height: 10),
              _AlertRow(label: 'Backup hebdo', detail: 'En attente', color: Color(0xFFF59E0B)),
              SizedBox(height: 10),
              _AlertRow(label: 'Derniere restauration', detail: 'Aucune', color: Color(0xFF64748B)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String value;

  const _SettingRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
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
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
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
