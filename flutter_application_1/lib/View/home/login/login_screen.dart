import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
        TextButton(onPressed: () {}, child: Text("This is login screen")),
        TextButton(onPressed: () {}, child: Text("This is login screen")),
        TextButton(onPressed: () {}, child: Text("This is login screen"))
      ],
    )) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
