import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendRequestsScreen extends StatelessWidget {
  Future<void> acceptRequest(String requesterUid) async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(currentUid).update({
      'friends': FieldValue.arrayUnion([requesterUid]),
      'requests': FieldValue.arrayRemove([requesterUid])
    });

    await FirebaseFirestore.instance.collection('users').doc(requesterUid).update({
      'friends': FieldValue.arrayUnion([currentUid])
    });
  }

  Future<void> declineRequest(String requesterUid) async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(currentUid).update({
      'requests': FieldValue.arrayRemove([requesterUid])
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(title: Text('Friend Requests')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(currentUid).snapshots(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final requests = List<String>.from(data['requests']);

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (ctx, i) {
              final requesterUid = requests[i];
              return ListTile(
                title: Text('Request from: $requesterUid'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: Icon(Icons.check), onPressed: () => acceptRequest(requesterUid)),
                    IconButton(icon: Icon(Icons.close), onPressed: () => declineRequest(requesterUid)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
