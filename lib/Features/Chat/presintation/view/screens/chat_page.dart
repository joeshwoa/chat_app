import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatPage({super.key, required this.userId, required this.userName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _firestore.collection('chats').add({
        'senderId': _auth.currentUser!.uid,
        'receiverId': widget.userId,
        'text': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.userName}', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: Navigator.canPop(context)? IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded, color: Colors.white,)): null,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('senderId', isEqualTo: _auth.currentUser!.uid)
                  .where('receiverId', isEqualTo: widget.userId)
                  .snapshots(),
              builder: (context, snapshot) {
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .where('senderId', isEqualTo: widget.userId)
                      .where('receiverId', isEqualTo: _auth.currentUser!.uid)
                      .snapshots(),
                  builder: (context, secondSnapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        secondSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final sentMessages = snapshot.data?.docs ?? [];
                    final receivedMessages = secondSnapshot.data?.docs ?? [];
                    final allMessages = [...sentMessages, ...receivedMessages];

                    if (allMessages.isEmpty) {
                      return const Center(child: Text('No messages found.'));
                    }

                    // Sort all messages based on the 'timestamp'
                    allMessages.sort((a, b) {
                      Timestamp aTimestamp = a['timestamp'] ?? Timestamp(0, 0);
                      Timestamp bTimestamp = b['timestamp'] ?? Timestamp(0, 0);
                      return aTimestamp.compareTo(bTimestamp);
                    });

                    return ListView.builder(
                      reverse: true, // Show the latest messages at the bottom
                      itemCount: allMessages.length,
                      itemBuilder: (context, index) {
                        final message = (allMessages.reversed.toList())[index];
                        final isSentByMe = message['senderId'] == _auth.currentUser!.uid;

                        return Align(
                          alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSentByMe ? Colors.black : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              message['text'],
                              style: TextStyle(
                                color: isSentByMe ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey)
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black)
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.black),
                  onPressed: sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
