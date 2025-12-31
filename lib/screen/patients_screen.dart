import 'package:flutter/material.dart';

class PatientsScreen extends StatefulWidget {
  final Animation<double> fadeAnimation;

  const PatientsScreen({super.key, required this.fadeAnimation});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  String _search = '';
  String _filterService = 'Tous';
  String _filterStatus = 'Tous';

  final List<Map<String, String>> _patients = [
    {
      'id': '00142',
      'name': 'Kofi Amen',
      'age': '45',
      'sex': 'M',
      'status': 'Stable',
      'room': '305-A',
      'doctor': 'Dr Ada',
      'service': 'Medecine interne',
      'insurance': 'INAM',
    },
    {
      'id': '00143',
      'name': 'Ama Koffi',
      'age': '32',
      'sex': 'F',
      'status': 'Suivi',
      'room': '201-B',
      'doctor': 'Dr Kokou',
      'service': 'Gynecologie',
      'insurance': 'CNSS',
    },
    {
      'id': '00144',
      'name': 'Edem Togo',
      'age': '67',
      'sex': 'M',
      'status': 'Critique',
      'room': 'USI-03',
      'doctor': 'Dr Ada',
      'service': 'Reanimation',
      'insurance': 'Privée',
    },
    {
      'id': '00145',
      'name': 'Sena Ablavi',
      'age': '28',
      'sex': 'F',
      'status': 'Externe',
      'room': 'N/A',
      'doctor': 'Dr Afi',
      'service': 'Consultation',
      'insurance': 'INAM',
    },
    {
      'id': '00146',
      'name': 'Kwame Mensah',
      'age': '55',
      'sex': 'M',
      'status': 'Stable',
      'room': '402-C',
      'doctor': 'Dr Kokou',
      'service': 'Cardiologie',
      'insurance': 'CNSS',
    },
    {
      'id': '00147',
      'name': 'Akossiwa Dzifa',
      'age': '39',
      'sex': 'F',
      'status': 'Suivi',
      'room': '203-A',
      'doctor': 'Dr Afi',
      'service': 'Gynecologie',
      'insurance': 'Privée',
    },
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
      final matchesSearch = _search.isEmpty ||
          p['name']!.toLowerCase().contains(_search) ||
          p['id']!.contains(_search) ||
          p['doctor']!.toLowerCase().contains(_search);
      final matchesService = _filterService == 'Tous' || p['service'] == _filterService;
      final matchesStatus = _filterStatus == 'Tous' || p['status'] == _filterStatus;
      return matchesSearch && matchesService && matchesStatus;
    }).toList();

    return FadeTransition(
      opacity: widget.fadeAnimation,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompactHeight = constraints.maxHeight < 700;
          if (isCompactHeight) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildStatsBar(filtered.length),
                  const SizedBox(height: 20),
                  _buildFilters(),
                  const SizedBox(height: 12),
                  _buildActionsRow(),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 520,
                    child: FadeTransition(
                      opacity: _fade,
                      child: _buildTable(filtered),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildStatsBar(filtered.length),
              const SizedBox(height: 20),
              _buildFilters(),
              const SizedBox(height: 12),
              _buildActionsRow(),
              const SizedBox(height: 20),
              Expanded(
                child: FadeTransition(
                  opacity: _fade,
                  child: _buildTable(filtered),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0EA5A4), Color(0xFF14B8A6)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0EA5A4).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registre des patients',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Gestion et suivi des admissions',
                        style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: isCompact ? constraints.maxWidth : 340,
                  child: TextField(
                    onChanged: (value) => setState(() => _search = value.trim().toLowerCase()),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Rechercher par nom, dossier, médecin...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0EA5A4), size: 22),
                      suffixIcon: _search.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, color: Colors.white54, size: 18),
                              onPressed: () => setState(() => _search = ''),
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFF1F2937),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF0EA5A4), width: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsBar(int filteredCount) {
    final stats = [
      {'label': 'Total patients', 'value': '${_patients.length}', 'icon': Icons.people, 'color': Color(0xFF3B82F6)},
      {'label': 'Affichés', 'value': '$filteredCount', 'icon': Icons.filter_alt, 'color': Color(0xFF0EA5A4)},
      {'label': 'Critiques', 'value': '${_patients.where((p) => p['status'] == 'Critique').length}', 'icon': Icons.warning_amber_rounded, 'color': Color(0xFFEF4444)},
      {'label': 'Stables', 'value': '${_patients.where((p) => p['status'] == 'Stable').length}', 'icon': Icons.check_circle, 'color': Color(0xFF22C55E)},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        final cards = stats.map((stat) {
          return SizedBox(
            width: isCompact ? 220 : null,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F2937), Color(0xFF111827)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: (stat['color'] as Color).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (stat['color'] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stat['value'] as String,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        stat['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList();

        if (isCompact) {
          return Column(
            children: cards
                .map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(width: constraints.maxWidth, child: card),
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: cards
              .map(
                (card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: card,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildFilters() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        final filterRow = Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _FilterChip(
              label: 'Service',
              value: _filterService,
              options: const ['Tous', 'Medecine interne', 'Gynecologie', 'Reanimation', 'Consultation', 'Cardiologie'],
              onChanged: (value) => setState(() => _filterService = value),
            ),
            _FilterChip(
              label: 'Statut',
              value: _filterStatus,
              options: const ['Tous', 'Stable', 'Suivi', 'Critique', 'Externe'],
              onChanged: (value) => setState(() => _filterStatus = value),
            ),
            if (_filterService != 'Tous' || _filterStatus != 'Tous')
              _ActionChip(
                label: 'Réinitialiser',
                icon: Icons.refresh_rounded,
                onTap: () => setState(() {
                  _filterService = 'Tous';
                  _filterStatus = 'Tous';
                }),
                color: const Color(0xFFEF4444),
              ),
          ],
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              filterRow,
            ],
          );
        }

        return Row(
          children: [
            filterRow,
          ],
        );
      },
    );
  }

  Widget _buildActionsRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0EA5A4), Color(0xFF14B8A6)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0EA5A4).withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text('Nouvelle admission', style: TextStyle(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        _ActionChip(label: 'Exporter', icon: Icons.file_download_outlined, onTap: () {}),
        _ActionChip(label: 'Attestations', icon: Icons.description_outlined, onTap: () {}),
        _ActionChip(label: 'Transfert', icon: Icons.swap_horiz_rounded, onTap: () {}),
        _ActionChip(label: 'Imprimer', icon: Icons.print_outlined, onTap: () {}),
      ],
    );
  }

  Widget _buildTable(List<Map<String, String>> patients) {
    final content = Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: _TableHeaderRow(),
        ),
        Expanded(
          child: patients.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 64, color: Colors.white.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun patient trouvé',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Essayez de modifier vos filtres',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: patients.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 300 + (index * 50)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: _PatientRow(
                        id: patient['id']!,
                        name: patient['name']!,
                        age: patient['age']!,
                        sex: patient['sex']!,
                        status: patient['status']!,
                        room: patient['room']!,
                        doctor: patient['doctor']!,
                        service: patient['service']!,
                        insurance: patient['insurance']!,
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5A4).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF0EA5A4).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description_outlined, color: Color(0xFF0EA5A4), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Total: ${patients.length} patients',
                      style: const TextStyle(
                        color: Color(0xFF0EA5A4),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _ActionChip(label: 'Précédent', icon: Icons.chevron_left, onTap: () {}),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5A4).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '1',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              _ActionChip(label: 'Suivant', icon: Icons.chevron_right, onTap: () {}),
            ],
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        final body = Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1F2937), Color(0xFF111827)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: content,
        );

        if (!isCompact) {
          return body;
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: 900, child: body),
        );
      },
    );
  }
}

