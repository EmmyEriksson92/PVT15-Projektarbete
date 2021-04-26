import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pvt_15/screens/reviews.dart';
import '../app_localizations.dart';
import '../size_config.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pvt_15/globals.dart' as globals;

import 'reviewPage.dart';

class WriteReview extends StatefulWidget {
  WriteReviewState createState() => WriteReviewState();
}

class WriteReviewState extends State<WriteReview> {
  final DatabaseReference database =
      FirebaseDatabase.instance.reference().child("Reviews");

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var _rating = 3.0;
  String text = '';
  String result = "";
  Widget data;
  List<String> _myList = new List();
  Map<String, List<Review>> map = new Map();

  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.grey[200],
            title: Text(
                AppLocalizations.of(context).translate('write_a_review'),
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: "Verdana",
                    color: Colors.black54,
                    fontWeight: FontWeight.bold)),
            leading: new IconButton(
                icon:
                    Icon(Icons.arrow_back_ios, color: Colors.black54, size: 24),
                onPressed: () => Navigator.of(context).pop(_myList))),
        body: Center(
            child: Container(
                width: MediaQuery.of(context).size.width,
                //height: SizeConfig.safeBlockVertical * 100,
                color: Colors.grey[200],
                child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: <
                        Widget>[
                  SizedBox(height: 10),
                  Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Text(
                        AppLocalizations.of(context)
                            .translate('do_a_contribution'),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      )),
                  stringDesign(),
                  SizedBox(height: 10),
                  CircleAvatar(
                      backgroundColor: Colors.green[400],
                      radius: 56,
                      child: Image.asset('assets/images/leaf.png')),
                  Text("Profil", textAlign: TextAlign.center),
                  SizedBox(height: 30),
                  Text(AppLocalizations.of(context).translate('enter_stars'),
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center),
                  ratingBar(),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: TextFormField(
                          controller: _controller,
                          maxLines: 12,
                          autocorrect: false,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: AppLocalizations.of(context)
                                .translate('write_a_review'),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                          validator: (text) {
                            if (text.length == 0 || text.trim().isEmpty) {
                              return 'Text is empty';
                            }
                            return null;
                          }),
                    ),
                  ),
                  BottomAppBar(
                    child: Row(
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.only(left: 60.0, right: 32.0),
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('cancel'),
                              ),
                              onPressed: () =>
                                  Navigator.of(context).pop(_myList),
                            )),
                        Container(
                            padding: EdgeInsets.only(left: 35.0, right: 28.0),
                            alignment: Alignment.bottomRight,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: Colors.green,
                              onPressed: () {
                                sendData();
                                print(normailization(_controller.text));
                                print(getRating());
                                _controller.clear();
                                Navigator.pop(context); //pops make reviewPage
                                Navigator.pop(context); //pops reviewPage
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) =>
                                            new ReviewPage())); //makes updated reviewPage
                              },
                              child: Text(
                                  AppLocalizations.of(context)
                                      .translate('post'),
                                  style: TextStyle(color: Colors.white)),
                            ))
                      ],
                    ),
                  )
                ])))));
  }

  double getRating() {
    return _rating;
  }

  double getAverageRating() {
    double total = 0;
    total += getRating();
    total += getRating();
    double average = total / 2;
    return average;
  }

  sendData() {
    database.push().set({'Rating': getRating(), 'Text': _controller.text});
  }

  readData() {
    database.once().then((DataSnapshot dataSnapShot) {
      print(dataSnapShot.value);
    });
  }

  Widget getAverageRatingBar() {
    return Align(
        alignment: Alignment.center,
        child: RatingBar(
            initialRating: 3,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 20,
            unratedColor: Colors.grey[400],
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
            onRatingUpdate: (rating) {
              setState(
                () {
                  _rating = getAverageRating();
                  print(_rating);
                  print(_controller.text);
                },
              );
            }));
  }

  Widget ratingBar() {
    return Align(
        alignment: Alignment.center,
        child: RatingBar(
            initialRating: 3,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 20,
            unratedColor: Colors.grey[400],
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
            onRatingUpdate: (rating) {
              setState(
                () {
                  _rating = rating;
                  //print(rating);
                  //print(_controller.text);
                },
              );
            }));
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
}

Widget stringDesign() {
  String name = 'Vasa Park';
  if(globals.place != null && globals.place.isNotEmpty)
    name = globals.place;

  return Text(name,
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.bold));
}
