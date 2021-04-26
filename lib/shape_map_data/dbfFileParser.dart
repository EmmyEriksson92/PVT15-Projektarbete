

import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:convert';

enum SociotopQuality { Gron_oas,	Lekplats,	Naturlek,	Promenader,Rofylldhet,	Blomprakt,	Bollspel,	Bollek,	Parklek, Picknick_S,	Grillning,	Pulkaaknin,	Odling,	Loptraning,	Skogskansl,	Utsikt,	Djurhallni,	Vattenkont,	Utomhusbad,	Skridskoak,	Naturupple,	Evenemang,	Folkliv,	Torghandel,	Uteserveri,	Batliv,	Vattenlek,	Badanlaggn,	Skate_Bmx,	Utegym_Fri}

class SociotopDescription
{
  String name;
  String typeName;
  
  int area;
  String stadsDel;
  String stadsDelsOmrade;
  int numQualities;
  List<String> qualities;
  
  bool matchQuality(String quality)
  {
    return qualities.contains(quality);
  }
  @override
  String toString()
  {
      return "$name , $typeName , $area, $stadsDel , $stadsDelsOmrade , $numQualities vs ${qualities.length} , $qualities ";

  }

  SociotopDescription(this.name, this.typeName, this.area, this.stadsDel, this.stadsDelsOmrade, this.numQualities,this.qualities);

}


class DbfFileHeader
{



}

class DbfFieldDescriptor
{
  final String name;
  final String type;
  final int length;
  final int decimals;

  DbfFieldDescriptor(this.name,this.type,this.length, this.decimals);


  String toString()
  {
    return "åäöname:$name ,type:$type , length:$length decimals:$decimals";
  }

}


class DbfFileParser
{

  int noOfRecords;
  int headerSize;

  int fileVersion;

  List<DbfFieldDescriptor> descArray;

  ByteData dbfFile;


  List<int> getBytes(int offset, int bytes)
  {

    List<int> byteList=new List<int>();
    for(int i =0;i<bytes;i++)
    {

      byteList.add(dbfFile.getInt8(offset+i));
    }
    return byteList;
  }


  List<int> buildRecordData()
  {
    List<int> workList = new List<int>();


    
    return workList;
  }

  List<int> getLatin(List<int> text)
  {
    for(int i=0; i<text.length;i++)
    {switch(text.elementAt(i))
    {
      case 00:// spacebar
        text.removeAt(i);
        text.insert(i, 0x20);
        break;
      case -27: //å
        text.removeAt(i);
        text.insert(i, 0xE5);
        break;
      case -59: //Å
        text.removeAt(i);
        text.insert(i, 0xC5);
        break;
      case -60://Ä
        text.removeAt(i);
        text.insert(i, 0xC6);
        break;
      case -28://ä
        text.removeAt(i);
        text.insert(i, 0xE4);
        break;

      case -10: //ö
        text.removeAt(i);
        text.insert(i, 0xF6);
        break;

        case -42://Ö
        text.removeAt(i);
        text.insert(i, 0xD6);
        break;
      default:break;
    }
     
    }
    return text;
  }

  DbfFieldDescriptor _parseFieldDescriptor(int fdOffset)
  {


      return DbfFieldDescriptor(Latin1Decoder(allowInvalid:true).convert(getLatin(getBytes(fdOffset,11))).trim(),
      Latin1Decoder().convert(getBytes(fdOffset+11,1)).trim(),
      dbfFile.getInt8(fdOffset+16),
      dbfFile.getInt8(fdOffset+17)
      );


  }


  void _parseFieldDescriptorArray()
  {
      descArray = new List<DbfFieldDescriptor>();

      int workOffset=32;
      int descriptorLength=32;
      if(fileVersion==3)
      {
        workOffset=32;
      }
      while(workOffset+descriptorLength<=headerSize)
      {

          descArray.add(_parseFieldDescriptor(workOffset));
          workOffset+=descriptorLength;
      }



  }

  DbfFileParser(this.dbfFile);



    /* File Header
      Byte 	Contents 	Description
      0 	1 byte 	Valid dBASE III PLUS table file (03h without a memo .DBT file; 83h with a memo).
      1-3 	3 bytes 	Date of last update; in YYMMDD format.
      4-7 	32-bit number 	Number of records in the table.
      8-9 	16-bit number 	Number of bytes in the header.
      10-11 	16-bit number 	Number of bytes in the record.
      12-14 	3 bytes 	Reserved bytes.
      15-27 	13 bytes 	Reserved for dBASE III PLUS on a LAN.
      28-31 	4 bytes 	Reserved bytes.
      32-n 	32 bytes 	Field descriptor array (the structure of this array is each shown below)
      n+1 	1 byte 	0Dh stored as the field terminator. 
    */

  List<SociotopDescription> parse()
  {

    parseHeader();

    return parseRecords();

  }

  void parseHeader()
  {
    
    
    //get ValidByte
    fileVersion=dbfFile.getInt8(0);

    // getDate

    // get no of Records
    noOfRecords=dbfFile.getUint32(4,Endian.little);

    // get no of bytes in header
    headerSize= dbfFile.getUint16(8, Endian.little);

    //get no of bytes for records


    // get field descriptor array. 
    _parseFieldDescriptorArray();



  }

  SociotopDescription _parseRecord(int workOffset)
  {

    
    String workString;


    String namn;
    String typ;
    int area;
    String stadsdel;
    String stadsdelso;
    int kvaliteCount;
    List<String> kvaliteer=new List<String>();
    for(int i =0; i< descArray.length; i++)
    {
      workString=Latin1Decoder(allowInvalid: true).convert(getLatin(getBytes(workOffset,descArray.elementAt(i).length))).trim();

      switch(descArray.elementAt(i).name.trim())
      {


      case "Namn":
        namn=workString;break;
      case "Typ":
        typ=workString;break;
      case "Area":
        area=int.parse(workString);break;
      case "Stadsdel":
        stadsdel=workString;break;
      case "Stadsdelso":
        stadsdelso=workString;break;
      case "Antal_kval":
      kvaliteCount=int.parse(workString);break;
      // kvaliteer
      default:if(double.parse(workString)>0.5){kvaliteer.add(descArray.elementAt(i).name.trim());}break;
      
        
      }
      
    

      workOffset+=descArray.elementAt(i).length;
    }

    return new SociotopDescription(namn, typ, area, stadsdel,stadsdelso, kvaliteCount, kvaliteer);
  }

  List<SociotopDescription> parseRecords()
  {
    List<SociotopDescription> workList=new List<SociotopDescription>();
    int workOffset=headerSize+1;
    int recordLen=getRecordLength();

    for(int i=0;i<noOfRecords; i++)
    {
      workList.add(_parseRecord(workOffset));
      workOffset+=recordLen+1;// empty space between each record
    }

  return workList;

  }



  int getRecordLength()
  {
    int rVal=0;
    for(int i =0; i<descArray.length; i++)
    {
      rVal+=descArray.elementAt(i).length;
    }
    return rVal;
  }




}