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

  Future<String> joinOrCreateChatRoom(
      String chatRoomName, String userId) async {
    QuerySnapshot existingChatRooms = await _firestore
        .collection('courseChats')
        .where('name', isEqualTo: chatRoomName)
        .limit(1)
        .get();

    if (existingChatRooms.docs.isNotEmpty) {
      DocumentReference chatRoomRef = existingChatRooms.docs.first.reference;
      await addParticipantToChatRoom(chatRoomRef, userId);
      return chatRoomRef.id;
    } else {
      DocumentReference newChatRoomRef =
          await _firestore.collection('courseChats').add({
        'name': chatRoomName,
        'participants': [userId],
      });
      return newChatRoomRef.id;
    }
  }

  Future<void> addParticipantToChatRoom(
      DocumentReference chatRoomRef, String userId) async {
    await chatRoomRef.update({
      'participants': FieldValue.arrayUnion([userId])
    });
  }

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
    return "";
  }

  Future<Map<String, dynamic>> fetchChatRoomDetails(String chatRoomId) async {
    try {
      DocumentSnapshot chatRoomSnapshot =
          await _firestore.collection('courseChats').doc(chatRoomId).get();
      Map<String, dynamic>? chatRoomData =
          chatRoomSnapshot.data() as Map<String, dynamic>?;

      if (chatRoomData == null) {
        return {};
      }

      List<String> participants =
          List<String>.from(chatRoomData['participants']);

      QuerySnapshot lastMessageSnapshot = await chatRoomSnapshot.reference
          .collection('message')
          .orderBy('time', descending: true)
          .limit(1)
          .get();

      String lastMessage = lastMessageSnapshot.docs.isNotEmpty
          ? (lastMessageSnapshot.docs.first.data()
              as Map<String, dynamic>)['text'] as String
          : 'No messages yet';
      Timestamp timestamp = lastMessageSnapshot.docs.isNotEmpty
          ? (lastMessageSnapshot.docs.first.data()
              as Map<String, dynamic>)['time'] as Timestamp
          : Timestamp.now();

      return {
        'name': chatRoomData['name'],
        'participants': participants,
        'lastMessage': lastMessage,
        'timestamp': timestamp,
      };
    } catch (e) {
      // Handle exceptions or log errors
    }
    return {};
  }
}
