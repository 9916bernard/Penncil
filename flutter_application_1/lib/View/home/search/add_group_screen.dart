import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/user_data_provider.dart';
import 'package:provider/provider.dart';

class AddGroupScreen extends StatelessWidget {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController = TextEditingController();

  AddGroupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final user = userDataProvider.user;

    void addGroup() async {
      final String groupName = _groupNameController.text;
      final String groupDescription = _groupDescriptionController.text;

      if (groupName.isNotEmpty && groupDescription.isNotEmpty && user != null) {
        // Create a new group document in the 'groups' collection
        DocumentReference group = await FirebaseFirestore.instance.collection('groups').add({
          'name': groupName,
          'description': groupDescription,
          'enrolledUsers': [user.id] // Initially enroll the current user
        });

        // Add the group to the user's 'enrolledGroups'
        await FirebaseFirestore.instance.collection('users').doc(user.id).update({
          'enrolledGroups': FieldValue.arrayUnion([group.id])
        });

        // Update the local user data
        await userDataProvider.addEnrolledGroup(group.id);

        // Clear the text fields
        _groupNameController.clear();
        _groupDescriptionController.clear();

        // Navigate back
        Navigator.of(context).pop();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Own Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(hintText: 'Group Name'),
            ),
            TextField(
              controller: _groupDescriptionController,
              decoration: InputDecoration(hintText: 'Group Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addGroup,
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
