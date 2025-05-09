import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
// Import your bird repository
import '../repositories/bird_details_repository.dart';

class BirdDetailScreen extends StatelessWidget {
  final String birdName;
  final String birdImage;
  final String birdDescription;

  BirdDetailScreen({
    required this.birdName,
    required this.birdImage,
    required this.birdDescription,
  });

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchGoogleSearch(String birdName) async {
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
      final location = description.substring(locationStartIndex).trim();
      final cleanDescription = description.replaceFirst(location, "").trim();
      return {"location": location, "description": cleanDescription};
    }
    return {"location": "", "description": description};
  }

  @override
  Widget build(BuildContext context) {
    final locationResult = extractLocation(birdDescription);
    String location = locationResult["location"] ?? "";
    String cleanDescription = locationResult["description"] ?? "";

    // Get bird data from the repository
    final Map<String, dynamic> birdData = BirdDetailsRepository.getBirdData(birdName);
    final String habitat = birdData["habitat"] ?? "Not available";
    final String distribution = birdData["distribution"] ?? "Not available";
    final String food = birdData["food"] ?? "Not available";
    final String conservationStatus = birdData["conservation_status"] ?? "Unknown";
    final String funFact = birdData["fun_fact"] ?? "No fun fact available";
    final String wikiLink = birdData["wiki_link"] ?? "https://en.wikipedia.org/wiki/$birdName";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2563EB)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          birdName,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bird Image
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.width * 0.7, // Responsive height
              child: Image.asset(
                birdImage,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bird Name and Learn More Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          birdName,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _launchURL(wikiLink),
                        icon: Icon(Icons.link, size: 18),
                        label: Text("Learn More"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Info Grid - Converted to Column for better text display
                  // Use separate rows instead of GridView to prevent overflow
                  Column(
                    children: [
                      Row(
                        children: [
                          // Habitat
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.terrain,
                              title: "Habitat",
                              content: habitat,
                            ),
                          ),
                          SizedBox(width: 16),
                          // Distribution
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.public,
                              title: "Distribution",
                              content: distribution,
                              allowMultiline: true,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          // Diet
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.restaurant_menu,
                              title: "Diet",
                              content: food,
                              allowMultiline: true,
                            ),
                          ),
                          SizedBox(width: 16),
                          // Status
                          Expanded(
                            child: _buildStatusCard(
                              title: "Status",
                              status: conservationStatus,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Fun Fact Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Color(0xFF2563EB),
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Fun Fact",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          funFact,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // About Section
                  if (cleanDescription.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "About",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey.shade200,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            cleanDescription,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    bool allowMultiline = false,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Color(0xFF2563EB),
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            maxLines: allowMultiline ? 5 : 2, // Allow more lines for certain fields
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String status,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Color(0xFF2563EB),
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: BirdDetailsRepository.getStatusColor(status),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: BirdDetailsRepository.getStatusTextColor(status),
              ),
            ),
          ),
        ],
      ),
    );
  }
}