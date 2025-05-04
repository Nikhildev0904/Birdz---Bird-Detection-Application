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

    return Scaffold(
      appBar: _selectedIndex == 0 // Show AppBar only on Home screen
          ? AppBar(
        elevation: 0, // Remove shadow
        backgroundColor: Colors.white, // Clean white background
        title: Row(
          children: [
            // Logo with subtle shadow
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/bird_logo.png',
                height: 50,
                width: 50,
              ),
            ),
            SizedBox(width: 12), // Increased spacing for better layout
            // App name with custom gradient text
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Color(0xFF1E40AF), // Deeper blue
                  Color(0xFF3B82F6), // Medium blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'Birdz',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                  color: Colors.white, // This becomes the gradient color
                ),
              ),
            ),
          ],
        ),
      )
          : null, // No AppBar on other screens
      endDrawer: AppDrawer(onSelectItem: _onItemTapped),
      body: Container(
        // Wrap the body in a container with decoration
        decoration: BoxDecoration(
          // Use a subtle pattern with blue and white
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage('assets/subtle_pattern.png'), // Add a subtle pattern asset
            opacity: 0.05, // Very light pattern
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF2563EB), // Primary blue color
          unselectedItemColor: Colors.grey.shade600,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_rounded),
              label: 'Classify',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on_rounded),
              label: 'Locate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flutter_dash_rounded),
              label: 'Birds',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info_rounded),
              label: 'About',
            ),
          ],
        ),
      ),
    );
  }
}