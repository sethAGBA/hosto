import 'package:flutter/material.dart';
import '../widgets/permission_scope.dart';
import '../models/room.dart';
import '../models/bed.dart';
import '../services/database_service.dart';

class ChambresScreen extends StatefulWidget {
  final Animation<double> fadeAnimation;

  const ChambresScreen({super.key, required this.fadeAnimation});

  @override
  State<ChambresScreen> createState() => _ChambresScreenState();
}

class _ChambresScreenState extends State<ChambresScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  String _floor = 'Etage 1';
  String _type = 'Tous';
  String _status = 'Tous';
  final DatabaseService _databaseService = DatabaseService();
  List<Room> _rooms = [];
  bool _loading = true;
  Room? _selectedRoom;
  List<Bed> _selectedBeds = [];
  bool _loadingBeds = false;
  List<Bed> _bedsAll = [];
  bool _loadingBedsSummary = true;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _wingController = TextEditingController();
  final TextEditingController _bedCountController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _formType = 'Standard';
  String _formStatus = 'Libre';
  Room? _editingRoom;
  final Map<String, String?> _errors = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    _loadRooms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _numberController.dispose();
    _floorController.dispose();
    _wingController.dispose();
    _bedCountController.dispose();
    _priceController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _rooms.where((room) {
      final typeOk = _type == 'Tous' || room.type == _type;
      final floorOk = _floor == 'Tous' || room.floor == _floor;
      final statusOk = _status == 'Tous' || room.status == _status;
      final searchOk = query.isEmpty ||
          room.number.toLowerCase().contains(query) ||
          room.floor.toLowerCase().contains(query) ||
          room.type.toLowerCase().contains(query);
      return typeOk && floorOk && statusOk && searchOk;
    }).toList();
    final filteredRoomIds = filtered.map((room) => room.id).toSet();
    final bedsForFilter = _bedsAll.where((bed) => filteredRoomIds.contains(bed.roomId)).toList();
    final bedTotal = bedsForFilter.isNotEmpty ? bedsForFilter.length : filtered.fold(0, (sum, room) => sum + room.bedCount);
    final bedOccupied = bedsForFilter.where((bed) => bed.status == 'Occupe').length;
    final bedFree = bedsForFilter.where((bed) => bed.status == 'Libre').length;
    final bedCleaning = bedsForFilter.where((bed) => bed.status == 'Nettoyage').length;
    final bedMaintenance = bedsForFilter.where((bed) => bed.status == 'Maintenance').length;
    final occupancy = bedTotal == 0 ? 0.0 : (bedOccupied / bedTotal);

    return FadeTransition(
      opacity: widget.fadeAnimation,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompactHeight = constraints.maxHeight < 760;
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildStatsRow(
            occupied: bedOccupied,
            free: bedFree,
            cleaning: bedCleaning,
            maintenance: bedMaintenance,
            total: bedTotal,
            occupancy: occupancy,
          ),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 12),
              _buildFilters(),
              const SizedBox(height: 12),
              _buildActionsRow(),
              const SizedBox(height: 16),
              if (isCompactHeight)
                SizedBox(
                  height: 560,
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
                )
              else
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
          );

          if (!isCompactHeight) {
            return content;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: content,
          );
        },
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

  Widget _buildSearchBar() {
    return SizedBox(
      width: 360,
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: Colors.white, fontSize: 12),
        decoration: InputDecoration(
          hintText: 'Rechercher chambre, etage, type...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6366F1), size: 18),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 16),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF111827),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.3),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow({
    required int occupied,
    required int free,
    required int cleaning,
    required int maintenance,
    required int total,
    required double occupancy,
  }) {
    final cards = [
      _StatCard(label: 'Lits total', value: '$total', icon: Icons.hotel, color: const Color(0xFF3B82F6)),
      _StatCard(label: 'Lits occupes', value: '$occupied', icon: Icons.bedtime, color: const Color(0xFFEF4444)),
      _StatCard(label: 'Lits libres', value: '$free', icon: Icons.check_circle, color: const Color(0xFF22C55E)),
      _StatCard(label: 'Nettoyage', value: '$cleaning', icon: Icons.cleaning_services, color: const Color(0xFFF59E0B)),
      _StatCard(label: 'Maintenance', value: '$maintenance', icon: Icons.build_circle, color: const Color(0xFF6366F1)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 1200;
        final progressCard = Container(
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
        );

        if (isCompact) {
          return Column(
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: cards.map((card) => SizedBox(width: 220, child: card)).toList(),
              ),
              const SizedBox(height: 12),
              progressCard,
            ],
          );
        }

        return Row(
          children: [
            ...cards.map((card) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: card))),
            Expanded(child: progressCard),
          ],
        );
      },
    );
  }

  Widget _buildFilters() {
    final floors = _floorOptions();
    return Row(
      children: [
        _FilterChip(
          label: 'Etage',
          value: _floor,
          options: floors,
          onChanged: (value) => setState(() => _floor = value),
        ),
        const SizedBox(width: 12),
        _FilterChip(
          label: 'Type',
          value: _type,
          options: const ['Tous', 'Standard', 'VIP', 'USI'],
          onChanged: (value) => setState(() => _type = value),
        ),
        const SizedBox(width: 12),
        _FilterChip(
          label: 'Statut',
          value: _status,
          options: const ['Tous', 'Libre', 'Occupe', 'Nettoyage', 'Maintenance'],
          onChanged: (value) => setState(() => _status = value),
        ),
        const Spacer(),
        _LegendBadge(label: 'Libre', color: const Color(0xFF22C55E)),
        const SizedBox(width: 8),
        _LegendBadge(label: 'Occupe', color: const Color(0xFFEF4444)),
        const SizedBox(width: 8),
        _LegendBadge(label: 'Nettoyage', color: const Color(0xFFF59E0B)),
        const SizedBox(width: 8),
        _LegendBadge(label: 'Maintenance', color: const Color(0xFF6366F1)),
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
        guard(
          _ActionButton(
            label: 'Nouvelle chambre',
            icon: Icons.add_circle_outline,
            color: const Color(0xFF6366F1),
            onTap: () => _openRoomDialog(),
          ),
          canEdit,
        ),
        guard(
          _ActionButton(
            label: 'Marquer nettoyage',
            icon: Icons.cleaning_services,
            color: const Color(0xFFF59E0B),
            onTap: () => _updateRoomStatus('Nettoyage'),
          ),
          canEdit,
        ),
        guard(
          _ActionButton(
            label: 'Liberer chambre',
            icon: Icons.logout_rounded,
            color: const Color(0xFF22C55E),
            onTap: () => _updateRoomStatus('Libre'),
          ),
          canEdit,
        ),
        guard(
          _ActionButton(
            label: 'Maintenance',
            icon: Icons.build_circle,
            color: const Color(0xFF6366F1),
            onTap: () => _updateRoomStatus('Maintenance'),
          ),
          canEdit,
        ),
        guard(
          _ActionButton(
            label: 'Historique mouvements',
            icon: Icons.history,
            color: const Color(0xFF3B82F6),
            onTap: _showPlaceholderHistory,
          ),
          canView,
        ),
      ],
    );
  }

  Widget _buildMap(List<Room> rooms) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
        ),
      );
    }
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
              children: rooms
                  .map(
                    (room) => _RoomTile(
                      room: room,
                      selected: _selectedRoom?.id == room.id,
                      onTap: () {
                        setState(() => _selectedRoom = room);
                        _loadBeds(room);
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPanel(List<Room> rooms) {
    final byType = {
      'Standard': rooms.where((r) => r.type == 'Standard').length,
      'VIP': rooms.where((r) => r.type == 'VIP').length,
      'USI': rooms.where((r) => r.type == 'USI').length,
    };
    final maintenanceRooms = rooms.where((r) => r.status == 'Maintenance' || r.status == 'Nettoyage').toList();

    return Column(
      children: [
        _PanelCard(
          title: 'Chambre selectionnee',
          child: _selectedRoom == null
              ? Text(
                  'Selectionnez une chambre pour voir le detail.',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                )
              : SizedBox(
                  height: 360,
                  child: SingleChildScrollView(
                    child: _RoomDetailCard(
                      room: _selectedRoom!,
                      beds: _selectedBeds,
                      loadingBeds: _loadingBeds,
                      canEdit: PermissionScope.of(context).canEdit('Chambres'),
                      canDelete: PermissionScope.of(context).canDelete('Chambres'),
                      onEdit: () => _openRoomDialog(room: _selectedRoom),
                      onDelete: () => _confirmDeleteRoom(_selectedRoom!),
                      onUpdateBedStatus: _updateBedStatus,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        const SizedBox(height: 12),
        _PanelCard(
          title: 'Alertes maintenance',
          child: Column(
            children: maintenanceRooms.isEmpty
                ? [
                    Text(
                      'Aucune alerte active.',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                    ),
                  ]
                : maintenanceRooms
                    .map(
                      (room) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _AlertRow(
                          label: 'Chambre ${room.number}',
                          detail: room.status,
                          color: room.status == 'Maintenance' ? const Color(0xFF6366F1) : const Color(0xFFF59E0B),
                        ),
                      ),
                    )
                    .toList(),
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

  List<String> _floorOptions() {
    final floors = _rooms.map((room) => room.floor).where((floor) => floor.isNotEmpty).toSet().toList();
    floors.sort();
    final fallback = floors.isNotEmpty ? floors : ['Etage 1', 'Etage 2', 'Etage 3', 'Etage 4'];
    final options = ['Tous', ...fallback];
    if (!options.contains(_floor)) {
      options.add(_floor);
    }
    return options;
  }

  Future<void> _loadRooms() async {
    setState(() => _loading = true);
    final rooms = await _databaseService.getRooms();
    for (final room in rooms) {
      await _databaseService.syncBedsForRoom(roomId: room.id, bedCount: room.bedCount);
    }
    final beds = await _databaseService.getBeds();
    if (!mounted) return;
    setState(() {
      _rooms = rooms;
      _bedsAll = beds;
      _loadingBedsSummary = false;
      _loading = false;
    });
  }

  Future<void> _loadBeds(Room room) async {
    setState(() => _loadingBeds = true);
    await _databaseService.syncBedsForRoom(roomId: room.id, bedCount: room.bedCount);
    final beds = await _databaseService.getBedsByRoom(room.id);
    if (!mounted) return;
    setState(() {
      _selectedBeds = beds;
      _loadingBeds = false;
    });
  }

  Future<void> _openRoomDialog({Room? room}) async {
    _errors.clear();
    _editingRoom = room;
    _numberController.text = room?.number ?? '';
    _floorController.text = room?.floor ?? (_floor == 'Tous' ? '' : _floor);
    _wingController.text = room?.wing ?? '';
    _bedCountController.text = room?.bedCount.toString() ?? '';
    _priceController.text = room?.pricePerDay.toString() ?? '';
    _formType = room?.type ?? 'Standard';
    _formStatus = room?.status ?? 'Libre';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620, maxHeight: 760),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          room == null ? 'Nouvelle chambre' : 'Modifier chambre',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _formRow([
                          _field('Numero', _numberController, key: 'number'),
                          _field('Etage', _floorController, key: 'floor'),
                        ]),
                        const SizedBox(height: 12),
                        _formRow([
                          _field('Aile', _wingController),
                          _typeDropdown(),
                        ]),
                        const SizedBox(height: 12),
                        _formRow([
                          _field('Nombre de lits', _bedCountController, key: 'beds'),
                          _field('Tarif / jour', _priceController),
                        ]),
                        const SizedBox(height: 12),
                        _statusDropdown(),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                    border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
                  ),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _saveRoom,
                        icon: const Icon(Icons.save),
                        label: Text(room == null ? 'Creer' : 'Enregistrer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _formRow(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;
        if (isCompact) {
          return Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }
        return Row(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              Expanded(child: children[i]),
              if (i != children.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _field(String label, TextEditingController controller, {String? key}) {
    final error = key == null ? null : _errors[key];
    final required = key != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelWithRequired(label, required),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: key == null
              ? null
              : (_) {
                  if (_errors[key] != null) {
                    setState(() => _errors[key] = null);
                  }
                },
          style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: InputDecoration(
            errorText: error,
            errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
            filled: true,
            fillColor: const Color(0xFF111827),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _typeDropdown() {
    const options = ['Standard', 'VIP', 'USI'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelWithRequired('Type', true),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _errors['type'] != null ? const Color(0xFFEF4444) : Colors.white.withOpacity(0.08)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _formType,
              dropdownColor: const Color(0xFF0F172A),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6366F1)),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
              onChanged: (value) {
                setState(() {
                  _formType = value ?? _formType;
                  _errors['type'] = null;
                });
              },
            ),
          ),
        ),
        if (_errors['type'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_errors['type'] ?? '', style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11)),
          ),
      ],
    );
  }

  Widget _statusDropdown() {
    const options = ['Libre', 'Occupe', 'Nettoyage', 'Maintenance'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelWithRequired('Statut', true),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _errors['status'] != null ? const Color(0xFFEF4444) : Colors.white.withOpacity(0.08)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _formStatus,
              dropdownColor: const Color(0xFF0F172A),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6366F1)),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
              onChanged: (value) {
                setState(() {
                  _formStatus = value ?? _formStatus;
                  _errors['status'] = null;
                });
              },
            ),
          ),
        ),
        if (_errors['status'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_errors['status'] ?? '', style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11)),
          ),
      ],
    );
  }

  Future<void> _saveRoom() async {
    final number = _numberController.text.trim();
    final floor = _floorController.text.trim();
    final wing = _wingController.text.trim();
    final bedCount = int.tryParse(_bedCountController.text.trim());
    final price = double.tryParse(_priceController.text.trim().replaceAll(',', '.')) ?? 0;

    _errors['number'] = number.isEmpty ? 'Champ obligatoire' : null;
    _errors['floor'] = floor.isEmpty ? 'Champ obligatoire' : null;
    _errors['beds'] = bedCount == null ? 'Nombre invalide' : null;
    _errors['type'] = _formType.isEmpty ? 'Champ obligatoire' : null;
    _errors['status'] = _formStatus.isEmpty ? 'Champ obligatoire' : null;

    if (_errors.values.any((value) => value != null)) {
      setState(() {});
      return;
    }

    final now = DateTime.now();
    final room = Room(
      id: _editingRoom?.id ?? 'room_${now.millisecondsSinceEpoch}',
      number: number,
      floor: floor,
      wing: wing,
      type: _formType,
      bedCount: bedCount ?? 1,
      status: _formStatus,
      pricePerDay: price,
      createdAt: _editingRoom?.createdAt ?? now.millisecondsSinceEpoch,
      updatedAt: now.millisecondsSinceEpoch,
    );

    if (_editingRoom == null) {
      await _databaseService.insertRoom(room);
      await _databaseService.syncBedsForRoom(roomId: room.id, bedCount: room.bedCount);
      await _showStatusDialog('Chambre ajoutee', 'La chambre a ete enregistree.');
    } else {
      await _databaseService.updateRoom(room);
      await _databaseService.syncBedsForRoom(roomId: room.id, bedCount: room.bedCount);
      await _showStatusDialog('Chambre mise a jour', 'Les informations ont ete mises a jour.');
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    _editingRoom = null;
    _loadRooms();
    if (_selectedRoom?.id == room.id) {
      _loadBeds(room);
    }
  }

  Future<void> _confirmDeleteRoom(Room room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Supprimer chambre', style: TextStyle(color: Colors.white)),
          content: Text(
            'Confirmer la suppression de la chambre ${room.number} ?',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Supprimer', style: TextStyle(color: Color(0xFFEF4444))),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await _databaseService.deleteBedsByRoom(room.id);
      await _databaseService.deleteRoom(room.id);
      await _showStatusDialog('Chambre supprimee', 'La chambre a ete supprimee.');
      _selectedRoom = null;
      _selectedBeds = [];
      _loadRooms();
    }
  }

  Future<void> _updateRoomStatus(String status) async {
    if (_selectedRoom == null) {
      await _showStatusDialog('Selection requise', 'Selectionnez une chambre pour continuer.');
      return;
    }
    final updated = Room(
      id: _selectedRoom!.id,
      number: _selectedRoom!.number,
      floor: _selectedRoom!.floor,
      wing: _selectedRoom!.wing,
      type: _selectedRoom!.type,
      bedCount: _selectedRoom!.bedCount,
      status: status,
      pricePerDay: _selectedRoom!.pricePerDay,
      createdAt: _selectedRoom!.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _databaseService.updateRoom(updated);
    _selectedRoom = updated;
    _loadRooms();
  }

  Future<void> _updateBedStatus(Bed bed, String status) async {
    final updated = Bed(
      id: bed.id,
      roomId: bed.roomId,
      number: bed.number,
      status: status,
      createdAt: bed.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _databaseService.updateBed(updated);
    if (_selectedRoom != null) {
      _loadBeds(_selectedRoom!);
    }
    final beds = await _databaseService.getBeds();
    if (!mounted) return;
    setState(() => _bedsAll = beds);
  }

  void _showPlaceholderHistory() {
    _showStatusDialog('Historique', 'Le journal des mouvements sera disponible bientot.');
  }

  Future<void> _showStatusDialog(String title, String message) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B1220),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: Text(message, style: TextStyle(color: Colors.white.withOpacity(0.7))),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: Color(0xFF6366F1))),
            ),
          ],
        );
      },
    );
  }

  Widget _labelWithRequired(String label, bool required) {
    if (!required) {
      return Text(
        label,
        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600),
      );
    }
    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600),
        children: [
          TextSpan(text: label),
          const TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
        ],
      ),
    );
  }
}

