import 'package:flutter/material.dart';
import 'package:flutter_application_1/View/home/chat/chatroom_page.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildChatRoomItem(
                context, 'Open Groupchat 1'), // Pass context here
          ],
        ),
      ),
    );
  }

  Widget _buildChatRoomItem(BuildContext context, String chatRoomName) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Card(
        color: Colors.transparent, // Transparent background for the card
        child: ListTile(
          title: Text(
            chatRoomName,
            style: TextStyle(color: Colors.white), // Text color
          ),
          trailing: Icon(Icons.arrow_forward, color: Colors.white),
          onTap: () {
            // Navigate to the chatroom page when tapped
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Chatroom()),
            );
          },
        ),
      ),
    );
  }
}
