import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/user_model.dart'; // Import your User model

class UserDataProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AppUser? _user; // Use your custom AppUser model

  AppUser? get user => _user;

  UserDataProvider() {
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        _user = AppUser.fromFirestore(userDoc); // Use your custom AppUser model
        notifyListeners();
      } catch (e) {
        rethrow; // Handle errors appropriately
      }
    }
  }

  Future<void> updateUserName(String newUserName) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        await _firestore.collection('users').doc(firebaseUser.uid).update({
          'userName': newUserName,
        });
        if (_user != null) {
          _user = AppUser( // Use your custom AppUser model
            id: _user!.id,
            userName: newUserName,
            email: _user!.email,
            profileImageUrl: _user!.profileImageUrl,
          );
          notifyListeners();
        }
      } catch (e) {
        rethrow; // Handle errors appropriately
      }
    }
  }

  Future<void> uploadProfilePicture(File newImage) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      final ref = FirebaseStorage.instance.ref().child('user_images').child(user.uid + '.jpg');
      await ref.putFile(newImage);
      final url = await ref.getDownloadURL();
      await user.updateProfile(photoURL: url);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'pickedImage': url,
      });
      _user = AppUser(
        id: _user!.id,
        userName: _user!.userName,
        email: _user!.email,
        profileImageUrl: url,
      ); // Update the local user data
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
  // Add more methods for updating user data as needed
}
