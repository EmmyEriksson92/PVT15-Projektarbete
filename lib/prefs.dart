
library pvt15.prefs;

import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs
{
  SharedPreferences prefs;
  static bool init=false;
  static  int value=0;
  static int unbufferedValue=0;

  static Prefs instance;
  

  static Prefs getInstance()
  {
    if(instance!=null)
    {
      return instance;
    }
    else
    {
        instance=Prefs._();
    }
  }

  String getLanguage()
  {
    if(prefs.containsKey('Language'))
    {
      return prefs.getString('Language');
    }else{
      return "SWE";

     }
  }

  Prefs._()
  {
    Init();
  }
  
  
   void Init() async
  {
    prefs= await SharedPreferences.getInstance();
  }

  

  // Saves at position locally so that it can be used as a starting point
void _savePostion(Position previousPostion) async
{
  if(previousPostion !=null)
  {
    prefs.setDouble("LastPositionLongitude", previousPostion.longitude);
    prefs.setDouble("LastPositionLatitude", previousPostion.latitude);

  }
  

}
// Loads a last known position from memory so that the map can be used with out GPS turned on
positionLoadPreviousPostion() 
{

  return Position();

  
}

double loadLastLatitude()
{
  if(prefs.containsKey('LastLatitude'))
  {
    return prefs.getDouble('LastLatitude');
  }else{
    return 0.00;
  }
}


double loadLastLongitude()
{
  if(prefs.containsKey('LastLongitude'))
  {
    return prefs.getDouble('LastLongitude');
  }else{
    return 0.00;
  }
}



// Wrappers for SharedPreferences

bool getBool(String key)
{
  return prefs.getBool(key);
}

bool containsKey(String key)
{
  return prefs.containsKey(key);
}

int getInt(String key)
{
  return prefs.getInt(key);
}

double getDouble(String key)
{
  return prefs.getDouble(key);
}

String getString(String key)
{
  return prefs.getString(key);
}

List<String> getStringList(String key)
{
  return prefs.getStringList(key);
}

  
  void _persistAndIncrement() async{

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(prefs.getInt('counter')!=null)
    {
      value =prefs.getInt('counter');
    }

    Prefs.value+=1;
    unbufferedValue+=1;
     prefs.setInt('counter', value);// async
    if(prefs.getInt('counter')==Prefs.value&& Prefs.value==unbufferedValue)
    {
      print( "buffered matches last saved");
    }else{
      print("mismatch: ");
    }
    print(Prefs.value.toString() + " : "+ prefs.getInt('counter').toString()+ " : "+ unbufferedValue.toString());

    //_getValue();
  }
}