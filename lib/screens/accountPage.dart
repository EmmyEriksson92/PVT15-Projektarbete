import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:pvt_15/app_localizations.dart';
import 'package:pvt_15/size_config.dart';
import 'package:pvt_15/infrastructure/firebase_auth.dart';
import 'mapPage.dart';

class AccountPage extends StatefulWidget {
  MapPageState m;
  final AuthFunc auth;
  final VoidCallback onSignOut;
  final String userId, userEmail;

  AccountPage({Key key, this.auth, this.onSignOut, this.userEmail, this.userId, this.m})
      : super(key: key);
  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(children: <Widget>[
            SizedBox(width: SizeConfig.safeBlockHorizontal * 20),
            Text(AppLocalizations.of(context).translate('account'),
                style: TextStyle(
                  fontSize: 25,
                  fontFamily: "Poppins-Bold",
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                )),
          ]),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black54,
                size: 24,
              ),
              onPressed: () => Navigator.of(context).pop()),
          backgroundColor: Colors.white,
        ),
        body: ListView(
          children: <Widget>[
            Column(children: <Widget>[
              Container(
                child: Stack(
                    alignment: Alignment.bottomCenter,
                    overflow: Overflow.visible,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              height: 200.0,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(
                                    "assets/images/background_profile.png"),
                              )),
                            ),
                          )
                        ],
                      ),
                      Positioned(
                          top: 100.0,
                          child: Container(
                            width: 130.0,
                            height: 130.0,
                            decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image:
                                      AssetImage("assets/images/profile.png"),
                                )),
                          ))
                    ]),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                height: 80.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Johanna JR",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          fontFamily: "Poppins-Bold",
                        )),
                  ],
                ),
              ),
              SizedBox(height: 12),
              SafeArea(
                  child: Container(
                padding: EdgeInsets.only(left: 6.0, right: 6.0),
                child: Column(children: <Widget>[
                  ListTile(
                    title: Text(
                      AppLocalizations.of(context).translate('change_e-mail'),
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    leading: Icon(Icons.mail, color: Colors.black54, size: 18),
                    onTap: () {},
                  ),
                  ListTile(
                    title: Text(
                      AppLocalizations.of(context).translate('change_password'),
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    leading:
                        Icon(Icons.vpn_key, color: Colors.black54, size: 18),
                    onTap: () {},
                  ),
                  ListTile(
                    title: Text(
                      AppLocalizations.of(context).translate('privacy_terms'),
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    leading: Icon(Icons.lock, color: Colors.black54, size: 18),
                    onTap: () {},
                  ),
                  SizedBox(height: 84),
                  Divider(),
                  SizedBox(
                      width: 150,
                      height: 50,
                      child: Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [Colors.green, Colors.greenAccent])),
                          child: RaisedButton(
                            onPressed: () {
                              setState(() {
                                widget.m.signOut();
                                Navigator.pop(context);
                                Navigator.pop(context);
                              });
                            },
                            color: Colors.transparent,
                            child: Text(
                                AppLocalizations.of(context)
                                    .translate('log_out'),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: "Poppins-Bold",
                                    letterSpacing: 1.0)),
                          )))
                ]),
              ))
            ])
          ],
        ));
  }
}
