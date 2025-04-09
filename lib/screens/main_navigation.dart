// screens/main_navigation.dart

import 'package:flutter/material.dart';
import 'package:popup_app/screens/like_list_page.dart';
import 'package:popup_app/screens/map_page.dart';
import 'package:popup_app/screens/popup_list_page.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    PopupListPage(),
    LikeListPage(),
    MapPage(),
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.favorite),
      label: 'Like',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.map_rounded),
      label: 'Map',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: _onTap,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
