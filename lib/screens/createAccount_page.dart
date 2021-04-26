import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pvt_15/app_localizations.dart';
import 'package:pvt_15/infrastructure/firebase_auth.dart';
import "package:pvt_15/screens/login.dart";

class CreateAccount extends StatefulWidget {
  final AuthFunc auth;
  final VoidCallback onSignedUp;

  CreateAccount(this.auth, this.onSignedUp);
  @override 
  CreateAccountState createState() => new CreateAccountState();
}

class CreateAccountState extends State<CreateAccount> {
 final _formKey = new GlobalKey<FormState>();
  String _email, _password, _errorMessage;

  bool _isIos, _isLoading; 
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
        child: Form(
                key: _formKey, 
        child: SafeArea(
          child:Container(
            padding: EdgeInsets.only(left: 24.0, right: 24.0),
            child: Center(
              child: Column(
                children: [
              languageSettingIcons(context),
              leafIcon,
              SizedBox(height: 24),
              title(context),
               SizedBox(height: 24),
              emailInput(context),
               SizedBox(height: 12),
              passwordInput(context),
               SizedBox(height: 44),
              createAccountButton(context)
              
                  ])))))));
  }

   bool _validateAndSave() {
      final form = _formKey.currentState;
      if (form.validate()) {
        form.save();
        return true;
      }
      return false;
    }

     void _showVerifyEmailSentDialog() {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: new Text((AppLocalizations.of(context).translate('thanks'))),
                content: new Text(AppLocalizations.of(context).translate('link_email')),
                actions: <Widget>[
                  new FlatButton(
                      onPressed: () {
                        /* _changeFormToSignIn(); */
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'))
                ]);
          });
    }

    void _validateAndSubmit() async {
      setState(() {
        _errorMessage = "";
        _isLoading = true;
      });

      if (_validateAndSave()) {
        String userId = "";
        try {
          userId = await widget.auth.signUp(_email, _password);
          widget.auth.sendEmailVerification();
          _showVerifyEmailSentDialog();

          /* } */

          setState(() {
            _isLoading = false;
          });

          if (userId.length > 0 && userId != null) {
            widget.onSignedUp();
          } 
        } catch (e) {
          print(e);
            _isLoading = false;
            _errorMessage = e.message;
        }
      }
    } 

  TextFormField emailInput(BuildContext context) {
    return TextFormField(
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
         validator: (value) => value.isEmpty ? AppLocalizations.of(context).translate('email_not_empty') : null,
        onSaved: (value) => _email = value.trim(), 
        decoration: InputDecoration(
          hintText:
              AppLocalizations.of(context).translate('e-mail'),
          fillColor: Colors.white,
          filled: true,
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
            Radius.circular(32),
          )),
          hintStyle: TextStyle(color: Colors.grey[800]),
        ));
  }

  TextFormField passwordInput(BuildContext context) {
    return TextFormField(
        autofocus: false,
        obscureText: true,
         validator: (value) =>
        value.isEmpty ? AppLocalizations.of(context).translate('password_not_empty') : null,
        onSaved: (value) => _password = value.trim(), 
        decoration: InputDecoration(
          hintText:
              AppLocalizations.of(context).translate('password'),
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(32),
            ),
          ),
          hintStyle: TextStyle(color: Colors.grey[800]),
        ));
  }

  Widget createAccountButton( BuildContext context){
    return  SizedBox(
      height: 50, 
      width: 150,
      child: Container(
        child: Container(
       decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.green, Colors.greenAccent])
       ),
      child: RaisedButton(
      onPressed: () {
        if (_validateAndSave()) {
          _validateAndSubmit();
          Navigator.pop(context);
        }
      },
      color: Colors.transparent,
      child: Text(
        AppLocalizations.of(context).translate("create_account"),
      style: TextStyle(
        fontSize: 14,
        color: Colors.white,fontFamily: "Poppins-Bold",letterSpacing: 1.0
        )),
        elevation: 10.0,
            ),
           ),
      ));
}
}