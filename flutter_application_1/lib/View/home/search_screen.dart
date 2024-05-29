import 'package:flutter/material.dart';
import 'package:flutter_application_1/View/global_widgets/add_course_widget.dart';
import 'package:flutter_application_1/View/home/main/course_detail_screen.dart';
import 'package:flutter_application_1/models/course_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/course_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = "";
  Map<String, Map<String, dynamic>> userCache = {};

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);

    // Fetch courses when the screen is built
    courseProvider.fetchCourses();

    List<Course> displayedCourses = searchQuery.isEmpty
        ? courseProvider.courses
        : courseProvider.courses
            .where((course) =>
                course.name.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim();
                });
              },
              decoration: InputDecoration(
                labelText: "Search for courses",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: displayedCourses.length,
              itemBuilder: (context, index) {
                final course = displayedCourses[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CourseDetailScreen(courseId: course.id),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Center(
                              child: Text(
                                'User-picked image goes here',
                                style: TextStyle(color: Colors.grey),
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
                                  String userId = course.enrolledUsers[index];
                                  if (!userCache.containsKey(userId)) {
                                    userCache[userId] =
                                        {}; // Initialize with an empty map
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(userId)
                                        .get()
                                        .then((userDoc) {
                                      if (userDoc.exists) {
                                        setState(() {
                                          userCache[userId] = userDoc.data()!;
                                        });
                                      }
                                    });
                                  }

                                  return Positioned(
                                    left: index * 30.0,
                                    child: userCache[userId]!.isNotEmpty
                                        ? CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                userCache[userId]![
                                                        'pickedImage'] ??
                                                    'default_user_image_url'),
                                            radius: 20,
                                          )
                                        : CircleAvatar(
                                            backgroundColor: Colors.grey,
                                            radius: 20,
                                            child: CircularProgressIndicator(),
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
              },
            ),
          ),
          AddCourseWidget(),
        ],
      ),
    );
  }
}
