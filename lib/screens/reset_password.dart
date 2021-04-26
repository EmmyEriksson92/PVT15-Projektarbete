import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pvt_15/app_localizations.dart';
import 'package:pvt_15/screens/login.dart';

class ResetPassword extends StatefulWidget {
  @override
  ResetPasswordState createState() => new ResetPasswordState();
}

class ResetPasswordState extends State<ResetPassword> {
  String _email;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background_app.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: SafeArea(
                child: Container(
                    padding: EdgeInsets.only(left: 24.0, right: 24.0),
                    child: Center(
                        child: ListView(
                      children: <Widget>[
                        languageSettingIcons(context),
                        leafIcon,
                        SizedBox(height: 24),
                        title(context),
                        SizedBox(height: 24),
                        emailInput(context),
                        SizedBox(height: 5),
                        Container(
                          padding: EdgeInsets.only(
                              top: 24.0, left: 100.0, right: 100.0),
                          child: RaisedButton(
                            elevation: 10.0,
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            onPressed: () {},
                            child: Ink(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [
                                          Colors.green,
                                          Colors.greenAccent
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Container(
                                  constraints: BoxConstraints(
                                      maxWidth: 200.0, minHeight: 45.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                      AppLocalizations.of(context)
                                          .translate('reset_password'),
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: "Poppins-Bold",
                                          letterSpacing: 1.0)),
                                )),
                            padding: EdgeInsets.all(0.0),
                          ),
                        ),
                        SizedBox(height: 44),
                        FlatButton(
                            child: Text(
                                AppLocalizations.of(context)
                                    .translate('cancel'),
                                style: TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.underline,
                                    fontSize: 16,
                                    letterSpacing: 1.0,
                                    fontFamily: "Poppins-Bold")),
                            onPressed: () => Navigator.of(context).pop())
                      ],
                    ))))));
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
                      Radius.circular(10),
                    )),
                    hintStyle: TextStyle(
                        color: Colors.grey[800], fontFamily: 'OpenSans'),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    )))));
  }
}
