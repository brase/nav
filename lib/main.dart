import 'dart:async';

import 'package:baseflow_plugin_template/baseflow_plugin_template.dart';
import 'package:flutter/material.dart';
import 'package:nav/WaypointProjectionView.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'DataAccess.dart';
import 'MainView.dart';

import 'dart:developer' as developer;

/// Defines the main theme color.
final MaterialColor themeMaterialColor =
    BaseflowPluginExample.createMaterialColor(
        const Color.fromRGBO(48, 49, 60, 1));

void main() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();

  final dbFolder = await getDatabasesPath();
  final dbPath = join(dbFolder, 'rallynav.db');
  developer.log("DB Path: $dbPath");

  // Open the database and store the reference.
  final Future<Database> database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      dbPath, onCreate: (db, version) {
    return db.execute(
      '''CREATE TABLE "WaypointProjection" (
	        "id"	INTEGER,
          "totalKilometers"	REAL,
          "pictureNumber"	INTEGER,
          "heading"	REAL,
          "distance"	REAL,
          PRIMARY KEY("id"));''',
    );
  }, version: 1);

  final DataAccess dataAccess = DataAccess(database);

  runApp(MyApp(dataAccess: dataAccess,));
}

class MyApp extends StatelessWidget {
  final DataAccess dataAccess;

  MyApp({this.dataAccess});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rally Navigator',
      // theme: ThemeData(
      //   primaryColor: Colors.white
      // ),
      home: MainView(dataAccess),
    );
  }
}
