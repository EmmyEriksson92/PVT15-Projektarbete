import 'dart:convert';
import 'dart:async';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'package:pvt_15/infrastructure/restroom.dart';
import 'package:pvt_15/infrastructure/trash_can.dart';
import 'package:pvt_15/globals.dart' as globals;
import 'package:pvt_15/json/parse_local_json.dart';

//Fetches and returns data about restrooms
Future<Restroom> fetchRestroom(String url) async {
  final response = await http.get(url);
  if (response.statusCode == 200) {
    try{
      return Restroom.fromJson(json.decode(response.body));
    }catch(exception){
      if(globals.debug){
        log('Exception occurred when trying to request restrooms via HTTP.');
        log('Exception: $exception');
        log('HTTP request failed, parsing previously used restrooms from file in local storage.');
        log('--------------------------------------------------------------------------------');
      }
      Future<Restroom> _restrooms = ApiRequestLocal().parseLocalRestroom('assets/json/stockholm_toilets.json');
      _restrooms.then((Restroom value) => globals.restrooms = value); //Loads all restrooms
      return globals.restrooms;
    }
  } else {
    throw Exception('Failed to load restrooms');
  }
}

//Fetches and returns data about trash cans
Future<TrashCan> fetchTrashCan(String url) async {
  final response = await http.get(url);
  if (response.statusCode == 200) {
    try{
      return TrashCan.fromJson(json.decode(response.body));
    }catch(exception){
      if(globals.debug){
        log('Exception occurred when trying to request trash cans via HTTP.');
        log('Exception: $exception');
        log('HTTP request failed, parsing previously used trash cans from file in local storage.');
        log('--------------------------------------------------------------------------------');
      }
      Future<TrashCan> _trashCans = ApiRequestLocal().parseLocalTrashCan('assets/json/stockholm_trashcans.json');
      _trashCans.then((TrashCan value) => globals.trashCans = value); //Loads all trash cans
      return globals.trashCans;
    }
  } else {
    throw Exception('Failed to load trash cans');
  }
}
