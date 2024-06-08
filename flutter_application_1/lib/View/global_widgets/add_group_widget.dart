import 'package:flutter/material.dart';
import 'package:flutter_application_1/View/home/search/add_group_screen.dart';

class AddGroupWidget extends StatelessWidget {
  AddGroupWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: TextButton(
        onPressed: () {
          // Navigate to the AddGroupScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddGroupScreen(),
            ),
          );
        },
        child: Text('Create Own Group'),
      ),
    );
  }
}
