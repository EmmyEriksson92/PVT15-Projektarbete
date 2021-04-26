import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class FacebookSharePage extends StatefulWidget {
  @override
  State<FacebookSharePage> createState() => FacebookSharePageState();
}

class FacebookSharePageState extends State<FacebookSharePage> {
  String msg;
  String base64Image;

  @override
  Widget build(BuildContext context) {
    return Container(
           width: double.infinity,
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.center,
             children: <Widget>[
               SizedBox(height: 30),
               RaisedButton(
                 child: Text('share to shareFacebook'),
                 onPressed: () {
                   FlutterShareMe().shareToFacebook(
                       url: 'https://sv.wikipedia.org/wiki/Ivar_Los_park#/media/Fil:Ivar_Los_park01.jpg', msg: 'WOW! Hittade den här supermysiga parken med hjälp av STHLMParkliv Appen!');
                 },
               ),
             ],
           ),
         );
  }
}

class FlutterShareMe {
  final MethodChannel _channel = const MethodChannel('flutter_share_me');

  ///share to facebook
  Future<String> shareToFacebook({String msg = '', String url = ''}) async {
    final Map<String, Object> arguments = Map<String, dynamic>();
    arguments.putIfAbsent('msg', () => msg);
    arguments.putIfAbsent('url', () => url);
    dynamic result;
    try {
      result = await _channel.invokeMethod('shareFacebook', arguments);
    } catch (e) {
      return "false";
    }
    return result;
  }
}