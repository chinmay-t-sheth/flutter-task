import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'fd.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;
  static const String _dbName = 'fd_tracker.db';
  static const int _dbVersion = 3; // CHANGED: Incremented version

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE fds(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        bankName TEXT NOT NULL,
        accountNo TEXT,
        principal REAL NOT NULL,
        rate REAL NOT NULL,
        compounding TEXT,
        startDate TEXT NOT NULL,
        maturityDate TEXT NOT NULL,
        payoutFreq TEXT,
        maturityAmount REAL,
        tds REAL,
        documentPath TEXT,
        status TEXT,
        createdAt TEXT NOT NULL, // ADDED: createdAt column
        nomineeName TEXT,
        jointHolder TEXT,
        remarks TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE interest_log(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fdId INTEGER NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        note TEXT,
        FOREIGN KEY(fdId) REFERENCES fds(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE fds ADD COLUMN nomineeName TEXT');
      await db.execute('ALTER TABLE fds ADD COLUMN jointHolder TEXT');
      await db.execute('ALTER TABLE fds ADD COLUMN remarks TEXT');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS interest_log(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          fdId INTEGER NOT NULL,
          date TEXT NOT NULL,
          amount REAL NOT NULL,
          note TEXT,
          FOREIGN KEY(fdId) REFERENCES fds(id) ON DELETE CASCADE
        )
      ''');
    }

    // ADDED: Migration for version 3 (add createdAt column)
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE fds ADD COLUMN createdAt TEXT');

      // Set default value for existing records - use startDate as createdAt
      await db.execute('UPDATE fds SET createdAt = startDate WHERE createdAt IS NULL');
    }
  }

  Future<int> insertFD(FD fd) async {
    final dbClient = await database;

    // Ensure createdAt is included in the map
    final Map<String, dynamic> fdMap = fd.toMap();

    // If createdAt is not in the map (for backward compatibility), add it
    if (!fdMap.containsKey('createdAt')) {
      fdMap['createdAt'] = (fd.createdAt ?? fd.startDate).toIso8601String();
    }

    return await dbClient.insert('fds', fdMap,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<FD>> getFDs() async {
    final dbClient = await database;
    final List<Map<String, dynamic>> maps = await dbClient.query('fds');
    if (maps.isEmpty) return [];
    return List.generate(maps.length, (i) => FD.fromMap(maps[i]));
  }

  Future<int> updateFD(FD fd) async {
    final dbClient = await database;

    // Ensure createdAt is included in the map
    final Map<String, dynamic> fdMap = fd.toMap();

    // If createdAt is not in the map (for backward compatibility), add it
    if (!fdMap.containsKey('createdAt')) {
      fdMap['createdAt'] = (fd.createdAt ?? fd.startDate).toIso8601String();
    }

    return await dbClient.update('fds', fdMap,
        where: 'id = ?', whereArgs: [fd.id]);
  }

  Future<int> deleteFD(int id) async {
    final dbClient = await database;
    return await dbClient.delete('fds', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertInterest(int fdId, double amount, {String? note, DateTime? customDate}) async {
    final dbClient = await database;
    return await dbClient.insert('interest_log', {
      'fdId': fdId,
      'date': (customDate ?? DateTime.now()).toIso8601String(),
      'amount': amount,
      'note': note ?? '',
    });
  }

  Future<List<Map<String, dynamic>>> getInterestLogs(int fdId) async {
    final dbClient = await database;
    return await dbClient.query('interest_log',
        where: 'fdId = ?', whereArgs: [fdId], orderBy: 'date DESC');
  }
}