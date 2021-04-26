
import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pvt_15/globals.dart' as globals;

//The function that fetch the current GPS coordinates.
Future<Position> _getCurrentLocation() {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  return geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
}

LatLng getPosition(){
  try {
    Future<Position> _posFuture = _getCurrentLocation();
    _posFuture.then((Position value) => (globals.currentPosition = value));
  } catch (exception) {
    if (globals.debug) {
      log('Exception when fetching current GPS position.');
      log('Exception: $exception');
    }
  }
  return new LatLng(globals.currentPosition.latitude, globals.currentPosition.longitude);
}