import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/View/home/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers to retrieve text from text fields
  final _authentication = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String userName = '';
  String userEmail = '';
  String userPassword = '';

  void _tryValidation() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        // Using AppBar for the back button
        title: Text("Sign up"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: ValueKey(3),
                validator: (value) {
                  if (value!.isEmpty || value.length < 4) {
                    return 'Please enter at least 4 characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  userName = value!;
                },
                onChanged: (value) {
                  userName = value;
                },
                decoration: InputDecoration(
                  labelText: 'User Name',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 20),

              TextFormField(
                key: ValueKey(1),
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onSaved: (value) {
                  userEmail = value!;
                },
                onChanged: (value) {
                  userEmail = value;
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              TextFormField(
                key: ValueKey(2),
                validator: (value) {
                  if (value!.isEmpty || value.length < 6) {
                    return 'Please enter at least 6 characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  userPassword = value!;
                },
                onChanged: (value) {
                  userPassword = value;
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true, // Hide the text being entered
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  _tryValidation();
                  try {
                    final newUser =
                        await _authentication.createUserWithEmailAndPassword(
                            email: userEmail, password: userPassword);

                            await FirebaseFirestore.instance.collection('users').doc(newUser.user!.uid).set({
                              'userName': userName, 
                              'email': userEmail,
                            });

                    if (newUser.user != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    }
                  } catch (e) {
                    print(e);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()), 
                      ),
                    );
                  }
                },
                child: Text('Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
