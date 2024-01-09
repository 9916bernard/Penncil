import 'package:flutter/material.dart';
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
                return ListTile(
                  title: Text(course.name),
                  subtitle: Text(course.description),
                  onTap: () {
                    // Define action on tap, like navigating to a course detail screen
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
