import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/patient.dart';
import '../models/medical_staff.dart';
import '../models/bed.dart';
import '../models/consultation.dart';
import '../models/emergency_box.dart';
import '../models/emergency_visit.dart';
import '../models/exam_analysis.dart';
import '../models/room.dart';
import '../models/user.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    await init();
    return _db!;
  }

  Future<void> init({String? dbPath, bool useInMemory = false}) async {
    if (_db != null) return;

    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      sqfliteFfiInit();
    }

    final String pathToOpen;
    if (useInMemory) {
      pathToOpen = ':memory:';
    } else if (dbPath != null) {
      pathToOpen = dbPath;
    } else {
      final documents = await getApplicationDocumentsDirectory();
      pathToOpen = p.join(documents.path, 'reshopital.db');
    }

    final dbFactory = (Platform.isMacOS || Platform.isLinux || Platform.isWindows)
        ? databaseFactoryFfi
        : databaseFactory;

    _db = await dbFactory.openDatabase(
      pathToOpen,
      options: OpenDatabaseOptions(
        version: 7,
        onCreate: (db, version) async {
          await _createCoreTables(db);
          await _ensurePatientColumns(db);
          await _ensureAuditLogsTable(db);
          await _ensureBedsTable(db);
          await _ensureConsultationColumns(db);
          await _ensureExamAnalysisColumns(db);
          await _ensureUrgencesTables(db);
        },
        onOpen: (db) async {
          await _ensurePatientColumns(db);
          await _ensureAuditLogsTable(db);
          await _ensureBedsTable(db);
          await _ensureConsultationColumns(db);
          await _ensureExamAnalysisColumns(db);
          await _ensureUrgencesTables(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          await _createCoreTables(db);
          await _ensurePatientColumns(db);
          await _ensureAuditLogsTable(db);
          await _ensureBedsTable(db);
          await _ensureConsultationColumns(db);
          await _ensureExamAnalysisColumns(db);
          await _ensureUrgencesTables(db);
        },
      ),
    );
  }

  Future<void> _createCoreTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        password_hash TEXT,
        role TEXT,
        created_at INTEGER,
        last_login INTEGER,
        is_active INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS patients (
        id TEXT PRIMARY KEY,
        dossier_number TEXT,
        first_name TEXT,
        last_name TEXT,
        date_of_birth INTEGER,
        sex TEXT,
        phone TEXT,
        address TEXT,
        blood_group TEXT,
        allergies TEXT,
        emergency_contact TEXT,
        status TEXT,
        room TEXT,
        doctor TEXT,
        service TEXT,
        insurance TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS personnel_medical (
        id TEXT PRIMARY KEY,
        first_name TEXT,
        last_name TEXT,
        role TEXT,
        specialty TEXT,
        department_id TEXT,
        phone TEXT,
        email TEXT,
        status TEXT,
        hired_at INTEGER,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS departements (
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        head_id TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS chambres_lits (
        id TEXT PRIMARY KEY,
        room_number TEXT,
        floor TEXT,
        wing TEXT,
        room_type TEXT,
        bed_count INTEGER,
        status TEXT,
        price_per_day REAL,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS lits (
        id TEXT PRIMARY KEY,
        room_id TEXT,
        bed_number TEXT,
        status TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS consultations (
        id TEXT PRIMARY KEY,
        patient_id TEXT,
        practitioner_id TEXT,
        department_id TEXT,
        scheduled_at INTEGER,
        status TEXT,
        reason TEXT,
        diagnosis TEXT,
        notes TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS hospitalisations (
        id TEXT PRIMARY KEY,
        patient_id TEXT,
        room_id TEXT,
        admission_at INTEGER,
        discharge_at INTEGER,
        status TEXT,
        diagnosis TEXT,
        attending_id TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS prescriptions_medicaments (
        id TEXT PRIMARY KEY,
        patient_id TEXT,
        practitioner_id TEXT,
        medication_name TEXT,
        dosage TEXT,
        frequency TEXT,
        start_at INTEGER,
        end_at INTEGER,
        notes TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS examens_analyses (
        id TEXT PRIMARY KEY,
        patient_id TEXT,
        requester_id TEXT,
        exam_type TEXT,
        priority TEXT,
        status TEXT,
        requested_at INTEGER,
        scheduled_at INTEGER,
        completed_at INTEGER,
        result_summary TEXT,
        notes TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS urgences (
        id TEXT PRIMARY KEY,
        patient_name TEXT,
        age INTEGER,
        reason TEXT,
        priority TEXT,
        status TEXT,
        arrival_at INTEGER,
        box_label TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS emergency_boxes (
        id TEXT PRIMARY KEY,
        label TEXT,
        status TEXT,
        patient_name TEXT,
        priority TEXT,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS interventions_chirurgicales (
        id TEXT PRIMARY KEY,
        patient_id TEXT,
        surgeon_id TEXT,
        room_id TEXT,
        procedure TEXT,
        scheduled_at INTEGER,
        status TEXT,
        notes TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS stock_medicaments (
        id TEXT PRIMARY KEY,
        name TEXT,
        form TEXT,
        dosage TEXT,
        quantity INTEGER,
        min_quantity INTEGER,
        unit_price REAL,
        expiry_date INTEGER,
        supplier_id TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS stock_materiels (
        id TEXT PRIMARY KEY,
        name TEXT,
        category TEXT,
        quantity INTEGER,
        min_quantity INTEGER,
        unit_price REAL,
        supplier_id TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS facturation_paiements (
        id TEXT PRIMARY KEY,
        patient_id TEXT,
        assurance_id TEXT,
        total_amount REAL,
        insurance_amount REAL,
        patient_amount REAL,
        status TEXT,
        issued_at INTEGER,
        paid_at INTEGER,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS assurances_mutuelles (
        id TEXT PRIMARY KEY,
        name TEXT,
        coverage_rate REAL,
        plafond REAL,
        status TEXT,
        contact TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS fournisseurs (
        id TEXT PRIMARY KEY,
        name TEXT,
        category TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS approvisionnements (
        id TEXT PRIMARY KEY,
        supplier_id TEXT,
        item_type TEXT,
        item_name TEXT,
        quantity INTEGER,
        unit_price REAL,
        status TEXT,
        ordered_at INTEGER,
        received_at INTEGER,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS comptabilite_hospitaliere (
        id TEXT PRIMARY KEY,
        entry_date INTEGER,
        reference TEXT,
        description TEXT,
        debit REAL,
        credit REAL,
        account TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS rapports_statistiques (
        id TEXT PRIMARY KEY,
        report_type TEXT,
        period_start INTEGER,
        period_end INTEGER,
        payload TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS paramet (
        id TEXT PRIMARY KEY,
        key TEXT,
        value TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS audit_logs (
        id TEXT PRIMARY KEY,
        actor_id TEXT,
        action TEXT,
        target TEXT,
        payload TEXT,
        created_at INTEGER
      )
    ''');

    await db.execute('CREATE INDEX IF NOT EXISTS idx_patients_name ON patients(last_name, first_name)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_patients_dossier ON patients(dossier_number)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_consultations_patient ON consultations(patient_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_hospitalisations_patient ON hospitalisations(patient_id)');
  }

  Future<void> _ensurePatientColumns(Database db) async {
    final rows = await db.rawQuery('PRAGMA table_info(patients)');
    final existing = rows.map((row) => row['name'] as String).toSet();
    final needed = <String, String>{
      'status': 'TEXT',
      'room': 'TEXT',
      'doctor': 'TEXT',
      'service': 'TEXT',
      'insurance': 'TEXT',
    };

    for (final entry in needed.entries) {
      if (!existing.contains(entry.key)) {
        await db.execute('ALTER TABLE patients ADD COLUMN ${entry.key} ${entry.value}');
      }
    }
  }

  Future<void> _ensureAuditLogsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS audit_logs (
        id TEXT PRIMARY KEY,
        actor_id TEXT,
        action TEXT,
        target TEXT,
        payload TEXT,
        created_at INTEGER
      )
    ''');
  }

  Future<void> _ensureBedsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS lits (
        id TEXT PRIMARY KEY,
        room_id TEXT,
        bed_number TEXT,
        status TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');
  }

  Future<void> _ensureConsultationColumns(Database db) async {
    final rows = await db.rawQuery('PRAGMA table_info(consultations)');
    final existing = rows.map((row) => row['name'] as String).toSet();
    final needed = <String, String>{
      'patient_name': 'TEXT',
      'doctor_name': 'TEXT',
      'location': 'TEXT',
      'notes': 'TEXT',
    };
    for (final entry in needed.entries) {
      if (!existing.contains(entry.key)) {
        await db.execute('ALTER TABLE consultations ADD COLUMN ${entry.key} ${entry.value}');
      }
    }
  }

  Future<void> _ensureExamAnalysisColumns(Database db) async {
    final rows = await db.rawQuery('PRAGMA table_info(examens_analyses)');
    final existing = rows.map((row) => row['name'] as String).toSet();
    final needed = <String, String>{
      'scheduled_at': 'INTEGER',
      'notes': 'TEXT',
    };
    for (final entry in needed.entries) {
      if (!existing.contains(entry.key)) {
        await db.execute('ALTER TABLE examens_analyses ADD COLUMN ${entry.key} ${entry.value}');
      }
    }
  }

  Future<void> _ensureUrgencesTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS urgences (
        id TEXT PRIMARY KEY,
        patient_name TEXT,
        age INTEGER,
        reason TEXT,
        priority TEXT,
        status TEXT,
        arrival_at INTEGER,
        box_label TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS emergency_boxes (
        id TEXT PRIMARY KEY,
        label TEXT,
        status TEXT,
        patient_name TEXT,
        priority TEXT,
        updated_at INTEGER
      )
    ''');

    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM emergency_boxes')) ?? 0;
    if (count == 0) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final labels = ['Box 1', 'Box 2', 'Box 3', 'Dechocage'];
      for (final label in labels) {
        await db.insert(
          'emergency_boxes',
          {
            'id': 'box_${label.replaceAll(' ', '_').toLowerCase()}',
            'label': label,
            'status': 'Libre',
            'patient_name': null,
            'priority': 'Vert',
            'updated_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  Future<List<User>> getUsers() async {
    final database = await db;
    final rows = await database.query('users');
    return rows.map(User.fromMap).toList();
  }

  Future<User?> getUserById(String id) async {
    final database = await db;
    final rows = await database.query('users', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  Future<User?> getUserByEmail(String email) async {
    final database = await db;
    final rows = await database.query('users', where: 'email = ?', whereArgs: [email]);
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  Future<void> insertUser(User user) async {
    final database = await db;
    await database.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateUser(User user) async {
    final database = await db;
    await database.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<void> deleteUser(String id) async {
    final database = await db;
    await database.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Patient>> getPatients({String? query}) async {
    final database = await db;
    if (query == null || query.trim().isEmpty) {
      final rows = await database.query('patients', orderBy: 'last_name, first_name');
      return rows.map(Patient.fromMap).toList();
    }

    final q = '%${query.trim()}%';
    final rows = await database.query(
      'patients',
      where: 'last_name LIKE ? OR first_name LIKE ? OR dossier_number LIKE ?',
      whereArgs: [q, q, q],
      orderBy: 'last_name, first_name',
    );
    return rows.map(Patient.fromMap).toList();
  }

  Future<Patient?> getPatientById(String id) async {
    final database = await db;
    final rows = await database.query('patients', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Patient.fromMap(rows.first);
  }

  Future<void> insertPatient(Patient patient) async {
    final database = await db;
    await database.insert('patients', patient.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updatePatient(Patient patient) async {
    final database = await db;
    await database.update('patients', patient.toMap(), where: 'id = ?', whereArgs: [patient.id]);
  }

  Future<void> deletePatient(String id) async {
    final database = await db;
    await database.delete('patients', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MedicalStaff>> getPersonnel() async {
    final database = await db;
    final rows = await database.query('personnel_medical', orderBy: 'last_name, first_name');
    return rows.map(MedicalStaff.fromMap).toList();
  }

  Future<void> insertPersonnel(MedicalStaff staff) async {
    final database = await db;
    await database.insert('personnel_medical', staff.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updatePersonnel(MedicalStaff staff) async {
    final database = await db;
    await database.update('personnel_medical', staff.toMap(), where: 'id = ?', whereArgs: [staff.id]);
  }

  Future<void> deletePersonnel(String id) async {
    final database = await db;
    await database.delete('personnel_medical', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Room>> getRooms() async {
    final database = await db;
    final rows = await database.query('chambres_lits', orderBy: 'room_number');
    return rows.map(Room.fromMap).toList();
  }

  Future<void> insertRoom(Room room) async {
    final database = await db;
    await database.insert('chambres_lits', room.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateRoom(Room room) async {
    final database = await db;
    await database.update('chambres_lits', room.toMap(), where: 'id = ?', whereArgs: [room.id]);
  }

  Future<void> deleteRoom(String id) async {
    final database = await db;
    await database.delete('chambres_lits', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Bed>> getBedsByRoom(String roomId) async {
    final database = await db;
    final rows = await database.query('lits', where: 'room_id = ?', whereArgs: [roomId], orderBy: 'bed_number');
    return rows.map(Bed.fromMap).toList();
  }

  Future<List<Bed>> getBeds() async {
    final database = await db;
    final rows = await database.query('lits', orderBy: 'room_id, bed_number');
    return rows.map(Bed.fromMap).toList();
  }

  Future<void> insertBed(Bed bed) async {
    final database = await db;
    await database.insert('lits', bed.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateBed(Bed bed) async {
    final database = await db;
    await database.update('lits', bed.toMap(), where: 'id = ?', whereArgs: [bed.id]);
  }

  Future<void> deleteBedsByRoom(String roomId) async {
    final database = await db;
    await database.delete('lits', where: 'room_id = ?', whereArgs: [roomId]);
  }

  Future<void> syncBedsForRoom({required String roomId, required int bedCount}) async {
    final database = await db;
    final existing = await getBedsByRoom(roomId);
    final now = DateTime.now().millisecondsSinceEpoch;
    if (existing.length > bedCount) {
      final toRemove = existing.sublist(bedCount);
      for (final bed in toRemove) {
        await database.delete('lits', where: 'id = ?', whereArgs: [bed.id]);
      }
    } else if (existing.length < bedCount) {
      for (int i = existing.length; i < bedCount; i++) {
        final bedNumber = '${i + 1}'.padLeft(2, '0');
        await database.insert(
          'lits',
          {
            'id': 'bed_${roomId}_$bedNumber',
            'room_id': roomId,
            'bed_number': bedNumber,
            'status': 'Libre',
            'created_at': now,
            'updated_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  Future<List<Consultation>> getConsultations({String? doctor}) async {
    final database = await db;
    if (doctor == null || doctor.trim().isEmpty || doctor == 'Tous') {
      final rows = await database.query('consultations', orderBy: 'scheduled_at');
      return rows.map(Consultation.fromMap).toList();
    }
    final rows = await database.query(
      'consultations',
      where: 'doctor_name = ?',
      whereArgs: [doctor],
      orderBy: 'scheduled_at',
    );
    return rows.map(Consultation.fromMap).toList();
  }

  Future<void> insertConsultation(Consultation consultation) async {
    final database = await db;
    await database.insert('consultations', consultation.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateConsultation(Consultation consultation) async {
    final database = await db;
    await database.update('consultations', consultation.toMap(), where: 'id = ?', whereArgs: [consultation.id]);
  }

  Future<void> deleteConsultation(String id) async {
    final database = await db;
    await database.delete('consultations', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ExamAnalysis>> getExamAnalyses() async {
    final database = await db;
    final rows = await database.query('examens_analyses', orderBy: 'requested_at');
    return rows.map(ExamAnalysis.fromMap).toList();
  }

  Future<void> insertExamAnalysis(ExamAnalysis exam) async {
    final database = await db;
    await database.insert('examens_analyses', exam.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateExamAnalysis(ExamAnalysis exam) async {
    final database = await db;
    await database.update('examens_analyses', exam.toMap(), where: 'id = ?', whereArgs: [exam.id]);
  }

  Future<void> deleteExamAnalysis(String id) async {
    final database = await db;
    await database.delete('examens_analyses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<EmergencyVisit>> getEmergencyVisits() async {
    final database = await db;
    final rows = await database.query('urgences', orderBy: 'arrival_at');
    return rows.map(EmergencyVisit.fromMap).toList();
  }

  Future<void> insertEmergencyVisit(EmergencyVisit visit) async {
    final database = await db;
    await database.insert('urgences', visit.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateEmergencyVisit(EmergencyVisit visit) async {
    final database = await db;
    await database.update('urgences', visit.toMap(), where: 'id = ?', whereArgs: [visit.id]);
  }

  Future<void> deleteEmergencyVisit(String id) async {
    final database = await db;
    await database.delete('urgences', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<EmergencyBox>> getEmergencyBoxes() async {
    final database = await db;
    final rows = await database.query('emergency_boxes', orderBy: 'label');
    return rows.map(EmergencyBox.fromMap).toList();
  }

  Future<void> insertEmergencyBox(EmergencyBox box) async {
    final database = await db;
    await database.insert('emergency_boxes', box.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateEmergencyBox(EmergencyBox box) async {
    final database = await db;
    await database.update('emergency_boxes', box.toMap(), where: 'id = ?', whereArgs: [box.id]);
  }

  Future<Map<String, String>> getSettings(List<String> keys) async {
    if (keys.isEmpty) return {};
    final database = await db;
    final placeholders = List.filled(keys.length, '?').join(', ');
    final rows = await database.query(
      'paramet',
      columns: ['key', 'value'],
      where: 'key IN ($placeholders)',
      whereArgs: keys,
    );
    return {for (final row in rows) row['key'] as String: row['value'] as String? ?? ''};
  }

  Future<void> setSetting(String key, String value) async {
    final database = await db;
    await database.insert(
      'paramet',
      {
        'id': 'param_$key',
        'key': key,
        'value': value,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> setSettings(Map<String, String> values) async {
    final database = await db;
    await database.transaction((txn) async {
      for (final entry in values.entries) {
        await txn.insert(
          'paramet',
          {
            'id': 'param_${entry.key}',
            'key': entry.key,
            'value': entry.value,
            'created_at': DateTime.now().millisecondsSinceEpoch,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> insertAuditLog({
    required String actorId,
    required String action,
    required String target,
    String? payload,
  }) async {
    final database = await db;
    final now = DateTime.now().millisecondsSinceEpoch;
    await database.insert(
      'audit_logs',
      {
        'id': 'audit_$now',
        'actor_id': actorId,
        'action': action,
        'target': target,
        'payload': payload ?? '',
        'created_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, Object?>>> getAuditLogs({int limit = 20}) async {
    final database = await db;
    return database.query(
      'audit_logs',
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }
}
