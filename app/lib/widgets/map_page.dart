import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/plant_location_model.dart';
import 'package:plants_and_places/services.dart';
import 'package:plants_and_places/widgets/loading.dart';
import 'package:plants_and_places/widgets/plant_detail_page.dart';

class MapPage extends StatefulWidget {
  MapPage({Key key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  Future<Map<String, dynamic>> _userCameraPositionFuture;

  Future<Map<String, dynamic>> _prepareMap() async {
    Position currentLocation = await getCurrentLocation(context);
    CameraPosition cameraPosition = new CameraPosition(
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
      zoom: 14.4746,
    );

    APIResponse response = await RESTAPI.listPlantLocations();
    while (!response.success) {
      response = await RESTAPI.listPlantLocations();
    }

    var markers = Set<Marker>();
    int id = 0;
    (response.object as List<PlantLocationModel>).forEach((element) {
      markers.add(Marker(
        markerId: MarkerId(id.toString()),
        position: LatLng(element.latitude, element.longitude),
        infoWindow: InfoWindow(
            title: element.plant,
            snippet: "Fes click per veure aquesta flor.",
            onTap: () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return PlantDetailPage(element);
                }))),
      ));
      id++;
    });

    return {
      'cameraPosition': cameraPosition,
      'markers': markers,
    };
  }

  initState() {
    super.initState();
    _userCameraPositionFuture = _prepareMap();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: FutureBuilder(
          future: _userCameraPositionFuture,
          builder: (BuildContext context,
              AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.hasData) {
              return GoogleMap(
                mapType: MapType.hybrid,
                initialCameraPosition: snapshot.data['cameraPosition'],
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                markers: snapshot.data['markers'],
              );
            } else {
              return DefaultLoading();
            }
          }),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {},
      //   label: Text('Alguna cosa farà'),
      //   icon: Icon(Icons.directions_boat),
      // ),
    );
  }
}
