import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLogin = true;

  Future<void> _submit() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final auth = FirebaseAuth.instance;

    try {
      if (isLogin) {
        await auth.signInWithEmailAndPassword(email: email, password: password);
      } else {
        UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'name': '',
          'bio': '',
          'profilePic': '',
          'friends': [],
          'requests': [],
        });
      }
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Authentication failed.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          elevation: 8,
          color: Colors.white,
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Welcome to Friend App', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                SizedBox(height: 20),
                TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
                TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(isLogin ? 'Login' : 'Sign Up'),
                ),
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(isLogin ? 'Create Account' : 'Already have an account? Login'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
