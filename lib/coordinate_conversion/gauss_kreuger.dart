import 'dart:math';
import 'dart:core';

class GaussKreuger{
  double _axis;
  double _flattening;
  double _centralMeridian;
  double _scale;
  double _falseNorthing;
  double _falseEasting;

  void swedishParams(String projection){

    //RT90 parameters and GRS80 ellipsoid
    if (projection == "rt90_7.5_gon_v") {
      _grs80Params();
      _centralMeridian = 11.0 + 18.375 / 60.0;
      _scale = 1.000006000000;
      _falseNorthing = -667.282;
      _falseEasting = 1500025.141;
    } else if (projection == "rt90_5.0_gon_v") {
      _grs80Params();
      _centralMeridian = 13.0 + 33.376 / 60.0;
      _scale = 1.000005800000;
      _falseNorthing = -667.130;
      _falseEasting = 1500044.695;
    } else if (projection == "rt90_2.5_gon_v") {
      _grs80Params();
      _centralMeridian = 15.0 + 48.0 / 60.0 + 22.624306 / 3600.0;
      _scale = 1.00000561024;
      _falseNorthing = -667.711;
      _falseEasting = 1500064.274;
    } else if (projection == "rt90_0.0_gon_v") {
      _grs80Params();
      _centralMeridian = 18.0 + 3.378 / 60.0;
      _scale = 1.000005400000;
      _falseNorthing = -668.844;
      _falseEasting = 1500083.521;
    } else if (projection == "rt90_2.5_gon_o") {
      _grs80Params();
      _centralMeridian = 20.0 + 18.379 / 60.0;
      _scale = 1.000005200000;
      _falseNorthing = -670.706;
      _falseEasting = 1500102.765;
    } else if (projection == "rt90_5.0_gon_o") {
      _grs80Params();
      _centralMeridian = 22.0 + 33.380 / 60.0;
      _scale = 1.000004900000;
      _falseNorthing = -672.557;
      _falseEasting = 1500121.846;
    } 
    
    /////////////////////////////////////////////////////////////////////
    //RT90 parameters and Bessel 1841 ellipsoid
    else if (projection == "bessel_rt90_7.5_gon_v") {
      _besselParams();
      _centralMeridian = 11.0 + 18.0 / 60.0 + 29.8 / 3600.0;
    } else if (projection == "bessel_rt90_5.0_gon_v") {
      _besselParams();
      _centralMeridian = 13.0 + 33.0 / 60.0 + 29.8 / 3600.0;
    } else if (projection == "bessel_rt90_2.5_gon_v") {
      _besselParams();
      _centralMeridian = 15.0 + 48.0 / 60.0 + 29.8 / 3600.0;
    } else if (projection == "bessel_rt90_0.0_gon_v") {
      _besselParams();
      _centralMeridian = 18.0 + 3.0 / 60.0 + 29.8 / 3600.0;
    } else if (projection == "bessel_rt90_2.5_gon_o") {
      _besselParams();
      _centralMeridian = 20.0 + 18.0 / 60.0 + 29.8 / 3600.0;
    }else if (projection == "bessel_rt90_5.0_gon_o") {
      _besselParams();
      _centralMeridian = 22.0 + 33.0 / 60.0 + 29.8 / 3600.0;
    }

    /////////////////////////////////////////////////////////////////////
    //SWEREF99TM and SWEREF99ddmm parameters
    else if (projection == "sweref_99_tm") {
      _sweref99Params();
      _centralMeridian = 15.00;
      _scale = 0.9996;
      _falseNorthing = 0.0;
      _falseEasting = 500000.0;
    } else if (projection == "sweref_99_1200") {
      _sweref99Params();
      _centralMeridian = 12.00;
    } else if (projection == "sweref_99_1330") {
      _sweref99Params();
      _centralMeridian = 13.50;
    } else if (projection == "sweref_99_1500") {
      _sweref99Params();
      _centralMeridian = 15.00;
    } else if (projection == "sweref_99_1630") {
      _sweref99Params();
      _centralMeridian = 16.50;
    } else if (projection == "sweref_99_1800") {
      _sweref99Params();
      _centralMeridian = 18.00;
    } else if (projection == "sweref_99_1415") {
      _sweref99Params();
      _centralMeridian = 14.25;
    } else if (projection == "sweref_99_1545") {
      _sweref99Params();
      _centralMeridian = 15.75;
    } else if (projection == "sweref_99_1715") {
      _sweref99Params();
      _centralMeridian = 17.25;
    } else if (projection == "sweref_99_1845") {
      _sweref99Params();
      _centralMeridian = 18.75;
    } else if (projection == "sweref_99_2015") {
      _sweref99Params();
      _centralMeridian = 20.25;
    } else if (projection == "sweref_99_2145") {
      _sweref99Params();
      _centralMeridian = 21.75;
    } else if (projection == "sweref_99_2315") {
      _sweref99Params();
      _centralMeridian = 23.25;
    } else {
      _centralMeridian = double.minPositive;
    }
  }

