# 🐦 Mobile Application for Classification of Indian Bird Species  
🌿 **A Flutter-based mobile application for classifying Indian bird species in their natural habitats, leveraging cutting-edge machine learning models.**

---

## ✨ Features  
- 🐦 **Bird Classification**: Identifies bird species using a ResNet-based classification model with 93% accuracy.  
- 🎯 **Bird Detection**: Detects birds in images using YOLOv8 for precise localization.  
- 📱 **User-Friendly Interface**: Intuitive UI with a carousel slider, search functionality, and detailed bird profiles.  
- 📂 **Contribute to Dataset**: Allows users to upload bird images to expand the dataset and improve the classification model.  

---

## 🛠️ Technology Stack  

### **Frontend**  
- **Flutter**: For creating a cross-platform mobile application with a sleek and responsive design.  

### **Backend**  
- **Node.js**: For managing API communication and storing data efficiently.  

### **Machine Learning**  
- **ResNet**: For accurate bird species classification.  
- **YOLOv8**: For bird detection and localization in images.  

### **Dataset**  
- **Size**: 6952 images of Indian bird species.  
- **Preprocessing**: Applied augmentation, resizing, to improve model robustness.  

---

## 🧭 How It Works  
1. **Upload an image of a bird.**  
2. The app detects if a bird is present using **YOLOv8**.  
3. If detected, **EfficientNetB7** classifies the bird species.  
4. View detailed information, including habitat, behavior, and images of the bird.  

---

## Architecture
![image](https://github.com/user-attachments/assets/ec661e0c-a7b6-4439-b78c-cf4b51f3fd91)


## 📸 Screenshots  

### **Home Screen**

<img width="299" height="610" alt="image" src="https://github.com/user-attachments/assets/adba6fa0-f326-4516-986a-6c8bd2fa3bfd" />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<img width="298" height="610" alt="image" src="https://github.com/user-attachments/assets/883cf245-69c0-4d4a-bb2e-b392ecb8de21" />




### **Validation && Classification Screen**

<img width="240" height="560" alt="image" src="https://github.com/user-attachments/assets/9dafac66-c9da-4f1c-a457-96f8d50155ce" />
&nbsp;&nbsp;&nbsp;
<img width="240" height="560" alt="image" src="https://github.com/user-attachments/assets/f341b62f-db1e-4a91-8947-f6e041dcddad" />
&nbsp;&nbsp;&nbsp;
<img width="240" height="560" alt="image" src="https://github.com/user-attachments/assets/c68a0db7-c5d6-4c51-9d92-bd872a7c8d3a" />
&nbsp;&nbsp;&nbsp;
<img width="240" height="560" alt="image" src="https://github.com/user-attachments/assets/9bffa0a4-3cb3-40c6-813d-297b8df9a487" />



---

## 🚀 Installation & Deployment

### **Prerequisites**
- **Flutter SDK**: Version 3.5.4 or higher
- **Android SDK**: For Android development and APK building
- **Node.js**: Backend server (if running locally)
- **Git**: For cloning the repository

### **1. Clone the Repository**
```bash
git clone https://github.com/Nikhildev0904/Birdz---Bird-Detection-Application.git
cd Birdz---Bird-Detection-Application
```

### **2. Install Dependencies**
```bash
# Install Flutter dependencies
flutter pub get

# Verify Flutter installation
flutter doctor
```

### **3. Configuration Required**

#### **⚠️ Important: Base URL Configuration**
The app connects to a backend server for bird classification. You **must** update the base URL:

**File**: `lib/screens/classify_screen.dart` (Line 20)
```dart
const String BaseUrl = 'https://your-server-url.com'; // Change this to your server
```

**Alternative URL** (Line 21 - commented):
```dart
const String BaseUrl = 'https://your-ngrok-url.com'; // For local development
```

#### **Google Maps API Key**
Update the Google Maps API key for location features:

**File**: `android/app/src/main/AndroidManifest.xml` (Line 45)
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY" />
```

#### **eBird API Key**
For bird sighting data (optional):

**File**: `lib/BirdWatchExplorer/BirdWatchExplorer.dart` (Line 472)
```dart
String apiKey = "your-ebird-api-key";
```

### **4. Run the Application**

#### **Development Mode**
```bash
# Run in debug mode
flutter run

# Run on specific device
flutter run -d chrome          # Web
flutter run -d windows         # Windows
flutter run -d android         # Android (device/emulator)
```

#### **Build APK for Android**
```bash
# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Build app bundle (recommended for Play Store)
flutter build appbundle --release
```

#### **Build for Other Platforms**
```bash
# Build for iOS
flutter build ios --release

# Build for Web
flutter build web

# Build for Windows
flutter build windows

# Build for Linux
flutter build linux
```

### **5. APK Installation**

#### **Install APK on Android Device**
1. Enable "Install from unknown sources" in device settings
2. Transfer the APK file to your device
3. Locate and tap the APK file to install

#### **Install via ADB (for developers)**
```bash
# Install debug APK
adb install build/app/outputs/flutter-apk/app-debug.apk

# Install release APK
adb install build/app/outputs/flutter-apk/app-release.apk
```

### **6. Troubleshooting**

#### **Common Issues**
- **Gradle errors**: Run `flutter clean` then `flutter pub get`
- **Missing assets**: Ensure all assets in `pubspec.yaml` exist in the `assets/` folder
- **Network errors**: Verify base URL and internet connectivity
- **Permission errors**: Check AndroidManifest.xml for required permissions

#### **Required Permissions**
The app requires these Android permissions (already configured):
- `INTERNET` - For API calls
- `ACCESS_FINE_LOCATION` - For location services
- `ACCESS_COARSE_LOCATION` - For approximate location
- `CAMERA` - For taking photos
- `READ_EXTERNAL_STORAGE` - For accessing gallery

#### **Asset Verification**
Ensure these assets exist in the `assets/` folder:
- Bird images (JPG format)
- Logo files
- Animation files (Lottie JSON)
- Background images

### **7. Backend Setup (Optional)**
If you want to run your own classification backend:

1. Set up a Node.js server with endpoints:
   - `/upload` - Image upload
   - `/validate/` - Bird detection
   - `/classify/` - Species classification
   - `/get-probabilities/` - Prediction probabilities
   - `/get-adjusted-predictions/` - Final classification

2. Update the `BaseUrl` in `classify_screen.dart` to point to your server

### **8. Production Deployment**

#### **Google Play Store**
1. Build release app bundle: `flutter build appbundle --release`
2. Create a Google Play Console account
3. Upload the AAB file
4. Complete store listing and release process

