import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:developer';

import 'package:pvt_15/coordinate_conversion/sweref99_position.dart';
import 'package:pvt_15/coordinate_conversion/wgs84_position.dart';
import 'package:pvt_15/globals.dart' as globals;
import 'package:pvt_15/screens/mapPage.dart';

BitmapDescriptor myIcon;


//Translates coordinates from the featurelist using the coordinate conversion classes,
//then adds markers representing restrooms to _markers
List<Marker> addTrashCanMarkers(List<Marker> markers){
  for(int i = 0; i < globals.trashCans.features.length; i++){
    SWEREF99Position sweref99 = new SWEREF99Position.full(
      globals.trashCans.features[i].geometry.coordinates[1] + 0.0,
      globals.trashCans.features[i].geometry.coordinates[0] + 0.0 
    );
    WGS84Position wsg84 = sweref99.toWGS84();  
    globals.markers.add(   
      Marker(
        markerId: MarkerId('TrashCan$i'),
        position: LatLng(wsg84.lat, wsg84.long),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(  
          title: '${globals.trashCans.features[i].properties.featureTypeName}',
          snippet: '${globals.trashCans.features[i].properties.mainAttributeDescription}'
        ),
        visible: false,
      )    
    );
  }
  return markers;
}



List<Marker> addAverageMarkers(List<Marker> markers){
  for(int i = 0; i < globals.workSocMap.places.length; i++){
   
    markers.add(
      Marker( 
        markerId: MarkerId('Average$i'),
        position: globals.workSocMap.places.elementAt(i).mapArea.getAverageWGs84(),
        icon: BitmapDescriptor.defaultMarker,   
        infoWindow: InfoWindow(
          title: '${globals.workSocMap.places.elementAt(i).getName()}',
          snippet: '${globals.workSocMap.places.elementAt(i).getType()}',   
        ),  
        visible: false,  onTap: (){log("markedTapped");},
      )
    );
  }
  return markers;
} 


//Translates coordinates from the featurelist using the coordinate conversion classes,   
//then adds markers representing restrooms to _markers
List<Marker> addRestroomMarkers(List<Marker> markers, MapPageState mp, myIcon){
  for(int i = 0; i < globals.restrooms.features.length; i++){
    SWEREF99Position sweref99 = new SWEREF99Position.full(
      globals.restrooms.features[i].geometry.coordinates[1] + 0.0,
      globals.restrooms.features[i].geometry.coordinates[0] + 0.0 
    );
    WGS84Position wsg84 = sweref99.toWGS84(); 
    markers.add(
      Marker( 
        onTap: (){_onRestroomMarkerTap(mp,globals.restrooms.features[i].properties.adress);},
        markerId: MarkerId('Restroom$i'),
        position: LatLng(wsg84.lat, wsg84.long),
        icon: myIcon,   
        visible: false,
      )
    );
  }
  return markers;
} 


void _onRestroomMarkerTap(MapPageState mp, String adress)
{
  mp.showRestRoomMarker(adress);
  log("Restroom marker tapped...");
}