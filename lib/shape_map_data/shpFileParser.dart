import 'dart:developer';

import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:pvt_15/globals.dart' as globals;
import 'package:pvt_15/coordinate_conversion/sweref99_position.dart';
import 'package:pvt_15/coordinate_conversion/wgs84_position.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';


class BBox2D
{
  
  double xMin;
  double yMin;
  double xMax;
  double yMax;

  BBox2D();
  BBox2D.fill(this.xMin,this.yMin,this.xMax,this.yMax);

  String toString()
  {
    return "$xMin : $yMin : $xMax : $yMax";
  }
}

class Point2D{

  final double x;
  final double y;

  Point2D(this.x,this.y){
    if(x==null||y==null)
    {

      throw IndexError;
    }
  }

  @override
  String toString()
  {
    if(x!=null&&y!=null)
    {
        return "  y:$y x:$x";
    }else
    {
      return "x Or y is null y: $y  x: $x";
    }
  }
}

class ShpPart
{

  List<Point2D> points;
  
  ShpPart(Point2D startPoint)
  {
    points = new List<Point2D>();
    points.add(startPoint);
  }


  // returns true if this completes the part
  bool addPoint(Point2D newPoint)
  {
    points.add(newPoint);
    if(newPoint==points.first&&points.length>2)
    {
      return true;
    }else
    {
      return false;
    }
  }



  String toString()
  {



   return "first point ${points.first} last point: ${points.last}";
  }
  
}


class ShpPolygon
{
  int polygonRecordID;
  BBox2D boundingBox;
  int numParts; // as reported by the file
  int numPoints; // --||--
  List<ShpPart> parts  = new List<ShpPart>();

  int calcPoints()
  {
      int rVal=0;
      for(int i=0; i<parts.length;i++)
      {
        rVal+=parts.elementAt(i).points.length;

      }
      return rVal;

  }

  ShpPolygon( this.boundingBox, this.numParts, this.numPoints,this.polygonRecordID );

  int addPart ( ShpPart nPart)
  {
    parts.add(nPart);
    return parts.length;

  }

  LatLng getAverageWGs84()
  {

        Point2D w2D = getAverage();
        SWEREF99Position sP= SWEREF99Position.full(w2D.y+0.0,w2D.x+0.0);
        WGS84Position wP = sP.toWGS84();
        return new LatLng(wP.latitude, wP.longitude);
  }

  Point2D getAverage()
  {
    double x=0;
    double y=0;
    int amount=0;
    for(int i =0; i<parts.length;i++)
    {
      for(int j=0; j<parts.elementAt(i).points.length;j++)
      {
        x+=parts.elementAt(i).points.elementAt(j).x;
        y+=parts.elementAt(i).points.elementAt(j).y;
        amount++;
      }
    }
    x/=amount;
    y/=amount;
    return Point2D(x,y);
  }

  String toString()
  {

    String retVal= 'ShpPolygon:'+" BBOx: "+  boundingBox.toString() +" numParts:" +numParts.toString() +" NumPoints:" +numPoints.toString()+" Actual points: ${calcPoints()}" +"Parts:" +parts.toString();
    return retVal;
  }


}

class ShpBoundingBox{

  final double xMin;
  final double yMin;
  final double xMax;
  final double yMax;
  final double zMin;
  final double zMax;
  final double mMin;
  final double mMax;

  ShpBoundingBox([this.xMin=0,this.yMin=0,this.xMax=0,this.yMax=0,this.zMin=0,this.zMax=0,this.mMin=0,this.mMax=0]);

  String toString()
  {
    return "BB : $xMin $yMin $xMax $yMax";

  }

}

class ShpPolygonOffsets
{
  static const int recordNo=0; // 4
  static const int length=4; // 4
  static const int shapeType=8; // 0+8
  static const int Box= 12; // 4 + 8
  static const int numParts=44; // 36+8
  static const int numPoints=48; // 40+8
  static const int parts = 52; // 44+8
  static int getPoints(int noOfParts)
  {
    return parts+(4* noOfParts);
  }
  static int getNextPolyOffset(ShpPolygon poly)
  {
      return getPoints(poly.numParts)+(16*poly.numPoints);
  }

}


class ShpFileParser
{
  ByteData shpFile;
  static const int startOffset=100;
  int currentOffset;

  /*
   * the file to parse as ByteData 
   * 
   */
  ShpFileParser( this.shpFile);

  int getVersion()
  {
    return shpFile.getUint32(28,Endian.little);
  }

  int getShapeType()
  {
    
    return shpFile.getUint32(32,Endian.little);
  }

  int getFileLength()
  {

    return shpFile.getUint32(24,Endian.big);
  }

  ShpBoundingBox getBoundingBox()
  {
    return ShpBoundingBox(
      shpFile.getFloat64(36,Endian.little),
      shpFile.getFloat64(44,Endian.little),
      shpFile.getFloat64(52,Endian.little),
      shpFile.getFloat64(60,Endian.little),
      shpFile.getFloat64(68,Endian.little),
      shpFile.getFloat64(76,Endian.little),
      shpFile.getFloat64(84,Endian.little),
      shpFile.getFloat64(92,Endian.little)
    );


  }

