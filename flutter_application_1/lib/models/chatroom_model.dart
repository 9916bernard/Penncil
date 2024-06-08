import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final String name;
  final List<String> participants;

  ChatRoom({required this.id, required this.name, required this.participants});
//여기선 가지고만 있고 하는건 provider에서
  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      id: doc.id,
      name: data['name'] ?? '',
      participants: List.from(data['participants'] ?? []),
    );
  }
}
