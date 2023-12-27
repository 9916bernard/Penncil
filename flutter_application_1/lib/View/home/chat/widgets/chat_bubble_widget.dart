import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_8.dart';

class ChatBubbles extends StatelessWidget {
  const ChatBubbles(this.message, this.isMe, this.userName, {Key? key}) : super(key: key);

  final String message;
  final String userName;
  final bool isMe;

  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          userName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),),
        Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            ChatBubble(
              clipper: ChatBubbleClipper8(type: isMe ? BubbleType.sendBubble : BubbleType.receiverBubble),
              alignment: isMe ? Alignment.topRight : Alignment.topLeft,
              margin: const EdgeInsets.only(bottom: 10),
              backGroundColor: isMe ? Colors.blue : Colors.grey[300],
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Text(
                  message,
                  style: TextStyle(color: isMe ? Colors.white : Colors.black),
                ),
              ),
            ),
            
          ],
        ),
      ],
    );
  }
}