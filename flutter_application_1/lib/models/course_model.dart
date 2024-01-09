import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String name;
  final String description;
  final List<String> enrolledUsers;

  Course(
      {required this.id,
      required this.name,
      required this.description,
      required this.enrolledUsers});

  factory Course.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Course(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      enrolledUsers: List<String>.from(data['enrolledUsers'] ?? []),
    );
  }
}
