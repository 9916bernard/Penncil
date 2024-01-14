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

  // Fetch courses for a specific user (유저의 courses)
  Future<void> fetchUserCourses(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .where('enrolledUsers', arrayContains: userId)
        .get();
    _courses =
        querySnapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();
    notifyListeners();
  }

  // Fetch course details from Firestore (course의 정보)
  Future<Course?> fetchCourseDetails(String courseId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .get();
      if (docSnapshot.exists) {
        return Course.fromFirestore(docSnapshot);
      }
    } catch (e) {
      // Handle errors or log them
    }
    return null; // Return null if course is not found or an error occurs
  }

  // Add a new course to Firestore
  Future<void> enrollInCourse(String courseId, String userId) async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .update({
      'enrolledUsers': FieldValue.arrayUnion([userId])
    });

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'enrolledCourses': FieldValue.arrayUnion([courseId])
    });

    notifyListeners(); // Notify listeners to rebuild the UI if needed
  }

  Future<void> removeFromCourse(String courseId, String userId) async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .update({
      'enrolledUsers': FieldValue.arrayRemove([userId])
    });

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'enrolledCourses': FieldValue.arrayRemove([courseId])
    });

    notifyListeners(); // Notify listeners to rebuild the UI if needed
  }

  
}
