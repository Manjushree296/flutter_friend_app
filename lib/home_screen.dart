import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';
import 'user_list_screen.dart';
import 'friend_requests_screen.dart';
import 'friends_screen.dart';
import 'auth_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatelessWidget {
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AuthScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Text('Friend App Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, size: 30),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade200, Colors.blue.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                'https://cdn.pixabay.com/photo/2017/02/01/22/02/friends-2037327_960_720.png',
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Welcome, Friend!',
              style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '"Friendship is the golden thread that ties the heart of all the world."',
              style: TextStyle(fontSize: 16, color: Colors.white70, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  _buildHomeTile(context, 'My Profile', Icons.person, ProfileScreen()),
                  _buildHomeTile(context, 'All Users', Icons.group, UserListScreen()),
                  _buildHomeTile(context, 'Friend Requests', Icons.mail, FriendRequestsScreen()),
                  _buildHomeTile(context, 'My Friends', Icons.people_alt, FriendsScreen()),
                  _buildHomeTile(context, 'Chat with Friends', Icons.chat, ChatScreen()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTile(BuildContext context, String title, IconData icon, Widget page) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }
}
