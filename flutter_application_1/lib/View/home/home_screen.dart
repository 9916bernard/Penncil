import 'package:animation_search_bar/animation_search_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/View/home/chat/chat_screen.dart';
import 'package:flutter_application_1/View/home/profile/profile_screen.dart';
import 'package:flutter_application_1/View/home/search/search_screen.dart';
import 'package:flutter_application_1/View/home/add_group_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _authentication.currentUser;
    try {
      if (user != null) {
        loggedUser = user;
        print(loggedUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }

  int _selectedIndex = 0; // The default selected index for the BottomNavigationBar
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  // Pages that correspond to the tabs in the BottomNavigationBar
  final List<Widget> _pages = <Widget>[
    SearchScreen(),
    AddGroupScreen(), // Add Group screen
    ChatScreen(), // Chat screen
    ProfileScreen(), // Profile screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Switches to the tab that was tapped
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: _pages[_selectedIndex], // Display the page selected by the bottom navigation bar
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        backgroundColor: Colors.white,
        color: Color.fromARGB(255, 8, 122, 216),
        buttonBackgroundColor: Color.fromARGB(255, 8, 122, 216),
        height: 60,
        items: <Widget>[
          Icon(Icons.explore_outlined, size: 30, color: Colors.white),
          Icon(Icons.add, size: 30, color: Colors.white), // Add group screen
          Icon(Icons.chat, size: 30, color: Colors.white), // Chat screen
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
