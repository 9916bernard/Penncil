import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String description;
  final List<String> enrolledUsers;
  final String category;
  final String subcategory;
  final String imageUrl;
  final int groupLimit;
  final int currentMembers;
  final Timestamp expiryTime; // Add this field

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
    required this.expiryTime, // Initialize this field
  });

  factory Group.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
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
      expiryTime: data['expiryTime'] ?? Timestamp.now(), // Default to current time if not provided
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'enrolledUsers': enrolledUsers,
      'category': category,
      'subcategory': subcategory,
      'imageUrl': imageUrl,
      'groupLimit': groupLimit,
      'currentMembers': currentMembers,
      'expiryTime': expiryTime,
    };
  }
}
