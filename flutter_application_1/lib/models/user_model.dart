import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String userName;
  final String email;
  final String profileImageUrl;

  AppUser({
    required this.id,
    required this.userName,
    required this.email,
    required this.profileImageUrl,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      userName: data['userName'] ?? '',
      email: data['email'] ?? '',
      profileImageUrl: data['pickedImage'] ?? '',
    );
  }
}
