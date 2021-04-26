import 'package:pvt_15/coordinate_conversion/gauss_kreuger.dart';
import 'package:pvt_15/coordinate_conversion/position.dart';
import 'package:pvt_15/coordinate_conversion/wgs84_position.dart';

enum SWEREFProjection {
  sweref_99_tm,
  sweref_99_12_00,
  sweref_99_13_30,
  sweref_99_15_00,
  sweref_99_16_30,
  sweref_99_18_00,
  sweref_99_14_15,
  sweref_99_15_45,
  sweref_99_17_15,
  sweref_99_18_45,
  sweref_99_20_15,
  sweref_99_21_45,
  sweref_99_23_15
}

class SWEREF99Position extends Position{

  SWEREFProjection _projection;

  SWEREF99Position.full(double n, double e) : super.full(n, e, Grid.sweref99){
    this._projection = SWEREFProjection.sweref_99_18_00;
  }
  SWEREF99Position.projection(double n, double e, SWEREFProjection projection) : super.full(n, e, Grid.sweref99){
    this._projection = projection;
  }
  SWEREF99Position.grid(WGS84Position position, SWEREFProjection projection) : super.grid(Grid.sweref99){
        GaussKreuger gkProjection = new GaussKreuger();
        gkProjection.swedishParams(_getProjectionString(projection));
        List<double> latLon = gkProjection.geodeticToGrid(position.lat, position.long);
        this.latitude = latLon[0];
        this.longitude = latLon[1];
        this._projection = projection;
  }

  WGS84Position toWGS84() {
    GaussKreuger gkProjection = new GaussKreuger();
    gkProjection.swedishParams(_getProjectionString(this._projection));
    List<double> latLon = gkProjection.gridToGeodetic(this.latitude, this.longitude);
    WGS84Position newPos = new WGS84Position.full(latLon[0], latLon[1]);

    return newPos;
  }

  String getProjectionString(){
    return _getProjectionString(this._projection);
  }

  String _getProjectionString(SWEREFProjection projection){
    String retVal;
    switch(projection){
      case SWEREFProjection.sweref_99_tm:
        retVal = "sweref_99_tm";
        break;
      case SWEREFProjection.sweref_99_12_00:
        retVal = "sweref_99_1200";
        break;
      case SWEREFProjection.sweref_99_13_30:
        retVal = "sweref_99_1330";
        break;
      case SWEREFProjection.sweref_99_14_15:
        retVal = "sweref_99_1415";
        break;
      case SWEREFProjection.sweref_99_15_00:
        retVal = "sweref_99_1500";
        break;
      case SWEREFProjection.sweref_99_15_45:
        retVal = "sweref_99_1545";
        break;
      case SWEREFProjection.sweref_99_16_30:
        retVal = "sweref_99_1630";
        break;
      case SWEREFProjection.sweref_99_17_15:
        retVal = "sweref_99_1715";
        break;
      case SWEREFProjection.sweref_99_18_00:
        retVal = "sweref_99_1800";
        break;
      case SWEREFProjection.sweref_99_18_45:
        retVal = "sweref_99_1845";
        break;
      case SWEREFProjection.sweref_99_20_15:
        retVal = "sweref_99_2015";
        break;
      case SWEREFProjection.sweref_99_21_45:
        retVal = "sweref_99_2145";
        break;
      case SWEREFProjection.sweref_99_23_15:
        retVal = "sweref_99_2315";
        break;
      default:
        retVal = "sweref_99_tm";
        break;
    }
    return retVal;
  }

  @override
  String toString() {
    return ("N: ${this.latitude} E: ${this.longitude} Projection: ${getProjectionString()}"); //Locale.US
  }
}