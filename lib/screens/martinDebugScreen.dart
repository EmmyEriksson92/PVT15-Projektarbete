import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:pvt_15/screens/login.dart';

import 'dart:developer';

import 'package:pvt_15/shape_map_data/sociotopMap.dart';


class HellqDebugScreen extends StatefulWidget{
 
  @override
  HellqDebugScreenState createState() => new HellqDebugScreenState();
}

class HellqDebugScreenState extends State<HellqDebugScreen>
{

  SociotopMap workMap;
@override
Widget build(BuildContext context)
{

  final shapeLoadButton = FlatButton(child:  Align(
    alignment: Alignment.bottomCenter,
  child: Text('Load Shape',style: TextStyle(color: Colors.black,fontSize: 12)
  ),
  ),
  onPressed: (){
    print(new DateTime.now().millisecondsSinceEpoch);
    workMap=new SociotopMap();
    print(new DateTime.now().millisecondsSinceEpoch);
  }
  )  ;


  final shpCheckbutton = FlatButton(child:  Align(
    alignment: Alignment.bottomCenter,
  child: Text('Shapefile',style: TextStyle(color: Colors.black,fontSize: 12)
  ),
  ),
  onPressed: (){
    print("shp test pressed");
    if(workMap!=null)
    {
      workMap.parse();
    }
    else
    {

      log(" no sociotop map loaded");
    }
  }
  )  ;

  final dbCheckButton = FlatButton(child:  Align(
    alignment: Alignment.bottomCenter,
  child: Text('Database',style: TextStyle(color: Colors.black,fontSize: 12)
  ),
  ),
  onPressed: (
   
  ){ workMap.invalidCheck();}
  )  ;

  final okButton = FlatButton(child:  Align(
    alignment: Alignment.bottomCenter,
  child: Text('Debug',style: TextStyle(color: Colors.black,fontSize: 12)
  ),
  ),
  onPressed: (){Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );}
  )  ;


  final returnButton = FlatButton(child:  Align(
    alignment: Alignment.bottomCenter,
  child: Text('Return to login Screen',style: TextStyle(color: Colors.black,fontSize: 12)
  ),
  ),
  onPressed: (){Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );}
  )  ;

final dbfButton = FlatButton(child:  Align(
    alignment: Alignment.bottomCenter,
  child: Text('Dbf test',style: TextStyle(color: Colors.black,fontSize: 12)
  ),
  ),
  onPressed: (){
    print("dbf test pressed");
   
    if(workMap.parsed)
    {

      log("${workMap.places}");
      for(int i=0; i< workMap.places.length;i++)
      {

        debugPrint(workMap.places.elementAt(i).mapArea.toString());
      }
    }
                  }
  )  ;



  final recButton = FlatButton(child:  Align(
    alignment: Alignment.bottomCenter,
  child: Text('rec test',style: TextStyle(color: Colors.black,fontSize: 12)
  ),
  ),
  onPressed: (){
    print("rec test pressed");
    workMap.testRecs();
                  }
  )  ;


  return Scaffold(body: Container(
    height: MediaQuery.of(context).size.height,
    width: MediaQuery.of(context).size.width,
    color: Colors.amberAccent[7],
    child : Center(child: ListView(
    shrinkWrap: true,
    children: <Widget>[okButton,returnButton,shapeLoadButton,shpCheckbutton,dbCheckButton, dbfButton, recButton],
       ),
    )
    )
    )
    ;
}


}
