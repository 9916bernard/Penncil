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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text('Your Courses',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                if (user != null && user.enrolledCourses.isNotEmpty)
                  Container(
                    height: MediaQuery.of(context).size.height,
                    child: ListView.builder(
                      itemCount: user.enrolledCourses.length,
                      itemBuilder: (context, index) {
                        return Consumer<CourseProvider>(
                          builder: (context, courseProvider, child) {
                            return FutureBuilder<Course?>(
                              future: courseProvider.fetchCourseDetails(
                                  user.enrolledCourses[index]),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.data != null) {
                                    Course course = snapshot.data!;
                                    return GestureDetector(
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
                                      child: Card(
                                        color: Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                course.name,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Container(
                                                height: 200,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'User-picked image goes here',
                                                    style: TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Container(
                                                height: 40,
                                                child: Stack(
                                                  children: List.generate(
                                                    course.enrolledUsers.length,
                                                    (index) {
                                                      return Positioned(
                                                        left: index * 30.0,
                                                        child: FutureBuilder<
                                                            DocumentSnapshot>(
                                                          future: FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'users')
                                                              .doc(course
                                                                      .enrolledUsers[
                                                                  index])
                                                              .get(),
                                                          builder: (context,
                                                              userSnapshot) {
                                                            if (userSnapshot
                                                                        .connectionState ==
                                                                    ConnectionState
                                                                        .done &&
                                                                userSnapshot
                                                                        .data !=
                                                                    null) {
                                                              Map<String,
                                                                      dynamic>
                                                                  userData =
                                                                  userSnapshot
                                                                          .data!
                                                                          .data()
                                                                      as Map<
                                                                          String,
                                                                          dynamic>;
                                                              return CircleAvatar(
                                                                backgroundImage:
                                                                    NetworkImage(
                                                                        userData['pickedImage'] ??
                                                                            'default_user_image_url'),
                                                                radius: 20,
                                                              );
                                                            } else {
                                                              return CircleAvatar(
                                                                backgroundColor:
                                                                    Colors.grey,
                                                                radius: 20,
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              );
                                                            }
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
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
