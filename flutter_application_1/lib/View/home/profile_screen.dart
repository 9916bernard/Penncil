import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/View/login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _authentication = FirebaseAuth.instance;
  User? loggedInUser;
  String? imageUrl; // URL of the user's profile picture
  String? userName; // The user's name
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    fetchUserData();
  }

  void getCurrentUser() {
    final user = _authentication.currentUser;
    if (user != null) {
      loggedInUser = user;
    }
  }

  void fetchUserData() async {
    if (loggedInUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(loggedInUser!.uid).get();
      setState(() {
        userName = userDoc['userName'];
        imageUrl = userDoc['pickedImage'];
        _usernameController.text = userName ?? ''; // Set the initial value for the controller
      });
    }
  }

  Future<void> updateUserName(String newUserName) async {
    try {
      await loggedInUser!.updateProfile(displayName: newUserName);
      await FirebaseFirestore.instance.collection('users').doc(loggedInUser!.uid).update({
        'userName': newUserName,
      });
      setState(() {
        userName = newUserName; // Update the local state
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> uploadNewProfilePicture(File newImage) async {
    try {
      String imageUrl = await uploadImageToFirebase(newImage);
      await loggedInUser!.updateProfile(photoURL: imageUrl);
      await FirebaseFirestore.instance.collection('users').doc(loggedInUser!.uid).update({
        'pickedImage': imageUrl,
      });
      setState(() {
        this.imageUrl = imageUrl;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<String> uploadImageToFirebase(File image) async {
    final ref = FirebaseStorage.instance.ref().child('user_images').child(loggedInUser!.uid + '.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await uploadNewProfilePicture(imageFile);
    }
  }

  // void addCourse(String courseName) {
  //   FirebaseFirestore.instance.collection('courses').add({
  //     'name': courseName,
  //     'user': loggedInUser!.uid,
  //   });
  // }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(imageUrl ?? ''),
              radius: 50,
            ),
            TextButton(
              onPressed: () => pickImage(),
              child: Text("Change Profile Picture"),
            ),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            ElevatedButton(
              onPressed: () {
                updateUserName(_usernameController.text);
              },
              child: Text('Change Username'),
            ),
            // Add more form fields or buttons as needed for courses, etc.
            TextButton(
              onPressed: () {
                _authentication.signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}