import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/View/home/home_screen.dart';
import 'package:flutter_application_1/View/home/main/main_screen.dart';
import 'package:flutter_application_1/View/login/signup_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers to retrieve text from text fields
  final _authentication = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String userEmail = '';
  String userPassword = '';

  void _tryValidation() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signUpWithGoogle() async {
    try {
      // Trigger the Google sign-in flow
      final UserCredential userCredential = await signInWithGoogle();

      // Check if the user already exists in your 'users' collection in Firestore
      final userExists = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userExists.exists) {
        // If the user exists, navigate to the home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        // If the user does not exist, create a new record
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'userName': userCredential.user!.displayName,
          'email': userCredential.user!.email,
          'pickedImage': userCredential.user!.photoURL,
        });

        // After creating the record, navigate to the home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } catch (e) {
      print(e); // For debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in with Google'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        // Using AppBar for the back button
        title: Text("Login"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  child: Text('Free pass')),
              TextFormField(
                key: ValueKey(3),
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
                key: ValueKey(4),
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
                        await _authentication.signInWithEmailAndPassword(
                            email: userEmail, password: userPassword);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  } on FirebaseAuthException catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                      ),
                    );
                  }
                },
                child: Text('Login'),
              ),
              TextButton(
                onPressed:
                    signUpWithGoogle, // Call the googleSignUp method when the button is pressed
                child: Text('Log in with Google'),
              ),
              SizedBox(height: 50),
              Center(child: Text('Don\'t have an account? Sign up')),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },
                child: Text('Sign up with Email'),
              ),
              TextButton(
                onPressed:
                    signUpWithGoogle, // Call the googleSignUp method when the button is pressed
                child: Text('Sign up with Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
