# 📱 Flutter Video & Audio Calling App

## 📝 Description

A real-time communication app built with Flutter that enables video and audio calling between users. The app features Firebase authentication (Email/Password and Google Sign-In), real-time user management with Firestore, and high-quality video/audio calls powered by Agora SDK. Users can view a list of registered users and instantly initiate calls with camera toggle, mic mute, and camera switching capabilities.

### 📸 Screenshots

<div align="center">
  <img width="200" height="600" alt="Audio calling" src="https://github.com/user-attachments/assets/adc1de6f-79fe-4661-b11a-d69a693571d0" />
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  <!-- 5 spaces gap -->
  <img width="200" height="600" alt="Video calling" src="https://github.com/user-attachments/assets/7cb30ced-d2de-4c1b-ba99-d325967adde9" />
</div>
---


## 🛠️ Technical Stack

### **Frontend**
- **Framework:** Flutter 3.0+
- **State Management:** Riverpod
- **Language:** Dart 3.0+

### **Backend Services**
- **Authentication:** Firebase Authentication
- **Database:** Cloud Firestore
- **Real-time Communication:** Agora RTC SDK
- **Local Storage:** SQLite (sqflite)

### **Key Dependencies**
```yaml
dependencies:
  flutter_riverpod: ^2.0.0
  firebase_core: ^2.0.0
  firebase_auth: ^4.0.0
  cloud_firestore: ^4.0.0
  google_sign_in: ^6.0.0
  agora_rtc_engine: ^6.0.0
  permission_handler: ^11.0.0
```

### **Architecture**
- **Pattern:** Service-based architecture
- **Services:**
  - `AuthService` - Handles user authentication
  - `AgoraService` - Manages RTC engine and call functionality
  - `DatabaseService` - Local data persistence

### **Features**
- Email/Password & Google authentication
- Real-time user list from Firestore
- Video calling with PiP mode
- Audio-only calling
- Camera/microphone controls
- Connection state monitoring

---

## 🚀 Quick Setup

```bash
# Clone and install
git clone <repo-url>
flutter pub get

# Configure Firebase
flutterfire configure

# Add Agora App ID in lib/services/agora_service.dart
static const String APP_ID = '<---APP_ID---->';

# Run
flutter run
```

---

## 📄 License

MIT License
