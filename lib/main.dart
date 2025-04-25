import 'package:coffee_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BirdApp());
}

class BirdApp extends StatelessWidget {
  const BirdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Birdz',
      theme: ThemeData(
        primarySwatch: Colors.green,
        hintColor: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
              color: Colors.green[800]),
          titleLarge: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.green),
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black87),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: SplashWrapper(),
    );
  }
}
