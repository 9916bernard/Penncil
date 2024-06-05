import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String description;
  final String category;
  final String subcategory;
  final String imageUrl;
  final List<String> enrolledUsers;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.subcategory,
    required this.imageUrl,
    required this.enrolledUsers,
  });

  factory Group.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Group(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      subcategory: data['subcategory'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      enrolledUsers: List<String>.from(data['enrolledUsers'] ?? []),
    );
  }
}
