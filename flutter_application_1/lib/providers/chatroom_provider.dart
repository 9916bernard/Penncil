// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/View/home/chat/chatroom_page.dart';

// class ChatroomProvider with ChangeNotifier {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   Chatroom? _currentChatroom;

//   Chatroom? get currentChatroom => _currentChatroom;

//   Future<void> fetchChatroomDetails(String chatroomId) async {
//     DocumentSnapshot docSnapshot = await _firestore.collection('chatrooms').doc(chatroomId).get();
//     if (docSnapshot.exists) {
//       _currentChatroom = Chatroom.fromFirestore(docSnapshot);
//       notifyListeners();
//     }
//   }

//   // Additional methods to handle chatroom creation, updating, etc.
// }
