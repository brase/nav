import 'package:sqflite/sqflite.dart';
import 'WaypointProjectionView.dart';

import 'dart:developer' as developer;

class DataAccess {
  final Future<Database> _database;

  DataAccess(this._database);

  Future<void> insertWaypointProjection(WaypointProjection proj) async {
    final Database db = await _database;
    developer.log("Insert: ${proj.id}");
    await db.insert(
      WaypointProjection.tableName,
      proj.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateWaypointProjection(WaypointProjection proj) async {
    final Database db = await _database;
    developer.log("Update: ${proj.id}");
    await db.update(
      WaypointProjection.tableName,
      proj.toMap(),
      where: "Id = ${proj.id}"
    );
  }

  // A method that retrieves all the dogs from the dogs table.
  Future<List<WaypointProjection>> waypointProjecions() async {
    final Database db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(WaypointProjection.tableName);

    return List.generate(maps.length, (i) {
      return WaypointProjection.fromMap(maps[i]);
    });
  }

  Future<void> deleteWaypointProjection(id) async {
    final Database db = await _database;
    await db.delete(WaypointProjection.tableName, where: "id = ?", whereArgs: [id]);
  }
}
