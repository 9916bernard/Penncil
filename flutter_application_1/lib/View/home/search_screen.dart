import 'package:flutter/material.dart';
import 'package:flutter_application_1/View/global_widgets/add_course_widget.dart';
import 'package:flutter_application_1/View/home/main/course_detail_screen.dart';
import 'package:flutter_application_1/models/course_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/course_provider.dart'; // Import your CourseProvider

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);

    // Fetch courses when the screen is built
    courseProvider.fetchCourses();

    List<Course> displayedCourses = searchQuery.isEmpty
        ? courseProvider.courses // 검색창에 아무것도 안들어갔을때
        : courseProvider.courses
            .where((course) =>
                course.name.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList(); // 검색창에 뭐 들어갔을때

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
                return ListTile(
                  title: Text(course.name),
                  subtitle: Text(course.description),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CourseDetailScreen(courseId: course.id)),
                    );
                    // Define action on tap, like navigating to a course detail screen
                  },
                );
              },
            ),
          ),
          Text('Cant find the course?'),
          AddCourseWidget(),
        ],
      ),
    );
  }
}
