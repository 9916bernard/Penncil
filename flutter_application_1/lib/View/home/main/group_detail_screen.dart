import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/View/home/chat/chatroom_page.dart';
import 'package:flutter_application_1/models/group_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/providers/chatroom_provider.dart';
import 'package:flutter_application_1/providers/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/group_provider.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;

  GroupDetailScreen({required this.groupId});

  @override
  _GroupDetailScreenState createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isEnrolled = false;
  Group? group;

  @override
  void initState() {
    super.initState();
    fetchGroupDetails();
  }

  Future<void> fetchGroupDetails() async {
    Group? fetchedGroup =
        await Provider.of<GroupProvider>(context, listen: false)
            .fetchGroupDetails(widget.groupId);

    if (fetchedGroup != null) {
      setState(() {
        group = fetchedGroup;
        isEnrolled = group!.enrolledUsers.contains(_auth.currentUser?.uid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final chatRoomProvider =
        Provider.of<ChatRoomProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Group Details'),
      ),
      body: group == null
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
                        Text(group!.name,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () => isEnrolled
                              ? removeFromGroup(groupProvider)
                              : enrollInGroup(groupProvider),
                          child: Text(isEnrolled
                              ? 'Remove from Group'
                              : 'Join Group'),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(group!.description, style: TextStyle(fontSize: 18)),
                    SizedBox(height: 20),
                    Text('Enrolled Students',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: group!.enrolledUsers.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder<AppUser?>(
                          future: Provider.of<UserDataProvider>(context,
                                  listen: false)
                              .fetchUserDetails(group!.enrolledUsers[index]),
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
                      onPressed: group!.currentMembers >= group!.groupLimit
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Group is full'),
                                ),
                              );
                            }
                          : () => joinGroupChat(chatRoomProvider),
                      child: Text('Join Group Chat'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void joinGroupChat(ChatRoomProvider provider) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && group != null) {
      String chatRoomId =
          await provider.joinOrCreateChatRoom(group!.name, currentUser.uid);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chatroom(chatRoomId: chatRoomId)),
      );
    }
  }

  void enrollInGroup(GroupProvider provider) async {
    if (group!.currentMembers >= group!.groupLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Group is full'),
        ),
      );
      return;
    }
    await provider.enrollInGroup(widget.groupId, _auth.currentUser!.uid);
    await fetchGroupDetails(); // Refetch group details to update the UI
  }

  void removeFromGroup(GroupProvider provider) async {
    await provider.removeFromGroup(widget.groupId, _auth.currentUser!.uid);
    await fetchGroupDetails(); // Refetch group details to update the UI
  }
}
