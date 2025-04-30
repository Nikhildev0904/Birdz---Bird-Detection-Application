import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../repositories/bird_repository.dart';
import 'bird_detail_screen.dart';

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
            const Color.fromARGB(255, 255, 255, 255)
          ], // Define gradient colors
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Row(children: [
                  Text(
                    'Find Your Bird',
                    style: TextStyle(
                      fontSize: 35, // Increase font size
                      fontWeight: FontWeight.bold,
                      color: const Color.fromRGBO(37, 99, 235,
                          1), // Use a dark green for better contrast
                    ),
                  ),
                  SizedBox(width: 5),
                  // Lottie.asset(
                  //   'assets/animations/b3.json',
                  //   height: 100,
                  //   width: 100,
                  // ),
                ]),
                ElevatedButton(
                  onPressed: () {
                    onSelectTab(1);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, // Text color
                    backgroundColor: Colors.white, // Button background
                    elevation: 2, // Slight shadow
                    side: BorderSide(color: Colors.blue, width: 1.5), // Border
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(10), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 10),
                  ),
                  child: Text(
                    'Validate & Classify',
                    style: TextStyle(color: Colors.black, fontSize: 23,fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),

                SizedBox(height: 15), //25
                // Lottie.asset(
                //   'assets/animations/b4.json',
                //   height: 100,
                //   width: 550,
                // ),
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