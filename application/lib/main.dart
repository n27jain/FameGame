import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'pages/home.dart';

void main() {
  //use timestamp with 
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then(
    (_)  {
      print("Timestamps enabled in snapshots\n");
    }, onError: (_){
      print("Error enabling timestamps in snapshots\n");
    }
  );
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
