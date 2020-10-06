import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Blank extends StatefulWidget {
  @override
  _BlankState createState() => _BlankState();
}

// final FirebaseAuth auth = FirebaseAuth.instance;
// final GoogleSignIn googleSignIn = GoogleSignIn();

class _BlankState extends State<Blank> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlutterLogo(size: 150),
              SizedBox(height: 50),
              signInButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget signInButton() {
    return GestureDetector(
      onTap: null, //login,
      child: Container(
        width: 260.0,
        height: 60.0,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/google_signin_button.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
