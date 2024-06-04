import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/group_model.dart';

class GroupProvider with ChangeNotifier {
  List<Group> _groups = [];

  List<Group> get groups => _groups;

  // Fetch all groups from Firestore
  Future<void> fetchGroups() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('groups').get();
    _groups =
        querySnapshot.docs.map((doc) => Group.fromFirestore(doc)).toList();
    notifyListeners();
  }

  // Fetch groups for a specific user (유저의 groups)
  Future<void> fetchUserGroups(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('groups')
        .where('enrolledUsers', arrayContains: userId)
        .get();
    _groups =
        querySnapshot.docs.map((doc) => Group.fromFirestore(doc)).toList();
    notifyListeners();
  }

  // Fetch group details from Firestore (group의 정보)
  Future<Group?> fetchGroupDetails(String groupId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .get();
      if (docSnapshot.exists) {
        return Group.fromFirestore(docSnapshot);
      }
    } catch (e) {
      // Handle errors or log them
    }
    return null; // Return null if group is not found or an error occurs
  }

  // Add a new group to Firestore
  Future<void> enrollInGroup(String groupId, String userId) async {
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .update({
      'enrolledUsers': FieldValue.arrayUnion([userId])
    });

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'enrolledGroups': FieldValue.arrayUnion([groupId])
    });

    notifyListeners(); // Notify listeners to rebuild the UI if needed
  }

  Future<void> removeFromGroup(String groupId, String userId) async {
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .update({
      'enrolledUsers': FieldValue.arrayRemove([userId])
    });

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'enrolledGroups': FieldValue.arrayRemove([groupId])
    });

    notifyListeners(); // Notify listeners to rebuild the UI if needed
  }
}
