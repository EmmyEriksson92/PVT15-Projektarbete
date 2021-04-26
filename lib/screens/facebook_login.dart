import 'dart:async';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter/material.dart';
import 'package:pvt_15/app_localizations.dart';
import 'mapPage.dart';

class LoginFacebook extends StatefulWidget {
  @override
  FacebookLoginState createState() => new FacebookLoginState();
}

class FacebookLoginState extends State<LoginFacebook> {
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  String _message = "";
  bool _isLoggedIn = false;

  Future<Null> _login() async {
    final FacebookLoginResult result = await facebookSignIn.logIn(['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        
        //Under the first showMessage (when the login is successfull) it should take us to the map screen.
        _showMessage(
         'Välkommen!');
        _isLoggedIn = true;
        Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MapPage()));        

        break;
      case FacebookLoginStatus.cancelledByUser:
        _showMessage(AppLocalizations.of(context).translate('Login cancelled by the user'));
        _isLoggedIn = false;
        break;
      case FacebookLoginStatus.error:
        _showMessage(AppLocalizations.of(context).translate('Something went wrong with the login process. \n error_facebook${result.errorMessage}'));
        _isLoggedIn = false;
        break;
    }
  }

  Future<Null> logOut() async {
    await facebookSignIn.logOut();
    _showMessage('Logged out.');
  }

  void _showMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: Scaffold(
        appBar: new AppBar(
          title: new Text('Logga in med facebook'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: (){
              Navigator.pop(context);
            },
            )
        ),
        body: new Center(
            child: _isLoggedIn
                ? OutlineButton(
                    child: Text(AppLocalizations.of(context).translate("log_out")),
                    onPressed: () {
                      logOut();
                    })
                : Center(
                    child: OutlineButton(
                        child: Text(AppLocalizations.of(context).translate("login_facebook")),
                        onPressed: () {
                          _login();
                        })))));
  }
}