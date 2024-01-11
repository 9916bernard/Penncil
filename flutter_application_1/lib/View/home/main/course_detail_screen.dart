import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/View/home/chat/chatroom_page.dart';
import 'package:flutter_application_1/models/course_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/providers/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/course_provider.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  CourseDetailScreen({required this.courseId});

  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isEnrolled = false;
  Course? course;

  @override
  void initState() {
    super.initState();
    fetchCourseDetails();
  }

  Future<void> fetchCourseDetails() async {
    Course? fetchedCourse =
        await Provider.of<CourseProvider>(context, listen: false)
            .fetchCourseDetails(widget.courseId);

    if (fetchedCourse != null) {
      setState(() {
        course = fetchedCourse;
        isEnrolled = course!.enrolledUsers.contains(_auth.currentUser?.uid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Course Details'),
      ),
      body: course == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(course!.name,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () => isEnrolled
                              ? removeFromCourse(courseProvider)
                              : enrollInCourse(courseProvider),
                          child: Text(isEnrolled
                              ? 'Remove from Course'
                              : 'Mark as Enrolled'),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(course!.description, style: TextStyle(fontSize: 18)),
                    SizedBox(height: 20),
                    Text('Enrolled Students',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: course!.enrolledUsers.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder<AppUser?>(
                          future: Provider.of<UserDataProvider>(context,
                                  listen: false)
                              .fetchUserDetails(course!.enrolledUsers[index]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.data != null) {
                              AppUser user = snapshot.data!;
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(user.profileImageUrl),
                                ),
                                title: Text(user.userName),
                              );
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                        );
                      },
                    ),
                    ElevatedButton(
                      onPressed: () => joinCourseChat(),
                      child: Text('Join Course Chat'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void joinCourseChat() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && course != null) {
      // Check if a chatroom with the course name already exists
      QuerySnapshot existingChatrooms = await FirebaseFirestore.instance
          .collection('courseChats')
          .where('name', isEqualTo: course!.name)
          .limit(1)
          .get();

      if (existingChatrooms.docs.isNotEmpty) {
        // Chatroom already exists, add user as a participant if not already
        DocumentReference chatRoomRef = existingChatrooms.docs.first.reference;
        await addParticipantToChatRoom(chatRoomRef, currentUser.uid);
      } else {
        // Create a new chatroom
        DocumentReference newChatRoomRef =
            await FirebaseFirestore.instance.collection('courseChats').add({
          'name': course!.name,
          'participants': [currentUser.uid],
        });
        await addParticipantToChatRoom(newChatRoomRef, currentUser.uid);
      }
    }
  }

  Future<void> addParticipantToChatRoom(
      DocumentReference chatRoomRef, String userId) async {
    await chatRoomRef.update({
      'participants': FieldValue.arrayUnion([userId])
    });

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'joinedChatrooms': FieldValue.arrayUnion([chatRoomRef.id])
    });

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Chatroom(chatRoomId: chatRoomRef.id)),
    );
  }

  void enrollInCourse(CourseProvider provider) async {
    await provider.enrollInCourse(widget.courseId, _auth.currentUser!.uid);
    await fetchCourseDetails(); // Refetch course details to update the UI
  } //프로바이더에 있는 함수가 작동하기까지 기다림

  void removeFromCourse(CourseProvider provider) async {
    await provider.removeFromCourse(widget.courseId, _auth.currentUser!.uid);
    await fetchCourseDetails(); // Refetch course details to update the UI
  }
}
