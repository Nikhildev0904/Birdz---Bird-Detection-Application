import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final Function(int) onSelectItem;

  AppDrawer({required this.onSelectItem});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Center(
              child: Text(
                'Birdz',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color:Color.fromRGBO(37, 99, 235, 1),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: const Color.fromRGBO(37, 99, 235, 1)),
            title: const Text(
              'Home',
              style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0), // Set the desired text color
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Closes the AppDrawer
              onSelectItem(0); // Navigate to Home
            }, // Set index for Home
          ),
          ListTile(
            leading: Icon(Icons.camera_alt, color: Color.fromRGBO(37, 99, 235, 1)),
            title: Text(
              'Classify',
              style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0), // Set the desired text color
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Closes the AppDrawer
              onSelectItem(1); // Navigate to Home
            }, // Set index for Classify
          ),
          ListTile(
            leading: Icon(Icons.location_on, color: Color.fromRGBO(37, 99, 235, 1)),
            title: Text(
              'Locate',
              style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0), // Set the desired text color
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Closes the AppDrawer
              onSelectItem(2); // Navigate to Home
            }, // Set index for Classify
          ),
          ListTile(
            leading: Icon(Icons.flutter_dash, color: Color.fromRGBO(37, 99, 235, 1)),
            title: Text(
              'Birds',
              style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0), // Set the desired text color
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Closes the AppDrawer
              onSelectItem(3); // Navigate to Home
            }, // Set index for Birds
          ),
          ListTile(
            leading: Icon(Icons.info, color: Color.fromRGBO(37, 99, 235, 1)),
            title: Text(
              'About',
              style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0), // Set the desired text color
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Closes the AppDrawer
              onSelectItem(4); // Navigate to Home
            }, // Set index for About
          ),
        ],
      ),
    );
  }
}