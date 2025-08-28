import 'package:sqflite/sqflite.dart';
import '../models/water_log.dart';
import 'Database_Service.dart';

class WaterLogService {
  final dbService = DatabaseService();

  Future<void> insertWaterLog(WaterLog waterLog) async {
    final db = await dbService.database;
    await db.insert(
      'water_logs',
      waterLog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<WaterLog>> getAllWaterLogs() async {
    final db = await dbService.database;
    final maps = await db.query('water_logs');
    return maps.map((map) => WaterLog.fromMap(map)).toList();
  }

  Future<WaterLog?> getWaterLogById(String id) async {
    final db = await dbService.database;
    final result = await db.query(
      'water_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return WaterLog.fromMap(result.first);
    }
    return null;
  }

  Future<void> updateWaterLog(WaterLog waterLog) async {
    final db = await dbService.database;
    await db.update(
      'water_logs',
      waterLog.toMap(),
      where: 'id = ?',
      whereArgs: [waterLog.id],
    );
  }

  Future<void> deleteWaterLog(String id) async {
    final db = await dbService.database;
    await db.delete('water_logs', where: 'id = ?', whereArgs: [id]);
  }
}
