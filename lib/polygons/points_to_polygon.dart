import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pvt_15/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:pvt_15/screens/mapPage.dart';

void addPolygons(MapPageState mp){
  for(int i = 0; i < globals.parts.length && i<globals.workSocMap.places.length; i++){
    if(globals.debug && globals.debugVerbose){
      log(globals.parts.elementAt(i).toString());
      log('${globals.parts.elementAt(i)}');
    }

    if(!globals.workSocMap.places.elementAt(i).isForbidden())
    globals.areas.add(
      new Polygon(
        polygonId: PolygonId('${globals.workSocMap.places.elementAt(i).getName()}'),
        points: globals.parts.elementAt(i),
        strokeWidth: 2,
        strokeColor: Colors.pink,
        fillColor: Colors.pink.withOpacity(0.2),
        visible: false,consumeTapEvents: true,
        onTap: (){
          _onPolygonTap(mp, globals.workSocMap.places.elementAt(i).getQualities(), '${globals.workSocMap.places.elementAt(i).getName()}');
        },
      )
    );
    if(globals.debug)
      log('${globals.workSocMap.places.elementAt(i).getName()} added.');
  }
} 

void _onPolygonTap(MapPageState mp, List<String> quals, String name)
{
  mp.showDialogbasedOnType(quals, name);
    log("$name has been tapped");
    log('$name has these qualities: ${globals.workSocMap.getByName(name).getQualities()}');

}
void getWorkMap(){
/* SociotopMap workMap = globals.workSocMap; */

  if(globals.workSocMap != null && globals.workSocMap.dataLoaded()){
    globals.workSocMap.parse();
  }
  if(globals.workSocMap != null && globals.workSocMap.parsed){
    
    if(globals.debug)
      log("Contents of workSocMap parsed.");

    for(int i = 0; i < globals.workSocMap.places.length; i++){
      globals.parts.addAll(

        // gives a list of SociotopArea with all the data in them
        globals.workSocMap.places.elementAt(i).getWGS84Points(), 
      );
    }
  }else
    if(globals.debug)
      log('Error when parsing workMap. Location: points_to_polygon.dart, method: getWorkMap');
}