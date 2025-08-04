# 👥 Flutter Friend App

A beautiful Flutter app for making and managing friends, sending/accepting friend requests, chatting with accepted friends, and managing profiles — powered by Firebase.

---

## 📸 Features

✅ User register and login  
✅ Send & accept friend requests  
✅ See friends list and chat with them  
✅ Real-time private chat with accepted friends  
✅ Firebase authentication (email/password)  
✅ Cloud Firestore for user & chat data  
✅ Light Blue UI theme with images  
✅ Logout button in every screen  
✅ Responsive design for mobile & web

---

## 🛠️ Requirements

| Tool                     | Version (recommended) |
|--------------------------|------------------------|
| Flutter SDK              | `>=3.10.0`             |
| Dart SDK                 | `>=3.0.0`              |
| Firebase account         | Any                    |
| Android Studio / VS Code | Latest                 |
| Git                      | Any recent version     |
| Chrome                   | Latest (for web)       |

---

## 🚀 Setup Instructions

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/Manjushree296/flutter_friend_app.git
cd flutter_friend_app
# 👥 Flutter Friend App


3️⃣ Set Up Firebase
Go to Firebase Console

Create a new Firebase project

Add an app (Web, Android, etc.)

Enable Firebase services:

Authentication > Sign-in method > Email/Password

Firestore Database > Start in test mode

Storage (optional, for profile images)

Install CLI (once):

dart pub global activate flutterfire_cli
Configure Firebase:

flutterfire configure
This will auto-generate lib/firebase_options.dart.

4️⃣ Run the App
flutter run -d chrome 