class _TableHeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HeaderCell('', 0.6),
        _HeaderCell('N° DOSSIER', 1.0),
        _HeaderCell('PATIENT', 1.8),
        _HeaderCell('AGE/SEXE', 0.9),
        _HeaderCell('STATUT', 1.1),
        _HeaderCell('CHAMBRE', 0.9),
        _HeaderCell('MÉDECIN', 1.3),
        _HeaderCell('ACTIONS', 1.0),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final double flex;

  const _HeaderCell(this.label, this.flex);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: (flex * 10).round(),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _PatientRow extends StatefulWidget {
  final String id;
  final String name;
  final String age;
  final String sex;
  final String status;
  final String room;
  final String doctor;
  final String service;
  final String insurance;

  const _PatientRow({
    required this.id,
    required this.name,
    required this.age,
    required this.sex,
    required this.status,
    required this.room,
    required this.doctor,
    required this.service,
    required this.insurance,
  });

  @override
  State<_PatientRow> createState() => _PatientRowState();
}

class _PatientRowState extends State<_PatientRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(widget.status);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: _hovered
              ? LinearGradient(
                  colors: [
                    const Color(0xFF0EA5A4).withOpacity(0.08),
                    Colors.white.withOpacity(0.04),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: _hovered ? null : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovered ? const Color(0xFF0EA5A4).withOpacity(0.3) : Colors.white.withOpacity(0.05),
            width: _hovered ? 2 : 1,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF0EA5A4).withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor.withOpacity(0.3), statusColor.withOpacity(0.15)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.4), width: 2),
                ),
                child: Center(
                  child: Text(
                    widget.name.substring(0, 1),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5A4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF0EA5A4).withOpacity(0.2)),
                ),
                child: Text(
                  '#${widget.id}',
                  style: const TextStyle(
                    color: Color(0xFF0EA5A4),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.local_hospital_rounded, size: 12, color: Colors.white.withOpacity(0.4)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.service,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 9,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.sex == 'M' ? Icons.male : Icons.female,
                      color: widget.sex == 'M' ? const Color(0xFF3B82F6) : const Color(0xFFEC4899),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.age} ans',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 11,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor.withOpacity(0.2), statusColor.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.4), width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 9,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bed_rounded, size: 12, color: Colors.white.withOpacity(0.6)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.room,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 13,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.doctor,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.health_and_safety_rounded, size: 11, color: Colors.white.withOpacity(0.4)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.insurance,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 10,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _IconButton(icon: Icons.visibility_outlined, color: const Color(0xFF0EA5A4), tooltip: 'Voir'),
                    const SizedBox(width: 6),
                    _IconButton(icon: Icons.edit_outlined, color: const Color(0xFF3B82F6), tooltip: 'Modifier'),
                    const SizedBox(width: 6),
                    _IconButton(icon: Icons.more_vert, color: Colors.white70, tooltip: 'Plus'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Critique':
        return const Color(0xFFEF4444);
      case 'Stable':
        return const Color(0xFF22C55E);
      case 'Suivi':
        return const Color(0xFFF59E0B);
      case 'Externe':
        return const Color(0xFF3B82F6);
      default:
        return Colors.white70;
    }
  }
}

