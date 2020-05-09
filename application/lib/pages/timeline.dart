import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../widgets/progress.dart';

final userRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {

  @override
  void initState() {
    final userRef = Firestore.instance.collection('users');
    super.initState();


  }
  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context),
      body: circularProgress(context),
    );
  }
}
