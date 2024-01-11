import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/View/home/chat/chatroom_page.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text("You need to be logged in to view chatrooms")),
      );
    }

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot> userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return Center(child: Text("No Chatrooms available"));
          }

          // Safely access 'joinedChatrooms' field
          var userData = userSnapshot.data!.data() as Map<String, dynamic>;
          List<dynamic> joinedChatrooms =
              userData.containsKey('joinedChatrooms')
                  ? List.from(userData['joinedChatrooms'])
                  : [];

          if (joinedChatrooms.isEmpty) {
            return Center(child: Text("No Chatrooms available"));
          }

          return ListView.builder(
            itemCount: joinedChatrooms.length,
            itemBuilder: (context, index) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('courseChats')
                    .doc(joinedChatrooms[index])
                    .get(),
                builder: (context, chatSnapshot) {
                  if (chatSnapshot.connectionState == ConnectionState.done &&
                      chatSnapshot.hasData) {
                    var chatRoom = chatSnapshot.data!;
                    return _buildChatRoomItem(context, chatRoom.id,
                        chatRoom.get('name') ?? 'Chatroom');
                  } else {
                    return SizedBox
                        .shrink(); // Skip rendering if chatroom data is not available
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildChatRoomItem(
      BuildContext context, String chatRoomId, String chatRoomName) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Card(
        child: ListTile(
          title: Text(chatRoomName),
          trailing: Icon(Icons.arrow_forward),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Chatroom(chatRoomId: chatRoomId)),
            );
          },
        ),
      ),
    );
  }
}
