import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TenantSetting extends StatefulWidget {
  const TenantSetting({super.key});

  @override
  State<TenantSetting> createState() => _TenantsettingState();
}

class _TenantsettingState extends State<TenantSetting> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DocumentSnapshot? userDoc;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    User? user = _auth.currentUser; // Get the currently logged-in user
    if (user != null) {
      userDoc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {}); // Update the UI after fetching user data
    }
  }

  void logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(
        context, '/login'); // Navigate to login screen
  }

  @override
  Widget build(BuildContext context) {
    String name = userDoc?['name'] ?? 'Loading...'; // Get the name
    String email = userDoc?['email'] ?? 'Loading...'; // Get the email
    String userType = userDoc?['userType'] ?? 'Loading...'; // Get user type
    String initials = name.isNotEmpty
        ? name.split(' ').map((e) => e[0]).join() // Get initials
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context), // Logout button
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Text(
                initials,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Text(
              name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              email,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(
              userType,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            // User type TextBox
          ],
        ),
      ),
    );
  }
}
