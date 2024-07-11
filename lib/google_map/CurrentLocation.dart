import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CurrentLocationPractice extends StatefulWidget {
  CurrentLocationPractice({super.key, required this.latlng});

  LatLng latlng;

  @override
  State<CurrentLocationPractice> createState() => _CurrentLocationPracticeState();
}

class _CurrentLocationPracticeState extends State<CurrentLocationPractice> {

  Completer<GoogleMapController> _controller = Completer();

  Set<Marker>  _myMarker = {};



  final Set<Polyline> _myPolline = HashSet<Polyline>();

  List<LatLng> points = [

  ];
  static final CameraPosition _kGooglePlex = CameraPosition(
      target: LatLng(29.57795440, 71.74741980),
      zoom: 15
  );

  Future<Position> getCurrentLocationn() async{
    await Geolocator.requestPermission().then((value) {

    }).onError((error, stackTrace) {
      print("Error : " + error.toString());
    });


    return await Geolocator.getCurrentPosition();
  }

  loadCurrentLocationOnMap() {

    getCurrentLocationn().then((value)async{
      print("My Location");
      print('${value.latitude} ${value.longitude}');
      

      CameraPosition cameraPosition = CameraPosition(
          target: LatLng(value.latitude, value.longitude),
          zoom: 14
      );

      GoogleMapController controller = await _controller.future;
      controller.animateCamera(
          CameraUpdate.newCameraPosition(cameraPosition)
      );
      setState(() {

      });

    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     _myMarker.add(
        Marker(
            markerId: MarkerId("Location"),
            position: widget.latlng,
          infoWindow: InfoWindow(
            title: "Place",
            snippet: "10=10"
          )
        )
    );

    getCurrentLocationn().then((value) async{
      points.add(LatLng(value.latitude, value.longitude));
      _myMarker.add(
          Marker(
              markerId: MarkerId("Location"),
              position: LatLng(value.latitude, value.longitude),
              infoWindow: InfoWindow(
                  title: "Place",
                  snippet: "10=10"
              )
          )
      );

      _myPolline.add(
          Polyline(polylineId: PolylineId("first"),
              points: points,
              color: Colors.blue
          ));

      GoogleMapController controller = await _controller.future;
      controller.animateCamera(
          CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: LatLng(value.latitude,value.longitude),
                  zoom: 14
              )
          )
      );
      setState(() {

      });
    });


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          onMapCreated: (GoogleMapController controller){
            _controller.complete(controller);
          },
          mapType: MapType.terrain,
          markers: _myMarker,
          initialCameraPosition: _kGooglePlex,
        ),
      ),
    );
  }
}
