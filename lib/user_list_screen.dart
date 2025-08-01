import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserListScreen extends StatelessWidget {
  Future<void> sendRequest(String targetUid) async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(targetUid).update({
      'requests': FieldValue.arrayUnion([currentUid]),
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(title: Text('All Users')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final users = snapshot.data!.docs
              .where((doc) => doc.id != currentUid)
              .toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (ctx, i) {
              final user = users[i];
              final name =
                  user['name'] ?? 'Unnamed User'; // fallback if name is null
              return ListTile(
                title: Text(name),
                trailing: ElevatedButton(
                  child: Text('Send Request'),
                  onPressed: () => sendRequest(user.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
