import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/models/chat_model.dart';

//나중에 개인챗 할때는 프로바이더에다가 새로운 메소드 만들어서 쓰면 될듯? personalchats/어쩌구/message 이렇게
class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ChatModel> _messages = [];

  List<ChatModel> get messages => _messages;

  Future<void> fetchMessages(String chatRoomId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('courseChats/$chatRoomId/message')
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
      await _firestore.collection('courseChats/$chatRoomId/message').add({
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
