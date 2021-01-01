import 'dart:async';

import 'package:baseflow_plugin_template/baseflow_plugin_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

/// Defines the main theme color.
final MaterialColor themeMaterialColor =
    BaseflowPluginExample.createMaterialColor(
        const Color.fromRGBO(48, 49, 60, 1));

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rally Navigator',
      // theme: ThemeData(
      //   primaryColor: Colors.white
      // ),
      home: MainView(),
    );
  }
}

/// Example [Widget] showing the functionalities of the geolocator plugin
class GeolocatorWidget extends StatefulWidget {
  /// Utility method to create a page with the Baseflow templating.
  static ExamplePage createPage() {
    return ExamplePage(Icons.location_on, (context) => GeolocatorWidget());
  }

  @override
  _GeolocatorWidgetState createState() => _GeolocatorWidgetState();
}

class _GeolocatorWidgetState extends State<GeolocatorWidget> {
  final List<_PositionItem> _positionItems = <_PositionItem>[];
  StreamSubscription<Position> _positionStreamSubscription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListView.builder(
        itemCount: _positionItems.length,
        itemBuilder: (context, index) {
          final positionItem = _positionItems[index];

          if (positionItem.type == _PositionItemType.permission) {
            return ListTile(
              title: Text(positionItem.displayValue,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )),
            );
          } else {
            return Card(
              child: ListTile(
                tileColor: themeMaterialColor,
                title: Text(
                  positionItem.displayValue,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            bottom: 80.0,
            right: 10.0,
            child: FloatingActionButton.extended(
              onPressed: () async {
                await Geolocator.getLastKnownPosition().then((value) => {
                      _positionItems.add(_PositionItem(
                          _PositionItemType.position, value.toString()))
                    });

                setState(
                  () {},
                );
              },
              label: Text("getLastKnownPosition"),
            ),
          ),
          Positioned(
            bottom: 10.0,
            right: 10.0,
            child: FloatingActionButton.extended(
                onPressed: () async {
                  await Geolocator.getCurrentPosition().then((value) => {
                        _positionItems.add(_PositionItem(
                            _PositionItemType.position, value.toString()))
                      });

                  setState(
                    () {},
                  );
                },
                label: Text("getCurrentPosition")),
          ),
          Positioned(
            bottom: 150.0,
            right: 10.0,
            child: FloatingActionButton.extended(
              onPressed: _toggleListening,
              label: Text(() {
                if (_positionStreamSubscription == null) {
                  return "getPositionStream = null";
                } else {
                  return "getPositionStream ="
                      " ${_positionStreamSubscription.isPaused ? "off" : "on"}";
                }
              }()),
              backgroundColor: _determineButtonColor(),
            ),
          ),
          Positioned(
            bottom: 220.0,
            right: 10.0,
            child: FloatingActionButton.extended(
              onPressed: () => setState(_positionItems.clear),
              label: Text("clear positions"),
            ),
          ),
          Positioned(
            bottom: 290.0,
            right: 10.0,
            child: FloatingActionButton.extended(
              onPressed: () async {
                await Geolocator.checkPermission().then((value) => {
                      _positionItems.add(_PositionItem(
                          _PositionItemType.permission, value.toString()))
                    });
                setState(() {});
              },
              label: Text("getPermissionStatus"),
            ),
          ),
        ],
      ),
    );
  }

  bool _isListening() => !(_positionStreamSubscription == null ||
      _positionStreamSubscription.isPaused);

  Color _determineButtonColor() {
    return _isListening() ? Colors.green : Colors.red;
  }

  void _toggleListening() {
    if (_positionStreamSubscription == null) {
      final positionStream = Geolocator.getPositionStream();
      _positionStreamSubscription = positionStream.handleError((error) {
        _positionStreamSubscription.cancel();
        _positionStreamSubscription = null;
      }).listen((position) => setState(() => _positionItems.add(
          _PositionItem(_PositionItemType.position, position.toString()))));
      _positionStreamSubscription.pause();
    }

    setState(() {
      if (_positionStreamSubscription.isPaused) {
        _positionStreamSubscription.resume();
      } else {
        _positionStreamSubscription.pause();
      }
    });
  }

  @override
  void dispose() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription.cancel();
      _positionStreamSubscription = null;
    }

    super.dispose();
  }
}

enum _PositionItemType {
  permission,
  position,
}

class _PositionItem {
  _PositionItem(this.type, this.displayValue);

  final _PositionItemType type;
  final String displayValue;
}

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final List<WaypointProjection> _projections = [
    WaypointProjection(
        totalKilometers: 21.3, bearing: 228, distance: 1200, pictureNumber: 32),
    WaypointProjection(
        totalKilometers: 42.3, bearing: 212, distance: 2900, pictureNumber: 45),
    WaypointProjection(
        totalKilometers: 69.3, bearing: 90, distance: 200, pictureNumber: 56)
  ];

  final _formKey = GlobalKey<FormState>();

  final addModel = WaypointProjection();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rally Navigator"),
        actions: [],
      ),
      body: _buildProjectionsView(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addProjection,
      ),
    );
  }

  _addProjection() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(title: Text("New projection")),
            body: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: "Total Distance",
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (newValue) => addModel.totalKilometers = double.parse(newValue),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: "Picture Number",
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (newValue) => addModel.pictureNumber = int.parse(newValue),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: "Bearing (°)",
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (newValue) => addModel.bearing = double.parse(newValue),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: "Distance (m)",
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (newValue) => addModel.distance = double.parse(newValue),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: () {},
                        child: Text("Cancel")
                      ),
                      SizedBox(width: 25),
                      RaisedButton(
                        onPressed: () {
                          if(_formKey.currentState.validate()){
                            _formKey.currentState.save();

                            _projections.add(addModel);
                            setState(() {});
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text("Save")
                      ),
                    ],)
                ],
              ),
            ),
          );
        })
    );
  }

  Widget _buildProjectionsView() {
    return ListView.builder(
        itemBuilder: _buildProjectionView, itemCount: _projections.length);
  }

  Widget _buildProjectionView(BuildContext context, int index) {
    final projection = _projections[index];

    return ListTile(
      title: Text(projection.totalKilometers.toString()),
      subtitle: Text(
          "Bearing: ${projection.bearing}; Distance ${projection.distance}"),
    );
  }
}

class WaypointProjection {
  WaypointProjection(
      {this.distance, this.bearing, this.pictureNumber, this.totalKilometers});

  double totalKilometers;
  int pictureNumber;
  double bearing;
  double distance;
}
