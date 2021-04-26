import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pvt_15/coordinate_conversion/sweref99_position.dart';
import 'package:pvt_15/coordinate_conversion/wgs84_position.dart';
import 'package:pvt_15/shape_map_data/dbfFileParser.dart';
import 'package:pvt_15/shape_map_data/shapeFileParsing.dart';
import 'package:pvt_15/shape_map_data/shpFileParser.dart';
import 'package:pvt_15/globals.dart'as globals;

class SociotopArea
{
  static List<String> typeBlacklist = [
    "kyrka", "kyrkogård","sjukhuspark","skolgård", "ungdomsgård", "koloniområde", "allé", "bostadsgård",
    "esplanad", "förgårdsmark", "gågata", "ip", "kaj", "odling", "täppa",
  ];
  
  final SociotopDescription description;
  final ShpPolygon mapArea;
  List<String> names;
  SociotopArea(this.description, this.mapArea);


  String getName()
  {
    return description.name;
  }
  String getType()
  {
    return description.typeName;
  }
  bool isForbidden()
  {
    return typeBlacklist.contains(description.typeName);

  }

  int invalidCheck()
  {
    int invCount=0;
    for(int i =0; i<mapArea.parts.length&&i<0;i++)
    {
      for (int j =0; j<mapArea.parts.elementAt(i).points.length;j++)
      {
        if(mapArea.parts.elementAt(i).points.elementAt(j).x<1000 || mapArea.parts.elementAt(i).points.elementAt(j).y<1000 )
        {
          invCount++;
        }
      }
    }
    return invCount;

  }

  bool matchAllQualties(List<String> reqs)
  {
    for(int i=0; i<reqs.length; i++)
    {
      if(!description.qualities.contains(reqs.elementAt(i)))
      {
        return false;
        
      }
    }
    return true;

  }

  List<String> getQualities()
  {
    return description.qualities;
  }

  String getAreaName()
  {
    return description.name;
  }

  String getAreaType()
  {
    return description.typeName;
  }
  Point2D getAveragePoint()
  {
    return mapArea.getAverage();
  }

  

  String toString()
  {
    return "${description.toString()} : ${mapArea.getAverage()}";
  }
/// returns a list of parts converted to WGS84 tyle LatLng each List<LatLng>  representes one ShpPart
  List<List<LatLng>> getWGS84Points()
  {
    List<List<LatLng>> workList=new List<List<LatLng>>();
    for(int i=0; i<mapArea.parts.length&&i<1;i++)
    {
      List<LatLng> pointList= new List<LatLng>();
      for(int j=0; j<mapArea.parts.elementAt(i).points.length; j++)
      {
        Point2D w2D = mapArea.parts.elementAt(i).points.elementAt(j);
        SWEREF99Position sP= SWEREF99Position.full(w2D.y+0.0,w2D.x+0.0);
        WGS84Position wP = sP.toWGS84();
        pointList.add(new LatLng(wP.lat,wP.long));

      }
      if(pointList.length>=2)
      {
        pointList.removeLast();
        pointList.add(pointList.first);
      }
      
      workList.add(pointList);
    }
    //log(" ${workList.length}");
    return workList;
  }
}

class Recommendation
{
  int weight;
  int distance;
  SociotopArea place;

  Recommendation(this.weight, this.place);

}

class SociotopMap
{

  HashMap<String, SociotopArea> quickAccess;
  String filename;
  ByteData shpFile;
  ByteData shxFile;
  ByteData dbfFile;
  String prjFile;

  bool shpLoaded=false;
  bool shxLoaded=false;
  bool dbfLoaded=false;

  bool parsed=false;

  List<String> placeNames;
  
  List<SociotopArea> places;
  HashMap<String, SociotopArea> quickAccessPlaces;

  void speedAccessPrep()
  {
    quickAccessPlaces= new HashMap();
    for(int i =0; i<places.length; i++)
    {
      quickAccessPlaces[places.elementAt(i).getName()]=places.elementAt(i);

    }
  }

