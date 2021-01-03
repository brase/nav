import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
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
                  labelText: "Total Distance",
                  border: OutlineInputBorder(),
                ),
                onSaved: (newValue) =>
                    addModel.totalKilometers = double.parse(newValue),
              ),
              SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.number,
                autocorrect: false,
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
                  labelText: "Bearing (°)",
                  border: OutlineInputBorder(),
                ),
                onSaved: (newValue) =>
                    addModel.bearing = double.parse(newValue),
              ),
              SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.number,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: "Distance (m)",
                  border: OutlineInputBorder(),
                ),
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

          return ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemBuilder: (context, i) {
                if (i.isOdd) return Divider();

                final index = i ~/ 2;
                return _buildProjectionView(context, snapshot.data[index]);
              },
              itemCount: snapshot.data.length * 2);
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildProjectionView(BuildContext context, WaypointProjection projection) {
    return ListTile(
      title: Text(projection.totalKilometers.toString()),
      subtitle: Text(
          "Bearing: ${projection.bearing}; Distance ${projection.distance}"),
      onTap: () => _openProjection(projection),
    );
  }

  void _openProjection(WaypointProjection projection) {
    Navigator.of(this.context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return WaypointProjectionView(projection);
    }));
  }
}
