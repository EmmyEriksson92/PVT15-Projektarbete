import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:pvt_15/infrastructure/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:pvt_15/app.dart';
import 'package:pvt_15/app_localizations.dart';
import 'package:pvt_15/globals.dart' as globals;
import 'package:pvt_15/screens/createAccount_page.dart';
import 'package:pvt_15/screens/facebook_login.dart';
import 'package:pvt_15/screens/martinDebugScreen.dart';
import 'package:pvt_15/screens/reset_password.dart';

enum STATE { SIGNIN, SIGNUP }

class LoginPage extends StatefulWidget {
  // var auth = AuthFunc();
  AuthFunc auth;
  VoidCallback onSignedIn;
  VoidCallback onSignedUp;

  LoginPage({this.auth, this.onSignedIn, this.onSignedUp});

  @override
  LoginPageState createState() => new LoginPageState();
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//THESE METHODS SHOULD BE EXECUTED DURING THE SPLASH SCREEN, NOT HERE DUE TO LOADTIME, CHANGE WHEN POSSIBLE       ///

void _checkStatus() {
  if (globals.debug) {
    log('Debug mode active. Variable located in globals.dart.');

    //Checks if SHP-file is loaded.
    if (!globals.workSocMap.shpLoaded)
      log('SHP-file not loaded.');
    else
      log('SHP-file loaded.');

    //Checks if SHX-file is loaded.
    if (!globals.workSocMap.shxLoaded)
      log('SHX-file not loaded.');
    else
      log('SHX-file loaded.');

    //Checks if DBF-file is loaded.
    if (!globals.workSocMap.dbfLoaded)
      log('DBF-file not loaded.');
    else
      log('DBF-file loaded.');

    //Checks if current position is loaded.
    if (globals.currentPosition == null) {
      log('Current position not loaded.');
      log('${globals.currentPosition}.');
    } else {
      log('Current position loaded.');
      log('${globals.currentPosition}.');
    }

    //Checks if last known position is loaded.
    if (globals.lastKnownPosition == null)
      log('Last known position not loaded.');
    else
      log('Last known position loaded.');
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class LoginPageState extends State<LoginPage> {
  final _formKey = new GlobalKey<FormState>();

  String _email, _password, _errorMessage;
  bool _isLoading;

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });

    if (_validateAndSave()) {
      String userId = "";
      try {
        userId = await widget.auth.signIn(_email, _password);

        setState(() {
          _isLoading = false;
        });

        if (userId != null &&  userId.length > 0 ) {
          widget.onSignedIn();
        }
      } catch (e) {
        print(e);
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
        });
      }
    } else
      print(_errorMessage);
  }

  @override
  void initState() {
    super.initState();
    _errorMessage = "";
    _isLoading = false;
  }

  Widget showCircularProgress() {
    if (_isLoading)
      return Center(
        child: CircularProgressIndicator(),
      );
    return Container(
      //empty view
      height: 0,
      width: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/background_app.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: new Form(
              key: _formKey,
              child: SafeArea(
                child: ListView(children: <Widget>[
                  SizedBox(height: 5.0),
                  languageSettingIcons(context),
                  leafIcon,
                  SizedBox(height: 38),
                  title(context),
                  SizedBox(height: 12),
                  emailInput(context),
                  passwordInput(context),
                  loginButton(context),
                  SizedBox(height: 12),
                  forgotPassword(context),
                  facebookButton(context),
                  SizedBox(height: 30),
                  createAccount(context),
                  if (globals.debug) mDebug(context),
                ]),
              ))),
    );
  }

  loginButton(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 24.0, left: 35.0, right: 32.0),
        child: RaisedButton(
          elevation: 10.0,
          onPressed: () {
            if (_validateAndSave()) {
              _validateAndSubmit();
              _checkStatus();
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(80),
          ),
          padding: EdgeInsets.all(0.0),
          child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.greenAccent, Colors.green],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Container(
                constraints: BoxConstraints(maxWidth: 400.0, minHeight: 55.0),
                alignment: Alignment.center,
                child: Text(AppLocalizations.of(context).translate('login'),
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        letterSpacing: 1.0)),
              )),
        ));
  }

  Widget emailInput(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 10.0, left: 25.0, right: 25.0),
        child: SingleChildScrollView(
            child: TextFormField(
                autofocus: false,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value.isEmpty
                    ? AppLocalizations.of(context).translate('email_not_empty')
                    : null,
                onSaved: (value) => _email = value.trim(),
                decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate('e-mail'),
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    )),
                    hintStyle: TextStyle(
                        color: Colors.grey[800], fontFamily: 'OpenSans'),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    )))));
  }

  Widget passwordInput(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 20.0, left: 25.0, right: 25.0),
        child: SingleChildScrollView(
            child: TextFormField(
                autofocus: false,
                obscureText: true,
                validator: (value) => value.isEmpty
                    ? AppLocalizations.of(context)
                        .translate('password_not_empty')
                    : null,
                onSaved: (value) => _password = value.trim(),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).translate('password'),
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  hintStyle: TextStyle(
                      color: Colors.grey[800], fontFamily: 'OpenSans'),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ))));
  }

  Align createAccount(BuildContext context) {
    return Align(
        child: RichText(
            text: TextSpan(
                text: AppLocalizations.of(context).translate("have_no_account"),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontFamily: 'Montserrat'),
                children: [
          TextSpan(
            text: AppLocalizations.of(context).translate("sign_up"),
            recognizer: new TapGestureRecognizer()
              ..onTap = () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CreateAccount(widget.auth, widget.onSignedUp)),
                );
              },
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          )
        ])));
  }
}

