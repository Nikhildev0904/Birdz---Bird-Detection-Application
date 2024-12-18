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
- **YOLOv11**: For bird detection and localization in images.  

### **Dataset**  
- **Size**: 6952 images of Indian bird species.  
- **Preprocessing**: Applied augmentation, resizing, to improve model robustness.  

---

## 🧭 How It Works  
1. **Upload an image of a bird.**  
2. The app detects if a bird is present using **YOLOv11**.  
3. If detected, **EfficientNetB7** classifies the bird species.  
4. View detailed information, including habitat, behavior, and images of the bird.  

---

## Architecture
![image](https://github.com/user-attachments/assets/ec661e0c-a7b6-4439-b78c-cf4b51f3fd91)


## 📸 Screenshots  

### **Home Screen**  

![image](https://github.com/user-attachments/assets/aa1237ac-bcd0-47e3-86ad-ff0022bbfd4f).  ![image](https://github.com/user-attachments/assets/3d414826-4e24-40e1-ad92-dbf85cdc0357)
    ![image](https://github.com/user-attachments/assets/36aed81d-cd40-467b-b26a-1ec957f1d974)  




### **Validation && Classification Screen**

![image](https://github.com/user-attachments/assets/2c9a4d62-6857-496c-a707-c2cee2941653)
![image](https://github.com/user-attachments/assets/eac41a0d-4667-417d-81a2-07966c753c60)

---

## 🚀 Installation  

### **Prerequisites**  
- Flutter SDK installed.  
- Node.js installed for the backend.  
