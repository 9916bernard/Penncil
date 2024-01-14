import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/chat_provider.dart';
import 'package:flutter_application_1/View/home/chat/widgets/chat_bubble_widget.dart';

class MessageWidget extends StatefulWidget {
  final String chatRoomId;

  const MessageWidget({Key? key, required this.chatRoomId}) : super(key: key);

  @override
  _MessageWidgetState createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<ChatProvider>(context, listen: false)
        .fetchMessages(widget.chatRoomId));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (_, chatProvider, __) {
        return ListView.builder(
          reverse: true,
          itemCount: chatProvider.messages.length,
          itemBuilder: (context, index) {
            final message = chatProvider.messages[index];
            return ChatBubbles(
              message.text,
              message.userId == FirebaseAuth.instance.currentUser!.uid,
              message.userName,
              message.userImage,
            );
          },
        );
      },
    );
  }
}
