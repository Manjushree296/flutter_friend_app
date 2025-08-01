import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendRequestsScreen extends StatefulWidget {
  @override
  _FriendRequestsScreenState createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;

  Future<void> acceptRequest(String requesterUid) async {
    if (currentUser == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .update({
          'friends': FieldValue.arrayUnion([requesterUid]),
          'requests': FieldValue.arrayRemove([requesterUid]),
        });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(requesterUid)
        .update({
          'friends': FieldValue.arrayUnion([currentUser!.uid]),
        });
  }

  Future<void> declineRequest(String requesterUid) async {
    if (currentUser == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .update({
          'requests': FieldValue.arrayRemove([requesterUid]),
        });
  }

  Future<void> sendRequest(String targetUid) async {
    if (currentUser == null || targetUid == currentUser!.uid) return;

    final targetRef = FirebaseFirestore.instance
        .collection('users')
        .doc(targetUid);
    final doc = await targetRef.get();

    if (doc.exists) {
      await targetRef.update({
        'requests': FieldValue.arrayUnion([currentUser!.uid]),
      });
    }
  }

  Future<String?> getUserIdByEmail(String email) async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (result.docs.isNotEmpty) {
      return result.docs.first.id;
    }
    return null;
  }

  Widget buildRequestTile(String requesterUid) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(requesterUid)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) return SizedBox();

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final name = data['name'] ?? 'Unknown';
        final photoUrl =
            data['photoUrl'] ??
            'https://cdn-icons-png.flaticon.com/512/149/149071.png';

        return Card(
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(photoUrl),
              radius: 25,
            ),
            title: Text(name),
            subtitle: Text(requesterUid),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () => acceptRequest(requesterUid),
                ),
                IconButton(
                  icon: Icon(Icons.cancel, color: Colors.red),
                  onPressed: () => declineRequest(requesterUid),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Friend Requests'),
        backgroundColor: Colors.blue[800],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Enter email to send friend request',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final email = _searchController.text.trim();
                    if (email.isEmpty) return;

                    final targetUid = await getUserIdByEmail(email);

                    if (targetUid != null) {
                      await sendRequest(targetUid);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Friend request sent!')),
                      );
                      _searchController.clear();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('User not found!')),
                      );
                    }
                  },
                  icon: Icon(Icons.person_add),
                  label: Text('Send'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser!.uid)
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!.data() as Map<String, dynamic>?;
                final requests = List<String>.from(data?['requests'] ?? []);

                if (requests.isEmpty) {
                  return Center(child: Text('No pending friend requests.'));
                }

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (ctx, i) => buildRequestTile(requests[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
