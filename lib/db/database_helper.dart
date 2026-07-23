import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/buku.dart';

/// Singleton helper untuk database lokal (SQLite) di HP.
/// Semua data barcode <-> judul buku disimpan di sini, tidak sinkron ke cloud.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'book_scanner.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE buku (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            barcode TEXT NOT NULL UNIQUE,
            judul TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Tambah atau update (kalau barcode sudah ada, datanya ditimpa).
  Future<int> upsertBuku(Buku buku) async {
    final db = await database;
    return db.insert(
      'buku',
      buku.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Cari buku berdasarkan barcode hasil scan. Null kalau tidak ketemu.
  Future<Buku?> getBukuByBarcode(String barcode) async {
    final db = await database;
    final result = await db.query(
      'buku',
      where: 'barcode = ?',
      whereArgs: [barcode],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Buku.fromMap(result.first);
  }

  Future<List<Buku>> getAllBuku() async {
    final db = await database;
    final result = await db.query('buku', orderBy: 'judul ASC');
    return result.map(Buku.fromMap).toList();
  }

  Future<int> deleteBuku(int id) async {
    final db = await database;
    return db.delete('buku', where: 'id = ?', whereArgs: [id]);
  }
}
