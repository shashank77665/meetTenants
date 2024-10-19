import 'package:flutter/material.dart';

class Tenantcommunity extends StatefulWidget {
  const Tenantcommunity({super.key});

  @override
  State<Tenantcommunity> createState() => _TenantcommunityState();
}

class _TenantcommunityState extends State<Tenantcommunity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Text('Community'),
      )),
    );
  }
}
