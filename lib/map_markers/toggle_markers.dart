import 'dart:developer';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:pvt_15/globals.dart' as globals;

//Creates a temporary list all markers are added, with visibility changed if element represents a restroom
//Temporary list then overwrites _markers which contains the actual marker list
void toggleRestroomVisibility(){
  print(globals.markers[1].position);
  List<Marker> tempMarkers = new List();
  for(int i = 0; i < globals.markers.length; i++){
    bool _visibility;
    if(globals.markers[i].markerId.value.contains('Restroom')){
      if(globals.markers[i].visible){
        _visibility = false;
      } else {
        _visibility = true;
      }
      tempMarkers.add(globals.markers[i].copyWith(visibleParam:_visibility));
    } else {
      tempMarkers.add(globals.markers[i]);
    }
  }
  globals.markers = tempMarkers;
}

//Creates a temporary list all markers are added, with visibility changed if element represents a trash can
//Temporary list then overwrites _markers which contains the actual marker list
void toggleTrashcanVisibility(){
  log("asdasd");
  List<Marker> tempMarkers = new List();
  for(int i = 0; i < globals.markers.length; i++){
    bool _visibility;
    if(globals.markers[i].markerId.value.contains('Average')){
      if(globals.markers[i].visible){
        _visibility = false;
      } else {
        _visibility = true;
      }
      tempMarkers.add(
        Marker(
          markerId: globals.markers[i].markerId,
          position: globals.markers[i].position,
          infoWindow: globals.markers[i].infoWindow,
          icon: globals.markers[i].icon,
          visible: _visibility,
        )
      );
    } else {
      tempMarkers.add(
        Marker(
          markerId: globals.markers[i].markerId,
          position: globals.markers[i].position,
          infoWindow: globals.markers[i].infoWindow,
          icon: globals.markers[i].icon,
          visible: globals.markers[i].visible,
        )
      );
    }
  }
  globals.markers = tempMarkers;
}

