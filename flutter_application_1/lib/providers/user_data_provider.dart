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
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        _user = null; // Clear user data when signed out
      } else {
        fetchUserData(); // Fetch new user data when signed in
      }
      notifyListeners();
    });
  }

  Future<void> fetchUserData() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();
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
          _user = AppUser(
            // Use your custom AppUser model
            id: _user!.id,
            userName: newUserName,
            email: _user!.email,
            profileImageUrl: _user!.profileImageUrl,
            enrolledGroups: _user!.enrolledGroups,
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
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child(user.uid + '.jpg');
        await ref.putFile(newImage);
        final url = await ref.getDownloadURL();
        await user.updateProfile(photoURL: url);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'pickedImage': url,
        });
        _user = AppUser(
          id: _user!.id,
          userName: _user!.userName,
          email: _user!.email,
          profileImageUrl: url,
          enrolledGroups: _user!.enrolledGroups,
        ); // Update the local user data
        notifyListeners();
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> addEnrolledGroup(String groupId) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null && _user != null) {
      try {
        // Update the user's enrolledGroups in Firestore
        await _firestore.collection('users').doc(firebaseUser.uid).update({
          'enrolledGroups': FieldValue.arrayUnion([groupId])
        });

        // Update the local user data to include the new group
        List<String> updatedGroups = List.from(_user!.enrolledGroups ?? [])
          ..add(groupId);
        _user = AppUser(
          id: _user!.id,
          userName: _user!.userName,
          email: _user!.email,
          profileImageUrl: _user!.profileImageUrl,
          enrolledGroups:
              updatedGroups, // include the enrolledGroups field in your AppUser model if it's not already there
        );
        notifyListeners();
      } catch (e) {
        print(e);
      }
    }
  }

  Future<AppUser?> fetchUserDetails(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return AppUser.fromFirestore(userDoc);
      }
    } catch (e) {
      // Handle exceptions
      print(e); // Consider proper error handling
    }
    return null;
  }
}
