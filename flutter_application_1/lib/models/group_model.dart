import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String description;
  final List<String> enrolledUsers;
  final String category;
  final String subcategory;
  final String imageUrl;
  final int groupLimit; // Add this field
  final int currentMembers; // Add this field

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.enrolledUsers,
    required this.category,
    required this.subcategory,
    required this.imageUrl,
    required this.groupLimit,
    required this.currentMembers,
  });

  factory Group.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Group(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      enrolledUsers: List<String>.from(data['enrolledUsers'] ?? []),
      category: data['category'] ?? '',
      subcategory: data['subcategory'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      groupLimit: data['groupLimit'] ?? 0,
      currentMembers: data['currentMembers'] ?? 0,
    );
  }
}
