import 'package:flutter/material.dart';

AppBar header(context, {bool isCustomTitle = false, String title, bool removeBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
      isCustomTitle ? title : "Fame Game",
      style: TextStyle(
        color: Theme.of(context).accentColor,
        fontFamily: "Signatra",
        fontSize: 50.0,
      ),
    ),
    centerTitle: true,
    backgroundColor:  Theme.of(context).primaryColor,
  );
}

