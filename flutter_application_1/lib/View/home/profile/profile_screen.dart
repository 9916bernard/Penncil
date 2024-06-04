import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/View/global_widgets/add_group_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/View/login/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/user_data_provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _authentication = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the username controller with data from the provider.
    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);
    _usernameController.text = userDataProvider.user?.userName ?? '';
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await Provider.of<UserDataProvider>(context, listen: false)
          .uploadProfilePicture(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final user = userDataProvider.user; // Use the user data from the provider

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _authentication.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: <Widget>[
            if (user == null)
              SizedBox(
                height: 100, // match the size of CircleAvatar
                width: 100,
                child:
                    CircularProgressIndicator(), // Show a loading indicator while user data is being fetched
              )
            else
              CircleAvatar(
                backgroundImage: NetworkImage(user.profileImageUrl ??
                    'default_image_url'), // Use the profileImageUrl from the provider
                radius: 50,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: TextButton(
                onPressed: pickImage,
                child: const Text("Change Profile Picture"),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: user?.userName ??
                      'Loading...', // Use the userName from the provider
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (user != null) {
                    // Check if the user data is available
                    userDataProvider.updateUserName(_usernameController.text);
                  }
                },
                child: Text('Change Username'),
              ),
            ),
            AddGroupWidget(),
          ],
        ),
      ),
    );
  }
}
