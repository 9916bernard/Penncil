import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/models/chatroom_model.dart';

class ChatRoomProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ChatRoom> _chatRooms = [];

  List<ChatRoom> get chatRooms => _chatRooms;

  Future<void> fetchChatRooms() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('courseChats').get();
      _chatRooms =
          querySnapshot.docs.map((doc) => ChatRoom.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      // Handle exceptions
    }
  }

  // Method to join or create a chat room 이거 코스챗에서 쓰는거임
  Future<String> joinOrCreateChatRoom(
      String chatRoomName, String userId) async {
    // Check if a chat room with the given name already exists
    QuerySnapshot existingChatRooms = await _firestore
        .collection('courseChats')
        .where('name', isEqualTo: chatRoomName)
        .limit(1)
        .get();

    if (existingChatRooms.docs.isNotEmpty) {
      // Chat room exists, join it
      DocumentReference chatRoomRef = existingChatRooms.docs.first.reference;
      await addParticipantToChatRoom(chatRoomRef, userId);
      return chatRoomRef.id; // Return existing chat room ID
    } else {
      // Create a new chat room
      DocumentReference newChatRoomRef =
          await _firestore.collection('courseChats').add({
        'name': chatRoomName,
        'participants': [userId],
      });
      return newChatRoomRef.id; // Return new chat room ID
    }
  }

  // Method to add a participant to a chat room
  Future<void> addParticipantToChatRoom(
      DocumentReference chatRoomRef, String userId) async {
    await chatRoomRef.update({
      'participants': FieldValue.arrayUnion([userId])
    });
  }

  // Fetch chat rooms for a specific user
  Future<List<String>> fetchUserChatRooms(String userId) async {
    List<String> userChatRooms = [];

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('courseChats')
          .where('participants', arrayContains: userId)
          .get();

      for (var doc in querySnapshot.docs) {
        userChatRooms.add(doc.id);
      }
    } catch (e) {
      // Handle exceptions or log errors
    }

    return userChatRooms;
  }

  Future<String> fetchChatRoomName(String chatRoomId) async {
    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('courseChats').doc(chatRoomId).get();
      if (docSnapshot.exists) {
        return docSnapshot.get('name') as String;
      }
    } catch (e) {
      // Handle exceptions or log errors
    }
    return ""; // Return an empty string if the chat room name is not found
  }

  // Future<void> joinChatRoom(String chatRoomId, String userId) async {
  //   try {
  //     await _firestore.collection('courseChats').doc(chatRoomId).update({
  //       'participants': FieldValue.arrayUnion([userId])
  //     });
  //     fetchChatRooms();
  //   } catch (e) {
  //     // Handle exceptions
  //   }
  // }

  // Future<void> createChatRoom(String name, String userId) async {
  //   try {
  //     DocumentReference docRef =
  //         await _firestore.collection('courseChats').add({
  //       'name': name,
  //       'participants': [userId],
  //     });
  //     joinChatRoom(docRef.id, userId);
  //   } catch (e) {
  //     // Handle exceptions
  //   }
  // }

  // Future<void> leaveChatRoom(String chatRoomId, String userId) async {
  //   try {
  //     await _firestore.collection('courseChats').doc(chatRoomId).update({
  //       'participants': FieldValue.arrayRemove([userId])
  //     });
  //     fetchChatRooms();
  //   } catch (e) {
  //     // Handle exceptions
  //   }
  // }
}
