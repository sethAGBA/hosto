import 'package:flutter/material.dart';
// import 'dart:math' as math;

class DashboardScreen extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const DashboardScreen({super.key, required this.fadeAnimation});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Chiffres clés du jour'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: const [
                _KpiCard(
                  title: 'Patients hospitalisés',
                  value: '142',
                  subtitle: '+6 vs hier',
                  trend: 4.4,
                  icon: Icons.people_alt_rounded,
                  color: Color(0xFF3B82F6),
                  index: 0,
                ),
                _KpiCard(
                  title: 'Consultations',
                  value: '87',
                  subtitle: '25 en attente',
                  trend: 12.5,
                  icon: Icons.event_available_rounded,
                  color: Color(0xFF10B981),
                  index: 1,
                ),
                _KpiCard(
                  title: 'Urgences',
                  value: '12',
                  subtitle: '3 critiques',
                  trend: -8.3,
                  icon: Icons.warning_amber_rounded,
                  color: Color(0xFFEF4444),
                  index: 2,
                ),
                _KpiCard(
                  title: 'Disponibilité lits',
                  value: '23/180',
                  subtitle: 'Occupation 78%',
                  trend: 0.0,
                  icon: Icons.bed_rounded,
                  color: Color(0xFF8B5CF6),
                  index: 3,
                ),
              ],
            ),
            const SizedBox(height: 28),
            _buildSectionTitle('Graphiques & activité'),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _ChartCard(
                      title: 'Admissions sur 30 jours',
                      subtitle: 'Tendance stable',
                      width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                    ),
                    _ChartCard(
                      title: 'Occupation par service',
                      subtitle: 'Médecine interne en tension',
                      width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),
            _buildSectionTitle('Alertes & performance'),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _InfoCard(
                      title: 'Alertes critiques',
                      width: isWide ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth,
                      child: const _AlertList(),
                    ),
                    _InfoCard(
                      title: 'Indicateurs de performance',
                      width: isWide ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth,
                      child: const _PerformanceList(),
                    ),
                    _InfoCard(
                      title: 'Agenda du jour',
                      width: isWide ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth,
                      child: const _AgendaList(),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0EA5A4), Color(0xFF14B8A6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final double trend;
  final IconData icon;
  final Color color;
  final int index;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.trend,
    required this.icon,
    required this.color,
    required this.index,
  });

  @override
  State<_KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<_KpiCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 600 + (widget.index * 100)),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: 260,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isHovered
                        ? [
                            const Color(0xFF1F2937),
                            const Color(0xFF111827),
                          ]
                        : [
                            const Color(0xFF111827),
                            const Color(0xFF0F172A),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isHovered
                        ? widget.color.withOpacity(0.3)
                        : Colors.white.withOpacity(0.08),
                    width: _isHovered ? 2 : 1,
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: widget.color.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.color.withOpacity(0.2),
                                widget.color.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(widget.icon, color: widget.color, size: 24),
                        ),
                        const Spacer(),
                        if (widget.trend != 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: (widget.trend > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.trend > 0 ? Icons.trending_up : Icons.trending_down,
                                  color: widget.trend > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.trend.abs()}%',
                                  style: TextStyle(
                                    color: widget.trend > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Colors.white, widget.color.withOpacity(0.8)],
                      ).createShader(bounds),
                      child: Text(
                        widget.value,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: widget.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.color.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChartCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final double width;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.width,
  });

  @override
  State<_ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<_ChartCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: widget.width,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isHovered
                ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                : [const Color(0xFF111827), const Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFF0EA5A4).withOpacity(0.3)
                : Colors.white.withOpacity(0.08),
            width: _isHovered ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5A4).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.show_chart_rounded,
                    color: Color(0xFF0EA5A4),
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 160, child: _AnimatedChartPlaceholder()),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MetricChip(label: 'Moyenne 32/j', color: Color(0xFF0EA5A4), icon: Icons.trending_flat),
                _MetricChip(label: 'Pic 48', color: Color(0xFF3B82F6), icon: Icons.arrow_upward),
                _MetricChip(label: 'Min 18', color: Color(0xFF22C55E), icon: Icons.arrow_downward),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedChartPlaceholder extends StatefulWidget {
  const _AnimatedChartPlaceholder();

  @override
  State<_AnimatedChartPlaceholder> createState() => _AnimatedChartPlaceholderState();
}