class _IconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;

  const _IconButton({required this.icon, required this.color, required this.tooltip});

  @override
  State<_IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<_IconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _hovered ? widget.color.withOpacity(0.2) : widget.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered ? widget.color.withOpacity(0.5) : widget.color.withOpacity(0.25),
              width: _hovered ? 2 : 1,
            ),
          ),
          child: Icon(widget.icon, color: widget.color, size: 16),
        ),
      ),
    );
  }
}

class _FilterChip extends StatefulWidget {
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
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: _hovered
              ? const LinearGradient(
                  colors: [Color(0xFF1F2937), Color(0xFF111827)],
                )
              : null,
          color: _hovered ? null : const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovered ? const Color(0xFF0EA5A4).withOpacity(0.4) : Colors.white.withOpacity(0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.label == 'Service' ? Icons.business_center : Icons.check_circle_outline,
              size: 16,
              color: const Color(0xFF0EA5A4),
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.label}: ',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            DropdownButton<String>(
              value: widget.value,
              dropdownColor: const Color(0xFF1F2937),
              underline: const SizedBox.shrink(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0EA5A4), size: 18),
              items: widget.options
                  .map((opt) => DropdownMenuItem(
                        value: opt,
                        child: Text(opt),
                      ))
                  .toList(),
              onChanged: (val) => widget.onChanged(val ?? widget.value),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final chipColor = widget.color ?? Colors.white70;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? chipColor.withOpacity(0.15) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered ? chipColor.withOpacity(0.4) : Colors.white.withOpacity(0.1),
              width: _hovered ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: chipColor, size: 16),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: _hovered ? Colors.white : Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
