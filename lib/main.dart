import 'package:flutter/material.dart';

import 'calculator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.black,
      ),
      home: Calculator(title: 'Calculator'),
      debugShowCheckedModeBanner: false,
    );
  }
}