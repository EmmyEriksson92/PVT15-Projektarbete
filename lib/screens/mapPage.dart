//Imports from defualt dart packages
import 'dart:async';
import 'dart:developer';

//Imports from default flutter packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/rendering.dart';

//Imports from external packages
import 'package:dropdownfield/dropdownfield.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong/latlong.dart' as distance;

//Imports from local files
import 'package:pvt_15/app_localizations.dart';
import 'package:pvt_15/facebookShare.dart';
import 'package:pvt_15/globals.dart' as globals;
import 'package:pvt_15/infrastructure/firebase_auth.dart';
import 'package:pvt_15/map_markers/markers_to_list.dart';
import 'package:pvt_15/polygons/points_to_polygon.dart';
import 'package:pvt_15/polygons/toggle_polygons.dart';
import 'package:pvt_15/screens/accountPage.dart';
import 'package:pvt_15/screens/filter.dart';
import 'package:pvt_15/screens/reportPage.dart';
import 'package:pvt_15/screens/reviewPage.dart';
import 'package:pvt_15/screens/settings_menu.dart';
import 'package:pvt_15/shape_map_data/sociotopMap.dart';
import 'package:pvt_15/size_config.dart';
import 'package:pvt_15/map_markers/toggle_markers.dart';
import 'package:pvt_15/modules/gps_position.dart';
import 'package:pvt_15/modules/helpers.dart' as helper;


enum ConfirmAction { Cancel, Delete }

class MapPage extends StatefulWidget {
  AuthFunc auth;
  VoidCallback onSignOut;
  String userId, userEmail;

  MapPage({Key key, this.auth, this.onSignOut, this.userEmail, this.userId})
      : super(key: key);

  @override
  State<MapPage> createState() {
    globals.currentMapState = MapPageState();
    return globals.currentMapState;
  }
}

class MapPageState extends State<MapPage> {
  /////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///VARIABLES START ---------- PUT VARIABLES BELOW IN SIMILAR GROUPINGS AND ALPHABETICAL ORDER

  //BitmapDescriptors
  BitmapDescriptor destinationIcon;
  BitmapDescriptor sourceIcon;
  BitmapDescriptor toiletIcon;

  //Boolean values
  bool _isEmailVerified = false;
  bool checked = false;
  bool _direction = false;
  bool favorite = false;
  bool placeSearched = true;

  //Colors
  Color favouriteButtonColor = Colors.grey;

  //Keys
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  //Strings
  String _currentItemSelected = "Alfabetisk ordning";
  String chosenFavouritePlace = '';
  String _googleAPIKey = 'AIzaSyAkN0ek8rOvIGgSie0h8PxTS1VHzETPwuc';
  String input = "";
  String _mapStyle;
  String message = '';
  String selectPlace = '';
  String value = "";
  String quals = "";
  String image = "";
  String date;
  String name = "";
  String facebookShareURL;

  //Ints
  int navigationIndex = 0;
  int photoIndex = 0;

  //Lists
  List<LatLng> polylineCoordinates = [];
  List<String> favouritePlaces = [];
  List<String> places = ["Park 1", "Park 2", "Park 3", "Park 4", "Hej"];
  List<String> dates = [];
  List<String> images = [
    "assets/images/4h.jpg",
    "assets/images/4h1.jpg",
    "assets/images/4h2.jpg"
  ];
  List<String> imagesBathing = [
    "assets/images/bathing1.jpg",
    "assets/images/bathing2.jpg",
    "assets/images/bathing3.jpg"
  ];
  List<String> imagesPark = [
    "assets/images/park.jpg",
    "assets/images/park1.jpg",
    "assets/images/park2.jpg"
  ];
  List<String> imagesParkPlay = [
    "assets/images/parkPlay1.jpg",
    "assets/images/parkPlay2.jpg",
    "assets/images/parkPlay3.jpg"
  ];
  List<String> items = ["Alfabetisk ordning", "Tilläggsdatum"];

  //Map related
  MapType _currentMapType = MapType.normal;
  PolylinePoints polylinePoints = PolylinePoints();

  //Controllers
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController _mapController;
  ScrollController scrollViewColtroller = ScrollController();
  TextEditingController myController;

