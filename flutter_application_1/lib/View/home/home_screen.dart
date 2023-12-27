import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/View/home/chat/chat_screen.dart';
import 'package:flutter_application_1/View/home/main_screen.dart';
import 'package:flutter_application_1/View/home/profile_screen.dart';
import 'package:flutter_application_1/View/login/login_screen.dart';
import 'package:flutter_application_1/View/home/chat/chat_screen.dart';
import 'package:flutter_application_1/View/home/profile_screen.dart';
import 'package:flutter_application_1/View/home/main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;

  @override
  void initState() {
    // TODO: implement initState
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

  int _selectedIndex =
      0; // The default selected index for the BottomNavigationBar

  // Pages that correspond to the tabs in the BottomNavigationBar
  final List<Widget> _pages = <Widget>[
    MainScreen(),
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
      appBar: AppBar(
        title: Text('Studygroup Demo'),
         automaticallyImplyLeading: false,
      ),
      body: _pages[
          _selectedIndex], // Display the page selected by the bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