  SociotopArea getByName(String name)
  {
    if(quickAccessPlaces==null)
    {
      speedAccessPrep();
    }
    if(quickAccessPlaces.containsKey(name))
    {
      return quickAccessPlaces[name];
    }
    else
    {
      return null;
    }
  }
/// returns wether or not this instance has shapefile data loaded
  bool dataLoaded()
  {
    return shpLoaded&&shxLoaded&&dbfLoaded;
  }

  SociotopMap({String filename="assets/mapdata/Sthlm_Sociotopkarta_2014_sweref"})
  {
    this.filename=(filename);
    _loadData();
  }

   int invalidCheck()
  {
    int rVal=0;
    int invSum=0;
    int twoParters=0;
    for(int i=0; i<places.length;i++)
    {
      int scratch=places.elementAt(i).invalidCheck();
      if(scratch>0)
      {
        rVal++;
        log(" $i :  ${places.elementAt(i).description.name}");
      }
      if(places.elementAt(i).mapArea.parts.length>1)
      {
        log(" $i :  ${places.elementAt(i).description.name}");
        twoParters++;
      }
      invSum+=scratch;


    }
    log(" invalid polygons: $rVal, total invalid points : $invSum , twoparters : $twoParters");
    debugPrint("${places.elementAt(461).mapArea}");
    return rVal;
  }


  void _loadData() async
  {
  try{

    
    shpFile= await rootBundle.load('$filename.shp');
    
    shpLoaded=true;
  } catch(e)
  {
    shpLoaded=false;
    log(e.toString());
  }
  try{

    shxFile = await rootBundle.load('$filename.shx');
    shxLoaded=true;
  }catch(e)
  {
    shxLoaded=false;
    log("$e");
  }

  try{
     dbfFile  =await rootBundle.load('$filename.dbf');
    dbfLoaded=true;
  }catch(e)
  {
    dbfLoaded=false;
    log("$e");
  }
   

  }

  List<ShpPolygon> _parseShp()
  {
   return ShapeFileParsing.parseShp(shpFile);
  }

  List<SociotopDescription>  _parseDbf()
  {

   return ShapeFileParsing.parseDbf(dbfFile);
  }

  List<String> getPlaceNames()
  {
    if(placeNames==null)
    {
      placeNames=new List<String>();
      for(int i=0; i<places.length; i++)
      {
        placeNames.add(places[i].getName());
      }

    }
    return placeNames;
  }


///
///Merges a list of ShpPolygons with a matching listof SocitopDescriptions
///
  List<SociotopArea> _merge( List<ShpPolygon> poly, List<SociotopDescription> desc)
  {
    if( poly.length==desc.length)
    {
      int blacklisted=0;
      List<SociotopArea> workList= new List<SociotopArea>();
      for(int i=0;i<poly.length;i++)
      {
        SociotopArea wArea= SociotopArea(desc.elementAt(i), poly.elementAt(i));
        if(!wArea.isForbidden())
        {
          workList.add(wArea);
        }else
        {
          blacklisted++;
        }
        
      }
      log(" $blacklisted places removed from list of places.");
      places=workList;
      speedAccessPrep();
      return workList;

    }else
    {
      return null;
    }
  }
/// parses loaded data, returns wether or not it succeded
///
  bool parse()
  {
    if(_merge( _parseShp(),_parseDbf())!=null)
    {
      parsed=true;
      return parsed;
    }else
    {
      return parsed;
    }



  }

