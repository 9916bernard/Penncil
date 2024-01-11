import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/View/home/chat/widgets/chat_bubble_widget.dart';

class MessageWidget extends StatelessWidget {
  final String chatRoomId;

  const MessageWidget({Key? key, required this.chatRoomId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('courseChats/$chatRoomId/message')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: ListView.builder(
            reverse: true,
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return ChatBubbles(
                docs[index]['text'],
                docs[index]['userId'].toString() == user!.uid,
                docs[index]['userName'],
                docs[index]['userImage'],
              );
            },
          ),
        );
      },
    );
  }
}