  ShpPart _parsePart(int currentOffset, int nextOffset)
  {
    ShpPart workPart = new ShpPart(getPoint(currentOffset));
    bool done=false;
    int workOffset=currentOffset+16;
    while(!done && workOffset<=nextOffset-(16))
    {

      workPart.addPoint(getPoint(workOffset));
      workOffset+=16;
    }      
   
    return workPart;
  }

  Point2D getPoint(int currentOffset)
  {
  
    try{
       return new Point2D(shpFile.getFloat64(currentOffset,Endian.little),shpFile.getFloat64(currentOffset+8, Endian.little));

    }
    catch(e)
    {
      log(e.toString()+"tried getting point att $currentOffset");
      return null;
    }
   
  }

  // iterate from the first part to get the offsets for the start of each part but stop before the number of points
  List<int> getPartOffsets(int currentOffset, int numparts)
  {

    int workOffset=currentOffset+ShpPolygonOffsets.parts;
    int endPoint = currentOffset+ShpPolygonOffsets.getPoints(numparts);
    List<int> workList = new List<int>();

    for(int i=workOffset;i<endPoint;i+=4)
    {

      workList.add(workOffset+shpFile.getUint32(i, Endian.little)+4);
      //log("poffset : $currentOffset : ${workList.last} :  ${currentOffset+ShpPolygonOffsets.getPoints(numparts)}  ");
    }
    return workList;
    


  }

  BBox2D getPolyBBox(int currentOffset)
  {

    return new BBox2D.fill(
      shpFile.getFloat64(currentOffset+ShpPolygonOffsets.Box+(8*0),Endian.little),
      shpFile.getFloat64(currentOffset+ShpPolygonOffsets.Box+(8*1), Endian.little),
      shpFile.getFloat64(currentOffset+ShpPolygonOffsets.Box+(8*2), Endian.little),
      shpFile.getFloat64(currentOffset+ShpPolygonOffsets.Box+(8*3), Endian.little)

    );
    //  polygon offset + intrapolygon box offset+ which boxpart * double_byte_size

  }

  int getPolyNumParts(int currentOffset)
  {

    return shpFile.getInt32(currentOffset+ShpPolygonOffsets.numParts, Endian.little);
  }

  int getPolyNumPoints(int currentOffset)
  {

    return shpFile.getInt32(currentOffset+ShpPolygonOffsets.numPoints, Endian.little);
  }

  ShpPolygon _parsePolygon(int currentOffset, int recordLength/*in bytes*/)
  {

    // MAke sure that the record header fits
    if(shpFile.getUint32(currentOffset+ShpPolygonOffsets.shapeType, Endian.little)==5)
    {
        if(currentOffset==null && globals.debug)
     {
       log("Currently unsupported format");
     }

    // PArse bounding box
    BBox2D boundingBox = getPolyBBox(currentOffset);

    // create work Polygon
    ShpPolygon workPoly = new ShpPolygon(boundingBox, getPolyNumParts(currentOffset) , getPolyNumPoints(currentOffset),shpFile.getUint32(currentOffset,Endian.big));
    

    // Generate offsets for each part
    List<int> partOffsetList =  getPartOffsets(currentOffset, workPoly.numParts);


    int endPoint;


    if((getFileLength()*2)-4>currentOffset+ShpPolygonOffsets.getNextPolyOffset(workPoly))
    {
      endPoint=currentOffset+ShpPolygonOffsets.getNextPolyOffset(workPoly);

    }else
    {
      endPoint=(getFileLength()*2)-4;
    }

    // go through each part by getting the offset for the first point
    for(int i=0; i< workPoly.numParts&&i<recordLength;i++)
    {
      
      // the offset for the current polygon  + the intrapolygon offset for parts + which part it is * int_byte_size

      int nextOffset;
      // set next Offset
      if(i<workPoly.numParts-1)
      {
        nextOffset=partOffsetList.elementAt(i+1);// HACK?
      }else
      {
        nextOffset=endPoint;
      }
      if(partOffsetList.elementAt(i)==currentOffset+ShpPolygonOffsets.getPoints(workPoly.numParts))
      {
        //log(" Match");
      }else
      {
        if(i==0 && globals.debug)
        {
          log( "Mismatch: ${ partOffsetList.elementAt(i)-currentOffset+ShpPolygonOffsets.getPoints(workPoly.numParts)}");
        }
      }
     
        workPoly.addPart(_parsePart(partOffsetList.elementAt(i)+( partOffsetList.elementAt(i)-currentOffset+ShpPolygonOffsets.getPoints(workPoly.numParts)),nextOffset));
    }
    return workPoly;
    }else
    {
      if(globals.debug)
        log("shape mismatch shape is ${shpFile.getUint32(currentOffset+ShpPolygonOffsets.shapeType,Endian.little)}");
        
      return null;
    }

    
  }

  List<ShpPolygon> parseAsPolygon()
  {
    List<ShpPolygon> polys = new List<ShpPolygon>();
    int filesizeInBytes = getFileLength()*2;
   

    int currentOffset=startOffset;
    ShpPolygon workPoly;


    //Parse record
    while(currentOffset<filesizeInBytes-4)
    {
      
      workPoly = _parsePolygon(currentOffset,shpFile.getUint32(currentOffset+ShpPolygonOffsets.length,Endian.big)*2);

      polys.add(workPoly);
      currentOffset+=ShpPolygonOffsets.getNextPolyOffset(workPoly);


    }
    if(globals.debug) 
      log('${polys.length} ShpPolygons parsed');

    return polys;

  }




}