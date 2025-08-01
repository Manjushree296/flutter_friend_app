import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_list_screen.dart';
import 'friend_requests_screen.dart';
import 'friends_screen.dart';
import 'auth_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatelessWidget {
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => AuthScreen()));
  }

  final List<_DashboardItem> items = [
    _DashboardItem('All Users', Icons.group_rounded, UserListScreen()),
    _DashboardItem(
      'Friend Requests',
      Icons.mail_outline_rounded,
      FriendRequestsScreen(),
    ),
    _DashboardItem('My Friends', Icons.people_alt_rounded, FriendsScreen()),
    _DashboardItem(
      'Chat with Friends',
      Icons.chat_bubble_outline_rounded,
      ChatScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a), // dark blue-gray
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e293b),
        elevation: 0,
        title: const Text('Friend App', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1e293b), Color(0xFF0f172a)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Scrollbar(
            thumbVisibility: true,
            radius: const Radius.circular(8),
            thickness: 5,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) =>
                  _buildCard(context, items[index]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, _DashboardItem item) {
    return Card(
      color: const Color(0xFF334155),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFF3b82f6),
          child: Icon(item.icon, size: 30, color: Colors.white),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white70,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => item.page),
        ),
      ),
    );
  }
}

class _DashboardItem {
  final String title;
  final IconData icon;
  final Widget page;

  _DashboardItem(this.title, this.icon, this.page);
}
