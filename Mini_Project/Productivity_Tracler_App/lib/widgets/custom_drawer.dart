import 'package:flutter/material.dart';
import '../main.dart'; // If using named routes, ensure they're set in main.dart

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Productivity App', style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
          ListTile(
            title: Text('Dashboard'),
            onTap: () => Navigator.pushNamed(context, '/'),
          ),
          ListTile(
            title: Text('Tasks'),
            onTap: () => Navigator.pushNamed(context, '/tasks'),
          ),
          ListTile(
            title: Text('Pomodoro'),
            onTap: () => Navigator.pushNamed(context, '/pomodoro'),
          ),
          ListTile(
            title: Text('Analytics'),
            onTap: () => Navigator.pushNamed(context, '/analytics'),
          ),
          ListTile(
            title: Text('Profile'),
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
    );
  }
}
