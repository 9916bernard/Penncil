import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/View/home/chat/chatroom_page.dart';
import 'package:flutter_application_1/providers/chatroom_provider.dart';

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
              return FutureBuilder<String>(
                future: chatRoomProvider.fetchChatRoomName(chatRoomId),
                builder: (context, chatNameSnapshot) {
                  if (chatNameSnapshot.connectionState ==
                          ConnectionState.done &&
                      chatNameSnapshot.hasData) {
                    return _buildChatRoomItem(
                        context, chatRoomId, chatNameSnapshot.data!);
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
      BuildContext context, String chatRoomId, String chatRoomName) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Card(
        child: ListTile(
          title: Text(chatRoomName),
          trailing: Icon(Icons.arrow_forward),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Chatroom(chatRoomId: chatRoomId)),
            );
          },
        ),
      ),
    );
  }
}
