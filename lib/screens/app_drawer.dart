import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final Function(int) onSelectItem;

  AppDrawer({required this.onSelectItem});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB8FFA9), Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/Birdz.png', // Replace with your image path
                fit: BoxFit.contain,
                width: 200, // Adjust the size as needed
                height: 200,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.green),
            title: Text(
              'Home',
              style: TextStyle(
                  color: Colors.green, // Set the desired text color
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Closes the AppDrawer
              onSelectItem(0); // Navigate to Home
            }, // Set index for Home
          ),
          ListTile(
            leading: Icon(Icons.camera_alt, color: Colors.green),
            title: Text(
              'Classify',
              style: TextStyle(
                  color: Colors.green, // Set the desired text color
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Closes the AppDrawer
              onSelectItem(1); // Navigate to Home
            }, // Set index for Classify
          ),
          ListTile(
            leading: Icon(Icons.flutter_dash, color: Colors.green),
            title: Text(
              'Birds',
              style: TextStyle(
                  color: Colors.green, // Set the desired text color
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Closes the AppDrawer
              onSelectItem(2); // Navigate to Home
            }, // Set index for Birds
          ),
          ListTile(
            leading: Icon(Icons.info, color: Colors.green),
            title: Text(
              'About',
              style: TextStyle(
                  color: Colors.green, // Set the desired text color
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Closes the AppDrawer
              onSelectItem(3); // Navigate to Home
            }, // Set index for About
          ),
        ],
      ),
    );
  }
}