import 'package:flutter/material.dart';
import 'package:meettenants/eua/presentation/saved.dart';
import 'package:meettenants/eua/presentation/tenantcommunity.dart';
import 'package:meettenants/eua/presentation/tenanthome.dart';
import 'package:meettenants/eua/presentation/tenantsetting.dart';

class EUAHome extends StatefulWidget {
  const EUAHome({super.key});

  @override
  State<EUAHome> createState() => _EUAHomeState();
}

class _EUAHomeState extends State<EUAHome> {
  int _selectedIndex = 0;

  // List of pages for each tab
  final List<Widget> _pages = [
    TenantHome(),
    TenantSaved(),
    Tenantcommunity(),
    TenantSetting()
  ];

  // This function handles the navigation between pages
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _pages[_selectedIndex], // Display the selected page
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex, // The currently selected index
        selectedItemColor: Colors.blue, // The color of the selected icon
        unselectedItemColor: Colors.grey, // The color of the unselected icons
        onTap: _onItemTapped, // This function will change the selected page
      ),
    );
  }
}
