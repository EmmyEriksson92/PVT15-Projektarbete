abstract class Position{
  
  double latitude;
  double longitude;
  Grid gridFormat;

  Position.full(double latitude, double longitude, Grid gridformat){
    this.latitude = latitude;
    this.longitude = longitude;
    this.gridFormat = gridFormat;
  }

  Position.grid(Grid gridFormat){
    this.gridFormat = gridFormat;
  }

  Position();

  double get lat{
    return latitude;
  }

  double get long{
    return longitude;
  }
}

enum Grid{
  rt90,
  wgs84,
  sweref99
}