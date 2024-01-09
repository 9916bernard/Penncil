import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/course_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/course_provider.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  CourseDetailScreen({required this.courseId});

  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isEnrolled = false;
  Course? course;

  @override
  void initState() {
    super.initState();
    fetchCourseDetails();
  }

  Future<void> fetchCourseDetails() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .get();

    if (snapshot.exists) {
      setState(() {
        course = Course.fromFirestore(snapshot);
        isEnrolled = course!.enrolledUsers.contains(_auth.currentUser?.uid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Course Details'),
      ),
      body: course == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(course!.name,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () => isEnrolled
                              ? removeFromCourse(courseProvider)
                              : enrollInCourse(courseProvider),
                          child: Text(isEnrolled
                              ? 'Remove from Course'
                              : 'Mark as Enrolled'),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(course!.description, style: TextStyle(fontSize: 18)),
                    SizedBox(height: 20),
                    Text('Enrolled Students',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: course!.enrolledUsers.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(course!.enrolledUsers[index])
                              .get(),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState ==
                                    ConnectionState.done &&
                                userSnapshot.data != null) {
                              Map<String, dynamic> userData = userSnapshot.data!
                                  .data() as Map<String, dynamic>;
                              return Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          userData['pickedImage'] ??
                                              'default_user_image_url'),
                                      radius: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                        userData['userName'] ?? 'Unknown User'),
                                  ],
                                ),
                              );
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void enrollInCourse(CourseProvider provider) async {
    await provider.enrollInCourse(widget.courseId, _auth.currentUser!.uid);
    await fetchCourseDetails(); // Refetch course details to update the UI
  }

  void removeFromCourse(CourseProvider provider) async {
    await provider.removeFromCourse(widget.courseId, _auth.currentUser!.uid);
    await fetchCourseDetails(); // Refetch course details to update the UI
  }
}
