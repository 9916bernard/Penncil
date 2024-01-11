import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String text;
  final DateTime time;
  final String userId;
  final String userName;
  final String userImage;

  ChatMessage({
    required this.text,
    required this.time,
    required this.userId,
    required this.userName,
    required this.userImage,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      text: data['text'] ?? '',
      time: (data['time'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userImage: data['userImage'] ?? '',
    );
  }
}
