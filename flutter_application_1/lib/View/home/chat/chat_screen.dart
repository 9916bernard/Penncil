import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/View/home/chat/chatroom_page.dart';
import 'package:flutter_application_1/providers/chatroom_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chatRoomProvider = Provider.of<ChatRoomProvider>(context);
    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);
    final user = userDataProvider.user;

    return Scaffold(
      body: FutureBuilder<List<String>>(
        future: chatRoomProvider.fetchUserChatRooms(user!.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No Chatrooms available"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              String chatRoomId = snapshot.data![index];
              return FutureBuilder<Map<String, dynamic>>(
                future: chatRoomProvider.fetchChatRoomDetails(chatRoomId),
                builder: (context, chatRoomSnapshot) {
                  if (chatRoomSnapshot.connectionState ==
                          ConnectionState.done &&
                      chatRoomSnapshot.hasData) {
                    var chatRoomData = chatRoomSnapshot.data!;
                    return _buildChatRoomItem(
                      context,
                      chatRoomId,
                      chatRoomData['name'],
                      List<String>.from(chatRoomData['participants']),
                      chatRoomData['lastMessage'],
                      chatRoomData['timestamp'],
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildChatRoomItem(
    BuildContext context,
    String chatRoomId,
    String chatRoomName,
    List<String> participants,
    String lastMessage,
    Timestamp timestamp,
  ) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Chatroom(chatRoomId: chatRoomId)),
          );
        },
        child: Card(
          color: Color.fromARGB(139, 250, 250, 250),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  child: Stack(
                    children: List.generate(
                      participants.length > 4 ? 4 : participants.length,
                      (index) {
                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(participants[index])
                              .get(),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState ==
                                    ConnectionState.done &&
                                userSnapshot.data != null) {
                              Map<String, dynamic> userData = userSnapshot.data!
                                  .data() as Map<String, dynamic>;
                              return Positioned(
                                left: index * 12.0,
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      userData['pickedImage'] ??
                                          'default_user_image_url'),
                                  radius: 12,
                                ),
                              );
                            } else {
                              return CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 12,
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            chatRoomName,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${participants.length}',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        lastMessage,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      _formatTimestamp(timestamp),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final hours = date.hour;
    final minutes = date.minute.toString().padLeft(2, '0');
    final period = hours >= 12 ? 'pm' : 'am';
    final formattedHour = hours % 12 == 0 ? 12 : hours % 12;
    return '$period $formattedHour:$minutes';
  }
}
