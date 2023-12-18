import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/View/login/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final _authentication = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
            onPressed: () {
              _authentication.signOut();

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text("Logout")),
      ],
    )); // Basic content for the profile screen
  }
}
