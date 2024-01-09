import 'package:flutter/material.dart';
import 'package:flutter_application_1/View/global_widgets/add_course_widget.dart';
import 'package:flutter_application_1/View/home/main/course_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/user_data_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    // Ensuring that the user data is refreshed when the screen is loaded
    Future.microtask(() =>
        Provider.of<UserDataProvider>(context, listen: false).fetchUserData());
  }

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final user = userDataProvider.user;

    return Center(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text('Your Courses',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                if (user != null && user.enrolledCourses.isNotEmpty)
                  Container(
                    height: MediaQuery.of(context).size.height *
                        0.5, // Adjust the size as per your need
                    child: ListView.builder(
                      itemCount: user.enrolledCourses.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('courses')
                              .doc(user.enrolledCourses[index])
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.data != null) {
                              Map<String, dynamic> courseData =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              return Card(
                                child: ListTile(
                                  title: Text(courseData['name']),
                                  subtitle: Text(courseData['description']),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CourseDetailScreen(
                                                courseId: user
                                                    .enrolledCourses[index]),
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                        );
                      },
                    ),
                  )
                else
                  Text("You are not enrolled in any courses."),
                AddCourseWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
