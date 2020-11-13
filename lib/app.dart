import 'package:flutter/material.dart';

import 'theme/consts.dart';

import 'screens/browse_decks/browse_decks_screen.dart';
import 'screens/conversations/conversations_screen.dart';
//import 'screens/home_screen.dart';
import 'screens/settings/settings_screen.dart';

import 'screens/authentication/login_main.dart';

class CustomNavigatorHomePage extends StatefulWidget {
  @override
  _CustomNavigatorHomePageState createState() =>
      _CustomNavigatorHomePageState();
}

class _CustomNavigatorHomePageState extends State<CustomNavigatorHomePage> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    LoginMain(),
    BrowseDecksScreen(),
    ConversationsScreen(),
    SettingsScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) => onTabTapped(index),
        backgroundColor: AppColors.darkColor,
        currentIndex: _currentIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white24,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_carousel_rounded),
            label: "Browse Decks",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_rounded),
            label: "Conversations",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          )
        ],
      ),
    );
  }
}
