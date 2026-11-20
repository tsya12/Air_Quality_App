import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class StorageService {
  static Database? _database;

  // Inisialisasi Database SQLite
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('air_quality.db');
    return _database!;
  }

  // Membuat tabel search_history jika database belum ada
  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE search_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            city TEXT NOT NULL,
            aqi INTEGER NOT NULL,
            status TEXT NOT NULL,
            searched_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // 1. Simpan riwayat pencarian
  static Future<void> insertHistory(String city, int aqi, String status) async {
    final now = DateTime.now();
    final item = {
      'city': city,
      'aqi': aqi,
      'status': status,
      'searched_at': 'Hari ini, ${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}',
    };

    if (kIsWeb) {
      // Jika di Chrome/Web, simpan ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      List<String> list = prefs.getStringList('web_history') ?? [];
      // Hapus jika kota yang sama sudah ada di daftar agar tidak duplikat
      list.removeWhere((e) {
        final decoded = json.decode(e);
        return decoded['city'].toString().toLowerCase() == city.toLowerCase();
      });
      list.insert(0, json.encode(item));
      if (list.length > 15) list = list.sublist(0, 15);
      await prefs.setStringList('web_history', list);
    } else {
      // Jika di HP Android/iOS, simpan ke SQLite
      final db = await database;
      await db.delete('search_history', where: 'LOWER(city) = ?', whereArgs: [city.toLowerCase()]);
      await db.insert('search_history', item);
    }
  }

  // 2. Ambil semua riwayat pencarian (terbaru di atas)
  static Future<List<Map<String, dynamic>>> getHistory() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('web_history') ?? [];
      return list.map((e) => json.decode(e) as Map<String, dynamic>).toList();
    } else {
      final db = await database;
      return await db.query('search_history', orderBy: 'id DESC', limit: 15);
    }
  }

  // 3. Hapus semua riwayat (untuk tombol "Hapus semua")
  static Future<void> clearHistory() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('web_history');
    } else {
      final db = await database;
      await db.delete('search_history');
    }
  }

  // 4. SharedPreferences: Simpan Kota Terakhir yang dicari
  static Future<void> saveLastCity(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_city', cityName);
  }

  // 5. SharedPreferences: Muat Kota Terakhir saat aplikasi dibuka
  static Future<String> getLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_city') ?? 'Makassar';
  }
}