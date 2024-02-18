import 'package:flutter/material.dart';
import 'package:flutter_application_1/View/global_widgets/add_course_widget.dart';
import 'package:flutter_application_1/View/home/main/course_detail_screen.dart';
import 'package:flutter_application_1/models/course_model.dart';
import 'package:flutter_application_1/providers/course_provider.dart';
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
    // microtask는 main screen이 빌드될떄마다 실행됨
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
                      itemCount: user.enrolledCourses
                          .length, // 유저의 enrolledCourses의 길이만큼 리스트뷰 생성
                      itemBuilder: (context, index) {
                        return Consumer<CourseProvider>(
                          // CourseProvider를 consumer로 감싸서 rebuild되게 함
                          builder: (context, courseProvider, child) {
                            return FutureBuilder<Course?>(
                              future: courseProvider.fetchCourseDetails(
                                  user.enrolledCourses[index]),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.data != null) {
                                    Course course = snapshot.data!;
                                    return Card(
                                      child: ListTile(
                                        title: Text(course.name),
                                        subtitle: Text(course.description),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CourseDetailScreen(
                                                      courseId: course.id),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  } else {
                                    return Text('Course not found');
                                  }
                                } else {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  )
                else
                  Center(child: Text("You are not enrolled in any courses.")),
                AddCourseWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
