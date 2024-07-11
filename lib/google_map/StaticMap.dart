import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StaticMapWithMarker extends StatefulWidget {
  final LatLng latlng;

  StaticMapWithMarker({Key? key, required this.latlng}) : super(key: key);

  @override
  _StaticMapWithMarkerState createState() => _StaticMapWithMarkerState();
}

class _StaticMapWithMarkerState extends State<StaticMapWithMarker> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _myMarker = {};

  @override
  void initState() {
    super.initState();
    _myMarker.add(
      Marker(
        markerId: MarkerId("Location"),
        position: widget.latlng,
        infoWindow: InfoWindow(
          title: "Place",
          snippet: "Location marker",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      mapType: MapType.normal,
      markers: _myMarker,
      initialCameraPosition: CameraPosition(
        target: widget.latlng,
        zoom: 14,
      ),
    );
  }
}
