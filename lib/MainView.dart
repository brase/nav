import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'DataAccess.dart';
import 'WaypointProjectionView.dart';

class MainView extends StatefulWidget {
  final DataAccess _dataAccess;

  MainView(this._dataAccess);

  @override
  _MainViewState createState() => _MainViewState(_dataAccess);
}

class _MainViewState extends State<MainView> {
  final DataAccess _dataAccess;
  final _formKey = GlobalKey<FormState>();

  final addModel = WaypointProjection();

  _MainViewState(this._dataAccess);

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
    Navigator.of(this.context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
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
                  labelText: "Total Distance (km)",
                  border: OutlineInputBorder(),
                ),
                validator: _validateDouble,
                onSaved: (newValue) =>
                    addModel.totalKilometers = double.parse(newValue),
              ),
              SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.number,
                autocorrect: false,
                validator: _validateInt,
                decoration: InputDecoration(
                  labelText: "Picture Number",
                  border: OutlineInputBorder(),
                ),
                onSaved: (newValue) =>
                    addModel.pictureNumber = int.parse(newValue),
              ),
              SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.number,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: "heading (°)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  var result = _validateDouble(value);
                  if (result != null) {
                    return result;
                  }

                  if (double.parse(value) > 360) {
                    return "Please enter a valid heading between 0 and 360.";
                  }

                  return null;
                },
                onSaved: (newValue) =>
                    addModel.heading = double.parse(newValue),
              ),
              SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.number,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: "Distance (km)",
                  border: OutlineInputBorder(),
                ),
                validator: _validateDouble,
                onSaved: (newValue) =>
                    addModel.distance = double.parse(newValue),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                      onPressed: () {
                        _formKey.currentState.reset();
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel")),
                  SizedBox(width: 25),
                  RaisedButton(
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();

                          await _dataAccess.insertWaypointProjection(addModel);
                          setState(() {});

                          Navigator.of(context).pop();
                        }
                      },
                      child: Text("Save")),
                ],
              )
            ],
          ),
        ),
      );
    }));
  }

  Widget _buildProjectionsView() {
    return FutureBuilder<List<WaypointProjection>>(
      future: _dataAccess.waypointProjecions(),
      builder: (context, AsyncSnapshot<List<WaypointProjection>> snapshot) {
        if (snapshot.hasData) {
          snapshot.data.sort((wp1, wp2){return wp1.totalKilometers.compareTo(wp2.totalKilometers);});
          return ListView.separated(
              separatorBuilder: (context, index) => Divider(
                    color: Colors.grey[950],
                  ),
              padding: EdgeInsets.all(16.0),
              itemBuilder: (context, i) {
                return _buildProjectionView(context, snapshot.data[i], (wp) {
                  snapshot.data.remove(wp);
                });
              },
              itemCount: snapshot.data.length);
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildProjectionView(BuildContext context, WaypointProjection projection, delete) {
    return Dismissible(
      background: stackBehindDismiss(),
      key: ObjectKey(projection),
      child: ListTile(
        title: Text("${projection.totalKilometers} km"),
        subtitle: Text(
            "Heading: ${projection.heading}° Distance: ${projection.distance} km"),
        trailing: projection.used
                  ?  Icon(Icons.check_box_outlined)
                  :  Icon(Icons.check_box_outline_blank),
        onTap: () => _openProjection(projection),
      ),
      onDismissed: (direction) async {
        await _dataAccess.deleteWaypointProjection(projection.id);
        setState(() {delete(projection);});
        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Item deleted"),
            action: SnackBarAction(
                label: "UNDO",
                onPressed: () async {
                  await _dataAccess.insertWaypointProjection(projection);
                  setState(() {});
                })));
      },
    );
  }

  Widget stackBehindDismiss() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.0),
      color: Colors.red,
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }

  void _openProjection(WaypointProjection projection) {
    Navigator.of(this.context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {

      final callback = (WaypointProjection proj) async {
        await _dataAccess.updateWaypointProjection(proj);
        setState(() {});
      };
      return WaypointProjectionView(projection: projection, updateProjection: callback, );
    }));
  }

  String _validateDouble(String value) {
    if (value.isEmpty) {
      return "Please enter some value.";
    }

    if (double.tryParse(value) == null) {
      return "Please enter a number.";
    }

    return null;
  }

  String _validateInt(String value) {
    if (value.isEmpty) {
      return "Please enter some value.";
    }

    if (int.tryParse(value) == null) {
      return "Please enter a number.";
    }

    return null;
  }
}