class _RoomTile extends StatefulWidget {
  final Room room;
  final bool selected;
  final VoidCallback onTap;

  const _RoomTile({required this.room, required this.selected, required this.onTap});

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
      child: GestureDetector(
        onTap: widget.onTap,
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
            border: Border.all(
              color: widget.selected ? const Color(0xFF6366F1) : statusColor.withOpacity(0.4),
              width: widget.selected ? 2 : (_hovered ? 2 : 1),
            ),
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
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Occupe':
        return const Color(0xFFEF4444);
      case 'Nettoyage':
        return const Color(0xFFF59E0B);
      case 'Maintenance':
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFF22C55E);
    }
  }
}

class _RoomDetailCard extends StatelessWidget {
  final Room room;
  final List<Bed> beds;
  final bool loadingBeds;
  final bool canEdit;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final void Function(Bed bed, String status) onUpdateBedStatus;

  const _RoomDetailCard({
    required this.room,
    required this.beds,
    required this.loadingBeds,
    required this.canEdit,
    required this.canDelete,
    required this.onEdit,
    required this.onDelete,
    required this.onUpdateBedStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _detailRow('Numero', room.number),
        _detailRow('Etage', room.floor),
        _detailRow('Aile', room.wing.isEmpty ? '--' : room.wing),
        _detailRow('Type', room.type),
        _detailRow('Lits', room.bedCount.toString()),
        _detailRow('Statut', room.status),
        _detailRow('Tarif', room.pricePerDay > 0 ? room.pricePerDay.toStringAsFixed(0) : '--'),
        const SizedBox(height: 10),
        Row(
          children: [
            _ActionChip(
              label: 'Modifier',
              icon: Icons.edit_outlined,
              color: const Color(0xFF3B82F6),
              onTap: canEdit ? onEdit : null,
            ),
            const SizedBox(width: 8),
            _ActionChip(
              label: 'Supprimer',
              icon: Icons.delete_outline,
              color: const Color(0xFFEF4444),
              onTap: canDelete ? onDelete : null,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Lits',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (loadingBeds)
          const SizedBox(
            height: 32,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
              ),
            ),
          )
        else if (beds.isEmpty)
          Text(
            'Aucun lit configure.',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: beds
                .map(
                  (bed) => _BedChip(
                    bed: bed,
                    canEdit: canEdit,
                    onUpdate: (status) => onUpdateBedStatus(bed, status),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '--' : value,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _BedChip extends StatelessWidget {
  final Bed bed;
  final bool canEdit;
  final ValueChanged<String> onUpdate;

  const _BedChip({required this.bed, required this.canEdit, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final color = _bedStatusColor(bed.status);
    return PopupMenuButton<String>(
      enabled: canEdit,
      onSelected: onUpdate,
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'Libre', child: Text('Libre')),
        PopupMenuItem(value: 'Occupe', child: Text('Occupe')),
        PopupMenuItem(value: 'Nettoyage', child: Text('Nettoyage')),
        PopupMenuItem(value: 'Maintenance', child: Text('Maintenance')),
      ],
      child: Opacity(
        opacity: canEdit ? 1 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Lit ${bed.number}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
              ),
              const SizedBox(width: 6),
              Text(
                bed.status,
                style: TextStyle(color: color.withOpacity(0.8), fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _bedStatusColor(String status) {
    switch (status) {
      case 'Occupe':
        return const Color(0xFFEF4444);
      case 'Nettoyage':
        return const Color(0xFFF59E0B);
      case 'Maintenance':
        return const Color(0xFF6366F1);
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
  final VoidCallback? onTap;

  const _ActionButton({required this.label, required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color, size: 18),
        label: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionChip({required this.label, required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
