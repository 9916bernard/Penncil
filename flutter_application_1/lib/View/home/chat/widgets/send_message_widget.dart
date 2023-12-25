import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SendMessageWidget extends StatefulWidget {
  const SendMessageWidget({super.key});

  @override
  State<SendMessageWidget> createState() => _SendMessageWidgetState();
}

class _SendMessageWidgetState extends State<SendMessageWidget> {
  var _enteredMessage = '';

  void _sendMessage() {
    FocusScope.of(context).unfocus();
    FirebaseFirestore.instance.collection('chats/aSxIFTC1GpObrgriv3Iu/message').add({
      'text': _enteredMessage,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _enteredMessage = value;
                              });
                            } ,
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
                          onPressed: _enteredMessage.trim().isEmpty ? null : () {
                            // Send message
                            _sendMessage();
                          },
                          icon: Icon(Icons.send),
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    
                  );
    
  }
}