import 'package:animation_search_bar/animation_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/View/global_widgets/add_group_widget.dart';
import 'package:flutter_application_1/View/home/main/group_detail_screen.dart';
import 'package:flutter_application_1/models/group_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/group_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = "";
  String selectedCategory = "All";
  String selectedSubcategory = "All";
  Map<String, Map<String, dynamic>> userCache = {};

  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = ["All", "Sports", "Study", "Hangout", "Travel", "Game"];
  final Map<String, List<String>> subcategories = {
    "All": ["All"],
    "Sports": ["All", "Soccer", "Basketball", "Workout"],
    "Study": ["All", "Math", "Science", "History"],
    "Hangout": ["All", "Cafe", "Park", "Movie"],
    "Travel": ["All", "Adventure", "Cultural", "Leisure"],
    "Game": ["All", "Board Games", "Video Games", "Card Games"]
  };

  final Map<String, IconData> categoryIcons = {
    "Sports": Icons.sports_soccer,
    "Study": Icons.school,
    "Hangout": Icons.local_cafe,
    "Travel": Icons.airplanemode_active,
    "Game": Icons.videogame_asset,
  };

  @override
  void initState() {
    super.initState();
    selectedSubcategory = subcategories[selectedCategory]?.first ?? "All";
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text;
    });
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
      backgroundColor: Color.fromARGB(8, 38, 135, 219),
      appBar: PreferredSize(
        
        preferredSize: Size(double.infinity, 70),
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(color: Color.fromARGB(8, 38, 135, 219), boxShadow: [
              
            ]),
            alignment: Alignment.center,
            child: AnimationSearchBar(
              centerTitle: 'DoItWithMe',
              onChanged: (text) {
                setState(() {
                  searchQuery = text.trim();
                });
              },
              searchTextEditingController: _searchController,
              horizontalPadding: 5,
              closeIconColor: Colors.black,
              searchIconColor: Colors.black,
              cursorColor: Colors.black,
              hintText: 'Search here...',
              textStyle: TextStyle(color: Colors.white),
              hintStyle: TextStyle(color: Colors.white70),
              searchFieldDecoration: BoxDecoration(
                color: Colors.blueGrey.shade700,
                border: Border.all(color: Colors.black.withOpacity(.2), width: .5),
                borderRadius: BorderRadius.circular(15),
              ),
              isBackButtonVisible: false, // Hide the back button
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      value: selectedCategory,
                      hint: Text(
                        'Select Category',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      items: categories.map<DropdownMenuItem<String>>((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(
                            category,
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                          selectedSubcategory = subcategories[selectedCategory]?.first ?? "All";
                        });
                      },
                      buttonStyleData: ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 18, 139, 238),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 127, 187, 236),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      iconStyleData: IconStyleData(
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                      ),
                      menuItemStyleData: MenuItemStyleData(
                        height: 50,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      value: selectedSubcategory,
                      hint: Text(
                        'Select Subcategory',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      items: (subcategories[selectedCategory] ?? ["All"]).map<DropdownMenuItem<String>>((String subcategory) {
                        return DropdownMenuItem<String>(
                          value: subcategory,
                          child: Text(
                            subcategory,
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSubcategory = newValue!;
                        });
                      },
                      buttonStyleData: ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 18, 139, 238),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 127, 187, 236),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      iconStyleData: IconStyleData(
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                      ),
                      menuItemStyleData: MenuItemStyleData(
                        height: 50,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
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
                        builder: (context) => GroupDetailScreen(groupId: group.id),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                group.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(categoryIcons[group.category] ?? Icons.category, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(
                                    group.category,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
                                    userCache[userId] = {}; // Initialize with an empty map
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
                                                userCache[userId]!['pickedImage'] ?? 'default_user_image_url'),
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
        ],
      ),
    );
  }
}