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
  
  // Cache for resolved image URLs to prevent unnecessary network requests
  Map<String, String> resolvedImageCache = {};

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
            // Clear the cache when we get new prediction images
            resolvedImageCache.clear();
            
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
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        elevation: 0,
        title: Text(
          'Bird Species Detection',
          style: TextStyle(
            color: Colors.black87, 
            fontSize: 22, 
            fontWeight: FontWeight.bold
          )
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background image
          Opacity(
            opacity: 0.5, // Increased opacity for better visibility
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/background_test.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // Blur effect when showing results
          if (resultMessage != null || detectedSpecies != null)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Reduced blur for better readability
              child: Container(
                color: Colors.black.withOpacity(0.1), // Lighter dim effect
              ),
            ),
            
          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                              padding: const EdgeInsets.all(16.0),
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                spreadRadius: 1,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                'Select Image Source',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Gallery Button
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: pickImage,
                                      icon: Icon(Icons.photo_library),
                                      label: Text('Gallery'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal[100],
                                        foregroundColor: Colors.black87,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  // Camera Button
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: captureImage,
                                      icon: Icon(Icons.camera_alt),
                                      label: Text('Camera'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal[100],
                                        foregroundColor: Colors.black87,
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 20),
                        
                        // Uploaded image section
                        if (imageUrl != null)
                          Card(
                            elevation: 5,
                            shadowColor: Colors.black26,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
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
                                      color: Colors.teal[800],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    height: 250,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        imageUrl!,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded / 
                                                    loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[200],
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
                                  SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: validateBird,
                                    icon: Icon(Icons.search),
                                    label: Text(
                                      'Validate Bird',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
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
                            padding: const EdgeInsets.only(top: 20.0),
                            child: ElevatedButton.icon(
                              onPressed: classifyBird,
                              icon: Icon(Icons.category),
                              label: Text(
                                'Classify Bird Species',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber[700],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          
                        // Image selection section
                        if (predictionImages.isNotEmpty)
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 20),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.collections, color: Colors.teal),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Select the most similar images',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.teal[50],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${selectedImages.length}/3',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 1,
                                  ),
                                  itemCount: predictionImages.length,
                                  itemBuilder: (context, index) {
                                    final url = predictionImages[index];
                                    final isSelected = selectedImages.contains(url);
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            selectedImages.remove(url);
                                          } else if (selectedImages.length < 3) {
                                            selectedImages.add(url);
                                          }
                                          showConfirmButton = selectedImages.isNotEmpty;
                                        });
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: isSelected ? Colors.blue : Colors.grey[300]!,
                                                width: isSelected ? 3 : 1,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: isSelected ? [
                                                BoxShadow(
                                                  color: Colors.blue.withOpacity(0.3),
                                                  blurRadius: 8,
                                                  spreadRadius: 1,
                                                ),
                                              ] : null,
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: getCachedImage(url),
                                            ),
                                          ),
                                          if (isSelected)
                                            Positioned(
                                              right: 5,
                                              top: 5,
                                              child: Container(
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                if (showConfirmButton)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child:
                                    Column(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            icon: const Icon(Icons.check_circle),
                                            label: Text(
                                              "Confirm Selection",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            onPressed: sendSelectedImagesForFinalClassification,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green[600],
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            icon: const Icon(Icons.not_interested),
                                            label: Text(
                                              "None of these",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                resultMessage = "Hmm, this bird doesn't match any species in our system. We're constantly expanding—stay tuned!";
                                                selectedImages.clear();
                                                showConfirmButton = false;
                                              });
                                            },
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.red[600],
                                              side: BorderSide(color: Colors.red[300]!),
                                              padding: EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ),
                              ],
                            ),
                          ),

                        // Result message
                        if (resultMessage != null)
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 16),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  resultMessage!.contains('detected!') ? Icons.check_circle : Icons.info,
                                  color: resultMessage!.contains('detected!') ? Colors.green : Colors.blue,
                                  size: 24,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    resultMessage!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                        // Prediction results
                        if (initialPrediction != null || detectedSpecies != null)
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 16),
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                if (initialPrediction != null)
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.auto_awesome,
                                            color: Colors.amber,
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Initial Prediction',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.amber[50],
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.amber[100]!),
                                          ),
                                          child: Text(
                                            initialPrediction!,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber[800],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                if (detectedSpecies != null) ...[

                                  SizedBox(height: initialPrediction != null ? 20 : 0),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Final Prediction',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.green[100]!),
                                      ),
                                      child: Text(
                                        detectedSpecies!,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[800],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  if (finalPredictionImage != null)
                                    Container(
                                      margin: EdgeInsets.only(top: 16),
                                      height: 220,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.asset(
                                          finalPredictionImage!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                ],
                              ]
                              ),
                          ),
                        
                        // Bird info button
                        if (s3ImageUrl != null && detectedSpecies != null && !detectedSpecies!.contains(','))
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(top: 20),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal[600],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              onPressed: () {
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
                              },
                              icon: Icon(Icons.info_outline, size: 24),
                              label: Text(
                                "View Bird Details",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                     ],
                    ]
                    ),
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