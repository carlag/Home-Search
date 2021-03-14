import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// class PropertyMap extends StatefulWidget {
//   @override
//   State<PropertyMap> createState() => PropertyMapState();
// }

// class PropertyMapState extends State<PropertyMap> {
class PropertyMap extends StatelessWidget {
  double longitude;
  double latitude;
  Completer<GoogleMapController> _controller = Completer();

  PropertyMap({required this.longitude, required this.latitude});

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    final position = LatLng(latitude, longitude);
    final cameraPosition = CameraPosition(
      target: position,
      zoom: 15,
    );
    return new Scaffold(
      body: GoogleMap(
        markers: {Marker(markerId: MarkerId('property'), position: position)},
        initialCameraPosition: cameraPosition,
        zoomGesturesEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
