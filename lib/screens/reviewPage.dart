import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pvt_15/size_config.dart';
import '../app_localizations.dart';
import "package:pvt_15/screens/write_review.dart";
import 'package:firebase_database/firebase_database.dart';
import 'package:pvt_15/screens/reviews.dart';

class ReviewPage extends StatefulWidget {
  ReviewPageState createState() => ReviewPageState();
}

class ReviewPageState extends State<ReviewPage> {
  static List<Review> reviews = [];
  WriteReviewState rate = new WriteReviewState();
  String string = "";

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.white,
            title: Text(AppLocalizations.of(context).translate('reviews'),
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: "Verdana",
                    color: Colors.black54,
                    fontWeight: FontWeight.bold)),
            leading: new IconButton(
                icon:
                    Icon(Icons.arrow_back_ios, color: Colors.black54, size: 24),
                onPressed: () => Navigator.of(context).pop())),
        body: Center(
            child: Container(
                padding: EdgeInsets.only(left: 30.0, right: 30.0),
                width: MediaQuery.of(context).size.width,
                height: SizeConfig.safeBlockVertical * 100,
                color: Colors.grey[200],
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)
                          .translate('do_a_contribution'),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                            child: (stringDesign())
                          ), //example of place that has reviews.
                        Expanded(child: startSecondScreen(context)),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                            rate.getAverageRating().toStringAsFixed(
                                rate.getAverageRating().truncateToDouble() ==
                                        rate.getAverageRating()
                                    ? 0
                                    : 2),
                            style: TextStyle(
                                color: Colors.amber,
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold)),
                        SizedBox(width: 5),
                        rate.getAverageRatingBar(),
                        SizedBox(width: 5),
                        Text(
                            reviews.length.toString() +
                                " " +
                                AppLocalizations.of(context)
                                    .translate('reviews'),
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontFamily: "sans-serif"))
                      ],
                    ),
                    SizedBox(height: 5),
                    Expanded(child: returnList()),
                  ],
                ))));
  }

  Widget startSecondScreen(BuildContext context) {
    return Container(
        child: RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.green,
      child: Text(AppLocalizations.of(context).translate('write_a_review'),
          style: TextStyle(fontSize: 14, color: Colors.white)),
      onPressed: () {
        Navigator.push(
            context,
            new MaterialPageRoute(
              builder: (context) => new WriteReview(),
            ));
        setState(() {});
      },
    ));
  }

  Widget returnList() {
    return new Container(
        child: reviews.length == 0
            ? new Text(' No Data is Available')
            : new ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (_, index) {
                  return ui(
                    reviews[index].rating,
                    reviews[index].text,
                  );
                },
              ));
  }

  Widget getRating() {
    WriteReviewState w = new WriteReviewState();
    Widget ratingBar = w.ratingBar();
    return ratingBar;
  }

  Widget ui(int rating, String text) {
    return new Card(
      elevation: 10.0,
      child: new Container(
        padding: new EdgeInsets.all(20.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text('Rating : $rating/5'),
            new Text('Text : $text'),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    DatabaseReference database = FirebaseDatabase.instance.reference();
    database.child('Reviews').once().then((DataSnapshot snap) {
      var keys = snap.value.keys;
      var data = snap.value;
      reviews.clear();
      for (var key in keys) {
        /* reviews.add(new Review(data[key]['Rating'], data[key]['Text'])); */
        Review r = new Review(data[key]['Rating'], data[key]['Text']);
        reviews.add(r);
      }
      print('Length: ${reviews.length}');
      setState(() {});
    });
  }
}
