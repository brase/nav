import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

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
                  final geoUrl = Uri(
                    scheme: "geo",
                    path: "${_pos.latitude},${_pos.longitude}"
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

  @override
  void dispose() {
    _updateLocationTimer.cancel();
    super.dispose();
  }
}
