import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/models/chat_model.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ChatModel> _messages = [];

  List<ChatModel> get messages => _messages;

  Future<void> fetchMessages(String chatRoomId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('groupChats/$chatRoomId/message')
          .orderBy('time', descending: true)
          .get();

      _messages =
          snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      // Handle exceptions
    }
  }

  Future<void> sendMessage(String chatRoomId, String text, String userId,
      String userName, String userImage) async {
    try {
      await _firestore.collection('groupChats/$chatRoomId/message').add({
        'text': text,
        'userId': userId,
        'userName': userName,
        'userImage': userImage,
        'time': Timestamp.now(),
      });
      fetchMessages(chatRoomId); // Refresh messages after sending
    } catch (e) {
      // Handle exceptions
    }
  }
}
