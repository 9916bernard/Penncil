import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String text;
  final String userId;
  final String userName;
  final String userImage;
  final DateTime time;

  ChatModel({
    required this.id,
    required this.text,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.time,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      text: data['text'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userImage: data['userImage'] ?? '',
      time: (data['time'] as Timestamp).toDate(),
    );
  }
}
