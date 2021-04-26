library pvt15.globals;

import 'dart:collection';

import 'package:pvt_15/screens/mapPage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pvt_15/infrastructure/restroom.dart';
import 'package:pvt_15/infrastructure/trash_can.dart';
import 'package:pvt_15/shape_map_data/sociotopMap.dart';
import 'package:latlong/latlong.dart' as distance;

//Set this to true to use debugging code
bool debug = false;

//Set this to true for extra information
bool debugVerbose = false;

bool isLoggedIn = false;

//Contains current and last known positions as of when app starts
Position currentPosition = new Position();
Position lastKnownPosition = new Position();

//Classes for restrooms 
Restroom restrooms = new Restroom();
TrashCan trashCans = new TrashCan();

//Contains which toggle buttons are currently pressed
HashMap<String, bool> filterButtonsPressed = new HashMap<String, bool>();

//Contains which filters from the filter drawer that are currently applied to the toggle buttons
HashMap<String, bool> filtersApplied = new HashMap<String, bool>();

//Contains a list of markers that are used by Google Maps
List<Marker> markers = [];

//Contains a list of polygons that are used by Google Maps
List<Polygon> areas = [];
Map<PolylineId, Polyline> polylines = {};

//Used for containing and working on shape file data
List<List<LatLng>> parts = [];
SociotopMap workSocMap = new SociotopMap();

int markerCount = 1;

String place;


// for calculating distance between places
distance.Distance pathDistance = new distance.Distance();

MapPageState currentMapState;


//
Map<String, List<String>> qByName = {

  //Qualities in English for when app is in english mode
  'Ball game':["Bollek", "Bollspel"],
  'Park': ["Parklek"],
  'Playground':["Lekplats"],
  'Sledding hill':["Pulkaåknin"],
  'Picnic': ["Picknick_S"],
  'Outdoor bathing': ["Utomhusbad"],
  'Barbeque': ["Grillning"],
  'Walking':  ["Promenader"],
  'Nature play': ["Naturupple", "Naturlek"],
  'Animal friendly':["Djurhållni"],

  //Qualities in Swedish for when app is in swedish mode
  'Bollspel':["Bollek","Bollspel"],
  'Lekplats':["Lekplats"],
  'Pulkabacke':["Pulkaåknin"],
  'Picknick': ["Picknick_S"],
  'Utomhusbad': ["Utomhusbad"],
  'Grillning': ["Grillning"],
  'Promenad':  ["Promenader"],
  'Naturlek': ["Naturupple", "Naturlek"],
  'Djurhållning':["Djurhållni"]
};

List<String> extraFilterQual= new List();