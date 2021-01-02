import 'dart:async';

import 'package:baseflow_plugin_template/baseflow_plugin_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class WaypointProjection {
  WaypointProjection(
      {this.distance, this.bearing, this.pictureNumber, this.totalKilometers});

  double totalKilometers;
  int pictureNumber;
  double bearing;
  double distance;
}

class WaypointProjectionView extends StatefulWidget {
  WaypointProjectionView(WaypointProjection projection) {
    _projection = projection;
  }

  WaypointProjection _projection;

  @override
  _WaypointProjectionStateView createState() =>
      _WaypointProjectionStateView(_projection);
}

class _WaypointProjectionStateView extends State<WaypointProjectionView> {
  _WaypointProjectionStateView(WaypointProjection projection) {
    _projection = projection;
  }

  WaypointProjection _projection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Projection"),
        ),
        body: Container(
          child: Column(children: [
            Container(
                child: Text(
                    "Total Distance: ${_projection.totalKilometers.toString()}")),
            Container(
                child: Text(
                    "Picture Number: ${_projection.pictureNumber.toString()}")),
            Container(
                child: Text("Bearing: ${_projection.bearing.toString()}")),
            Container(
                child: Text("Distance: ${_projection.distance.toString()}")),
            Container(
              child: Text("Lat.: "),
            ),
            Container(
              child: Text("Long.: "),
            ),
          ]),
        ));
  }
}
