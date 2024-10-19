import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> createUser(BuildContext context, String email, String password,
    String name, bool checkUserType) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String userType = checkUserType ? 'broker' : 'tenant';

  try {
    // Create user with email and password
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    // Check if user is created successfully
    if (userCredential.user != null) {
      // Store additional user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'name': name,
        'userType': userType,
      });

      // Navigate to the appropriate screen based on userType
      if (userType == 'tenant') {
        Navigator.pushReplacementNamed(context, '/EUAHome');
      } else {
        Navigator.pushReplacementNamed(context, '/brokerHome');
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Logged in Sucessfully')));
    }
  } on FirebaseAuthException catch (e) {
    // Show error dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(e.message ?? "An error occurred"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

Future<void> login(BuildContext context, String email, String password) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  try {
    // Sign in with email and password
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    if (userCredential.user != null) {
      // Fetch the user's document from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      // Get userType from Firestore
      String userType = userDoc['userType'];

      // Navigate to the appropriate screen based on userType
      if (userType == 'tenant') {
        Navigator.pushReplacementNamed(context, '/EUAHome');
      } else if (userType == 'broker') {
        Navigator.pushReplacementNamed(context, '/brokerHome');
      }

      // Show a success message
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Logged in Successfully')));
    }
  } on FirebaseAuthException catch (e) {
    // Show an error dialog if login fails
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Alert'),
        content: Text(e.message ?? 'Failed to login'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'))
        ],
      ),
    );
  }
}

Future<dynamic>? logout(context) {
  FirebaseAuth _auth = FirebaseAuth.instance;

  try {
    _auth.signOut();
    Navigator.pushReplacementNamed(context, 'login');
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Logged out Sucessfully')));
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.message ?? 'Failed to logout')));
  }
  return null;
}
