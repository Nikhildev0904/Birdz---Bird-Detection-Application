import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import '../repositories/bird_repository.dart';
import '../screens/bird_detail_screen.dart';

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
  List<String> predictionImages = []; // After first classify API
  List<String> selectedImages = []; // After user selects multiple
  String? birdDescription;
  Map<String, dynamic>? probabilities; // Store probabilities
  String? initialPrediction; // Store initial prediction bird species
  String? finalPredictionImage; // Store final predicted bird image path

  bool showConfirmButton = false;

  // Upload image to the server
  Future<void> uploadImage(File imageFile) async {
    setState(() => isLoading = true); // Setting loading to true
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://mytownly.in/upload'),
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
      Uri.parse('https://mytownly.in/validate/'),
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

    if (imageUrl == null) {
      setState(() {
        resultMessage = 'Image URL is missing. Please upload an image first.';
      });
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://mytownly.in/get-probabilities/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"birdLink": imageUrl}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> envelope = json.decode(response.body);

        // Extract the "data" object
        final Map<String, dynamic>? data = envelope['data'] as Map<String, dynamic>?;

        if (data != null) {
          // Extract probabilities and images
          final List<dynamic>? imgsDynamic = data['images'] as List<dynamic>?;
          final Map<String, dynamic>? probabilitiesData = {
            "classIndex": data['classIndex'],
            "className": data['className'],
            "topPrediction1_class": data['topPrediction1_class'],
            "topPrediction2_class": data['topPrediction2_class'],
            "topPrediction1_probability": data['topPrediction1_probability'],
            "topPrediction2_probability": data['topPrediction2_probability'],
          };

          if (imgsDynamic != null && imgsDynamic.isNotEmpty && probabilitiesData != null) {
            setState(() {
              // Log the original URLs for debugging
              print("Original image URLs: $imgsDynamic");

              predictionImages = imgsDynamic
                  .cast<String>()
                  .map((url) {
                    // Transform all URLs to use the .JPG extension
                    final normalizedUrl = url.replaceAllMapped(
                      RegExp(r'\.jpg$', caseSensitive: false),
                      (match) => '.JPG',
                    );
                    print("Normalized URL: $normalizedUrl"); // Log the normalized URL
                    return normalizedUrl;
                  })
                  .toList();

              // Log the final list of prediction images
              print("Final prediction images: $predictionImages");

              probabilities = probabilitiesData; // Store probabilities in state
              initialPrediction = probabilitiesData['topPrediction1_class']; // Store initial prediction
              selectedImages.clear();
              resultMessage = null;
            });
          } else {
            setState(() {
              predictionImages = [];
              probabilities = null;
              resultMessage = 'No prediction images or probabilities returned.';
            });
          }
        } else {
          setState(() {
            resultMessage = 'Malformed response: missing "data" field.';
          });
        }
      } else {
        setState(() {
          resultMessage = 'Classification failed! (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        resultMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Pick an image from gallery
  Future<void> pickImage() async {
    setState(() {
      // Reset the previous results
      resultMessage = null;
      detectedSpecies = null;
      s3ImageUrl = null;
      isBird = false;
      predictionImages = [];
      selectedImages.clear();
      showConfirmButton = false;
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

  Future<void> sendSelectedImagesForFinalClassification() async {
    if (selectedImages.length != 3) {
      setState(() {
        resultMessage = 'Please select exactly 3 images.';
      });
      return;
    }

    if (probabilities == null) {
      setState(() {
        resultMessage = 'Probabilities data is missing.';
      });
      return;
    }

    setState(() => isLoading = true);
    try {
      // Extract class counts from selected images
      final classCounts = <String, int>{};
      for (var url in selectedImages) {
        final className = url.contains('/${probabilities!['classIndex']}_')
            ? probabilities!['className']
            : probabilities!['topPrediction2_class'];
        classCounts[className] = (classCounts[className] ?? 0) + 1;
      }

      // Ensure the class names are available
      final class1Name = probabilities!['className'];
      final class2Name = probabilities!['topPrediction2_class'];

      if (class1Name == null || class2Name == null) {
        setState(() {
          resultMessage = 'Unable to determine class names.';
        });
        return;
      }

      // Prepare the payload for the API
      final payload = {
        "birdLink": imageUrl, // URL of the uploaded bird image
        "selected_class1_name": class1Name,
        "selected_class2_name": class2Name,
        "selected_class1_value": classCounts[class1Name] ?? 0,
        "selected_class2_value": classCounts[class2Name] ?? 0,
      };

      final response = await http.post(
        Uri.parse('https://mytownly.in/get-adjusted-predictions/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> envelope = json.decode(response.body);

        // Extract the "data" object
        final Map<String, dynamic>? data = envelope['data'] as Map<String, dynamic>?;

        if (data != null && data['final_prediction'] != null) {
          final finalPrediction = data['final_prediction'];

          setState(() {
            detectedSpecies = finalPrediction['class'] ?? 'Unknown';
            final birdData = BirdRepository.birdData.firstWhere(
              (bird) => bird["name"]!.toLowerCase() == detectedSpecies!.toLowerCase(),
              orElse: () => {
                "image": "assets/placeholder.jpg", // Use a placeholder image if not found
              },
            );

            setState(() {
              finalPredictionImage = birdData["image"]; // Set final prediction image from birdData
              resultMessage = null;
            });
          });
        } else {
          setState(() {
            resultMessage = 'Malformed response: missing "data" field.';
          });
        }
      } else {
        setState(() {
          resultMessage = 'Final classification failed! (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        resultMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() => isLoading = false);
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
                      if (predictionImages.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select the most accurate bird image:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              if (predictionImages.isNotEmpty)
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: predictionImages.map((url) {
                                    final isSelected =
                                        selectedImages.contains(url);
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            selectedImages.remove(url);
                                          } else if (selectedImages.length < 3) {
                                            selectedImages.add(url);
                                          }
                                          showConfirmButton =
                                              selectedImages.isNotEmpty;
                                        });
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: isSelected
                                                      ? Colors.blue
                                                      : Colors.grey,
                                                  width: isSelected ? 3 : 1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: buildImage(url),
                                          ),
                                          if (isSelected)
                                            Positioned(
                                              right: 4,
                                              top: 4,
                                              child: Icon(Icons.check_circle,
                                                  color: Colors.blue),
                                            ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              if (showConfirmButton)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: ElevatedButton.icon(
                                    icon: Icon(Icons.check),
                                    label: Text("Confirm Selection"),
                                    onPressed:
                                        sendSelectedImagesForFinalClassification,
                                  ),
                                ),
                            ],
                          ),
                        ),

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
                      if (initialPrediction != null || detectedSpecies != null)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              if (initialPrediction != null)
                                Text(
                                  'Initial Prediction: $initialPrediction',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              if (detectedSpecies != null)
                                Column(
                                  children: [
                                    SizedBox(height: 16),
                                    Text(
                                      'Final Prediction: $detectedSpecies',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (finalPredictionImage != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 16.0),
                                        child: Image.asset(
                                          finalPredictionImage!,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                  ],
                                ),
                            ],
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

  // Add error handling for image loading with fallback for .jpg and .JPG
  Widget buildImage(String url) {
    return FutureBuilder<String>(
      future: resolveImageUrl(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          print("Failed to load image: $url"); // Log inaccessible URLs
          return Container(
            color: Colors.grey,
            child: Icon(Icons.broken_image, color: Colors.red),
          );
        } else {
          return Image.network(
            snapshot.data!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print("Failed to load resolved image: ${snapshot.data!}");
              return Container(
                color: Colors.grey,
                child: Icon(Icons.broken_image, color: Colors.red),
              );
            },
          );
        }
      },
    );
  }

  // Resolve the correct image URL by trying both .JPG and .jpg
  Future<String> resolveImageUrl(String url) async {
    try {
      // Try loading the image with .JPG
      final jpgUrl = url.replaceAllMapped(
        RegExp(r'\.jpg$', caseSensitive: false),
        (match) => '.JPG',
      );
      final response = await http.head(Uri.parse(jpgUrl));
      if (response.statusCode == 200) {
        return jpgUrl;
      }

      // Fallback to .jpg if .JPG fails
      final lowercaseUrl = url.replaceAllMapped(
        RegExp(r'\.JPG$', caseSensitive: false),
        (match) => '.jpg',
      );
      final fallbackResponse = await http.head(Uri.parse(lowercaseUrl));
      if (fallbackResponse.statusCode == 200) {
        return lowercaseUrl;
      }

      throw Exception("Both .JPG and .jpg failed for $url");
    } catch (e) {
      print("Error resolving image URL: $e");
      throw e;
    }
  }
}