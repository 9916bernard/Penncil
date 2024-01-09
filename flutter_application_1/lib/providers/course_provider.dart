import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/course_model.dart';

class CourseProvider with ChangeNotifier {
  List<Course> _courses = [];

  List<Course> get courses => _courses;

  // Fetch all courses from Firestore
  Future<void> fetchCourses() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('courses').get();
    _courses =
        querySnapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();
    notifyListeners();
  }

  // Fetch courses for a specific user
  Future<void> fetchUserCourses(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .where('enrolledUsers', arrayContains: userId)
        .get();
    _courses =
        querySnapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();
    notifyListeners();
  }

  // Add more methods as needed...
}
