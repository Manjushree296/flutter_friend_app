import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _controller.text.trim().isNotEmpty) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userName = userDoc.data()?['name'] ?? 'Anonymous';

      await FirebaseFirestore.instance.collection('chats').add({
        'text': _controller.text.trim(),
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'userName': userName,
        'reactions': [],
      });

      _controller.clear();
    }
  }

  void _addReaction(String messageId, String emoji) async {
    final docRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(messageId);
    await docRef.update({
      'reactions': FieldValue.arrayUnion([emoji]),
    });
  }

  void _deleteMessage(String messageId) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(messageId)
        .delete();
  }

  void _clearAllChats() async {
    final chatCollection = FirebaseFirestore.instance.collection('chats');
    final snapshots = await chatCollection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  Widget _buildMessageItem(
    Map<String, dynamic> msg,
    bool isMe,
    String messageId,
  ) {
    return GestureDetector(
      onLongPress: () {
        if (isMe) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Delete Message?'),
              content: Text('Are you sure you want to delete this message?'),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: Text('Delete'),
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteMessage(messageId);
                  },
                ),
              ],
            ),
          );
        }
      },
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          padding: EdgeInsets.all(12),
          constraints: BoxConstraints(maxWidth: 300),
          decoration: BoxDecoration(
            color: isMe ? Colors.blue[100] : Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(msg['text'] ?? '', style: TextStyle(fontSize: 16)),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    msg['userName'] ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                    onSelected: (emoji) => _addReaction(messageId, emoji),
                    itemBuilder: (context) =>
                        ['👍', '❤️', '😂', '😢', '🔥', '👏']
                            .map((e) => PopupMenuItem(value: e, child: Text(e)))
                            .toList(),
                  ),
                ],
              ),
              if (msg['reactions'] != null && msg['reactions'].isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Wrap(
                    spacing: 6,
                    children: msg['reactions']
                        .toSet()
                        .map<Widget>(
                          (emoji) =>
                              Text(emoji, style: TextStyle(fontSize: 16)),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Friends'),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            tooltip: 'Clear All Chats',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Clear All Chats?'),
                  content: Text('This will permanently delete all messages.'),
                  actions: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: Text('Clear All'),
                      onPressed: () {
                        Navigator.pop(context);
                        _clearAllChats();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (ctx, chatSnapshot) {
                  if (chatSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (chatSnapshot.hasError) {
                    return Center(child: Text('Something went wrong.'));
                  }

                  if (!chatSnapshot.hasData ||
                      chatSnapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No messages yet.'));
                  }

                  final chatDocs = chatSnapshot.data!.docs;

                  return ListView.builder(
                    reverse: true,
                    itemCount: chatDocs.length,
                    itemBuilder: (ctx, index) {
                      final msg =
                          chatDocs[index].data() as Map<String, dynamic>?;

                      if (msg == null) return SizedBox();

                      final isMe = msg['userId'] == user?.uid;
                      return _buildMessageItem(msg, isMe, chatDocs[index].id);
                    },
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      autocorrect: true,
                      decoration: InputDecoration(
                        hintText: 'Send a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.grey[100],
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.blue[800],
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
