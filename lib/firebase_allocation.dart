import 'package:flutter/material.dart';
import 'package:pvt_15/infrastructure/firebase_auth.dart';
//import 'firebase_auth.dart';
//import 'home_page.dart';
import 'screens/login.dart';
import 'screens/mapPage.dart';
//import 'signin_signup_page.dart';

//kan denna vara stateless om appstate är en state (den som tillkallar firebaseAllocation samt är app stateful)
class FirebaseAllocation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FirebaseAllocationHome(
      new MyAuth(),
    );
  }
}

class FirebaseAllocationHome extends StatefulWidget {
  FirebaseAllocationHome(this.auth);

  AuthFunc auth;

  @override
  State<StatefulWidget> createState() => new _FirebaseAllocationHomeState();
}

enum AuthStatus { NOT_LOGIN, NOT_DETERMINED, LOGIN }

class _FirebaseAllocationHomeState extends State<FirebaseAllocationHome> {
  AuthStatus authStatus = AuthStatus.NOT_LOGIN;
  String _userId = "", _userEmail = "";

  //For every state created this will be called exactly once. Checks if there is a user logged in and based on this sets the authStatus.
  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
          _userEmail = user?.email;
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGIN : AuthStatus.LOGIN;
      });
    });
  }

  //Depending on authstatus set in the initState() this switch decides whether to skip the loginpage or not.
  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return _showLoading();
        break;
      case AuthStatus.NOT_LOGIN:
        return new LoginPage(
            auth: widget.auth,
            onSignedIn: _onSignedIn,
            onSignedUp: _onSignedUp);
        break;
      case AuthStatus.LOGIN:
        if (_userId.length > 0 && _userId != null) {
          return new MapPage(
              userId: _userId,
              userEmail: _userEmail,
              auth: widget.auth,
              onSignOut: _onSignOut);
        } else
          return _showLoading();
        break;
      default:
        return _showLoading();
        break;
    }
  }

  void _onSignOut() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGIN;
      _userId = _userEmail = "";
    });
  }

  //when you log in this method will save values such as your _userId and your _userEmail and after that change the authStatus to logged in.
  void _onSignedIn() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
        _userEmail = user.email.toString();
      });
      setState(() {
        authStatus = AuthStatus.LOGIN;
      });
    });
  }

  void _onSignedUp() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
        _userEmail = user.email.toString();
      });
      setState(() {
        authStatus = AuthStatus.NOT_LOGIN;
      });
    });
  }
}

//Loadingscreen.
Widget _showLoading() {
  return Scaffold(
      body: Container(
          alignment: Alignment.center, child: CircularProgressIndicator()));
}