Row languageSettingIcons(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      IconButton(
        onPressed: () {
          Locale newLocale = Locale('sv', 'SV');
          App.setLocale(context, newLocale);
        },
        icon: Image.asset(
          'assets/images/flagIcon.png',
        ),
        iconSize: 40,
      ),
      IconButton(
        onPressed: () {
          Locale newLocale = Locale('en', 'US');
          App.setLocale(context, newLocale);
        },
        icon: Image.asset(
          'assets/images/flagIconEnglish.png',
        ),
        iconSize: 30,
      )
    ],
  );
}

Widget facebookButton(BuildContext context) {
  return Container(
      padding: EdgeInsets.only(top: 10.0, left: 35.0, right: 32.0),
      child: RaisedButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => LoginFacebook()));
          },
          color: Colors.white,
          elevation: 10.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          child: Container(
              constraints: BoxConstraints(maxWidth: 400.0, minHeight: 55.0),
              child: Row(
                children: <Widget>[
                  IconButton(
                    alignment: Alignment.bottomLeft,
                    onPressed: () {},
                    icon: Image.asset('assets/images/facebook_icon.png'),
                  ),
                  Text(AppLocalizations.of(context).translate("login_facebook"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'Montserrat',
                      ))
                ],
              ))));
}

FlatButton forgotPassword(BuildContext context) {
  return FlatButton(
      child: Align(
        child: Text(AppLocalizations.of(context).translate("forgot_password"),
            style: TextStyle(
                color: Colors.black,
                decoration: TextDecoration.underline,
                fontSize: 16,
                fontFamily: 'Montserrat')),
      ),
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPassword(),
            ));
      });
}

FlatButton mDebug(BuildContext context) {
  // Martins debug Knapp Start
  {
    return FlatButton(
        child: Align(
            alignment: Alignment.bottomRight,
            child: Text("Martin Debug",
                style: TextStyle(
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                    fontSize: 12))),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HellqDebugScreen()),
          );
        });
  }
} //Martins debug knapp end

final leafIcon = CircleAvatar(
    backgroundColor: Colors.green[400],
    radius: 56,
    child: Image.asset('assets/images/leaf.png'));

Widget title(BuildContext context) {
  return Text("STHLM Parkliv",
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: 30, fontFamily: 'Montserrat', letterSpacing: 1.0));
}
