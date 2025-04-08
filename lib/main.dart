import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'BirdWatchExplorer/BirdWatchExplorer.dart';

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

class SplashWrapper extends StatefulWidget {
  @override
  _SplashWrapperState createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(Duration(seconds: 6)); // Duration of splash screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen();
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.green[100], // Set the background color
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation
              Lottie.asset(
                'assets/animations/splash.json', // Replace with your Lottie animation file path
                width: 400, // Adjust size as needed
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      BirdsScreen(),
      AboutScreen(),
    ];
//0xFFB8FFA9
    return Scaffold(
      appBar: _selectedIndex == 0 // Show AppBar only on Home screen
          ? AppBar(
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFB8FFA9), Colors.black],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              title: Row(
                children: [
                  Image.asset(
                    'assets/Birdz.png', // Replace with your icon path
                    width: 80, // Size of the icon
                    height: 80,
                  ),
                  SizedBox(width: 8), // Adds spacing between icon and title
                  Text(
                    'Birdz',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontSize: 35, // Adjust size as needed
                      color: Colors.white, // You can change the text color
                    ),
                  ),
                ],
              ),
            )
          : null, // No AppBar on other screens
      endDrawer: AppDrawer(onSelectItem: _onItemTapped),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Classify',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flutter_dash),
            label: 'Birds',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
        ],
      ),
    );
  }
}

class BirdRepository {
  static final List<Map<String, String>> birdData = [
    {
      "name": "Eurasian Coot",
      "image": "assets/Eurasian Coot.JPG", // Replace with your image path
      "description":
          "A medium-sized, dark waterbird with a white bill and forehead shield. Dives underwater to feed on aquatic plants and small invertebrates. Often seen swimming with a jerky head motion. Loud, harsh croaks and growls. \n\nLocation: Lakes, ponds, and marshes across the Indian subcontinent, Europe, and Asia."
    },
    {
      "name": "Crow",
      "image": "assets/Crow.JPG", // Replace with your image path
      "description":
          "An intelligent, opportunistic feeder with glossy black plumage. Feeds on insects, fruits, and small animals, known for loud cawing calls. \n\nLocation: Urban areas, farmlands, forests, and wetlands worldwide, including the Indian subcontinent."
    },
    {
      "name": "Black-headed ibis",
      "image": "assets/Black-headed ibis.JPG", // Replace with your image path
      "description":
          "A large wading bird with a distinct black head and long, down-curved bill, forages in shallow water for fish, frogs, and invertebrates. Known for a low, grating croak. \n\nLocation: Wetlands, marshes, and rice paddies across the Indian subcontinent and Southeast Asia."
    },
    {
      "name": "Asian Openbill",
      "image": "assets/Asian Openbill.JPG", // Replace with your image path
      "description":
          "A medium-sized stork with a gap in its beak suited for gripping snails. Often seen foraging in shallow water, mostly silent. \n\nLocation: Wetlands, marshes, and rice fields in South Asia and Southeast Asia."
    },
    {
      "name": "Ashy crowned sparrow lark",
      "image":
          "assets/Ashy crowned sparrow lark.jpg", // Replace with your image path
      "description":
          "A small, stout lark with grey-brown plumage, seen running on the ground. Feeds on seeds and insects, male sings a soft buzzing song during flight displays. \n\nLocation: Dry open plains, scrublands, and agricultural fields across the Indian subcontinent."
    },
    {
      "name": "Red-wattled lapwing",
      "image": "assets/Red-wattled lapwing.jpg", // Replace with your image path
      "description":
          "Medium-sized wader with striking red wattles near its beak. Known for its loud, sharp “did-he-do-it” call. \n\nLocation: Farmland, wetlands, and grasslands across the Indian subcontinent."
    },
    {
      "name": "Paddyfield pipit",
      "image": "assets/Paddyfield pipit.jpg", // Replace with your image path
      "description":
          "Small brownish pipit with streaked upperparts, active forager on insects and seeds in open fields. Call is a soft “seet-seet” in flight. \n\nLocation: Open fields, grasslands, and cultivated areas across the Indian subcontinent."
    },
    {
      "name": "Little Cormorant",
      "image": "assets/Little Cormorant.JPG", // Replace with your image path
      "description":
          "Small black waterbird that dives for fish. Often seen drying wings. Short “kuk-kuk” call heard in colonies. \n\nLocation: Ponds, lakes, rivers, and marshes across South and Southeast Asia."
    },
    {
      "name": "Large-billed Crow",
      "image": "assets/Large-billed Crow.JPG", // Replace with your image path
      "description":
          "Large black crow with a prominent bill. Feeds on various foods including carrion, highly adaptable. \n\nLocation: Forests, urban areas, and wetlands throughout the Indian subcontinent and Southeast Asia."
    },
    {
      "name": "Indian Roller",
      "image": "assets/Indian Roller.jpg", // Replace with your image path
      "description":
          "Colorful bird with vivid blue wings, catches insects in flight. Known for its “rak-rak-rak” call. \n\nLocation: Open country, agricultural lands, and wooded areas across the Indian subcontinent."
    },
    {
      "name": "Yellow-wattled lapwing",
      "image":
          "assets/Yellow wattled lapwing.jpg", // Replace with your image path
      "description":
          "Medium-sized wader with yellow wattles and legs, swift on open ground. Short “kweek-kweek” call. \n\nLocation: Dry, open areas like grasslands and fields across India."
    },
    {
      "name": "White-breasted Waterhen",
      "image":
          "assets/White-breasted Waterhen.JPG", // Replace with your image path
      "description":
          "Medium-sized waterbird with white face and underparts, often along water edges. Loud “kruu-kruu-kruu” call. \n\nLocation: Wetlands, marshes, and reed beds across the Indian subcontinent and Southeast Asia.",
    },
    {
      "name": "Spot-billed Pelican",
      "image":
          "assets/Spot-billed Pelician.JPG", // Replace with your image path
      "description":
          "Large waterbird with spotted bill, seen gliding over water for fish. Usually silent except for low grunts. \n\nLocation: Large water bodies, lakes, and reservoirs across the Indian subcontinent and Southeast Asia.",
    },
    {
      "name": "Painted Stork",
      "image": "assets/Painted Stork.jpg", // Replace with your image path
      "description":
          "Large wading bird with a striking pink tertial feathers and long yellow beak. Often seen wading in shallow water for fish. Produces harsh croaks or whistles during breeding. \n\nLocation: Wetlands, marshes, and shallow water bodies across the Indian subcontinent and Southeast Asia.",
    },
  ];
}

