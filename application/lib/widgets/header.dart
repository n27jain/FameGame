import 'package:flutter/material.dart';

AppBar header(context) {
  return AppBar(
    title: Text(
      "Fame Game",
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