  /////////////////////////////////////////////////////////////////////
  //DEFAULT PARAMETERS

  void _grs80Params() {
    _axis = 6378137.0; // GRS 80.
    _flattening = 1.0 / 298.257222101; // GRS 80.
    _centralMeridian = double.minPositive;
  }

  void _besselParams() {
    _axis = 6377397.155; // Bessel 1841.
    _flattening = 1.0 / 299.1528128; // Bessel 1841.
    _centralMeridian = double.minPositive;
    _scale = 1.0;
    _falseNorthing = 0.0;
    _falseEasting = 1500000.0;
  }

  void _sweref99Params() {
    _axis = 6378137.0; // GRS 80.
    _flattening = 1.0 / 298.257222101; // GRS 80.
    _centralMeridian = double.minPositive;
    _scale = 1.0;
    _falseNorthing = 0.0;
    _falseEasting = 150000.0;
  }

  /////////////////////////////////////////////////////////////////////
  //CONVERSION FROM GEODETIC COORDINATES TO GRID COORDINATES
  
  List<double> geodeticToGrid (double latitude, double longitude){
    List<double> xy = new List<double>(2);

    // Prepare ellipsoid-based stuff
    double e2 = _flattening * (2.0 - _flattening);
    double n = _flattening / (2.0 - _flattening);
    double aRoof = _axis / (1.0 + n) * (1.0 + n * n / 4.0 + n * n * n * n / 64.0);
    double a = e2;
    double b = (5.0 * e2 * e2 - e2 * e2 * e2) / 6.0;
    double c = (104.0 * e2 * e2 * e2 - 45.0 * e2 * e2 * e2 * e2) / 120.0;
    double d = (1237.0 * e2 * e2 * e2 * e2) / 1260.0;
    double beta1 = n / 2.0 - 2.0 * n * n / 3.0 + 5.0 * n * n * n / 16.0 + 41.0 * n * n * n * n / 180.0;
    double beta2 = 13.0 * n * n / 48.0 - 3.0 * n * n * n / 5.0 + 557.0 * n * n * n * n / 1440.0;
    double beta3 = 61.0 * n * n * n / 240.0 - 103.0 * n * n * n * n / 140.0;
    double beta4 = 49561.0 * n * n * n * n / 161280.0;

    // Convert
    double degToRad = pi / 180.0;
    double phi = latitude * degToRad;
    double lambda = longitude * degToRad;
    double lambdaZero = _centralMeridian * degToRad;

    double phiStar = phi - sin(phi) * cos(phi) * (a +
      b * pow(sin(phi), 2) +
      c * pow(sin(phi), 4) +
      d * pow(sin(phi), 6));
    double deltaLambda = lambda - lambdaZero;
    double xiPrim = atan(tan(phiStar) / cos(deltaLambda));
    double etaPrim = mathAtanh(cos(phiStar) * sin(deltaLambda));
    double x = _scale * aRoof * (xiPrim +
      beta1 * sin(2.0 * xiPrim) * mathCosh(2.0 * etaPrim) +
      beta2 * sin(4.0 * xiPrim) * mathCosh(4.0 * etaPrim) +
      beta3 * sin(6.0 * xiPrim) * mathCosh(6.0 * etaPrim) +
      beta4 * sin(8.0 * xiPrim) * mathCosh(8.0 * etaPrim)) +
      _falseNorthing;
    double y = _scale * aRoof * (etaPrim +
      beta1 * cos(2.0 * xiPrim) * mathSinh(2.0 * etaPrim) +
      beta2 * cos(4.0 * xiPrim) * mathSinh(4.0 * etaPrim) +
      beta3 * cos(6.0 * xiPrim) * mathSinh(6.0 * etaPrim) +
      beta4 * cos(8.0 * xiPrim) * mathSinh(8.0 * etaPrim)) +
      _falseEasting;
    xy[0] = (x * 1000.0).roundToDouble() / 1000.0;
    xy[1] = (y * 1000.0).roundToDouble() / 1000.0;

    return xy;
  }

