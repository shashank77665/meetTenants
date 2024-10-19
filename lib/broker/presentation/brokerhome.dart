import 'package:flutter/material.dart';
import 'package:meettenants/broker/presentation/brokerlistingscreen.dart';
import 'package:meettenants/broker/presentation/brokersetting.dart';
import 'package:meettenants/broker/presentation/managelisting.dart';
import 'package:meettenants/broker/presentation/useractivity.dart';

class BrokerHomeScreen extends StatefulWidget {
  const BrokerHomeScreen({super.key});

  @override
  State<BrokerHomeScreen> createState() => _BrokerHomeScreenState();
}

class _BrokerHomeScreenState extends State<BrokerHomeScreen> {
  int _selectedIndex = 0;

  // List of screens for each BottomNavigationBar item
  final List<Widget> _pages = [
    BrokerListingScreen(),
    ManageListing(),
    UserActivity(),
    BrokerSetting()
  ];

  // Method to handle the BottomNavigationBar tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _pages[_selectedIndex], // Display the selected screen
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Keeps all icons labeled
        currentIndex: _selectedIndex, // The selected index
        onTap: _onItemTapped, // Handle the tap
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'My Listing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Manage Listing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'User Interaction',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Dummy screens for each BottomNavigationBar item
class MyListingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('My Listing Page'),
    );
  }
}

class PastListingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Past Listing Page'),
    );
  }
}

class UserInteractionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('User Interaction Page'),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Settings Page'),
    );
  }
}
