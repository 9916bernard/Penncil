import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_8.dart';

class ChatBubbles extends StatelessWidget {
  const ChatBubbles(this.message, this.isMe, this.userName, this.userImage, {Key? key}) : super(key: key);

  final String message;
  final String userName;
  final bool isMe;
  final String userImage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: isMe ? _buildMyMessageLayout(context) : _buildOtherMessageLayout(context),
    );
  }

  List<Widget> _buildMyMessageLayout(BuildContext context) {
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            userName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          ChatBubble(
            clipper: ChatBubbleClipper8(type: BubbleType.sendBubble),
            alignment: Alignment.topRight,
            margin: const EdgeInsets.only(bottom: 10),
            backGroundColor: Colors.blue,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Text(
                message,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),

      const SizedBox(width: 5,),
      
      CircleAvatar(
        radius: 25,
        backgroundImage: userImage.isNotEmpty ? NetworkImage(userImage) : null,
      ),
    ];
  }

  List<Widget> _buildOtherMessageLayout(BuildContext context) {
    return [
      CircleAvatar(
        radius: 25,
        backgroundImage: userImage.isNotEmpty ? NetworkImage(userImage) : null,
      ),

      const SizedBox(width: 5,),

      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          ChatBubble(
            clipper: ChatBubbleClipper8(type: BubbleType.receiverBubble),
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.only(bottom: 10),
            backGroundColor: Colors.grey[300],
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Text(
                message,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    ];
  }
}