class _AnimatedChartPlaceholderState extends State<_AnimatedChartPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bars = [24, 40, 32, 46, 28, 36, 50, 38, 44, 30, 42, 36];
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(bars.length, (index) {
            final value = bars[index];
            final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  index / bars.length,
                  1.0,
                  curve: Curves.easeOutCubic,
                ),
              ),
            );

            return Expanded(
              child: GestureDetector(
                onTap: () {},
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoveredIndex = index),
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: (value.toDouble() + 40) * animation.value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _hoveredIndex == index
                            ? [const Color(0xFF14B8A6), const Color(0xFF0EA5A4)]
                            : [const Color(0xFF0EA5A4), const Color(0xFF14B8A6)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: _hoveredIndex == index
                          ? [
                              BoxShadow(
                                color: const Color(0xFF0EA5A4).withOpacity(0.5),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _MetricChip({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final double width;
  final Widget child;

  const _InfoCard({required this.title, required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _AlertList extends StatelessWidget {
  const _AlertList();

  @override
  Widget build(BuildContext context) {
    final alerts = [
      ('3 patients en état critique', Icons.emergency, Color(0xFFEF4444)),
      ('Stock antibiotiques faible', Icons.medication, Color(0xFFF59E0B)),
      ('IRM en maintenance (salle 2)', Icons.engineering, Color(0xFF8B5CF6)),
      ('Infirmiers manquants: service urgence', Icons.group_off, Color(0xFFEC4899)),
    ];
    return Column(
      children: alerts.map((alert) {
        final index = alerts.indexOf(alert);
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(-20 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: alert.$3.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: alert.$3.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: alert.$3.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(alert.$2, color: alert.$3, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          alert.$1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class _PerformanceList extends StatelessWidget {
  const _PerformanceList();

  @override
  Widget build(BuildContext context) {
    const items = [
      _PerformanceItem(label: 'Temps attente moyen', value: '28 min', progress: 0.65, color: Color(0xFF0EA5A4)),
      _PerformanceItem(label: 'Satisfaction patients', value: '87%', progress: 0.87, color: Color(0xFF22C55E)),
      _PerformanceItem(label: 'Ratio personnel/patients', value: '1/8', progress: 0.45, color: Color(0xFF3B82F6)),
      _PerformanceItem(label: 'Taux occupation', value: '78%', progress: 0.78, color: Color(0xFFF59E0B)),
    ];
    return const Column(children: items);
  }
}

class _PerformanceItem extends StatefulWidget {
  final String label;
  final String value;
  final double progress;
  final Color color;

  const _PerformanceItem({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  State<_PerformanceItem> createState() => _PerformanceItemState();
}

class _PerformanceItemState extends State<_PerformanceItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.value,
                    style: TextStyle(
                      color: widget.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _animation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [widget.color, widget.color.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AgendaList extends StatelessWidget {
  const _AgendaList();

  @override
  Widget build(BuildContext context) {
    const items = [
      _AgendaItem(time: '09:00', title: 'Appendicectomie', location: 'Salle 2', status: 'En cours'),
      _AgendaItem(time: '11:30', title: 'Tournée médecine interne', location: 'Étage 2', status: 'À venir'),
      _AgendaItem(time: '14:30', title: 'Césarienne', location: 'Salle 1', status: 'À venir'),
      _AgendaItem(time: '16:00', title: 'Réunion staff', location: 'Salle de conférence', status: 'À venir'),
    ];
    return const Column(children: items);
  }
}

class _AgendaItem extends StatelessWidget {
  final String time;
  final String title;
  final String location;
  final String status;

  const _AgendaItem({
    required this.time,
    required this.title,
    required this.location,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'En cours';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0EA5A4).withOpacity(0.1) : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFF0EA5A4).withOpacity(0.3) : Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isActive
                    ? [const Color(0xFF0EA5A4), const Color(0xFF14B8A6)]
                    : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                time,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0EA5A4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'EN COURS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.white.withOpacity(0.5),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}