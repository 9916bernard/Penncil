import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('chats/aSxIFTC1GpObrgriv3Iu/message').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>> snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }
          
          final docs = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.all(10),  // Adjust spacing as needed
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],  // Grey message container
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            docs[index]['text'],
                            style: TextStyle(color: Colors.black),
                          ),
                        );
                      },
                      
                    ),
                  ),
                ),
                
              ],
            ),
          );
        }
      );
  }
}