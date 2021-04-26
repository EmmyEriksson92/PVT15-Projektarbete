import 'position.dart';

enum WGS84Format {Degrees, DegreesMinutes, DegreesMinutesSeconds}

class WGS84Position extends Position{

  WGS84Position.grid() : super.grid(Grid.wgs84);
  WGS84Position.full(double latitude, double longitude) : super.full(latitude, longitude, Grid.wgs84);

  WGS84Position.fault(String positionString, WGS84Format format) : super.grid(Grid.wgs84){
    if(format == WGS84Format.Degrees){
      positionString = positionString.trim();
      List<String> latLon = positionString.split(' ');
      if(latLon.length == 2){
        this.latitude = double.parse(latLon[0].replaceAll(',', '.'));
        this.longitude = double.parse(latLon[1].replaceAll(',', '.'));
      }else{
        throw new Exception('The position string is invalid'); //Check to make sure this is valid syntax, should be ParseException and have 0 after the string.
      }
    }else if (format == WGS84Format.DegreesMinutes || format == WGS84Format.DegreesMinutesSeconds) {
      int firstValueEndPos = 0;

      if(format == WGS84Format.DegreesMinutes)
        firstValueEndPos = positionString.indexOf("'");
      else if (format == WGS84Format.DegreesMinutesSeconds)
        firstValueEndPos = positionString.indexOf("\"");

      String lat = positionString.substring(0,firstValueEndPos +1).trim();
      String lon = positionString.substring(firstValueEndPos +1).trim();

      setLatitudeFromString(lat, format);
      setLongitudeFromString(lon,format);
    }
  }

  void setLatitudeFromString(String value, WGS84Format format) {
    value = value.trim();
    if(format == WGS84Format.DegreesMinutes)
      this.latitude = _parseValueFromDmString(value,"S");
    else if (format == WGS84Format.DegreesMinutesSeconds)
      this.latitude = _parseValueFromDmsString(value,"S");
    else if (format == WGS84Format.Degrees)
      this.latitude = double.parse(value);
  }

  void setLongitudeFromString(String value, WGS84Format format) {
    value = value.trim();
    if(format == WGS84Format.DegreesMinutes)
      this.longitude = _parseValueFromDmString(value,"W");
    else if (format == WGS84Format.DegreesMinutesSeconds)
      this.longitude = _parseValueFromDmsString(value,"W");
    else if (format == WGS84Format.Degrees)
      this.longitude = double.parse(value);
  }

  String latitudeToString(WGS84Format format) {
    if (format == WGS84Format.DegreesMinutes)
      return _convToDmString(this.latitude,"N","S");
    else if (format == WGS84Format.DegreesMinutesSeconds)
      return _convToDmsString(this.latitude,"N","S");
    else{
      return ("${this.latitude.toStringAsFixed(10)}"); //Locale.US
    }
  }

  String longitudeToString(WGS84Format format) {
    if (format == WGS84Format.DegreesMinutes)
      return _convToDmString(this.longitude,"E","W");
    else if (format == WGS84Format.DegreesMinutesSeconds)
      return _convToDmsString(this.longitude,"E","W");
    else{
      
      return ('${this.longitude.toStringAsFixed(10)}'); //Locale.US
    }
  }

  String _convToDmString(double value, String positiveValue, String negativeValue) {
    if (value == double.minPositive) {
      return "";
    }
    double degrees = value.abs().floorToDouble();
    double minutes = (value.abs() - degrees) * 60;

    
    return ('${value >=0 ? positiveValue : negativeValue}, $degrees\º, ${((minutes * 10000) / 10000).floorToDouble}\''); //Locale.US
  }

  String _convToDmsString(double value, String positiveValue,String negativeValue) {

    if(value == double.minPositive) {
      return "";
    }
    double degrees = value.abs().floorToDouble();
    double minutes = (value.abs() - degrees).floorToDouble() * 60;
    double seconds = (value.abs() - degrees - minutes / 60) * 3600;

    return ('${value >=0 ? positiveValue : negativeValue}, $degrees\º, $minutes\', ${((seconds * 100000) / 100000).round()}"'); //Locale.US
  }

  double _parseValueFromDmString(String value, String positiveChar) {
    double retVal = 0;
    if (!(value == null)) {
      if(value != "") {
        String direction = value.substring(0,1);
        value = value.substring(1).trim();

        String degree = value.substring(0,value.indexOf("º"));
        value = value.substring(value.indexOf("º") +1).trim();

        String minutes = value.substring(0,value.indexOf("'"));

        retVal = double.parse(degree);
        retVal += double.parse(minutes.replaceAll(",", ".")) / 60;

        if(retVal > 90) {
            retVal = double.minPositive;
        }
        if(direction == positiveChar || direction == "-") {
            retVal *= -1;
        }
      }
    }
    else {
      retVal = double.minPositive;
    }
    return retVal;
  }

  double _parseValueFromDmsString(String value, String positiveChar) {
    double retVal = 0;
    if(!(value == null)) {
      if(value != "") {
        String direction = value.substring(0,1);
        value = value.substring(1).trim();

        String degree = value.substring(0,value.indexOf("º"));
        value = value.substring(value.indexOf("º") +1).trim();

        String minutes = value.substring(0,value.indexOf("'"));
        value = value.substring(value.indexOf("'") + 1).trim();

        String seconds = value.substring(0,value.indexOf("\""));

        retVal = double.parse(degree);
        retVal += double.parse(minutes) / 60;
      
        retVal += double.parse(seconds.replaceAll(",", ".")) / 3600;
        
        if (retVal > 90) {
          retVal = double.minPositive;
          return retVal;
        }
        if(direction == positiveChar || direction == "-") {
          retVal *= -1;
        }
      }
    }
    else {
      retVal = double.minPositive;
    }
    return retVal;
  }

  @override
  String toString() {
    return ("Latitude: ${latitudeToString(WGS84Format.DegreesMinutesSeconds)}  Longitude: ${longitudeToString(WGS84Format.DegreesMinutesSeconds)}"); //Locale US
  }
}