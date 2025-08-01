import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PrivateChatScreen extends StatefulWidget {
  final String friendId;
  final String friendName;
  final String friendPhoto;

  PrivateChatScreen({
    required this.friendId,
    required this.friendName,
    required this.friendPhoto,
  });

  @override
  _PrivateChatScreenState createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  final _controller = TextEditingController();
  final userId = FirebaseAuth.instance.currentUser!.uid;
  bool isBlocked = false;

  String get chatId => userId.hashCode <= widget.friendId.hashCode
      ? '$userId-${widget.friendId}'
      : '${widget.friendId}-$userId';

  @override
  void initState() {
    super.initState();
    _checkIfBlocked();
  }

  void _checkIfBlocked() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('blocked')
        .doc(widget.friendId)
        .get();

    setState(() {
      isBlocked = doc.exists && doc.data()?['blocked'] == true;
    });
  }

  void _toggleBlockStatus() async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('blocked')
        .doc(widget.friendId);

    if (isBlocked) {
      await docRef.delete();
    } else {
      await docRef.set({'blocked': true});
    }

    _checkIfBlocked();
  }

  void _sendMessage() async {
    if (isBlocked) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('private_chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'text': text,
          'imageUrl': null,
          'senderId': userId,
          'receiverId': widget.friendId,
          'createdAt': Timestamp.now(),
          'reaction': '',
        });
    _controller.clear();
  }

  void _sendImageMessage() async {
    if (isBlocked) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance
        .ref()
        .child('chat_images')
        .child(fileName);

    await ref.putFile(imageFile);
    final imageUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('private_chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'text': '',
          'imageUrl': imageUrl,
          'senderId': userId,
          'receiverId': widget.friendId,
          'createdAt': Timestamp.now(),
          'reaction': '',
        });
  }

  void _reactToMessage(String messageId, String emoji) async {
    await FirebaseFirestore.instance
        .collection('private_chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'reaction': emoji});
  }

  void _clearAllMessages() async {
    final messages = await FirebaseFirestore.instance
        .collection('private_chats')
        .doc(chatId)
        .collection('messages')
        .get();

    for (var doc in messages.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.friendPhoto)),
            SizedBox(width: 10),
            Text(widget.friendName),
          ],
        ),
        backgroundColor: Colors.blue[800],
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _clearAllMessages();
              } else if (value == 'block') {
                _toggleBlockStatus();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text('Clear All Chats'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(
                      isBlocked ? Icons.lock_open : Icons.block,
                      color: isBlocked ? Colors.green : Colors.black,
                    ),
                    SizedBox(width: 8),
                    Text(isBlocked ? 'Unblock User' : 'Block User'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('private_chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (ctx, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == userId;
                    final imageUrl = msg['imageUrl'];
                    final text = msg['text'];

                    return ListTile(
                      title: Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue[100] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: imageUrl != null && imageUrl != ''
                              ? Image.network(imageUrl, height: 150)
                              : Text(text),
                        ),
                      ),
                      subtitle: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (msg['reaction'] != '')
                            Text(
                              msg['reaction'],
                              style: TextStyle(fontSize: 18),
                            ),
                          IconButton(
                            icon: Icon(Icons.emoji_emotions, size: 20),
                            onPressed: () async {
                              final emoji = await showModalBottomSheet<String>(
                                context: context,
                                builder: (_) => EmojiPicker(),
                              );
                              if (emoji != null) {
                                _reactToMessage(msg.id, emoji);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (isBlocked)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'You have blocked this user. Unblock to send messages.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.image),
                    onPressed: _sendImageMessage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class EmojiPicker extends StatelessWidget {
  final List<String> emojis = ['👍', '❤', '😂', '🔥', '😢', '😮', '🎉'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: emojis.map((emoji) {
        return InkWell(
          onTap: () => Navigator.pop(context, emoji),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(emoji, style: TextStyle(fontSize: 28)),
          ),
        );
      }).toList(),
    );
  }
}
