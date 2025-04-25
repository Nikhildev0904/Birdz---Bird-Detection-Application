import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        elevation: 0,
        title: Text(
          'About Us',
          style: TextStyle(color: Colors.black, fontSize: 25),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to our Indian Bird Species Detection App! This app uses advanced machine learning algorithms to classify bird species from images. The app helps bird enthusiasts, researchers, and hobbyists identify birds accurately using just their phone camera or gallery photos. Try it out and explore the beautiful world of birds!",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                height: 1.6,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 40),
            Center(
              child: Text(
                "CONTACT INFO",
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildInfoCard(
              imageUrl: 'https://img.icons8.com/bubbles/100/000000/phone.png',
              title: 'Phone',
              subtitle: '+91 98765XXXXX',
            ),
            SizedBox(height: 20),
            _buildInfoCard(
              imageUrl:
                  'https://img.icons8.com/bubbles/100/000000/new-post.png',
              title: 'Email',
              subtitle: 'dileepvadla27@gmail.com',
              onTap: _launchEmail,
            ),
            SizedBox(height: 20),
            _buildInfoCard(
              imageUrl:
                  'https://img.icons8.com/bubbles/100/000000/map-marker.png',
              title: 'Address',
              subtitle: 'VIT-AP University',
              onTap: _launchLocation,
            ),
            SizedBox(height: 40),
            Center(
                child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => _launchUrl(
                      'https://drive.google.com/drive/folders/1Dp92XBB8ewhxPe_xPguy7PLMSH4yGHsb'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white54,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                  child: Text(
                    'View Dataset',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Function to launch email client
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'dileepvadla27@gmail.com',
    );
    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    } else {
      throw 'Could not launch email client';
    }
  }

  // Function to launch location in Google Maps
  Future<void> _launchLocation() async {
    final Uri locationUri =
        Uri.parse('https://www.google.com/maps?q=VIT-AP+University');
    if (await canLaunch(locationUri.toString())) {
      await launch(locationUri.toString());
    } else {
      throw 'Could not launch $locationUri';
    }
  }

  // Helper function to build the info cards
  Widget _buildInfoCard({
    required String imageUrl,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Image.network(
          imageUrl,
          width: 40,
          height: 40,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.error, size: 40, color: Colors.grey);
          }, // Fallback image if loading fails
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.green[700],
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.black87),
        ),
        onTap: onTap,
      ),
    );
  }
}
