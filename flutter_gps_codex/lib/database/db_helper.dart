import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String path = join(
      await getDatabasesPath(),
      'gps_tracker.db',
    );

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE locations(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL,
            longitude REAL,
            timestamp TEXT
          )
        ''');
      },
    );
  }

  static Future<int> insertLocation(
    double latitude,
    double longitude,
  ) async {
    final db = await database;

    return await db.insert(
      'locations',
      {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getLocations() async {
    final db = await database;

    return await db.query(
      'locations',
      orderBy: 'id DESC',
    );
  }

  static Future<int> deleteAllLocations() async {
    final db = await database;

    return await db.delete('locations');
  }
}