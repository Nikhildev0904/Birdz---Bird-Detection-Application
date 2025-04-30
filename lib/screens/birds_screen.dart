import 'package:flutter/material.dart';
import '../repositories/bird_repository.dart';
import 'bird_detail_screen.dart';

class BirdsScreen extends StatefulWidget {
  @override
  _BirdSearchScreenState createState() => _BirdSearchScreenState();
}

class _BirdSearchScreenState extends State<BirdsScreen> {
  final List<Map<String, String>> birdData = BirdRepository.birdData;

  List<Map<String, String>> filteredBirdData = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredBirdData = birdData; // Initialize with all birds
    searchController.addListener(_filterBirds);
  }

  void _filterBirds() {
    setState(() {
      String query = searchController.text.toLowerCase();
      filteredBirdData = birdData.where((bird) {
        return bird["name"]!.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_filterBirds);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 202, 226, 255),
      appBar: AppBar(
        backgroundColor:  const Color.fromARGB(255, 202, 226, 255),
        elevation: 0,
        title: Text('Find Your Bird!',
            style: TextStyle(color: Colors.black, fontSize: 25)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for a bird',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Icon(Icons.search, color: Colors.grey),
                ],
              ),
            ),
            SizedBox(height: 16),
            filteredBirdData.isEmpty
                ? Column(
              children: [
                Text(
                  "No birds found!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                )
              ],
            )
                : Expanded(
              child: ListView.builder(
                itemCount: filteredBirdData.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BirdDetailScreen(
                            birdName: filteredBirdData[index]["name"]!,
                            birdImage: filteredBirdData[index]["image"]!,
                            birdDescription: filteredBirdData[index]
                            ["description"]!,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(
                                  filteredBirdData[index]["image"]!),
                              radius: 20,
                              backgroundColor: Colors.grey[300],
                            ),
                            SizedBox(width: 16),
                            Text(
                              filteredBirdData[index]["name"]!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}