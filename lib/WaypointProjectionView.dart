import 'dart:async';
import 'dart:developer' as developer;
import 'package:geo/geo.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class WaypointProjection {
  WaypointProjection(
      {this.distance, this.bearing, this.pictureNumber, this.totalKilometers});

  WaypointProjection.fromMap(Map<String, dynamic> map){
    this.id = map["id"];
    this.totalKilometers = map["totalKilometers"];
    this.pictureNumber = map["pictureNumber"];
    this.bearing = map["bearing"];
    this.distance = map["distance"];
  }

  int id;
  double totalKilometers;
  int pictureNumber;
  double bearing;
  double distance;

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'totalKilometers' : totalKilometers,
      'pictureNumber' : pictureNumber,
      'bearing' : bearing,
      'distance' : distance
    };
  }



  final String TableName = "WaypointProjection";
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
    _updateLocationTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await Geolocator.getCurrentPosition().then((value) => {_pos = value});
      if (mounted) {
        setState(() {});
      }
    });

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
                  final LatLng destination = _computeDestination(_pos.latitude, _pos.longitude, _projection.bearing, _projection.distance);
                  final geoUrl = Uri(
                    scheme: "geo",
                    path: "${destination.lat},${destination.lng}"
                  );
                  developer.log(geoUrl.toString());
                    await _launchURL(geoUrl.toString());
                  }
              ),
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

  _computeDestination(double lat, double long, double heading, double distance){
    return computeOffset(LatLng(lat, long), distance, heading);
  }

  @override
  void dispose() {
    _updateLocationTimer.cancel();
    super.dispose();
  }
}
