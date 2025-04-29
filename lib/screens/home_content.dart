import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../repositories/bird_repository.dart';
import 'bird_detail_screen.dart';
import '../BirdWatchExplorer/BirdWatchExplorer.dart';

class HomeContent extends StatelessWidget {
  final Function(int) onSelectTab;
  final List<Map<String, String>> birdData = BirdRepository.birdData;

  HomeContent({required this.onSelectTab});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            const Color.fromARGB(255, 173, 210, 174)
          ], // Define gradient colors
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Row(children: [
                  Text(
                    'Find Your Bird,',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 35, // Increase font size
                      fontWeight: FontWeight.bold,
                      color: Colors
                          .green[900], // Use a dark green for better contrast
                    ),
                  ),
                  SizedBox(width: 5),
                  Lottie.asset(
                    'assets/animations/b3.json',
                    height: 100,
                    width: 100,
                  ),
                ]),
                ElevatedButton(
                  onPressed: () {
                    onSelectTab(1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 173, 210, 174),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          20), // Add this line for rounded corners
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                  ),
                  child: Text(
                    'Validate',
                    style: TextStyle(color: Colors.black, fontSize: 23),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                ElevatedButton.icon(
                    icon: Icon(Icons.explore, size: 28),
                    label: Text("Birds near you",
                        style: TextStyle(fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BirdWatchExplorer()),
                      );
                    }),
                SizedBox(height: 15), //25
                Lottie.asset(
                  'assets/animations/b4.json',
                  height: 100,
                  width: 550,
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 290.0,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  enlargeCenterPage: true,
                ),
                items: birdData.asMap().entries.map((entry) {
                  Map<String, String> bird = entry.value; // Get bird details

                  return GestureDetector(
                    onTap: () {
                      // Navigate to BirdDetailsScreen, passing bird details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BirdDetailScreen(
                            birdName: bird["name"]!, // Bird name
                            birdImage: bird["image"]!, // Bird image
                            birdDescription:
                                bird["description"]!, // Bird description
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(15.0), // Rounded corners
                        border:
                            Border.all(color: Colors.black, width: 2), // Border
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26, // Shadow color
                            blurRadius: 5, // Blur radius
                            spreadRadius: 2, // Shadow spread
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            15.0), // Image corners match container
                        child: Image.asset(bird["image"]!, fit: BoxFit.cover),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
