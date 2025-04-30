import 'package:flutter/material.dart';
import 'package:coffee_app/screens/app_drawer.dart';
import 'package:coffee_app/screens/classify_screen.dart';
import 'package:coffee_app/screens/birds_screen.dart';
import 'package:coffee_app/screens/about_screen.dart';
import 'package:coffee_app/BirdWatchExplorer/BirdWatchExplorer.dart';
import 'package:coffee_app/screens/home_content.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomeContent(onSelectTab: _onItemTapped),
      ClassifyScreen(),
      BirdWatchExplorer(),
      BirdsScreen(),
      AboutScreen(),
    ];
//0xFFB8FFA9
    return Scaffold(
      appBar: _selectedIndex == 0 // Show AppBar only on Home screen
          ? AppBar(
        backgroundColor: const Color.fromARGB(255, 202, 226, 255),

        title: Row(
          children: [
            // Add the PNG logo here
            Image.asset(
              'assets/logo1.png',
              height: 60,
              width: 60,
              color: Colors.blue, // Change this to your desired color
              colorBlendMode: BlendMode.modulate,
            ),
            SizedBox(width: 8), // Adds spacing between icon and title
            const Text(
              'Birdz',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 35, // Adjust size as needed
                  color: Color.fromRGBO(37, 99, 235, 1) // You can change the text color
              ),
            ),
          ],
        ),
      )
          : null, // No AppBar on other screens
      endDrawer: AppDrawer(onSelectItem: _onItemTapped),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Classify',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Locate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flutter_dash),
            label: 'Birds',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
        ],
      ),
    );
  }
}