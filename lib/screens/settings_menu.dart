import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pvt_15/app_localizations.dart';
import 'package:pvt_15/screens/languagePage_settings.dart';
import 'package:pvt_15/size_config.dart';
import 'package:pvt_15/infrastructure/firebase_auth.dart';
import 'mapPage.dart';

class SettingsMenu extends StatefulWidget {
  MapPageState m;
  final AuthFunc auth;
  final VoidCallback onSignOut;
  final String userId, userEmail;

  SettingsMenu(
      {Key key, this.auth, this.onSignOut, this.userEmail, this.userId, this.m})
      : super(key: key);
  @override
  SettingsMenuState createState() => new SettingsMenuState();
}

class SettingsMenuState extends State<SettingsMenu> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: ListView(children: [
        Container(
            color: Colors.white,
            child: AppBar(
                title: Row(children: <Widget>[
                  Icon(Icons.settings, size: 24, color: Colors.black54),
                  SizedBox(width: 18),
                  Text(AppLocalizations.of(context).translate('settings'),
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
        SizedBox(height: 120),
        ListTile(
          title: Text(
            AppLocalizations.of(context).translate('privacy'),
            style: TextStyle(
                color: Colors.black54,
                fontSize: SizeConfig.safeBlockHorizontal * 5),
          ),
          leading: Icon(Icons.lock_outline,
              color: Colors.black54, size: SizeConfig.safeBlockHorizontal * 10),
          onTap: () {},
        ),
        ListTile(
          title: Text(
            AppLocalizations.of(context).translate('help'),
            style: TextStyle(
                color: Colors.black54,
                fontSize: SizeConfig.safeBlockHorizontal * 5),
          ),
          leading: Icon(Icons.help_outline,
              color: Colors.black54, size: SizeConfig.safeBlockHorizontal * 10),
          onTap: () {},
        ),
        ListTile(
          title: Text(
            AppLocalizations.of(context).translate('language'),
            style: TextStyle(
                color: Colors.black54,
                fontSize: SizeConfig.safeBlockHorizontal * 5),
          ),
          leading: Image.asset(
            'assets/images/flagIcon.png',
            width: 40,
            height: 60,
          ),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => LanguagePage()));
          },
        ),
        SizedBox(height: 300),
        logOutButton(context),
      ]),
    );
  }

  logOutButton(BuildContext context) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
            width: 160,
            height: 50,
            child: RaisedButton(
              color: Colors.white,
              onPressed: () {
                setState(() {
                  widget.m.signOut();
                  Navigator.pop(context);
                  Navigator.pop(context);
                });
              },
              child: Text(
                AppLocalizations.of(context).translate('log_out'),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Verdana",
                    color: Colors.black54),
              ),
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              )),
            )));
  }
}