// Updated HomeContent widget to match BirdHomePage layout
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
                    label: Text("Explore Bird Sightings",
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

// Updated AppDrawer to use BottomNavigationBar index
class AppDrawer extends StatelessWidget {
  final Function(int) onSelectItem;

  AppDrawer({required this.onSelectItem});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB8FFA9), Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/Birdz.png', // Replace with your image path
                fit: BoxFit.contain,
                width: 200, // Adjust the size as needed
                height: 200,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.green),
            title: Text(
              'Home',
              style: TextStyle(
                  color: Colors.green, // Set the desired text color
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Closes the AppDrawer
              onSelectItem(0); // Navigate to Home
            }, // Set index for Home
          ),
          ListTile(
            leading: Icon(Icons.camera_alt, color: Colors.green),
            title: Text(
              'Classify',
              style: TextStyle(
                  color: Colors.green, // Set the desired text color
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Closes the AppDrawer
              onSelectItem(1); // Navigate to Home
            }, // Set index for Classify
          ),
          ListTile(
            leading: Icon(Icons.flutter_dash, color: Colors.green),
            title: Text(
              'Birds',
              style: TextStyle(
                  color: Colors.green, // Set the desired text color
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Closes the AppDrawer
              onSelectItem(2); // Navigate to Home
            }, // Set index for Birds
          ),
          ListTile(
            leading: Icon(Icons.info, color: Colors.green),
            title: Text(
              'About',
              style: TextStyle(
                  color: Colors.green, // Set the desired text color
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context); // Closes the AppDrawer
              onSelectItem(3); // Navigate to Home
            }, // Set index for About
          ),
        ],
      ),
    );
  }
}

class ClassifyScreen extends StatefulWidget {
  @override
  _ClassifyScreenState createState() => _ClassifyScreenState();
}

class _ClassifyScreenState extends State<ClassifyScreen> {
  final picker = ImagePicker();
  String? imageUrl;
  String? resultMessage;
  String? detectedSpecies;
  String? s3ImageUrl;
  bool isBird = false;
  bool isLoading = false;

