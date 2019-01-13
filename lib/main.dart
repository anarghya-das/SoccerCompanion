import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'dart:core';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: HomeScreen(),
      appBar: AppBar(centerTitle: true, title: Text("Football Companion"),backgroundColor: Colors.black,),
    ),
  ));
}

