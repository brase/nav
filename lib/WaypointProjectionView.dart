import 'dart:async';
import 'dart:developer' as developer;
import 'package:geo/geo.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class WaypointProjection {
  WaypointProjection(
      {this.distance, this.heading, this.pictureNumber, this.totalKilometers});

  WaypointProjection.fromMap(Map<String, dynamic> map) {
    this.id = map["id"];
    this.totalKilometers = map["totalKilometers"];
    this.pictureNumber = map["pictureNumber"];
    this.heading = map["heading"];
    this.distance = map["distance"];
  }

  int id;
  double totalKilometers;
  int pictureNumber;
  double heading;
  double distance;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'totalKilometers': totalKilometers,
      'pictureNumber': pictureNumber,
      'heading': heading,
      'distance': distance
    };
  }

  static String get tableName => "WaypointProjection";
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
  Position _pos = Position();

  Timer _updateLocationTimer;

  @override
  Widget build(BuildContext context) {
    _updateLocationTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      await Geolocator.getCurrentPosition().then((value) => {_pos = value});
      if (mounted) {
        setState(() {});
      }
    });

    final valuesStyle = TextStyle(fontSize: 36);

    return Scaffold(
        appBar: AppBar(
          title: Text("Project Waypoint"),
        ),
        body: Container(
          child: Column(children: [
            Container(
                child: Center(
                    child: Text("${_projection.totalKilometers.toString()} km",
                        style: TextStyle(
                            fontSize: 80, fontWeight: FontWeight.bold)))),
            Container(
                margin: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween ,
                  children: [
                    Column(
                      children: [
                        Container(
                            child: Text(
                              "C = ${_projection.heading.toString()}°",
                              style: valuesStyle,)),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                            child:
                                Text("L = ${_projection.distance.toString()} km", style: valuesStyle,)),
                      ],
                    )
                  ],
            )),
            Container(
              child: Text("Lat.: ${_pos.latitude}"),
            ),
            Container(
              child: Text("Long.: ${_pos.longitude}"),
            ),
            Container(
              child: Text("Accuracy.: ${_pos.accuracy}"),
            ),
            Container(
              child: RaisedButton(
                  child: Text("Share"),
                  onPressed: () async {
                    final LatLng destination = _computeDestination(
                        _pos.latitude,
                        _pos.longitude,
                        _projection.heading,
                        _projection.distance);
                    final geoUrl = Uri(
                        scheme: "geo",
                        path: "${destination.lat},${destination.lng}");
                    developer.log(geoUrl.toString());
                    await _launchURL(geoUrl.toString());
                  }),
            )
          ]),
        ));
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _computeDestination(
      double lat, double long, double heading, double distance) {
    return computeOffset(LatLng(lat, long), distance * 1000, heading);
  }

  @override
  void dispose() {
    developer.log("disposed");
    _updateLocationTimer.cancel();
    super.dispose();
  }
}
