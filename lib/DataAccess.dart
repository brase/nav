import 'package:sqflite/sqflite.dart';
import 'WaypointProjectionView.dart';

class DataAccess {
  final Future<Database> _database;

  DataAccess(this._database);

  Future<void> insertWaypointProjection(WaypointProjection proj) async {
    final Database db = await _database;

    await db.insert(
      proj.TableName,
      proj.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all the dogs from the dogs table.
  Future<List<WaypointProjection>> waypointProjecions() async {
    final Database db = await _database;
    final List<Map<String, dynamic>> maps = await db.query('WaypointProjection');

    return List.generate(maps.length, (i) {
      return WaypointProjection.fromMap(maps[i]);
    });
  }
}
