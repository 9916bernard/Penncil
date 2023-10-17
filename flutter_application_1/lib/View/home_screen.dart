import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';

class HomeScreen extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [TextButton(onPressed: () {}, child: Text("Hello"))],
    )) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
