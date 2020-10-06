import 'package:flutter/material.dart';
import 'pages/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var themeData = ThemeData(
      primaryColor: Colors.black,
      primaryColorLight: Colors.white,
      accentColor: Colors.amber,
      //(0xD4AF37),
    );
    return MaterialApp(
      title: 'FlutterShare',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: Home(),
    );
  }
}
