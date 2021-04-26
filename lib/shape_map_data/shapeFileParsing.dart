import 'package:flutter/services.dart';
import 'package:pvt_15/shape_map_data/dbfFileParser.dart';
import 'dart:typed_data';
import 'dart:developer';
import 'package:pvt_15/globals.dart' as globals;

import 'package:pvt_15/shape_map_data/shpFileParser.dart';

class ShapeFileParsing
{

  static void getShpShapeType(ByteData shp)
  {
    
    shp.getUint32(32, Endian.little);
  }

  static List<ShpPolygon> parseShp(ByteData shp)
  {
    
      ShpFileParser shpParser = new ShpFileParser(shp);
      if(globals.debug)
        log('file version:${shpParser.getVersion()} shapetype:${shpParser.getShapeType()} filelength :  ${shpParser.getFileLength()} boundingbox ${shpParser.getBoundingBox()}');


      if(shpParser.getShapeType()==5)
      {
        
        List<ShpPolygon> polyList = shpParser.parseAsPolygon();
        
        return polyList;

      }else
      {
        log("file type mismatch");
      }
    
    return null;
  }

  static void parseShx(ByteData shp)
  {


  }

  static void parsePrj(String prj)
  {


  }

  static List<SociotopDescription> parseDbf(ByteData dbf)
  {

    List<SociotopDescription> wList=  DbfFileParser(dbf).parse();

    return wList;
  }

}