 List<SociotopArea> recommendByName(List<String> names)
 {
   List<SociotopArea> pList = new List<SociotopArea>();
    


    SociotopArea workArea;
   for(int i=0; i<names.length; i++)
   {
     workArea=getByName(names[i]);
     if(workArea!=null)
     {
       pList.add(workArea);
     }
   }

   return reccomendAreas(pList ,typeBlacklist: SociotopArea.typeBlacklist  );

 }

/// gives a list of up to ten SociotopArea based on a given list of favourites ( corpus) optional lists for blacklisted types and places as well of a list of qualties to always weigh at zero
  List<SociotopArea> reccomendAreas(List<SociotopArea> corpus, {List<String> typeBlacklist= const[] , List<String> nameBlacklist = const[], List<String> ignoreTypes = const [], int noOfRecs=10})
  {
    List<String> workNameBlacklist = List<String>.from(nameBlacklist);
    Map<String, int> qualities = new HashMap();
    List<Recommendation> recs = new List<Recommendation>();

    log("corpSize ${corpus.length}");
    // build blacklist and weigthing 
    for (int i =0; i<corpus.length;i++)
    {
      workNameBlacklist.add(corpus.elementAt(i).getAreaName());
      List<String> qualList= corpus.elementAt(i).getQualities();
      for(int j=0;j<qualList.length;j++)
      {
        if(qualities.containsKey(qualList.elementAt(j)))
        {
          
          qualities[qualList.elementAt(j)]= (qualities[qualList.elementAt(j)]+1);
        }else
        {
          qualities[qualList.elementAt(j)]=1;
        }
      }
    }
    // set weigth of ignored qualities to zero
    for ( int index=0; index <ignoreTypes.length; index++)
    {
      if (qualities.containsKey(ignoreTypes.elementAt(index)))
      {
        qualities[ignoreTypes.elementAt(index)]=0;
      }
    }


    if(globals.debug)
    {
      log("weight list : $qualities");
    }
    

 // calulate points for each place
    for(int i=0; i<places.length; i++)
    {
      int weight =0;
      
      if(     !(  workNameBlacklist.contains(places.elementAt(i).getAreaName()) ||(typeBlacklist!=null && typeBlacklist.contains(places.elementAt(i).getAreaType()))&&!places.elementAt(i).isForbidden()  ) )
      {
        List<String> wQual=places.elementAt(i).getQualities();
        for(int j=0; j<wQual.length;j++)
        {
          if(qualities.containsKey(wQual.elementAt(j)))
          {
            weight+= qualities[wQual.elementAt(j)];
          }
        }



       // added weigthed places to the list in the right spot
        bool added=false;
        for(int k=0;k<recs.length;k++)
        {
          if(recs.elementAt(k).weight<weight)
          {
            recs.insert(k, new Recommendation(weight, places.elementAt(i)));
            added=true;
            break;
          }

        }
        if(!added)
        {
          recs.add(new Recommendation(weight, places.elementAt(i)));
        }
        // remove extra places
        while(recs.length>noOfRecs)
        {
          recs.removeLast();
        }



      }

    }
    List<SociotopArea> rList = new List<SociotopArea>();
    log("recs:  ${recs.length}");
    for(int i=0; i<recs.length; i++)
    {
      rList.add(recs.elementAt(i).place);
    }
    return rList;
  }


  List<SociotopArea> testRecs()
  {
    parse();
    List<SociotopArea> corpus = new List<SociotopArea>();
    List<String> typeBlacklist = new List<String>();
    List<String> nameBlacklist = new List<String>();

    typeBlacklist.add("kyrkogård");
    typeBlacklist.add("strandpark");
    nameBlacklist.add("Mariatorget");
    nameBlacklist.add("Kaanan");

    for(int index =0;index<places.length ; index+=100)
    {
      corpus.add(places.elementAt(index));
    }
    log(" corpus :$corpus  name : $nameBlacklist type: $typeBlacklist");
    
    return reccomendAreas(corpus, typeBlacklist : typeBlacklist, nameBlacklist: nameBlacklist);
  }

  int startParsing()
  {

    if(!dataLoaded()&& shpFile!=null)
    {
      log("data not loaded");
      return -1;
    }else
    {
      log("data Loaded");
      ShapeFileParsing.parseShp(shpFile);

      return 0;
    }
  }

}