import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String userName;
  final String email;
  final String profileImageUrl;
  final List<String> enrolledGroups; // Renamed field

  AppUser({
    required this.id,
    required this.userName,
    required this.email,
    required this.profileImageUrl,
    required this.enrolledGroups, // Initialize this new field
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      userName: data['userName'] ?? '',
      email: data['email'] ?? '',
      profileImageUrl: data['pickedImage'] ?? '',
      enrolledGroups: List.from(data['enrolledGroups'] ??
          []), // Extract the enrolledGroups from the document, defaulting to an empty list if it's not present
    );
  }
}
