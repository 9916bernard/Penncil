import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/user_data_provider.dart';
import 'package:provider/provider.dart';

class AddCourseWidget extends StatelessWidget {
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _courseDescriptionController =
      TextEditingController();
  AddCourseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final user = userDataProvider.user;

    void addCourse() async {
      final String courseName = _courseNameController.text;
      final String courseDescription = _courseDescriptionController.text;

      if (courseName.isNotEmpty &&
          courseDescription.isNotEmpty &&
          user != null) {
        // Create a new course document in the 'courses' collection
        DocumentReference course =
            await FirebaseFirestore.instance.collection('courses').add({
          'name': courseName,
          'description': courseDescription,
          'enrolledUsers': [user.id] // Initially enroll the current user
        });

        // Add the course to the user's 'enrolledCourses'
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .update({
          'enrolledCourses': FieldValue.arrayUnion([course.id])
        });

        // Update the local user data
        await userDataProvider.addEnrolledCourse(course.id);

        // Clear the text fields
        _courseNameController.clear();
        _courseDescriptionController.clear();
      }
    }

    return // Add Course Button
        Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: TextButton(
        onPressed: () {
          // Show a dialog to add a new course
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Add New Course'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      TextField(
                        controller: _courseNameController,
                        decoration: InputDecoration(hintText: 'Course Name'),
                      ),
                      TextField(
                        controller: _courseDescriptionController,
                        decoration:
                            InputDecoration(hintText: 'Course Description'),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Add'),
                    onPressed: () {
                      addCourse();
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Text('Add Course'),
      ),
    );
  }
}
