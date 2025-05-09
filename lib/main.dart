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
          backgroundColor:const Color.fromRGBO(37, 99, 235, 1),
          foregroundColor: Color.fromRGBO(37, 99, 235, 1),
          elevation: 4,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
              color: const Color.fromRGBO(37, 99, 235, 1)),
          titleLarge: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.green),
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black87),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Color.fromRGBO(37, 99, 235, 1),
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: SplashWrapper(),
    );
  }
}