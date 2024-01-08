import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseId;

  CourseDetailScreen({required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            Map<String, dynamic> courseData =
                snapshot.data!.data() as Map<String, dynamic>;
            List<dynamic> enrolledUsers = courseData['enrolledUsers'] ?? [];
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(courseData['name'],
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text(courseData['description'],
                        style: TextStyle(fontSize: 18)),
                    SizedBox(height: 20),
                    Text('Enrolled Students',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SingleChildScrollView(
                      child: Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: enrolledUsers.length,
                          itemBuilder: (context, index) {
                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(enrolledUsers[index])
                                  .get(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState ==
                                        ConnectionState.done &&
                                    userSnapshot.data != null) {
                                  Map<String, dynamic> userData =
                                      userSnapshot.data!.data()
                                          as Map<String, dynamic>;
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
                                        Text(userData['userName'] ??
                                            'Unknown User'),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