  /////////////////////////////////////////////////////////////////////
  // CONVERSION FROM GRID COORDINATES TO GEODETIC COORDINATES

  List<double> gridToGeodetic (double x, double y){
    List<double> latLon = new List<double>(2);
    if (_centralMeridian == double.minPositive) {
      return latLon;
    }
    // Prepare ellipsoid-based stuff
    double e2 = _flattening * (2.0 - _flattening);
    double n = _flattening / (2.0 - _flattening);
    double aRoof = _axis / (1.0 + n) * (1.0 + n * n / 4.0 + n * n * n * n / 64.0);
    double delta1 = n / 2.0 - 2.0 * n * n / 3.0 + 37.0 * n * n * n / 96.0 - n * n * n * n / 360.0;
    double delta2 = n * n / 48.0 + n * n * n / 15.0 - 437.0 * n * n * n * n / 1440.0;
    double delta3 = 17.0 * n * n * n / 480.0 - 37 * n * n * n * n / 840.0;
    double delta4 = 4397.0 * n * n * n * n / 161280.0;

    double astar = e2 + e2 * e2 + e2 * e2 * e2 + e2 * e2 * e2 * e2;
    double bstar = -(7.0 * e2 * e2 + 17.0 * e2 * e2 * e2 + 30.0 * e2 * e2 * e2 * e2) / 6.0;
    double cstar = (224.0 * e2 * e2 * e2 + 889.0 * e2 * e2 * e2 * e2) / 120.0;
    double dstar = -(4279.0 * e2 * e2 * e2 * e2) / 1260.0;

     // Convert
    double degToRad = pi / 180;
    double lambdaZero = _centralMeridian * degToRad;
    double xi = (x - _falseNorthing) / (_scale * aRoof);
    double eta = (y - _falseEasting) / (_scale * aRoof);
    double xiPrim = xi -
      delta1 * sin(2.0 * xi) * mathCosh(2.0 * eta) -
      delta2 * sin(4.0 * xi) * mathCosh(4.0 * eta) -
      delta3 * sin(6.0 * xi) * mathCosh(6.0 * eta) -
      delta4 * sin(8.0 * xi) * mathCosh(8.0 * eta);
    double etaPrim = eta -
      delta1 * cos(2.0 * xi) * mathSinh(2.0 * eta) -
      delta2 * cos(4.0 * xi) * mathSinh(4.0 * eta) -
      delta3 * cos(6.0 * xi) * mathSinh(6.0 * eta) -
      delta4 * cos(8.0 * xi) * mathSinh(8.0 * eta);
    double phiStar = asin(sin(xiPrim) / mathCosh(etaPrim));
    double deltaLambda = atan(mathSinh(etaPrim) / cos(xiPrim));
    double lonRadian = lambdaZero + deltaLambda;
    double latRadian = phiStar + sin(phiStar) * cos(phiStar) *
      (astar +
      bstar * pow(sin(phiStar), 2) +
      cstar * pow(sin(phiStar), 4) +
      dstar * pow(sin(phiStar), 6));
    latLon[0] = latRadian * 180.0 / pi;
    latLon[1] = lonRadian * 180.0 / pi;
    return latLon;
  }

  double mathSinh(double value) {
    return 0.5 * (exp(value) - exp(-value));
  }

  double mathCosh(double value) {
    return 0.5 * (exp(value) + exp(-value));
  }

  double mathAtanh(double value) {
    return 0.5 * log((1.0 + value) / (1.0 - value));
  }
}