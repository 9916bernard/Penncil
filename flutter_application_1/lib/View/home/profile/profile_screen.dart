import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/View/login/login_screen.dart';
import 'package:flutter_application_1/providers/user_data_provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _authentication = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _usernameController = TextEditingController();
  bool _isEditingUsername = false;

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
      backgroundColor: Color.fromARGB(8, 38, 135, 219),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(8, 38, 135, 219),
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
              Column(
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black, // Border color
                          width: 3.0, // Border width
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(user.profileImageUrl ??
                            'default_image_url'), // Use the profileImageUrl from the provider
                        radius: 50,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Center(
                      child: Text(
                        user.userName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEditingUsername = !_isEditingUsername;
                        });
                      },
                      child: Text('Change Username'),
                    ),
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    height: _isEditingUsername ? 140 : 0,
                    child: SingleChildScrollView(
                      child: _isEditingUsername
                          ? Column(
                              children: [
                                SizedBox(height: 10),
                                TextFormField(
                                  controller: _usernameController,
                                  decoration: InputDecoration(
                                    labelText: 'Enter new username',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    if (user != null) {
                                      userDataProvider
                                          .updateUserName(_usernameController.text);
                                    }
                                    setState(() {
                                      _isEditingUsername = false;
                                    });
                                  },
                                  child: Text('Save'),
                                ),
                              ],
                            )
                          : Container(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}