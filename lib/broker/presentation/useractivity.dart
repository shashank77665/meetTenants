import 'package:flutter/material.dart';

class UserActivity extends StatelessWidget {
  const UserActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Text('User Activity'),
      )),
    );
  }
}
