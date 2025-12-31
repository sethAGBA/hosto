import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/patient.dart';
import '../models/medical_staff.dart';
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
        version: 4,
        onCreate: (db, version) async {
          await _createCoreTables(db);
          await _ensurePatientColumns(db);
          await _ensureAuditLogsTable(db);
        },
        onOpen: (db) async {
          await _ensurePatientColumns(db);
          await _ensureAuditLogsTable(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          await _createCoreTables(db);
          await _ensurePatientColumns(db);
          await _ensureAuditLogsTable(db);
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
        completed_at INTEGER,
        result_summary TEXT,
        created_at INTEGER,
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
