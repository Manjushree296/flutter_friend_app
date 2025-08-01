import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'private_chat_screen.dart'; // You'll create this screen next

class FriendsScreen extends StatelessWidget {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Map<String, dynamic>>> _getFriends() async {
    DocumentSnapshot currentUserDoc =
        await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();

    List<dynamic> friendIds = currentUserDoc['friends'] ?? [];
    List<Map<String, dynamic>> friends = [];

    for (var uid in friendIds) {
      DocumentSnapshot friendDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (friendDoc.exists) {
        friends.add({
          'uid': uid,
          'name': friendDoc['name'] ?? 'No Name',
          'bio': friendDoc['bio'] ?? '',
          'profilePic': friendDoc['profilePic'] ?? '',
        });
      }
    }

    return friends;
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Friends'),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: Icon(Icons.logout, size: 28),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getFriends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final friends = snapshot.data ?? [];
          if (friends.isEmpty) {
            return Center(child: Text('You have no friends yet.'));
          }
          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: friend['profilePic'].isNotEmpty
                        ? NetworkImage(friend['profilePic'])
                        : AssetImage('assets/default_profile.png') as ImageProvider,
                  ),
                  title: Text(
                    friend['name'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(friend['bio']),
                  trailing: ElevatedButton.icon(
                    icon: Icon(Icons.chat_bubble, size: 18),
                    label: Text("Chat"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PrivateChatScreen(
                            friendId: friend['uid'],
                            friendName: friend['name'],
                            friendPhoto: friend['profilePic'],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
