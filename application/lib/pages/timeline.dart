import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../widgets/progress.dart';

final usersRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List <dynamic> users = [] ;

  @override
  void initState() {
        getUsers();
        super.initState();
  }
  
  getUsers() async {
    final QuerySnapshot snapshot =  await usersRef.where("isAdmin", isEqualTo: false).getDocuments(); 
      snapshot.documents.forEach((DocumentSnapshot doc) {
        setState(() {
          users = snapshot.documents;
        });
      });
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context),
      body: Container(
        child: ListView(children: users.map((user) => user).toList(),),
      ),
    );
  }

    
}
