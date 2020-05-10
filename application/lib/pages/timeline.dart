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
    super.initState();
  }
  
  // getUsers() async {
  //   final QuerySnapshot snapshot =  await usersRef.where("isAdmin", isEqualTo: true).getDocuments(); 
  //     snapshot.documents.forEach((DocumentSnapshot doc) {
  //       setState(() {
  //         users = snapshot.documents;
  //       });
  //     });
  // }
  createUser() async {
    await usersRef.add({
      "username": "Linda",
      "postCount": 0,
      "isAdmin" : false,
    });
  }
  updateUser() async {
    await usersRef.add({
      "username": "Linda",
      "postCount": 0,
      "isAdmin" : false,
    });
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context),
      body: StreamBuilder<QuerySnapshot>(
        stream:usersRef.snapshots(),
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return circularProgress(context);
          }
          final List <Text> children = snapshot.data.documents.map((doc) => Text(doc['username'])).toList();
          return Container(
            child: ListView(
              children: children,
           ),
          );
        },
      ),
    );
  }

    
}
