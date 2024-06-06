import 'package:flutter/material.dart';
import 'package:flutter_application_1/View/global_widgets/add_group_widget.dart';
import 'package:flutter_application_1/View/home/main/group_detail_screen.dart';
import 'package:flutter_application_1/models/group_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/group_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = "";
  String selectedCategory = "All";
  String selectedSubcategory = "All";
  Map<String, Map<String, dynamic>> userCache = {};

  final List<String> categories = ["All", "Sports", "Study", "Hangout", "Travel", "Game"];
  final Map<String, List<String>> subcategories = {
    "All": ["All"],
    "Sports": ["All", "Soccer", "Basketball", "Workout"],
    "Study": ["All", "Math", "Science", "History"],
    "Hangout": ["All", "Cafe", "Park", "Movie"],
    "Travel": ["All", "Adventure", "Cultural", "Leisure"],
    "Game": ["All", "Board Games", "Video Games", "Card Games"]
  };

  @override
  void initState() {
    super.initState();
    selectedSubcategory = subcategories[selectedCategory]?.first ?? "All";
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);

    // Fetch groups when the screen is built
    groupProvider.fetchGroups();

    List<Group> displayedGroups = groupProvider.groups.where((group) {
      bool matchesCategory = selectedCategory == "All" || group.category == selectedCategory;
      bool matchesSubcategory = selectedSubcategory == "All" || group.subcategory == selectedSubcategory;
      bool matchesSearchQuery = group.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSubcategory && matchesSearchQuery;
    }).toList();

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
                labelText: "Search for groups",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                        selectedSubcategory = subcategories[selectedCategory]?.first ?? "All";
                      });
                    },
                    items: categories.map<DropdownMenuItem<String>>((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedSubcategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSubcategory = newValue!;
                      });
                    },
                    items: (subcategories[selectedCategory] ?? ["All"]).map<DropdownMenuItem<String>>((String subcategory) {
                      return DropdownMenuItem<String>(
                        value: subcategory,
                        child: Text(subcategory),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: displayedGroups.length,
              itemBuilder: (context, index) {
                final group = displayedGroups[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GroupDetailScreen(groupId: group.id),
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
                            group.name,
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
                            child: group.imageUrl.isNotEmpty
                                ? Image.network(
                                    group.imageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/default_${group.category.toLowerCase()}.png',
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            height: 40,
                            child: Stack(
                              children: List.generate(
                                group.enrolledUsers.length,
                                (index) {
                                  String userId = group.enrolledUsers[index];
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
          AddGroupWidget(),
        ],
      ),
    );
  }
}
