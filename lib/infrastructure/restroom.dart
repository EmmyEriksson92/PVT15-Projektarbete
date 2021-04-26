class Restroom {
  final String type;
  final int totalFeatures;
  final List<Features> features;
  

  Restroom({
    this.type,
    this.totalFeatures,
    this.features,
  });

  factory Restroom.fromJson(Map<String, dynamic> json) {
    return Restroom(
      type: json['type'],
      totalFeatures: json['totalFeatures'],
      features: parseFeatures(json),
    );
  }

  static List<Features> parseFeatures(featuresJson){
    var list = featuresJson['features'] as List;
    List<Features> featureList = list.map((data) => Features.fromJson(data)).toList();
    return featureList;
  }
}

/////////////////////////////////////////////////////////////////////
class Features{
  String type;
  String id;
  Geometry geometry;
  String geometryName;
  Property properties;

  Features({
    this.type,
    this.id,
    this.geometry,
    this.geometryName,
    this.properties,
  });

  factory Features.fromJson(Map<String, dynamic> parsedJson){
    return Features(
      type: parsedJson['type'],
      id: parsedJson['id'],
      geometry: Geometry.fromJson(parsedJson['geometry']),
      geometryName: parsedJson['geometry_name'],
      properties: Property.fromJson(parsedJson['properties']),
    );
  }

  static List<Geometry> parseGeometry(geometryJson){
    var list = geometryJson['geometry'] as List;
    List<Geometry> geometryList = list.map((data) => Geometry.fromJson(data)).toList();
    return geometryList;
  }
}

/////////////////////////////////////////////////////////////////////
class Geometry{
  String type;
  List coordinates;

  Geometry({
    this.type,
    this.coordinates,
  });

  factory Geometry.fromJson(Map<String, dynamic> parsedJson){
    return Geometry(
      type: parsedJson['type'],
      coordinates: parsedJson['coordinates'],
    );
  }
}

/////////////////////////////////////////////////////////////////////
class Property{
  int objectId;
  int versionId;
  String featureTypeName;
  int featureTypeObjectId;
  int featureTypeVersionId;
  String mainAttributeName;
  String mainAttributeValue;
  String mainAttributeDescription;
  String index;
  String adress;
  String status;
  String typ;
  String beskrivning;
  String farg;
  String driftansvar;
  String huvudman;
  String bilaga;
  int validFrom;
  int validTo;
  int cid;
  int createDate;
  int changeDate;

  Property({
    this.objectId,
    this.versionId,
    this.featureTypeName,
    this.featureTypeObjectId,
    this.featureTypeVersionId,
    this.mainAttributeName,
    this.mainAttributeValue,
    this.mainAttributeDescription,
    this.index,
    this.adress,
    this.status,
    this.typ,
    this.beskrivning,
    this.farg,
    this.driftansvar,
    this.huvudman,
    this.bilaga,
    this.validFrom,
    this.validTo,
    this.cid,
    this.createDate,
    this.changeDate,
  });

  factory Property.fromJson(Map<String, dynamic> parsedJson){
    return Property(
      objectId: parsedJson['OBJECT_ID'],
      versionId: parsedJson['VERSION_ID'],
      featureTypeName: parsedJson['FEATURE_TYPE_NAME'],
      featureTypeObjectId: parsedJson['FEATURE_TYPE_OBJECT_ID'],
      featureTypeVersionId: parsedJson['FEATURE_TYPE_VERSION_ID'],
      mainAttributeName: parsedJson['MAIN_ATTRIBUTE_NAME'],
      mainAttributeValue: parsedJson['MAIN_ATTRIBUTE_VALUE'],
      mainAttributeDescription: parsedJson['MAIN_ATTRIBUTE_DESCRIPTION'],
      index: parsedJson['Index'],
      adress: parsedJson['Adress'],
      status: parsedJson['Status'],
      typ: parsedJson['Typ'],
      beskrivning: parsedJson['Beskrivning'],
      farg: parsedJson['Färg'],
      driftansvar: parsedJson['Driftansvar'],
      huvudman: parsedJson['Huvudman'],
      bilaga: parsedJson['Bilaga'],
      validFrom: parsedJson['VALID_FROM'],
      validTo: parsedJson['VALID_TO'],
      cid: parsedJson['CID'],
      createDate: parsedJson['CREATE_DATE'],
      changeDate: parsedJson['CHANGE_DATE'],
    );
  }
}