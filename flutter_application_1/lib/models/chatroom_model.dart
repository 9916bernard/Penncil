//적용 안됨 미완

import 'package:cloud_firestore/cloud_firestore.dart';

class Chatroom {
  final String id;
  final String name;
  final List<String> participants;

  Chatroom({required this.id, required this.name, required this.participants});

  factory Chatroom.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Chatroom(
      id: doc.id,
      name: data['name'] ?? '',
      participants: List<String>.from(data['participants'] ?? []),
    );
  }
}
