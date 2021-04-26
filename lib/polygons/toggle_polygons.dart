import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pvt_15/globals.dart' as globals;

List<String> _visibleQualities = new List();

void toggleFilterPolygons()
{
  List<String> filterQuals= new List<String>();
  for(String s in globals.filtersApplied.keys)
  {
    if(globals.filtersApplied[s])
    {
      filterQuals.add(s);
    }
  }

  List<Polygon> tempPolys= new List<Polygon>();
  for(Polygon p in globals.areas)
  {
    if(p.visible)
    {
      
      if(globals.workSocMap.getByName(p.polygonId.value).matchAllQualties(filterQuals))
      {
        tempPolys.add(p.clone());
      }else
      {
        tempPolys.add(p.copyWith(visibleParam: false, consumeTapEventsParam: false));
      }
    }else
    {
      tempPolys.add(p.clone());
    }

  }
  globals.areas = tempPolys;

}


void togglePolygons(String quality){
  globals.filterButtonsPressed['Sökning'] = false;

  if(_visibleQualities.contains(quality)){
    _visibleQualities.remove(quality);
    if(globals.debug) log('Removed "$quality" from _visibleQualities');
  } else {
    _visibleQualities.add(quality);
    if(globals.debug) log('Added "$quality" from _visibleQualities');
  }
  if(globals.debug) log('Current contents of _visibleQualities: $_visibleQualities');
  togglePolygonVisibility();
}

void togglePolygonVisibility(){

  List<Polygon> tempPolygons = new List();

  for(int i = 0; i < globals.areas.length; i++){
    bool _visibility = globals.areas[i].visible;

    Color _color = _setColor(_visibility, i);
    _visibility = _setVisibility(i);

    tempPolygons.add(globals.areas[i].copyWith(fillColorParam:_color.withOpacity(0.2),strokeColorParam: _color, visibleParam:_visibility, consumeTapEventsParam: _visibility));
  }
  globals.areas = tempPolygons;
}

//Method to set the visibility value of the polygon being added.
bool _setVisibility(int i){
  bool _visibility;
  if(_visibleQualities.length == 0)
      _visibility = false;

  for(int j = 0; j < _visibleQualities.length; j++){
    bool matchesVisibleQualities = globals.workSocMap.getByName(globals.areas[i].polygonId.value).description.matchQuality(_visibleQualities[j]);

    if(matchesVisibleQualities){
      _visibility = true;
      break;
    }else{
      _visibility = false;
    }
  }
  return _visibility;
}

Color _setColor(bool _visibility, int i){
  Color _color;
  if(_visibleQualities.length > 0){

    if(_visibility && globals.areas[i].strokeColor == Colors.pink)
      _visibility = false;

    if(_visibleQualities.last == 'Djurhållni' && !_visibility)
      _color = Colors.amber;
    else if(_visibleQualities.last == 'Lekplats' && !_visibility)
      _color = Colors.purple;
    else if(_visibleQualities.last == 'Parklek' && !_visibility)
      _color = Colors.green;
    else if(_visibleQualities.last == 'Utomhusbad' && !_visibility)
      _color = Colors.lightBlue;
    else
      _color = globals.areas[i].strokeColor;

  } else {
    _color = Colors.white;
  }
  return _color;
}

void toggleSearchPolygon(String name){
  List<Polygon> tempPolygons = new List();
  _visibleQualities.clear();

  for(int i = 0; i < globals.areas.length; i++){
    if(globals.areas[i].polygonId.value == name){
      tempPolygons.add(
        globals.areas[i].copyWith(
          fillColorParam: Colors.pink.withOpacity(0.2),
          strokeColorParam: Colors.pink,
          visibleParam: true,
          consumeTapEventsParam: true
        )
      );
    }else{
      tempPolygons.add(
        globals.areas[i].copyWith(
          visibleParam: false,
          consumeTapEventsParam: false
        )
      );
    }
  }
  globals.areas = tempPolygons;
}