import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/chat_provider.dart';
import 'package:flutter_application_1/providers/user_data_provider.dart';

class SendMessageWidget extends StatefulWidget {
  final String chatRoomId;

  const SendMessageWidget({Key? key, required this.chatRoomId})
      : super(key: key);

  @override
  State<SendMessageWidget> createState() => _SendMessageWidgetState();
}

class _SendMessageWidgetState extends State<SendMessageWidget> {
  final _controller = TextEditingController();
  var _enteredMessage = '';

  void _sendMessage() {
    FocusScope.of(context).unfocus();
    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);
    final user = userDataProvider.user;

    if (user != null && _enteredMessage.trim().isNotEmpty) {
      Provider.of<ChatProvider>(context, listen: false).sendMessage(
        widget.chatRoomId,
        _enteredMessage,
        user.id,
        user.userName,
        user.profileImageUrl,
      );
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              maxLines: null,
              controller: _controller,
              onChanged: (value) {
                setState(() {
                  _enteredMessage = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          IconButton(
            onPressed: _enteredMessage.trim().isEmpty ? null : _sendMessage,
            icon: Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
