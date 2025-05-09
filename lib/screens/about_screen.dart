import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  // Only include the two specified developers
  final List<Map<String, String>> developers = [
    {
      "name": "Nikhil Dev A",
      "role": "App Developer",
      "linkedin": "https://www.linkedin.com/in/nikhil-dev-arepu/",
    },
    {
      "name": "Dileep Vadla",
      "role": "App Developer",
      "linkedin": "https://www.linkedin.com/in/dileep-vadla27/",
    },
    {
      "name": "Dileep Kumar C",
      "role": "App Developer",
      "linkedin": "https://www.linkedin.com/in/dileepkumarc003/",
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'About Us',
          style: TextStyle(
            color: Color(0xFF2563EB),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Description Card
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFF2563EB),
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          "About the App",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Welcome to our Indian Bird Species Detection App! This app uses advanced machine learning algorithms to classify bird species from images. The app helps bird enthusiasts, researchers, and hobbyists identify birds accurately using just their phone camera or gallery photos. You can also discover nearby bird sightings and explore popular birding hotspots in your area with our location-based features. Try it out and explore the beautiful world of birds!",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        _buildFeatureItem(
                            icon: Icons.camera_alt_outlined,
                            text: "AI Classification"
                        ),
                        SizedBox(width: 12),
                        _buildFeatureItem(
                            icon: Icons.info_outlined,
                            text: "Detailed Info"
                        ),
                        SizedBox(width: 12),
                        _buildFeatureItem(
                            icon: Icons.public_outlined,
                            text: "Wildlife Education"
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Official Website Button
              _buildResourceButton(
                icon: Icons.language,
                title: 'Visit Our Website',
                subtitle: 'Explore out Website and know more about BirdZ',
                onTap: () => _launchUrl('https://birdzin.vercel.app/'),
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),

              SizedBox(height: 30),

              // Team Section
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.people_outline,
                      color: Color(0xFF2563EB),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "DEVELOPERS",
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Team Members Row
              Row(
                children: [
                  Expanded(
                    child: _buildDeveloperCard(
                      name: developers[0]["name"]!,
                      role: developers[0]["role"]!,
                      linkedinUrl: developers[0]["linkedin"]!,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildDeveloperCard(
                      name: developers[1]["name"]!,
                      role: developers[1]["role"]!,
                      linkedinUrl: developers[1]["linkedin"]!,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildDeveloperCard(
                      name: developers[2]["name"]!,
                      role: developers[2]["role"]!,
                      linkedinUrl: developers[2]["linkedin"]!,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // Contact Info Section
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.contact_mail_outlined,
                      color: Color(0xFF2563EB),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "CONTACT INFO",
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Contact Cards - Enhanced
              _buildContactCard(
                icon: Icons.phone,
                title: 'Phone',
                subtitle: '+91 98765XXXXX',
                color: Colors.green.shade100,
                iconColor: Colors.green.shade700,
                onTap: () async {
                  final Uri phoneUri = Uri(
                    scheme: 'tel',
                    path: '+919876500000', // Placeholder number
                  );
                  if (await canLaunch(phoneUri.toString())) {
                    await launch(phoneUri.toString());
                  }
                },
              ),

              SizedBox(height: 16),

              _buildContactCard(
                icon: Icons.email_outlined,
                title: 'Email',
                subtitle: 'birdz.queries@gmail.com',
                color: Colors.blue.shade100,
                iconColor: Colors.blue.shade700,
                onTap: _launchEmail,
              ),

              SizedBox(height: 16),

              _buildContactCard(
                icon: Icons.location_on_outlined,
                title: 'Address',
                subtitle: 'VIT-AP University',
                color: Colors.orange.shade100,
                iconColor: Colors.orange.shade700,
                onTap: _launchLocation,
              ),

              SizedBox(height: 30),

              // External Links Section
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.link,
                      color: Color(0xFF2563EB),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "RESOURCES",
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // External Links Buttons
              _buildResourceButton(
                icon: Icons.dataset_outlined,
                title: 'View Dataset',
                subtitle: 'Check out the bird images used in training',
                onTap: () => _launchUrl('https://data.mendeley.com/preview/59htp7m6v9?a=8e721bdb-bc49-404f-9c4b-b23e1abe22a1'),
                gradient: LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),

              SizedBox(height: 16),

              // Source Code Button
              _buildResourceButton(
                icon: Icons.code_outlined,
                title: 'View Source Code',
                subtitle: 'Check out the source code on GitHub',
                onTap: () => _launchUrl('https://github.com/Nikhildev0904/Birdz---Bird-Detection-Application'),
                gradient: LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),

              SizedBox(height: 16),

              // Additional Resource Button
              _buildResourceButton(
                icon: Icons.book_outlined,
                title: 'EBird Guide',
                subtitle: 'Comprehensive guide to Indian birds',
                onTap: () => _launchUrl('https://ebird.org/region/IN'),
                gradient: LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF34D399)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),

              SizedBox(height: 30),

              // Version Info
              Center(
                child: Text(
                  "Version 1.0.0",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ),

              SizedBox(height: 8),

              // Copyright Info
              Center(
                child: Text(
                  "© 2025 Birdz Team",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build developer card
  Widget _buildDeveloperCard({
    required String name,
    required String role,
    required String linkedinUrl,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _launchUrl(linkedinUrl),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFF2563EB).withOpacity(0.1),
                  radius: 30,
                  child: Text(
                    name.substring(0, 1),
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.link,
                      size: 12,
                      color: Color(0xFF2563EB),
                    ),
                    SizedBox(width: 4),
                    Text(
                      "LinkedIn",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to launch URLs
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
      path: 'birdz.queries@gmail.com',
    );
    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    } else {
      throw 'Could not launch email client';
    }
  }

  // Function to launch location in Google Maps
  Future<void> _launchLocation() async {
    final Uri locationUri = Uri.parse('https://www.google.com/maps?q=VIT-AP+University');
    if (await canLaunch(locationUri.toString())) {
      await launch(locationUri.toString());
    } else {
      throw 'Could not launch $locationUri';
    }
  }

  // Helper function to build feature items
  Widget _buildFeatureItem({required IconData icon, required String text}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xFF2563EB).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Color(0xFF2563EB),
              size: 24,
            ),
            SizedBox(height: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build contact cards
  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to build resource buttons
  Widget _buildResourceButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}