import 'package:flutter/material.dart';
import 'WaypointProjectionView.dart';

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
    Navigator.of(context)
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
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();

                          setState(() => _projections.add(addModel));

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
    return ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;
          return _buildProjectionView(context, index);
        },
        itemCount: _projections.length * 2);
  }

  Widget _buildProjectionView(BuildContext context, int index) {
    final projection = _projections[index];

    return ListTile(
      title: Text(projection.totalKilometers.toString()),
      subtitle: Text(
          "Bearing: ${projection.bearing}; Distance ${projection.distance}"),
      onTap: () => _openProjection(projection),
    );
  }

  void _openProjection(WaypointProjection projection) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return WaypointProjectionView(projection);
    }));
  }
}