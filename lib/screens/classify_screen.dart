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
// base url
const String BaseUrl = 'https://mytownly.in';
//const String BaseUrl = 'https://0b85-103-186-254-122.ngrok-free.app';
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

  // Cache for resolved image URLs to prevent unnecessary network requests
  Map<String, String> resolvedImageCache = {};

  bool showConfirmButton = false;

  // Upload image to the server
  Future<void> uploadImage(File imageFile) async {
    setState(() => isLoading = true); // Setting loading to true
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$BaseUrl/upload'),
    );
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));
    final response = await request.send();
    final responseData = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final data = json.decode(responseData.body);
      setState(() {
        imageUrl = data['url'];
        print("image url"+imageUrl!);
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
      Uri.parse('$BaseUrl/validate/'),
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
        Uri.parse('$BaseUrl/get-probabilities/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"birdLink": imageUrl}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> envelope = json.decode(response.body);

        // Extract the "data" object
        final Map<String, dynamic>? data =
            envelope['data'] as Map<String, dynamic>?;

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

          if (imgsDynamic != null &&
              imgsDynamic.isNotEmpty &&
              probabilitiesData != null) {
            // Clear the cache when we get new prediction images
            resolvedImageCache.clear();

            setState(() {
              // Log the original URLs for debugging
              print("Original image URLs: $imgsDynamic");

              predictionImages = imgsDynamic.cast<String>().map((url) {
                // Transform all URLs to use the .JPG extension
                final normalizedUrl = url.replaceAllMapped(
                  RegExp(r'\.jpg$', caseSensitive: false),
                  (match) => '.JPG',
                );
                print(
                    "Normalized URL: $normalizedUrl"); // Log the normalized URL
                return normalizedUrl;
              }).toList();

              // Log the final list of prediction images
              print("Final prediction images: $predictionImages");

              probabilities = probabilitiesData; // Store probabilities in state
              initialPrediction = probabilitiesData[
                  'topPrediction1_class']; // Store initial prediction
              selectedImages.clear();
              resultMessage = null;
            });

            // Pre-resolve all image URLs in the background
            for (String url in predictionImages) {
              resolveImageUrl(url);
            }
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
      resolvedImageCache.clear(); // Clear the image cache
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
      predictionImages = [];
      selectedImages.clear();
      showConfirmButton = false;
      resolvedImageCache.clear(); // Clear the image cache
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
      print(
        class1Name +
            " " +
            class2Name +
            " " +
            classCounts[class1Name].toString() +
            " " +
            classCounts[class2Name].toString(),
      );

      // Prepare the payload for the API
      final payload = {
        "birdLink": imageUrl, // URL of the uploaded bird image
        "selected_class1_name": class1Name,
        "selected_class2_name": class2Name,
        "selected_class1_value": classCounts[class1Name] ?? 0,
        "selected_class2_value": classCounts[class2Name] ?? 0,
      };

      final response = await http.post(
        Uri.parse('$BaseUrl/get-adjusted-predictions/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> envelope = json.decode(response.body);

        // Extract the "data" object
        final Map<String, dynamic>? data =
            envelope['data'] as Map<String, dynamic>?;

        if (data != null && data['final_prediction'] != null) {
          final finalPrediction = data['final_prediction'];

          setState(() {
            detectedSpecies = finalPrediction['class'] ?? 'Unknown';
            final birdData = BirdRepository.birdData.firstWhere(
              (bird) =>
                  bird["name"]!.toLowerCase() == detectedSpecies!.toLowerCase(),
              orElse: () => {
                "image":
                    "assets/placeholder.jpg", // Use a placeholder image if not found
              },
            );

            setState(() {
              finalPredictionImage =
                  birdData["image"]; // Set final prediction image from birdData
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
          resultMessage =
              'Final classification failed! (${response.statusCode})';
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

  // Navigate to bird details screen
  void _navigateToBirdDetails() {
    if (detectedSpecies != null && !detectedSpecies!.contains(',')) {
      var birdData = BirdRepository.birdData.firstWhere(
        (bird) => bird["name"]!.toLowerCase() == detectedSpecies!.toLowerCase(),
        orElse: () => {
          "name": "Unknown Bird",
          "image": "assets/placeholder.jpg",
          "description": "No description available."
        },
      );

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Bird Species Detection',
            style: TextStyle(
                color: Color(0xFF1E40AF),
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Color(0xFFE7F0FF),
                ],
              ),
            ),
          ),

          // Blur effect when showing results
          if (resultMessage != null || detectedSpecies != null)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.05),
              ),
            ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Loading animation
                        if (isLoading)
                          Center(
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Lottie.asset(
                                      'assets/animations/loading.json',
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Processing...',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E40AF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        if (!isLoading) ...[
                          // Image source buttons
                          Container(
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
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.photo_camera,
                                      color: Color(0xFF1E40AF),
                                      size: 24,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Select Image Source',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E40AF),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Gallery Button
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: pickImage,
                                        icon:
                                            Icon(Icons.photo_library, size: 22),
                                        label: Text(
                                          'Gallery',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFFE7F0FF),
                                          foregroundColor: Color(0xFF1E40AF),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    // Camera Button
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: captureImage,
                                        icon: Icon(Icons.camera_alt, size: 22),
                                        label: Text(
                                          'Camera',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF2563EB),
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24),

                          // Uploaded image section
                          if (imageUrl != null)
                            Container(
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
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image,
                                          color: Color(0xFF1E40AF),
                                          size: 24,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Uploaded Image",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E40AF),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Container(
                                      height: 250,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          imageUrl!,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                color: Color(0xFF2563EB),
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[100],
                                              child: Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 64,
                                                  color: Colors.grey[400],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: validateBird,
                                        icon: Icon(Icons.search),
                                        label: Text(
                                          'Validate Bird',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF2563EB),
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Classify bird button (only show if bird is detected)
                          if (isBird)
                            Padding(
                              padding: const EdgeInsets.only(top: 24.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: classifyBird,
                                  icon: Icon(Icons.category),
                                  label: Text(
                                    'Classify Bird Species',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF2563EB),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ),

                          // Result message
                          if (resultMessage != null)
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 20),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    resultMessage!.contains('detected!')
                                        ? Icons.check_circle
                                        : Icons.info,
                                    color: resultMessage!.contains('detected!')
                                        ? Colors.green[600]
                                        : Color(0xFF2563EB),
                                    size: 24,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      resultMessage!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Image selection section - Vertical Layout (as requested by boss)
                          if (predictionImages.isNotEmpty)
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 24),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.collections,
                                            color: Color(0xFF2563EB),
                                            size: 24,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            'Select Images',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E40AF),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Selection counter badge
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFE7F0FF),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Color(0xFF2563EB),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Color(0xFF2563EB),
                                              size: 16,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              '${selectedImages.length}/3',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2563EB),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Choose 3 images that look most similar to your bird',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  // Vertical list of images instead of grid
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: predictionImages.length,
                                    itemBuilder: (context, index) {
                                      final url = predictionImages[index];
                                      final isSelected =
                                          selectedImages.contains(url);
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 16),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isSelected
                                                ? Color(0xFF2563EB)
                                                : Colors.grey[300]!,
                                            width: isSelected ? 4 : 3,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: Color(0xFF2563EB)
                                                        .withOpacity(0.2),
                                                    blurRadius: 8,
                                                    spreadRadius: 1,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (isSelected) {
                                                selectedImages.remove(url);
                                              } else if (selectedImages.length <
                                                  3) {
                                                selectedImages.add(url);
                                              }
                                              showConfirmButton =
                                                  selectedImages.isNotEmpty;
                                            });
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Stack(
                                              children: [
                                                // Larger image
                                                Container(
                                                  height: 250,
                                                  width: double.infinity,
                                                  child: getCachedImage(url),
                                                ),
                                                // Selection indicator
                                                if (isSelected)
                                                  Positioned(
                                                    right: 12,
                                                    top: 12,
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(6),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFF2563EB),
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color:
                                                                Colors.black26,
                                                            blurRadius: 4,
                                                            offset:
                                                                Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                    ),
                                                  ),
                                                // Tap to select overlay for unselected images
                                                if (!isSelected)
                                                  Positioned(
                                                    right: 12,
                                                    top: 12,
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 5),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black45,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: Text(
                                                        'Tap to select',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  if (showConfirmButton)
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(top: 20.0),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                icon: const Icon(
                                                    Icons.check_circle),
                                                label: Text(
                                                  "Confirm Selection",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                onPressed:
                                                    sendSelectedImagesForFinalClassification,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Color(0xFF2563EB),
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 16),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  elevation: 0,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 16),
                                            SizedBox(
                                              width: double.infinity,
                                              child: OutlinedButton.icon(
                                                icon: const Icon(
                                                    Icons.not_interested),
                                                label: Text(
                                                  "None of these match",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    resultMessage =
                                                        "Hmm, this bird doesn't match any species in our system. We're constantly expanding—stay tuned!";
                                                    selectedImages.clear();
                                                    showConfirmButton = false;
                                                  });
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor:
                                                      Colors.red[600],
                                                  side: BorderSide(
                                                      color: Colors.red[300]!),
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 16),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                                ],
                              ),
                            ),

                          // Prediction results
                          if (initialPrediction != null ||
                              detectedSpecies != null)
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 20),
                              padding: EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Column(children: [
                                if (initialPrediction != null)
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.auto_awesome,
                                            color: Color(0xFFF59E0B),
                                            size: 24,
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Initial Prediction',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1E40AF),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFFEDD5),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Color(0xFFF59E0B)
                                                  .withOpacity(0.5)),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              initialPrediction!,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFB45309),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Add uploaded image display for initial prediction
                                      SizedBox(height: 16),
                                      if (imageUrl != null)
                                        Container(
                                          height: 200,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 8,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.network(
                                              imageUrl!,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Color(0xFF2563EB),
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                  ),
                                                );
                                              },
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[100],
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      size: 64,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                if (detectedSpecies != null) ...[
                                  SizedBox(
                                      height:
                                          initialPrediction != null ? 30 : 0),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF10B981),
                                        size: 24,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Final Prediction',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E40AF),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFD1FAE5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Color(0xFF10B981)
                                              .withOpacity(0.5)),
                                    ),
                                    child: Text(
                                      detectedSpecies!,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF065F46),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  // Add final prediction image with tap to see details
                                  if (finalPredictionImage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.touch_app,
                                                color: Color(0xFF1E40AF),
                                                size: 18,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                "Tap image to see bird details",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontStyle: FontStyle.italic,
                                                  color: Color(0xFF1E40AF),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 12),
                                          GestureDetector(
                                            onTap: _navigateToBirdDetails,
                                            child: Container(
                                              height: 220,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.15),
                                                    blurRadius: 10,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    child: Image.asset(
                                                      finalPredictionImage!,
                                                      height: 220,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  // View details overlay
                                                  Positioned(
                                                    bottom: 0,
                                                    left: 0,
                                                    right: 0,
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 10,
                                                              horizontal: 16),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          begin: Alignment
                                                              .bottomCenter,
                                                          end: Alignment
                                                              .topCenter,
                                                          colors: [
                                                            Colors.black
                                                                .withOpacity(
                                                                    0.7),
                                                            Colors.transparent,
                                                          ],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  12),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  12),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.info_outline,
                                                            color: Colors.white,
                                                            size: 18,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            "View Details",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ]),
                            ),
                        ],
                      ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Get cached image to prevent reloading on selection
  Widget getCachedImage(String url) {
    // If we've already resolved this URL, use the cached version
    if (resolvedImageCache.containsKey(url)) {
      return Image.network(
        resolvedImageCache[url]!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    } else {
      // If not cached yet, resolve and cache it
      return FutureBuilder<String>(
        future: resolveImageUrl(url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF2563EB),
                ),
              ),
            );
          } else if (snapshot.hasError || !snapshot.hasData) {
            return Container(
              color: Colors.grey[200],
              child: Icon(Icons.broken_image, color: Colors.grey),
            );
          } else {
            // Store in cache for future use
            resolvedImageCache[url] = snapshot.data!;
            return Image.network(
              snapshot.data!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            );
          }
        },
      );
    }
  }

  // Resolve the correct image URL by trying both .JPG and .jpg
  Future<String> resolveImageUrl(String url) async {
    try {
      // If this URL has already been resolved, return the cached result
      if (resolvedImageCache.containsKey(url)) {
        return resolvedImageCache[url]!;
      }

      // Try loading the image with .JPG
      final jpgUrl = url.replaceAllMapped(
        RegExp(r'\.jpg$', caseSensitive: false),
        (match) => '.JPG',
      );

      try {
        final response = await http.head(Uri.parse(jpgUrl));
        if (response.statusCode == 200) {
          resolvedImageCache[url] = jpgUrl;
          return jpgUrl;
        }
      } catch (e) {
        print("Failed to check JPG version: $e");
      }

      // Fallback to .jpg if .JPG fails
      final lowercaseUrl = url.replaceAllMapped(
        RegExp(r'\.JPG$', caseSensitive: false),
        (match) => '.jpg',
      );

      try {
        final fallbackResponse = await http.head(Uri.parse(lowercaseUrl));
        if (fallbackResponse.statusCode == 200) {
          resolvedImageCache[url] = lowercaseUrl;
          return lowercaseUrl;
        }
      } catch (e) {
        print("Failed to check jpg version: $e");
      }

      // If both failed, try the original URL as a last resort
      resolvedImageCache[url] = url;
      return url;
    } catch (e) {
      print("Error resolving image URL: $e");
      // Return the original URL if all else fails
      return url;
    }
  }

  @override
  void dispose() {
    // Clear any resources when the widget is disposed
    resolvedImageCache.clear();
    super.dispose();
  }
}
