import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/user_data_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddGroupScreen extends StatefulWidget {
  AddGroupScreen({Key? key}) : super(key: key);

  @override
  _AddGroupScreenState createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController = TextEditingController();
  final TextEditingController _customCategoryController = TextEditingController();
  final TextEditingController _customSubcategoryController = TextEditingController();
  final TextEditingController _groupLimitController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _groupImage;

  final List<String> categories = ["Sports", "Study", "Hangout", "Travel", "Game", "Custom"];
  final Map<String, List<String>> subcategories = {
    "Sports": ["Soccer", "Basketball", "Workout", "Custom"],
    "Study": ["Math", "Science", "History", "Custom"],
    "Hangout": ["Cafe", "Park", "Movie", "Custom"],
    "Travel": ["Adventure", "Cultural", "Leisure", "Custom"],
    "Game": ["Board Games", "Video Games", "Card Games", "Custom"]
  };

  String _selectedCategory = "Sports";
  String _selectedSubcategory = "Soccer";
  bool _isCustomCategory = false;
  bool _isCustomSubcategory = false;

  Duration _expiryDuration = Duration(hours: 1);

  @override
  void initState() {
    super.initState();
    _selectedSubcategory = subcategories[_selectedCategory]?.first ?? "Custom";
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _groupImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('group_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() => {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      // Handle errors
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final user = userDataProvider.user;

    void addGroup() async {
      final String groupName = _groupNameController.text;
      final String groupDescription = _groupDescriptionController.text;
      final int groupLimit = int.tryParse(_groupLimitController.text) ?? 0;
      final Timestamp expiryTime = Timestamp.fromDate(
          DateTime.now().add(_expiryDuration));
      final String category = _isCustomCategory
          ? _customCategoryController.text
          : _selectedCategory;
      final String subcategory = _isCustomSubcategory
          ? _customSubcategoryController.text
          : _selectedSubcategory;

      if (groupName.isNotEmpty &&
          groupDescription.isNotEmpty &&
          groupLimit > 0 &&
          _expiryDuration.inHours > 0 &&
          category.isNotEmpty &&
          subcategory.isNotEmpty &&
          user != null) {
        String? imageUrl;
        if (_groupImage != null) {
          imageUrl = await _uploadImage(_groupImage!);
        }

        // Create a new group document in the 'groups' collection
        DocumentReference group = await FirebaseFirestore.instance.collection('groups').add({
          'name': groupName,
          'description': groupDescription,
          'category': category,
          'subcategory': subcategory,
          'imageUrl': imageUrl ?? '', // Save empty string if no image is uploaded
          'groupLimit': groupLimit,
          'currentMembers': 1,
          'expiryTime': expiryTime,
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
        _customCategoryController.clear();
        _customSubcategoryController.clear();
        _groupLimitController.clear();

        // Navigate back
        Navigator.of(context).pop();
      }
    }

    return Scaffold(
      backgroundColor: Color.fromARGB(8, 38, 135, 219),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 60), // To avoid overlap with the button
                  Text(
                    'Group Image',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _groupImage != null
                            ? FileImage(_groupImage!)
                            : AssetImage('assets/default_${_selectedCategory.toLowerCase()}.png') as ImageProvider,
                        child: _groupImage == null
                            ? Icon(
                                Icons.add_a_photo,
                                size: 50,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
                  TextField(
                    controller: _groupNameController,
                    decoration: InputDecoration(hintText: 'Group Name'),
                  ),
                  TextField(
                    controller: _groupDescriptionController,
                    decoration: InputDecoration(hintText: 'Group Description'),
                  ),
                  TextField(
                    controller: _groupLimitController,
                    decoration: InputDecoration(hintText: 'Group Limit'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Expiry Time',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final Duration? result = await showModalBottomSheet<Duration>(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: 200,
                            child: CupertinoTimerPicker(
                              mode: CupertinoTimerPickerMode.hm,
                              initialTimerDuration: _expiryDuration,
                              onTimerDurationChanged: (Duration newDuration) {
                                setState(() {
                                  _expiryDuration = newDuration;
                                });
                              },
                            ),
                          );
                        },
                      );
                      if (result != null) {
                        setState(() {
                          _expiryDuration = result;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black.withOpacity(.2)),
                      ),
                      child: Text(
                        'Expiry Time: ${_expiryDuration.inHours} hours',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Select Category',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                        _selectedSubcategory = subcategories[_selectedCategory]?.first ?? "Custom";
                        _isCustomCategory = _selectedCategory == "Custom";
                        _isCustomSubcategory = false; // Reset subcategory state
                        _customCategoryController.clear();
                      });
                    },
                    items: categories.map<DropdownMenuItem<String>>((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                  ),
                  if (_isCustomCategory)
                    TextField(
                      controller: _customCategoryController,
                      decoration: InputDecoration(hintText: 'Enter custom category'),
                    ),
                  SizedBox(height: 20),
                  Text(
                    'Select Subcategory',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: _selectedSubcategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSubcategory = newValue!;
                        _isCustomSubcategory = _selectedSubcategory == "Custom";
                        _customSubcategoryController.clear();
                      });
                    },
                    items: (subcategories[_selectedCategory] ?? ["Custom"]).map<DropdownMenuItem<String>>((String subcategory) {
                      return DropdownMenuItem<String>(
                        value: subcategory,
                        child: Text(subcategory),
                      );
                    }).toList(),
                  ),
                  if (_isCustomSubcategory)
                    TextField(
                      controller: _customSubcategoryController,
                      decoration: InputDecoration(hintText: 'Enter custom subcategory'),
                    ),
                  SizedBox(height: 80), // To avoid overflow at the bottom
                ],
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 20,
            child: TextButton(
              onPressed: addGroup,
              child: Text('Create Group'),
              
            ),
          ),
        ],
      ),
    );
  }
}