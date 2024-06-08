import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/View/home/chat/widgets/message_widget.dart';
import 'package:flutter_application_1/View/home/chat/widgets/send_message_widget.dart';
import 'package:flutter_application_1/providers/chatroom_provider.dart';
import 'package:provider/provider.dart';

class Chatroom extends StatefulWidget {
  final String chatRoomId;

  const Chatroom({Key? key, required this.chatRoomId}) : super(key: key);

  @override
  State<Chatroom> createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(), // Navigate back
        ),
        title: Text('Chatroom', style: TextStyle(fontSize: 18)), // Small title
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              if (userId != null) {
                await Provider.of<ChatRoomProvider>(context, listen: false)
                    .removeParticipantFromChatRoom(widget.chatRoomId, userId);
                Navigator.of(context).pop(); // Navigate back after exiting
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: MessageWidget(chatRoomId: widget.chatRoomId)),
          SendMessageWidget(chatRoomId: widget.chatRoomId),
        ],
      ),
    );
  }
}
