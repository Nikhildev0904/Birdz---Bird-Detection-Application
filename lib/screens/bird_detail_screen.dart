import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BirdDetailScreen extends StatelessWidget {
  final String birdName;
  final String birdImage;
  final String birdDescription;

  BirdDetailScreen({
    required this.birdName,
    required this.birdImage,
    required this.birdDescription,
  });

  void _launchURL(String birdName) async {
    final url = 'https://www.google.com/search?q=$birdName';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Map<String, String> extractLocation(String description) {
    final locationStartIndex = description.indexOf("Location:");
    if (locationStartIndex != -1) {
      // Extract location text starting from "Location:"
      final location = description.substring(locationStartIndex).trim();
      // Remove the location from the original description to avoid duplication
      final cleanDescription = description.replaceFirst(location, "").trim();
      return {"location": location, "description": cleanDescription};
    }
    return {"location": "Location not available", "description": description};
  }

  @override
  Widget build(BuildContext context) {
    // Return multiple values through `extractLocation`.
    final locationResult =
        extractLocation(birdDescription); // retrieve location
    String location = locationResult["location"]!;
    String cleanDescription = locationResult["description"]!;

    return Scaffold(
      backgroundColor: Colors.green[50],
      resizeToAvoidBottomInset: true, // Prevent overflow when keyboard pops up
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          birdName,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Bird Image
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      birdImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Description and Extracted Location
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cleanDescription,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 10),
                        if (location.isNotEmpty &&
                            location != "Location not available")
                          Text(
                            location,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.green[700],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // "Know More" Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () => _launchURL('Indian $birdName'),
                  icon: Icon(Icons.info, color: Colors.white),
                  label: Text(
                    "Know More",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}