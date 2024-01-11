import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/chat_model.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => _messages;

  // Fetch chat messages
  Future<void> fetchChatMessages(String chatRoomId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('chats/$chatRoomId/message')
        .orderBy('time', descending: true)
        .get();
    _messages =
        snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
    notifyListeners();
  }

  // Send a new message
  Future<void> sendMessage(String chatRoomId, ChatMessage message) async {
    await _firestore.collection('chats/$chatRoomId/message').add({
      'text': message.text,
      'time': Timestamp.fromDate(message.time),
      'userId': message.userId,
      'userName': message.userName,
      'userImage': message.userImage,
    });
    notifyListeners();
  }
}