  // Upload image to the server
  Future<void> uploadImage(File imageFile) async {
    setState(() => isLoading = true); // Setting loading to true
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://abraz.online/upload'),
    );
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));
    final response = await request.send();
    final responseData = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final data = json.decode(responseData.body);
      setState(() {
        imageUrl = data['url'];
        resultMessage = 'Image uploaded successfully!';
      });
    } else {
      setState(() {
        resultMessage = 'Image upload failed!';
      });
    }
    setState(() => isLoading = false); // Setting loading to false after upload
  }

  // Validate if the image contains a bird
  Future<void> validateBird() async {
    setState(() => isLoading = true);
    final response = await http.post(
      Uri.parse('https://abraz.online/validate'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"birdLink": imageUrl}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        isBird = data['isBird'];
        resultMessage = isBird ? 'Bird detected!' : 'No bird detected!';
      });
    } else {
      setState(() {
        resultMessage = 'Bird validation failed!';
      });
    }
    setState(() => isLoading = false);
  }

  // Classify the bird species
  Future<void> classifyBird() async {
    if (!isBird) {
      setState(() {
        resultMessage = 'No bird detected; classification skipped.';
      });
      return;
    }
    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse('https://abraz.online/classify'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"birdLink": imageUrl}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        detectedSpecies = data['classifiedBirds'] == "No birds detected"
            ? "No species detected"
            : data['classifiedBirds'].join(', ');
        s3ImageUrl = data['s3ImageUrl'];
      });
    } else {
      setState(() {
        resultMessage = 'Classification failed!';
      });
    }
    setState(() => isLoading = false);
  }

  // Pick an image from gallery
  Future<void> pickImage() async {
    setState(() {
      // Reset the previous results
      resultMessage = null;
      detectedSpecies = null;
      s3ImageUrl = null;
      isBird = false;
    });
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await uploadImage(imageFile);
    } else {
      print('No image selected.');
    }
  }

  // Capture an image from camera
  Future<void> captureImage() async {
    setState(() {
      // Reset the previous results
      resultMessage = null;
      detectedSpecies = null;
      s3ImageUrl = null;
      isBird = false;
    });
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await uploadImage(imageFile);
    } else {
      print('No image captured.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        elevation: 0,
        title: Text('Bird Species Detection',
            style: TextStyle(color: Colors.black, fontSize: 25)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.7, // Adjust this value for transparency
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      "assets/background_test.png"), // Add your background image here
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if (resultMessage != null || detectedSpecies != null)
            BackdropFilter(
              filter:
                  ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Blur effect
              child: Container(
                color: Colors.black.withOpacity(0.2), // Optional dim effect
              ),
            ),
          Center(
            // Wrap the whole body with Center widget
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center the column items
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Center horizontally
                  children: [
                    if (isLoading)
                      Center(
                        child: Lottie.asset(
                          'assets/animations/loading.json', // Path to your Lottie animation
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    if (!isLoading) ...[
                      // Button to upload image from gallery
                      ElevatedButton.icon(
                        onPressed: pickImage,
                        icon: Icon(Icons.upload),
                        label: Text('Upload Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 255, 255, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      // Button to capture image using the camera
                      ElevatedButton.icon(
                        onPressed: captureImage,
                        icon: Icon(Icons.camera_alt),
                        label: Text('Capture Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 255, 255, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      if (imageUrl != null)
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  "Uploaded Image",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                                SizedBox(height: 10),
                                // Wrap the Image.network in a Container with a fixed height
                                Container(
                                  height:
                                      250, // Set a fixed height (you can adjust this)
                                  child: Image.network(
                                    imageUrl!,
                                    fit: BoxFit
                                        .cover, // Ensures the image maintains its aspect ratio
                                  ),
                                ),
                                SizedBox(height: 10),
                                ElevatedButton.icon(
                                  onPressed: validateBird,
                                  icon: Icon(Icons.search),
                                  label: Text('Predict if Bird',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[100],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (isBird)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: ElevatedButton.icon(
                            onPressed: classifyBird,
                            icon: Icon(Icons.category),
                            label: Text('Classify Bird Species',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white54,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 8),
                      if (resultMessage != null)
                        Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                                0.8), // Semi-transparent background
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                          ),
                          child: Text(
                            resultMessage!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      SizedBox(height: 8),
                      if (detectedSpecies != null)
                        Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                                0.8), // Semi-transparent background
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                          ),
                          child: Text(
                            'Detected Species: $detectedSpecies',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (s3ImageUrl != null)
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(s3ImageUrl!),
                          ),
                        ),
                      if (s3ImageUrl != null && !detectedSpecies!.contains(','))
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white54,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          onPressed: () {
                            var birdData = BirdRepository.birdData.firstWhere(
                              (bird) =>
                                  bird["name"]!.toLowerCase() ==
                                  detectedSpecies!.toLowerCase(),
                              orElse: () => {
                                "name": "Unknown Bird",
                                "image":
                                    "assets/placeholder.jpg", // Use a placeholder image
                                "description": "No description available."
                              },
                            );

                            // Navigate to BirdDetailScreen with the selected bird data
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BirdDetailScreen(
                                  birdName: birdData["name"]!,
                                  birdImage: birdData["image"]!,
                                  birdDescription: birdData["description"]!,
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.info, color: Colors.white),
                          label: Text(
                            "Bird Info",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        backgroundColor: Colors.green[100],
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
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        onPressed: () {
                          // Action for "Contribute to Dataset"
                          // Example: Open a Google Form or new screen
                          _openContributionForm(context);
                        },
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text(
                          "Contribute to Dataset",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
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

  void _openContributionForm(BuildContext context) {
    const String contributionFormURL =
        "https://docs.google.com/forms/d/e/1FAIpQLSfgGsN4-3qfel3qVOFbP4H1myzr84XCKrcSMd84bG2SLWVxOA/viewform?usp=sf_link"; // Replace with your form link
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Contribute to our Dataset"),
        content: Text(
            "Help us grow the dataset by adding information about new birds."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Open the contribution form in a browser
              launch(contributionFormURL);
            },
            child: Text("Contribute"),
          ),
        ],
      ),
    );
  }
}

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
      body: SingleChildScrollView(
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
    );
  }
}

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
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _launchUrl(
                      'https://docs.google.com/forms/d/e/1FAIpQLSfgGsN4-3qfel3qVOFbP4H1myzr84XCKrcSMd84bG2SLWVxOA/viewform?usp=sf_link'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white54,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                  child: Text(
                    'Contribute to Dataset',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ),
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
