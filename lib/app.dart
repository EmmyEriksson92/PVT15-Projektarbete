import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pvt_15/infrastructure/restroom.dart';
import 'package:pvt_15/infrastructure/trash_can.dart';
import 'firebase_allocation.dart';

import 'package:pvt_15/json/parse_http_json.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_localizations.dart';

import 'package:pvt_15/globals.dart' as globals;
import 'package:pvt_15/shape_map_data/sociotopMap.dart';

import 'json/parse_http_json.dart';

class App extends StatefulWidget {
  App({Key key}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) async {
    AppState state = context.findAncestorStateOfType<AppState>();
    state.changeLanguage(newLocale);
  }

  @override
  AppState createState() => AppState();
}

//The function that fetch the current GPS coordinates.
Future<Position> _getCurrentLocation() {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  return geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
}

class AppState extends State {
  Locale _locale;

  changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //THESE METHODS SHOULD BE EXECUTED DURING THE SPLASH SCREEN, NOT HERE DUE TO LOADTIME, CHANGE WHEN POSSIBLE

    globals.workSocMap = new SociotopMap();

    globals.filterButtonsPressed['Djurhållni'] = false;
    globals.filterButtonsPressed['Lekplats'] = false;
    globals.filterButtonsPressed['Parklek'] = false;
    globals.filterButtonsPressed['Utomhusbad'] = false;
    globals.filterButtonsPressed['Sökning'] = false;

    //GETS CURRENT POSITION FROM GPS
    try {
      Future<Position> _posFuture = _getCurrentLocation();
      _posFuture.then((Position value) => (globals.currentPosition = value));
    } catch (exception) {
      if (globals.debug) {
        log('Exception when fetching current GPS position.');
        log('Exception: $exception');
      }
    }

    //PUTS ALL RESTROOMS IN AN INSTANCE OF RESTROOM
    try{
      Future<Restroom> _restrooms = fetchRestroom('http://openstreetgs.stockholm.se/geoservice/api/36a60c78-dc27-4178-8ae5-03fa00a745b8/wfs/?version=1.0.0&request=GetFeature&typeName=od_gis:Toalett_Punkt&outputFormat=JSON');
      _restrooms.then((Restroom value) => globals.restrooms = value); //Loads all toilets
    }catch(exception){
      if(globals.debug)
        log('Exception origin: Login.dart. Exception: $exception');
    }

    //PUTS ALL TRASH CANS IN AN INSTANCE OF TRASHCAN
    try{
      Future<TrashCan> _trashcans = fetchTrashCan('http://openstreetgs.stockholm.se/geoservice/api/36a60c78-dc27-4178-8ae5-03fa00a745b8/wfs/?version=1.0.0&request=GetFeature&typeName=od_gis:Skrapkorg_Punkt&outputFormat=JSON');
      _trashcans.then((TrashCan value) => globals.trashCans = value); //Loads all toilets
    }catch(exception){
      if(globals.debug)
        log('Exception origin: Login.dart. Exception: $exception');
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirebaseAllocation(),
      supportedLocales: [
        Locale('sv', 'SV'),
        Locale('en', 'US'),
      ],
      locale: _locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
    );
  }
}
