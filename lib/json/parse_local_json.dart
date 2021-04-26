  
import 'package:flutter/services.dart';
import 'package:pvt_15/infrastructure/restroom.dart';
import 'package:pvt_15/infrastructure/trash_can.dart';
import 'dart:convert';
import 'dart:async';

class ApiRequestLocal {

  //Fetches restrooms from local json source
  Future<Restroom> parseLocalRestroom(String source) async{
    String response = await rootBundle.loadString(source);
    final jsonResponse = json.decode(response);
    Restroom restroom = new Restroom.fromJson(jsonResponse);
    return restroom;
  }
  //Fetches trash cans from local json source
  Future<TrashCan> parseLocalTrashCan(String source) async{
    String response = await rootBundle.loadString(source);
    final jsonResponse = json.decode(response);
    TrashCan trashCan = new TrashCan.fromJson(jsonResponse);
    return trashCan;
  }
}