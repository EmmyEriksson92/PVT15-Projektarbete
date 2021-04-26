
import 'package:flutter/material.dart';
import 'package:pvt_15/app.dart';
import 'package:pvt_15/app_localizations.dart';

class LanguagePage extends StatefulWidget {
  @override
  LanguagePageState createState() => new LanguagePageState();
}

class LanguagePageState extends State<LanguagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(children: [
      Container(
          color: Colors.white,
          child: AppBar(
              title: Row(children: <Widget>[
                Icon(Icons.settings, size: 24, color: Colors.black54),
                SizedBox(width: 18),
                Text(AppLocalizations.of(context).translate("settings"),
                    style: TextStyle(
                        fontSize: 20,
                        fontFamily: "Verdana",
                        color: Colors.black54)),
              ]),
              backgroundColor: Colors.white,
              leading: new IconButton(
                  icon: Icon(Icons.arrow_back_ios,
                      color: Colors.black54, size: 24),
                  onPressed: () => Navigator.of(context).pop()))),
     // SizedBox(height: 100),
      ListTile(

        title: Text(
          AppLocalizations.of(context).translate("swedish"),
          style: TextStyle(
              color: Colors.black54,
              fontSize: 18),
        ),
        leading: Image.asset(
          'assets/images/flagIcon.png',
          width: 32,
          height: 30,
        ),
        onTap: () {
          Locale newLocale = Locale('sv', 'SV');
          App.setLocale(context, newLocale);
        },
      ),
      ListTile(
        title: Text(
          AppLocalizations.of(context).translate("english"),
          style: TextStyle(
              color: Colors.black54,
              fontSize: 18),
        ),
        leading: Image.asset('assets/images/flagIconEnglish.png',
            width: 30,
            height: 30),
        onTap: () {
          Locale newLocale = Locale('en', 'US');
          App.setLocale(context, newLocale);
        },
      )
    ]));
  }
}
