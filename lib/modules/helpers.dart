import 'dart:developer';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:pvt_15/globals.dart' as globals;
import 'package:latlong/latlong.dart' as distance;



bool isToiletNearby(LatLng position, double dist)
{
  for (int i =0;i< globals.markers.length; i++)
  {
    
    if(globals.pathDistance.distance(
     new distance.LatLng(position.latitude, position.longitude),
     new distance.LatLng(globals.markers[i].position.latitude,globals.markers[i].position.longitude)
    )<=dist)
    {
      return true;
    }

  }
  return false;

}

List<String> getFilterQualsByName(String name)
{
  if(globals.qByName.containsKey(name))
  {
    return globals.qByName[name];
  }
  else
  {
    return new List<String>();
  }

}

void toggleFilterQual(String filterName, bool toggleTo)
{

  for( String s in getFilterQualsByName(filterName))
  {
    globals.filtersApplied[s]=toggleTo;

  }
  if(toggleTo)
  {
    log("filters connected to button ${getFilterQualsByName(filterName)}");

  }else
  {
    log("button disabled");
  }

  log("currentFilers ${globals.filtersApplied}");
  

}

void clearFilters()
{
  for(String s in globals.filtersApplied.keys)
  {
    globals.filtersApplied[s]=false;
  }

}

void applyFilters()
{
  globals.currentMapState.doFilterStuff();
}