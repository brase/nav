import 'dart:async';
import 'dart:developer' as developer;
import 'package:geo/geo.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nav/DataAccess.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:developer' as developer;

class WaypointProjection {
  WaypointProjection(
      {this.distance, this.heading, this.pictureNumber, this.totalKilometers});

  WaypointProjection.fromMap(Map<String, dynamic> map) {
    this.id = map["id"];
    this.totalKilometers = map["totalKilometers"];
    this.pictureNumber = map["pictureNumber"];
    this.heading = map["heading"];
    this.distance = map["distance"];
    this.used = map["used"] >= 1;
  }

  int id;
  double totalKilometers;
  int pictureNumber;
  double heading;
  double distance;
  bool used;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'totalKilometers': totalKilometers,
      'pictureNumber': pictureNumber,
      'heading': heading,
      'distance': distance,
      'used': used == true ? 1 : 0
    };
  }

  static String get tableName => "WaypointProjection";
}

class WaypointProjectionView extends StatefulWidget {
  const WaypointProjectionView({
    Key key,
    this.projection,
    this.updateProjection}):super(key: key);

  final WaypointProjection projection;
  final Future<void> Function(WaypointProjection) updateProjection;

  @override
  _WaypointProjectionStateView createState() =>
      _WaypointProjectionStateView();
}

class _WaypointProjectionStateView extends State<WaypointProjectionView> {
  Position _pos = Position();

  Timer _updateLocationTimer;

  @override
  Widget build(BuildContext context) {

    developer.log("Show: ${widget.projection.id}");
    //Initial Location
    Geolocator.getCurrentPosition().then((value) => { _pos = value});

    //Keep location updated
    _updateLocationTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      _pos = await Geolocator.getCurrentPosition();
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
                    child: Text("${widget.projection.totalKilometers.toString()} km",
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
                              "C = ${widget.projection.heading.toString()}°",
                              style: valuesStyle,)),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                            child:
                                Text("L = ${widget.projection.distance.toString()} km", style: valuesStyle,)),
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
                  onPressed: _pos.accuracy != null && _pos.accuracy < 20 ? (() async { //disables button if pos is null
                    widget.projection.used = true;
                    await widget.updateProjection(widget.projection);

                    final LatLng destination = _computeDestination(
                        _pos.latitude,
                        _pos.longitude,
                        widget.projection.heading,
                        widget.projection.distance);
                    final geoUrl = Uri(
                        scheme: "geo",
                        path: "${destination.lat},${destination.lng}");
                    developer.log(geoUrl.toString());
                    await _launchURL(geoUrl.toString());

                    Navigator.of(this.context).pop();
                  }) : null),
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