  ///VARIABLES END ---------- PUT VARIABLES ABOVE IN SIMILAR GROUPINGS AND ALPHABETICAL ORDER
  /////////////////////////////////////////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();
    _setToiletIcon();
    addMarkers();
    _setMapStyle();
    getWorkMap();
    addPolygons(this);
    _checkEmailVerification();
    _setScrollViewController();
  }

  @override
  void dispose() {
    super.dispose();
    scrollViewColtroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      drawer: MyFilterPage(),
      key: _drawerKey,
      bottomNavigationBar: createBottomBar(context),
      body: Stack(children: <Widget>[
        createMapView(context),
        Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
                alignment: Alignment.topRight,
                child: SingleChildScrollView(
                  child: Column(
                    children: createRightMenu(context),
                  ),
                ))),
        createSearchbarPositioned(context),
        createDrawer(context),
      ]),
    );
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///GOOGLE MAP START

  //Creates the map view
  GoogleMap createMapView(context) {
    return GoogleMap(
      onTap: (LatLng a) {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      onMapCreated: _onMapCreated,
      initialCameraPosition: _myCurrentPosition,

      //OPTIONS
      padding: const EdgeInsets.only(top: 20.0),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      compassEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: false,

      //VARIABLES
      mapType: _currentMapType,
      markers: Set.from(globals.markers),
      polylines: Set<Polyline>.of(globals.polylines.values),
      polygons: Set.from(globals.areas),
    );
  }

  //Variable that provides current position and camera zoom.
  CameraPosition _myCurrentPosition = CameraPosition(
    target: LatLng(
        globals.currentPosition.latitude ??
            globals.lastKnownPosition.latitude ??
            59.32537100000000,
        globals.currentPosition.longitude ??
            globals.lastKnownPosition.longitude ??
            18.06555300000000),
    zoom: 15.151926040649414,
  );

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController.setMapStyle(_mapStyle);
    if (!_controller.isCompleted) _controller.complete(controller);
  }

  void _getPolyline(String placeName) async {
    PolylinePoints polylinePoints = PolylinePoints();
    LatLng destPoint =
        globals.workSocMap.getByName(placeName).mapArea.getAverageWGs84();
    PolylineResult result;
    result = await polylinePoints.getRouteBetweenCoordinates(
      _googleAPIKey,
      PointLatLng(
          globals.currentPosition.latitude, globals.currentPosition.longitude),
      PointLatLng(destPoint.latitude, destPoint.longitude),
      travelMode: TravelMode.walking,
      avoidHighways: true,
    );
    _addToResult(result, placeName);
  }

  void _addToResult(PolylineResult result, String placeName) {
    List<LatLng> line = [];
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        line.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      line.add(LatLng(
          globals.currentPosition.latitude, globals.currentPosition.longitude));
      line.add(
          globals.workSocMap.getByName(placeName).mapArea.getAverageWGs84());
      log(" ${result.errorMessage} path is empty ");
    }
    setState(() {
      _addPolyLine(line);
    });
  }

  //Creates the line on the map that marks the directions given to the user
  void _addPolyLine(List<LatLng> line) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: line,
        visible: true,
        width: 4,
        endCap: Cap.buttCap,
        startCap: Cap.roundCap);
    globals.polylines[id] = polyline;
  }

  //Toggles the display name of the button that toggles map view
  String map() {
    String string = "";
    if (_currentMapType == MapType.normal)
      string += "satellite";
    else
      string += "map";
    return string;
  }

  ///GOOGLE MAP END
  /////////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///LOGIN AND VERIFICATION START

  void signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignOut(); //call back
    } catch (e) {
      print(e);
    }
  }

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) _showVerifyEmailDialog();
  }

  //TODO: Got an error that this method was called before the innitstate was done.
  void _showVerifyEmailDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Text('Please verify your email'),
              content: new Text(
                  'We need you to verify your email to continue using this app'),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _sendVerifyEmail();
                    },
                    child: Text('Send')),
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Dismiss'))
              ]);
        });
  }

  void _sendVerifyEmail() {
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Text('Thank You'),
              content: new Text('Link to verify your email has been sent.'),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Ok'))
              ]);
        });
  }

  ///LOGIN AND VERIFICATION END
  /////////////////////////////////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///SEARCH START

  Positioned createSearchbarPositioned(BuildContext context) {
    return Positioned(
      top: 35,
      right: 15,
      left: 15,
      child: Container(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: DropDownField(
                    controller: myController,
                    hintText: AppLocalizations.of(context).translate('search'),
                    enabled: true,
                    items: globals.workSocMap.getPlaceNames(),
                    strict: false,
                    itemsVisibleInDropdown: 3,
                    onValueChanged: (dynamic value) {
                      selectPlace = value;
                      findArea(selectPlace);

                      log("$selectPlace searched for.");
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> createSearchRow(BuildContext context) {
    return [
      Text(AppLocalizations.of(context).translate('search')),
      IconButton(
        icon: Icon(Icons.search),
        onPressed: () {
          showSearch(context: context, delegate: DataSearch());
        },
      )
    ];
  }

  ///SEARCH END
  /////////////////////////////////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///ALERT DIALOG START / INFORMATION WINDOW START

  createAlertDialog(placeName, List<String> list) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                backgroundColor: Colors.grey[100],
                content: Container(
                    height: 550.0,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                        child: Column(children: <Widget>[
                      titleCloseDialogs(placeName, true),
                      Expanded(
                          child: Stack(children: [
                        showCarousel(list),
                        setPositionDots(),
                        Positioned(
                            top: 60.0,
                            left: 2.0,
                            right: 2.0,
                            child: Row(children: [
                              Expanded(
                                  child: IconButton(
                                      icon: Icon(Icons.keyboard_arrow_left,
                                          size: 40, color: Colors.white),
                                      onPressed: () {
                                        setState(() {
                                          photoIndex = photoIndex > 0
                                              ? photoIndex - 1
                                              : 0; //if first image, set to zero/Do nothing.
                                        });
                                      })),
                              SizedBox(width: 140),
                              IconButton(
                                  icon: Icon(Icons.keyboard_arrow_right,
                                      size: 40, color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      photoIndex =
                                          photoIndex < imagesParkPlay.length - 1
                                              ? photoIndex + 1
                                              : photoIndex;
                                    });
                                  })
                            ]))
                      ])),
                      SizedBox(height: 5),
                      showDistance(globals.workSocMap
                          .getByName(placeName)
                          .mapArea
                          .getAverageWGs84()),
                      SizedBox(height: 10),
                      showAreaInfrastructure(placeName),
                      SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          showAreaQualities(placeName),
                          SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              reviewsB(placeName),
                              SizedBox(height: 20),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Column(
                        children: [
                          rapportB(AppLocalizations.of(context)
                              .translate("report_problems")),
                          SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              titleSharePlace(),
                              SizedBox(height: 2),
                              Row(
                                children: <Widget>[
                                  Expanded(child: facebookIconShare(placeName)),
                                  messengerIconShare(),
                                  SizedBox(width: 30),
                                  createDirectionsButton(placeName),
                                ],
                              )
                            ],
                          )
                        ],
                      )
                    ]))));
          });
        });
  }

  Align createDirectionsButton(String placeName) {
    return Align(
        alignment: Alignment.bottomRight,
        child: RaisedButton(
          elevation: 10,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          onPressed: () {
            setState(() {
              _getPolyline(placeName);
              Navigator.pop(context, true);
            });
          },
          color: Colors.green,
          child: Text(AppLocalizations.of(context).translate('go_here'),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Calibri',
                  color: Colors.white,
                  fontSize: 16)),
        ));
  }

  Widget createFavoriteButton(String placeName) {
    return IconButton(
      icon: Icon(
        Icons.favorite,
        color: favouriteButtonColor,
      ),
      onPressed: () {
        if (!favouritePlaces.contains(placeName) &&
            placeName !=
                AppLocalizations.of(context).translate('favorite_places')) {
          favouritePlaces.add(placeName);
          setState(() {
            favouriteButtonColor = Colors.red;
            Navigator.pop(context, favouriteButtonColor);
          });
        } else {
          favouritePlaces.remove(placeName);
          setState(() {
            favouriteButtonColor = Colors.grey;
            favorite = false;
            Navigator.pop(context, favouriteButtonColor);
          });
        }
      },
    );
  }

  Widget titleSharePlace() {
    return Text(
      AppLocalizations.of(context).translate('share_place'),
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      textAlign: TextAlign.left,
    );
  }

  //TODO: DUPLICATED CODE. THIS CAN BE SHORTENED.
  //Shows the dialog window depending on which type used to call it.
  void showDialogbasedOnType(quals, String name) {
    if (globals.filterButtonsPressed['Djurhållni'] &&
        quals.contains('Djurhållni')) {
      createAlertDialog(name, images);
    } else if (globals.filterButtonsPressed['Parklek'] &&
        quals.contains('Parklek')) {
      createAlertDialog(name, imagesParkPlay);
    } else if (globals.filterButtonsPressed['Utomhusbad'] &&
        quals.contains('Utomhusbad')) {
      createAlertDialog(name, imagesBathing);
    } else if (globals.filterButtonsPressed['Lekplats'] &&
        quals.contains('Lekplats')) {
      createAlertDialog(name, imagesParkPlay);
    } else if (globals.filterButtonsPressed['Sökning']) {
      if (quals.contains('Djurhållni')) {
        createAlertDialog(name, images);
      } else if (quals.contains('Parklek')) {
        createAlertDialog(name, imagesParkPlay);
      } else if (quals.contains('Utomhusbad')) {
        createAlertDialog(name, imagesBathing);
      } else if (quals.contains('Lekplats')) {
        createAlertDialog(name, imagesParkPlay);
      }
    }
  }

  //Shows if there is a toilet in or nearby the area
  Container showAreaInfrastructure(String placeName) {
    return Container(
      child: Row(
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            showCheckInf(
                AppLocalizations.of(context).translate('toilet'),
                0.0,
                helper.isToiletNearby(
                    globals.workSocMap
                        .getByName(placeName)
                        .mapArea
                        .getAverageWGs84(),
                    200)),
          ]),
          SizedBox(width: 18),
          showRecoAge(AppLocalizations.of(context).translate('all_ages'))
        ],
      ),
    );
  }

  showDialogForToilet(String adress) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                backgroundColor: Colors.grey[100],
                content: Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(50)),
                    height: 550.0,
                    width: double.maxFinite,
                    child: ListView(children: <Widget>[
                      titleCloseDialogs(adress, false),
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top: 8.0),
                          height: 150.0,
                          width: 250,
                          decoration: BoxDecoration(
                            color: Color(0xFF333BFF),
                            image: DecorationImage(
                              image: AssetImage("assets/images/wc.png"),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        showIsAviAdapt("50 m"),
                        Container(
                            margin: const EdgeInsets.all(40.0),
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(
                                left: 10, right: 10, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              color: Colors.white,
                            ),
                            child: Column(children: <Widget>[
                              openHoursTitle(),
                              openHoursDialogs("06:00-24:00"),
                              SizedBox(height: 15),
                              Text(
                                  AppLocalizations.of(context)
                                      .translate('payment_methods'),
                                  style: TextStyle(fontSize: 14)),
                              showCheckInf(
                                  AppLocalizations.of(context)
                                      .translate('card'),
                                  70.0,
                                  true),
                              showCheckInf("Swish", 70.0, true),
                            ])),
                        SizedBox(height: 10),
                        rapportB(AppLocalizations.of(context)
                            .translate("report_problems")),
                      ]),
                      SizedBox(height: 30),
                      Align(
                          alignment: Alignment.bottomRight,
                          child: RaisedButton(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            onPressed: () {},
                            color: Colors.green,
                            child: Text(
                                AppLocalizations.of(context)
                                    .translate('go_here'),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Calibri',
                                    color: Colors.white,
                                    fontSize: 16)),
                          ))
                    ])));
          });
        });
  }

  Widget showIsAviAdapt(String distance) {
    return Row(
      children: [
        Icon(Icons.directions_walk, color: Colors.green),

        Text(distance,
            style:
                TextStyle(fontFamily: 'Calibri', fontStyle: FontStyle.italic)),
        SizedBox(width: 3),

        Text(AppLocalizations.of(context).translate('acc_adp'),
            style: TextStyle(fontSize: 12)),

        Text("Ja", style: TextStyle(fontSize: 12)),

        Icon(
          Icons.check,
          color: Colors.lightGreen[300],
          size: 16,
        ),
      ],
    );
  }

  Widget openHoursDialogs(String string) {
    return Text(AppLocalizations.of(context).translate('mon-sun') + string,
        style: TextStyle(fontSize: 12), textAlign: TextAlign.right);
  }

  Widget openHoursTitle() {
    return Text(
      AppLocalizations.of(context).translate('open_hours'),
      style: TextStyle(fontSize: 16),
    );
  }

  Widget titleCloseDialogs(String placeName, bool favorite) {
    return Row(children: [
      createFavoriteButton(placeName),
      Expanded(
          child: Text(placeName,
              softWrap: true,
              style: TextStyle(fontSize: 18, fontFamily: "Calibri"),
              textAlign: TextAlign.center)),
      SizedBox(
        height: 40,
        width: 40,
        child: IconButton(
          icon: Image.asset("assets/images/close.png"),
          iconSize: 8,
          onPressed: () {
            setState(() {
              favorite = false;
            });
            Navigator.of(context).pop();
          },
        ),
      )
    ]);
  }

  Widget showCarousel(List<String> list) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage(list[photoIndex]), fit: BoxFit.cover),
      ),
      height: 180.0,
      width: 390,
    );
  }

  Widget setPositionDots() {
    return Positioned(
      top: 160.0,
      left: 25.0,
      right: 25.0,
      child: SelectedPhoto(
          numberOfDots: imagesPark.length, photoIndex: photoIndex),
    );
  }

  Widget reviewsB(String place) {
    return Container(
        width: 100,
        height: 20,
        child: RaisedButton(
            color: Colors.white,
            child: Text(AppLocalizations.of(context).translate('reviews'),
                style: TextStyle(fontSize: 12), textAlign: TextAlign.right),
            onPressed: () {
              globals.place = place;
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ReviewPage()));
            } //will show reviews when pressed
            ));
  }

  Widget rapportB(String string) {
    return Container(
      width: 165,
      height: 40,
      padding: EdgeInsets.zero,
      child: RaisedButton(
        elevation: 10,
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportPage(),
              ));
        },
        child: Row(
          children: <Widget>[
            Icon(Icons.warning, color: Colors.red),
            Text(string, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget facebookIconShare(String placeName) {
    return IconButton(
      icon: Image.asset("assets/images/facebook_icon.png"),
      iconSize: 30,
      onPressed: () {
        facebookShareURL = 'https://sv.wikipedia.org/wiki/' + placeName;
        try {
          FlutterShareMe().shareToFacebook(
              url: facebookShareURL,
              msg:
                  'WOW! Hittade den här supermysiga parken med hjälp av STHLMParkliv Appen!');
        } catch (e) {
          FlutterShareMe().shareToFacebook(
              url:
                  'https://www.thelocal.se/userdata/images/article/606e0936719b7a5e9bf679b9e5165ec61b6d08d36c9ab0b5bc9bb7b4be6cb0f2.jpg',
              msg:
                  'WOW! Hittade den här supermysiga parken med hjälp av STHLMParkliv Appen!');
        }
      },
    );
  }

  Widget messengerIconShare() {
    return IconButton(
      icon: Image.asset("assets/images/messenger.jpg"),
      iconSize: 60,
      onPressed: () {},
    );
  }

  //Adds the qualities to the alert dialog under the header 'Suitable for'
  Widget showAreaQualities(String placeName) {
    List<String> qualities =
        globals.workSocMap.getByName(placeName).getQualities();
    List<Widget> widgetList = [];
    int qualitiesDisplayed = 0;

    log('Qualitis contains: $qualities');
    widgetList.add(Text(
        AppLocalizations.of(context).translate('suit_place_for'),
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        textAlign: TextAlign.left));
    for (int i = 0; i < qualities.length; i++) {
      if (matchingQuality(qualities[i]) && qualitiesDisplayed <= 2) {
        widgetList.add(SizedBox(height: 5));
        widgetList.add(Text(qualities[i],
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            textAlign: TextAlign.left));
        qualitiesDisplayed++;
      }
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: widgetList);
  }

  Widget showRecoAge(String age) {
    ReviewPageState r = new ReviewPageState();
    Widget rating = r.getRating();
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          rating,
          SizedBox(height: 10),
          Text(AppLocalizations.of(context).translate('reco_for_age'),
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              textAlign: TextAlign.right),
          Text(age, //fetch recommended age for place.
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              textAlign: TextAlign.right),
        ],
      ),
    );
  }

  Widget showCheckInf(String string, double width, bool exist) {
    Icon existIcon;
    if (exist) {
      existIcon = new Icon(
        Icons.check,
        color: Colors.lightGreen[300],
        size: 18,
      );
    } else {
      existIcon = new Icon(
        Icons.cancel,
        color: Colors.red,
        size: 18,
      );
    }
    return Row(
      children: [
        SizedBox(width: width),
        Text(
          string,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 12,
          ),
          textAlign: TextAlign.left,
        ),
        existIcon,
      ],
    );
  }

  //Shows the distance from the users current position to the target area or location
  Widget showDistance(LatLng averagePos) {
    LatLng currentPos = getPosition();
    double dist = globals.pathDistance.distance(
        new distance.LatLng(currentPos.latitude, currentPos.longitude),
        new distance.LatLng(averagePos.latitude, averagePos.longitude));
    String distText;
    if (dist >= 2000) {
      distText = "${(dist / 1000).toStringAsFixed(1)} km";
    } else {
      distText = "$dist m";
    }

    return Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      Icon(
        Icons.directions_walk,
        color: Colors.green,
      ),
      SizedBox(width: 5),
      Text(distText,
          style: TextStyle(fontFamily: 'Calibri', fontSize: 16),
          textAlign: TextAlign.left), //Fetch distance to place.
      SizedBox(width: 50),
      Text(
        AppLocalizations.of(context).translate(
            'grade')
        ,
        style: TextStyle(
          fontSize: 16,
        ), //fetch grade for place from review of place".
        textAlign: TextAlign.right,
      ),
    ]);
  }

  showDialogForTip() {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                backgroundColor: Colors.grey[100],
                content: Container(
                  color: Colors.white24,
                  height: 600.0,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                      child: Scrollbar(
                          child: ListView(
                    children: getSuggestions(context),
                  ))),
                ));
          });
        });
  }

  showDialogForFavorites(bool favorite, String name) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                backgroundColor: Colors.grey[100],
                content: Container(
                    color: Colors.white24,
                    height: 600,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                        child: Scrollbar(
                            child: Column(children: <Widget>[
                      titleCloseDialogs(
                          AppLocalizations.of(context)
                              .translate('favorite_places'),
                          favorite),
                      DropdownButton<String>(
                        items: items.map((String dropDownStringItem) {
                          if (dropDownStringItem == "Tilläggsdatum")
                            dropDownStringItem = AppLocalizations.of(context)
                                .translate('added_date');
                          else
                            dropDownStringItem = AppLocalizations.of(context)
                                .translate('alphabetical_order');

                          return DropdownMenuItem<String>(
                            value: dropDownStringItem,
                            child: Text(dropDownStringItem,
                                style: TextStyle(fontSize: 16)),
                          );
                        }).toList(),
                        onChanged: (String newValueSelected) {
                          if (newValueSelected ==
                              AppLocalizations.of(context)
                                  .translate('alphabetical_order'))
                            favouritePlaces.sort((a, b) {
                              return a.compareTo(b);
                            });
                          if (newValueSelected ==
                              AppLocalizations.of(context)
                                  .translate('added_date'))
                            dates.sort((a, b) => a.compareTo(b));
                          print(dates);

                          //execute when item is selected
                          setState(() {
                            this._currentItemSelected = newValueSelected;
                          });
                        },
                        hint: (Text(_currentItemSelected)),
                      ),
                      Expanded(
                          child: returnFavouritePlaces(
                              date, "assets/images/parkPlay3.jpg", name)),
                      Row(children: <Widget>[
                        Expanded(
                            child: SingleChildScrollView(
                                child: Container(
                                    width: 140,
                                    height: 40,
                                    child: TextFormField(
                                        onFieldSubmitted: (text) {
                                          print(text);
                                        },
                                        onChanged: (text) {
                                          setState(() {
                                            input = normailization(text);
                                          });
                                        },
                                        autofocus: false,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          hintText: AppLocalizations.of(context)
                                              .translate('search'),
                                          alignLabelWithHint: true,
                                          fillColor: Colors.white,
                                          filled: true,
                                          prefixIcon: Icon(Icons.search),
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                            Radius.circular(20),
                                          )),
                                          hintStyle: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12,
                                              fontFamily: 'OpenSans'),
                                        ))))),
                        Container(
                            padding: EdgeInsets.only(left: 3),
                            width: 46,
                            height: 20,
                            child: RaisedButton(
                              elevation: 10,
                              color: Colors.green,
                              onPressed: () {
                                setState(() {
                                  placeSearched = true;
                                  markedSearch(placeSearched);
                                  print(input);
                                });
                              },
                              child: Text("OK",
                                  style: TextStyle(
                                      fontSize: 8, color: Colors.white)),
                            ))
                      ])
                    ])))));
          });
        });
  }

  ///ALERT DIALOG END / INFORMATION WINDOW END
  /////////////////////////////////////////////////////////////////////////////////////////////////////////


  /////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///VISUAL ELEMENTS START

  Align createDrawer(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        children: [
          SizedBox(height: 180.0),
          Container(
            child: IconButton(
                onPressed: () => _drawerKey.currentState.openDrawer(),
                icon: Image.asset("assets/images/arrow_filter.png",
                    fit: BoxFit.fill),
                iconSize: 60),
          ),
        ],
      ),
    );
  }

  //Creates the filter buttons on the right hand side of the screen
  List<Widget> createRightMenu(BuildContext context) {
    return <Widget>[
      SizedBox(height: 160.0),
      button(_onToggleAnimalsButtonPressed, "assets/images/sheep.png",
          Colors.amberAccent[400]),
      SizedBox(height: 14.0),
      button(_onTogglePlaygroundsButtonPressed,
          "assets/images/playgroundIcon.png", Colors.purple),
      SizedBox(height: 14.0),
      button(_onToggleParksButtonPressed, "assets/images/parkIcon.png",
          Colors.green),
      SizedBox(height: 14.0),
      button(_onToggleOutdoorBathingButtonPressed, "assets/images/swimming.png",
          Colors.blue),
      SizedBox(height: 14.0),
      button(_onToggleRestroomMarkersButtonPressed, "assets/images/wc.png",
          Colors.blue[900]),
      if (globals.debug) SizedBox(height: 14.0),
      if (globals.debug)
        button(_onToggleTrashcanMarkersButtonPressed,
            "assets/images/trashcan.png", Colors.brown),
    ];
  }

  //Creates the bottom menu bar
  BottomAppBar createBottomBar(BuildContext context) {
    return BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 4.0,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,

          //TODO: CONTAINS DUPLICATED CODE, ONE METHOD CAN CREATE ALL BUTTONS
          children: <Widget>[
            //Creates the menu button in the bottom menu bar
            FlatButton(
              onPressed: () {
                showMenu(name);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Icon(Icons.menu, color: Colors.green.shade400),
                  Text(AppLocalizations.of(context).translate('menu'),
                      style: TextStyle(color: Colors.green.shade400)),
                ],
              ),
            ),

            //Creates the suggestions button in the bottom menu bar
            FlatButton(
              onPressed: () {
                showDialogForTip();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Icon(Icons.lightbulb_outline, color: Colors.green.shade400),
                  Text(AppLocalizations.of(context).translate('tip'),
                      style: TextStyle(color: Colors.green.shade400)),
                ],
              ),
            ),

            //Creates the change map style button in the bottom menu bar
            FlatButton(
              onPressed: () {
                setState(() {
                  _currentMapType = _currentMapType == MapType.normal
                      ? MapType.hybrid
                      : MapType.normal;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Icon(Icons.map, color: Colors.green.shade400),
                  Text(AppLocalizations.of(context).translate(map()),
                      style: TextStyle(color: Colors.green.shade400)),
                ],
              ),
            ),

            //Creates the find me button in the bottom menu bar
            FlatButton(
              onPressed: () {
                setState(() {
                  _mapController.animateCamera(CameraUpdate.newLatLng(LatLng(
                      globals.currentPosition.latitude ??
                          globals.lastKnownPosition.latitude ??
                          59.32537100000000,
                      globals.currentPosition.longitude ??
                          globals.lastKnownPosition.longitude ??
                          06555300000000)));
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Icon(Icons.my_location, color: Colors.green.shade400),
                  Text(AppLocalizations.of(context).translate('find_me'),
                      style: TextStyle(color: Colors.green.shade400)),
                ],
              ),
            ),
          ],
        ));
  }

  showMenu(String name) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0))),
        builder: (BuildContext context) {
          return Container(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                      child: SizedBox(
                    height: 200,
                    child: Stack(
                      alignment: Alignment(0, 0),
                      children: <Widget>[
                        Positioned(
                          child: ListView(
                            physics: NeverScrollableScrollPhysics(),

                            //TODO: CONTAINS LOTS OF DUPLICATED CODE, MAKE ONE METHOD TO CREATE ALL
                            children: <Widget>[
                              IconButton(
                                  icon: Image.asset("assets/images/dash.png"),
                                  alignment: Alignment.center,
                                  color: Colors.grey,
                                  iconSize: SizeConfig.blockSizeHorizontal * 15,
                                  onPressed: () => Navigator.of(context).pop()),

                              //Creates makeshift logout button in the menu
                              if (globals.debug)
                                ListTile(
                                  title: Text('Log Out'),
                                  leading:
                                      Icon(Icons.close, color: Colors.green),
                                  onTap: () {
                                    signOut();
                                  },
                                ),

                              //Creates the account row in the menu
                              ListTile(
                                title: Row(children: <Widget>[
                                  Text(
                                      AppLocalizations.of(context)
                                          .translate("account"),
                                      style: TextStyle(color: Colors.black54)),
                                ]),
                                leading: Icon(
                                  Icons.account_box,
                                  color: Colors.green,
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AccountPage(
                                              key: widget.key,
                                              auth: widget.auth,
                                              onSignOut: widget.onSignOut,
                                              userEmail: widget.userEmail,
                                              userId: widget.userId,
                                              m: this)));
                                },
                              ),

                              //Creates the favorites row in the menu
                              ListTile(
                                title: Text(
                                  AppLocalizations.of(context)
                                      .translate("favorite_places"),
                                  style: TextStyle(color: Colors.black54),
                                ),
                                leading: Icon(
                                  Icons.favorite,
                                  color: Colors.green,
                                ),
                                onTap: () {
                                  print(favouritePlaces.toString());
                                  showDialogForFavorites(favorite, name);
                                },
                              ),

                              //Creates the settings row in the menu
                              ListTile(
                                title: Text(
                                  AppLocalizations.of(context)
                                      .translate("settings"),
                                  style: TextStyle(color: Colors.black54),
                                ),
                                leading: Icon(
                                  Icons.settings,
                                  color: Colors.green,
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SettingsMenu(
                                              key: widget.key,
                                              auth: widget.auth,
                                              onSignOut: widget.onSignOut,
                                              userEmail: widget.userEmail,
                                              userId: widget.userId,
                                              m: this)));
                                },
                              ),

                              //Creates the reviews row in the menu
                              ListTile(
                                  title: Text(
                                    AppLocalizations.of(context)
                                        .translate("reviews"),
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  leading: Icon(
                                    Icons.rate_review,
                                    color: Colors.green,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ReviewPage(),
                                        ));
                                  }),

                              //Creates the report problems row in the menu
                              ListTile(
                                title: Text(
                                  AppLocalizations.of(context)
                                      .translate("report_problems"),
                                  style: TextStyle(color: Colors.black54),
                                ),
                                leading: Icon(
                                  Icons.warning,
                                  color: Colors.green,
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ReportPage()));
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
                ]),
              );
            }
          );
  }

  showImagesForTip(String place, String image, String icon, Color color) {
    return Column(children: [
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
            child: Text(place,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontStyle: FontStyle.italic))),
        Icon(
          Icons.favorite_border,
          size: 30,
          color: Colors.grey,
        ),
      ]),
      Stack(children: [
        Material(
            child: InkWell(
                onTap: () {
                  findArea(place);
                  Navigator.pop(context, true);
                },
                child: Container(
                    height: 150.0,
                    width: 250,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(image), fit: BoxFit.fill),
                      borderRadius: BorderRadius.circular(10),
                    )))),
        Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
              elevation: 50,
              backgroundColor: color,
              child: Image.asset(
                icon,
                alignment: Alignment.bottomRight,
                scale: 16,
              ),
              onPressed: () {}),
        )
      ])
    ]);
  }

  ///VISUAL ELEMENTS END
  /////////////////////////////////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///SUPPORT / HELP METHODS START

  //Creates buttons on the right hand side of the screen
  Widget button(Function function, String image, Color color) {
    return FloatingActionButton(
      focusElevation: 10.0,
      heroTag: null,
      onPressed: function,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: color,
      elevation: 5,
      child: Image.asset(
        image,
        scale: 16,
      ),
    );
  }

  //Checks if a quality should be printed in the alert dialog
  bool matchingQuality(String quality) {
    List<String> acceptedQualities = [
      'Naturlek',
      'Bollspel',
      'Utomhusbad',
      'Grillning',
      'Picknick',
      'Lekplats',
      'Vattenlek',
      'Skridskoåk'
    ];

    if (acceptedQualities.contains(quality)) {
      return true;
    } else {
      return false;
    }
  }

  void _setScrollViewController() {
    scrollViewColtroller = ScrollController();
    scrollViewColtroller.addListener(_scrollListener);
  }

  void _setToiletIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(
              devicePixelRatio: 2.5,
            ),
            'assets/images/marker_toilet_256c.png')
        .then((onValue) {
      toiletIcon = onValue;
    });
  }

  void addMarkers() {
    globals.markers = addRestroomMarkers(globals.markers, this, toiletIcon);
  }

  void _setMapStyle() {
    rootBundle.loadString('assets/map_styles/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  //Does filter stuff
  void doFilterStuff() {
    setState(() {
      toggleFilterPolygons();
    });
  }

  //Dictates what happens when restroom button is pressed
  void _onToggleRestroomMarkersButtonPressed() {
    setState(() {
      addMarkers();
      toggleRestroomVisibility();
    });
  }

  //Dictates what happens when trash can button is pressed
  void _onToggleTrashcanMarkersButtonPressed() {
    setState(() {
      toggleTrashcanVisibility();
    });
  }

  //Dictates what happens when animal button is pressed
  void _onToggleAnimalsButtonPressed() {
    setState(() {
      globals.filterButtonsPressed['Djurhållni'] =
          !globals.filterButtonsPressed['Djurhållni'];
      togglePolygons('Djurhållni');
    });
  }

  //Dictates what happens when playground button is pressed
  void _onTogglePlaygroundsButtonPressed() {
    setState(() {
      globals.filterButtonsPressed['Lekplats'] =
          !globals.filterButtonsPressed['Lekplats'];
      togglePolygons('Lekplats');
    });
  }

  //Dictates what happens when park button is pressed
  void _onToggleParksButtonPressed() {
    setState(() {
      globals.filterButtonsPressed['Parklek'] =
          !globals.filterButtonsPressed['Parklek'];
      togglePolygons('Parklek');
    });
  }

  //Dictates what happens when beach button is pressed
  void _onToggleOutdoorBathingButtonPressed() {
    setState(() {
      globals.filterButtonsPressed['Utomhusbad'] =
          !globals.filterButtonsPressed['Utomhusbad'];
      togglePolygons('Utomhusbad');
    });
  }

  void refreshVisiblePolys() {
    setState(() {
      togglePolygonVisibility();
    });
  }

  void showRestRoomMarker(String adress) {
    showDialogForToilet(adress);
  }

  void _scrollListener() {
    if (scrollViewColtroller.offset >=
            scrollViewColtroller.position.maxScrollExtent &&
        !scrollViewColtroller.position.outOfRange) {
      setState(() {
        message = "reach the bottom";
        _direction = true;
      });
    }
    if (scrollViewColtroller.offset <=
            scrollViewColtroller.position.minScrollExtent &&
        !scrollViewColtroller.position.outOfRange) {
      setState(() {
        message = "reach the top";
        _direction = false;
      });
    }
  }

  String normailization(String input) {
    if (input == null) return "";

    String normalized = "";

    input = input.toLowerCase();
    if (input.length > 0)
      input = input.substring(0, 1).toUpperCase() + input.substring(1);

    normalized = input;

    return normalized.trim();
  }

  Color markedSearch(placeSearched) {
    if (placeSearched = false)
      setState(() {
        return Colors.red;
      });
    else {
      return Colors.black;
    }
  }

  Widget myDetailsContainer(String place, String date, String picture) {
    var now = new DateTime.now();
    date = now.year.toString() +
        '-' +
        "05"
            '-' +
        now.day.toString(); //gets the right
    dates.add(date);
    return Container(
        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
        decoration: BoxDecoration(
            border: Border.all(color: markedSearch(placeSearched))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
                child: Text(
              place,
              style: TextStyle(
                color: Colors.black,
                fontSize: 9.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            )),
            Padding(
                padding: const EdgeInsets.only(
                    left: 3.0, bottom: 3.0, right: 3.0, top: 3.0),
                child: Container(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 60.0,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            image: DecorationImage(
                                image: AssetImage(picture), fit: BoxFit.fill),
                          ),
                        ),
                        SizedBox(width: 5),
                        Column(
                          children: <Widget>[
                            Container(
                                padding: EdgeInsets.zero,
                                width: 75,
                                height: 20,
                                child: RaisedButton(
                                  elevation: 5,
                                  color: Colors.green,
                                  child: Text(
                                      AppLocalizations.of(context)
                                          .translate('go_to_map'),
                                      style: TextStyle(
                                          fontSize: 7, color: Colors.white)),
                                  onPressed: () {
                                    findArea(place);
                                    Navigator.pop(context, true);
                                    Navigator.pop(context);
                                  },
                                )),
                            SizedBox(height: 5),
                            Text(
                                AppLocalizations.of(context)
                                        .translate('was_added') +
                                    date,
                                style: TextStyle(
                                    fontSize: 7,
                                    fontStyle: FontStyle
                                        .italic)), //fetch when favorite added.
                            SizedBox(height: 5),
                            Container(
                                width: 60,
                                height: 20,
                                child: RaisedButton(
                                    elevation: 5,
                                    color: Colors.white,
                                    child: Text(
                                        AppLocalizations.of(context)
                                            .translate('remove'),
                                        style: TextStyle(fontSize: 7),
                                        textAlign: TextAlign.center),
                                    onPressed: () {
                                      _asyncConfirmDialog(context, place);
                                    } //will remove favorite when pressed
                                    )),
                          ],
                        )
                      ]),
                ))
          ],
        ));
  }

  Widget getFittedBox(String place, String date, String image) {
    return Container(
        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: new FittedBox(
            child: Material(
                color: Colors.grey[200],
                elevation: 14.0,
                shadowColor: Color(0x802196F3),
                child: Row(
                    children: <Widget>[
                      Container(
                        child: myDetailsContainer(place, date, image),
                      ),
                    ]))));
  }

  Widget returnFavouritePlaces(String date, String image, String name) {
    return new Container(
        child: favouritePlaces.length == 0
            ? new Text(' No Data is Available')
            : new ListView.builder(
                itemCount: favouritePlaces.length,
                itemBuilder: (_, index) {
                  return getFittedBox(
                      favouritePlaces[index].toString(), date, image);
                },
              ));
  }

  Future<ConfirmAction> _asyncConfirmDialog(
      BuildContext context, String place) async {
    return showDialog<ConfirmAction>(
        context: context,
        barrierDismissible: false, // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.green,
            content: Text(
                AppLocalizations.of(context).translate('confirm_remove'),
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center),
            actions: <Widget>[
              Align(
                  alignment: Alignment.center,
                  child: RaisedButton(
                    color: Colors.white,
                    child: Text(
                        AppLocalizations.of(context).translate('remove'),
                        textAlign: TextAlign.center),
                    onPressed: () {
                      setState(() {
                        Navigator.of(context).pop(ConfirmAction.Delete);
                        favouritePlaces.remove(place);
                      });
                    },
                  )),
              Align(
                  alignment: Alignment.center,
                  child: RaisedButton(
                    color: Colors.white,
                    child: Text(
                        AppLocalizations.of(context).translate('cancel'),
                        textAlign: TextAlign.center),
                    onPressed: () {
                      Navigator.of(context).pop(ConfirmAction.Cancel);
                    },
                  ))
            ],
          );
        });
  }

  //Returns a list of widgets containing both the constant elements like title, along with suggested locations.
  // Support methods needs to be rewritten properly.
  List<Widget> getSuggestions(BuildContext context) {
    List<Widget> suggestionsList = [];
    suggestionsList = addSuggestionPageConstants(context);

    List<String> tempFavorites = [];
    if (favouritePlaces.length == 0)
      tempFavorites.add('Smedsudden');
    else
      tempFavorites = favouritePlaces;

    List<SociotopArea> suggestions =
        globals.workSocMap.recommendByName(tempFavorites);

    for (int i = 0; i < suggestions.length; i++) {
      String place = suggestions[i].getName();
      String image = getSuggestionImage(place, suggestionsList.length);
      String icon = getSuggestionIcon(image);
      Color color = getSuggestionColor(icon);

      suggestionsList.add(showImagesForTip(place, image, icon, color));
    }

    return suggestionsList;
  }

  //Returns color based solely on the selected icon. TEMPORARY SOLUTION!
  //Should be improved to be based on database contents instead.
  Color getSuggestionColor(String icon) {
    Color tempColor;

    if (icon == 'assets/images/swimming.png')
      tempColor = Colors.blue;
    else if (icon == 'assets/images/sheep.png')
      tempColor = Colors.yellow;
    else if (icon == 'assets/images/parkIcon.png')
      tempColor = Colors.green[700];
    else
      tempColor = Colors.purple;

    return tempColor;
  }

  //Returns icon based solely on the selected image. TEMPORARY SOLUTION!
  //Should be improved to be based on database contents instead.
  String getSuggestionIcon(String image) {
    String tempIcon;

    if (image == 'assets/images/bathing1.jpg')
      tempIcon = 'assets/images/swimming.png';
    else if (image == 'assets/images/4h.jpg')
      tempIcon = 'assets/images/sheep.png';
    else if (image == 'assets/images/park.jpg')
      tempIcon = 'assets/images/parkIcon.png';
    else
      tempIcon = 'assets/images/playgroundIcon.png';

    return tempIcon;
  }

  //Returns image based solely on if the area contains a certain quality. TEMPORARY SOLUTION!
  //Should be improved to be based on database contents instead.
  String getSuggestionImage(String place, int contents) {
    String tempImage;
    List<String> qualities = globals.workSocMap.getByName(place).getQualities();

    if (place != null) {
      if (qualities.contains('Djurhållni') && contents < 7)
        tempImage = 'assets/images/4h.jpg';
      else if ((qualities.contains('Parklek') ||
              qualities.contains('Naturlek') ||
              qualities.contains('Naturupple')) &&
          contents < 9)
        tempImage = 'assets/images/park.jpg';
      else if (qualities.contains('Utomhusbad') && contents < 12)
        tempImage = 'assets/images/bathing1.jpg';
      else
        tempImage = 'assets/images/parkPlay1.jpg';
    }

    return tempImage;
  }

  //Returns the constant UI elements used in the suggestions-page.
  List<Widget> addSuggestionPageConstants(BuildContext context) {
    List<Widget> tempList = [];
    tempList.add(
      titleCloseDialogs(AppLocalizations.of(context).translate('tip'), false),
    );
    tempList.add(
      Divider(
        color: Colors.black,
      ),
    );
    tempList.add(
      Text(AppLocalizations.of(context).translate('information_tip'),
          style: TextStyle(
              color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14),
          textAlign: TextAlign.center),
    );
    tempList.add(SizedBox(height: 10));
    return tempList;
  }

  //Finds an area based on name and centers the camera on it, unmarking all others.
  findArea(String place) {
    log(globals.workSocMap.getPlaceNames().toString());
    if (globals.workSocMap.getPlaceNames().contains(place)) {
      globals.filterButtonsPressed['Sökning'] = true;
      globals.filterButtonsPressed['Djurhållni'] = false;
      globals.filterButtonsPressed['Lekplats'] = false;
      globals.filterButtonsPressed['Parklek'] = false;
      globals.filterButtonsPressed['Utomhusbad'] = false;

      setState(() {
        toggleSearchPolygon(place);
      });

      LatLng nPos =
          globals.workSocMap.getByName(place).mapArea.getAverageWGs84();
      _mapController.animateCamera(CameraUpdate.newCameraPosition(
          new CameraPosition(target: nPos, zoom: 14.0)));
      primaryFocus.unfocus();
    }
  }

  ///SUPPORT / HELP METHODS END
  /////////////////////////////////////////////////////////////////////////////////////////////////////////

}

