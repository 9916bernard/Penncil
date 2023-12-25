import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/View/home/chat/widgets/message_widget.dart';
import 'package:flutter_application_1/View/home/chat/widgets/send_message_widget.dart';

class Chatroom extends StatefulWidget {
  const Chatroom({super.key});

  @override
  State<Chatroom> createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),  // Navigate back
        ),
        title: Text('Chatroom', style: TextStyle(fontSize: 18)), // Small title
      ),
      body: 
      Column(children: [
        Expanded(child: MessageWidget()),

        SendMessageWidget(),
      ],)
      
    );
  }
}


// Align(
//                   alignment: Alignment.bottomCenter,
//                   child: 
//                 ),