///MAPPAGESTATE END
///////////////////////////////////////////////////////////////////////////////////////////////////////////

class SelectedPhoto extends StatelessWidget {
  final int numberOfDots;
  final int photoIndex;

  SelectedPhoto({this.numberOfDots, this.photoIndex});

  Widget _inactivePhoto() {
    return new Container(
        child: new Padding(
      padding: const EdgeInsets.only(left: 3.0, right: 3.0),
      child: Container(
        height: 8.0,
        width: 8.0,
        decoration: BoxDecoration(
            color: Colors.grey, borderRadius: BorderRadius.circular(4.0)),
      ),
    ));
  }

  Widget _activePhoto() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 3.0, right: 3.0),
        child: Container(
          height: 10.0,
          width: 10.0,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.black, spreadRadius: 0.0, blurRadius: 2.0)
              ]),
        ),
      ),
    );
  }

  List<Widget> _buildDots() {
    List<Widget> dots = [];

    for (int i = 0; i < numberOfDots; ++i) {
      dots.add(i == photoIndex ? _activePhoto() : _inactivePhoto());
    }

    return dots;
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildDots(),
      ),
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  final List<String> places = ["Park 1", "Park 2", "Park 3", "Park 4", "Hej"];
  final List<String> recentPlaces = ["Park 1", "Park 2"];
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {},
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {},
    );
  }

  @override
  Widget buildResults(BuildContext context) {
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query == null || query.isEmpty
        ? recentPlaces
        : places.where((p) => p.startsWith(query)).toList();
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          showResults(context);
        },
        title: RichText(
            text: TextSpan(
          text: suggestionList[index].substring(0, query.length),
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          children: [
            TextSpan(
                text: suggestionList[index].substring(query.length),
                style: TextStyle(color: Colors.grey))
          ],
        )),
      ),
      itemCount: suggestionList.length,
    );
  }
}
