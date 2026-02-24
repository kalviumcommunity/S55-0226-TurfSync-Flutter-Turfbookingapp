# Firebase Setup Guide for TurfSync

Follow these steps to connect the TurfSync Flutter app to your own Firebase project.

---

## 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Add project** → name it (e.g. `turfsync`)
3. Enable Google Analytics (optional) → **Create project**

---

## 2. Register Your App

### Android

1. In the Firebase console, click **Add app → Android**
2. Package name: `com.example.turfsync` (or your custom one)
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`
5. Ensure `android/build.gradle` has the Google services plugin:

```groovy
// android/build.gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

6. Apply the plugin in `android/app/build.gradle`:

```groovy
apply plugin: 'com.google.gms.google-services'
```

### iOS

1. Click **Add app → iOS**
2. Bundle ID: `com.example.turfsync`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist` using Xcode
5. No CocoaPods changes needed (FlutterFire handles it)

---

## 3. Enable Authentication

1. Firebase Console → **Authentication → Sign-in method**
2. Enable **Email/Password** provider
3. (Optional) Enable **Google** sign-in if you extend auth later

---

## 4. Set Up Cloud Firestore

1. Firebase Console → **Firestore Database → Create database**
2. Choose **Start in test mode** initially (we'll deploy rules next)
3. Select a region close to your users

### Deploy Security Rules

```bash
# Install Firebase CLI if not installed
npm install -g firebase-tools

# Login
firebase login

# From the project root (where firebase.json is)
firebase deploy --only firestore:rules
```

The rules file (`firestore.rules`) is already included in this project.

---

## 5. Firestore Collections (auto-created)

The app auto-creates these collections on first use:

| Collection     | Purpose                                           |
| -------------- | ------------------------------------------------- |
| `users`        | User profiles (uid, email, role, fcmToken, etc.)  |
| `turfs`        | Turf data (name, location, hours, pricing)        |
| `bookings`     | Booking records with status tracking              |
| `bookedSlots`  | Composite-key docs for double-booking prevention  |
| `sessions`     | Practice sessions created by coaches              |

### Recommended Indexes

Create these composite indexes in the Firestore console (or let the app auto-prompt you):

```
bookings: userId ASC, createdAt DESC
bookings: status ASC, createdAt DESC
sessions: date ASC, createdAt DESC
bookedSlots: turfId ASC, date ASC
```

---

## 6. Enable Cloud Messaging (FCM)

1. Firebase Console → **Cloud Messaging**
2. For Android: no extra setup needed (handled by `google-services.json`)
3. For iOS:
   - Upload your APNs key/certificate in Firebase Console → Cloud Messaging → iOS
   - Add push notification capability in Xcode

---

## 7. FlutterFire CLI (Alternative Setup)

Instead of manual setup, you can use the FlutterFire CLI:

```bash
# Install
dart pub global activate flutterfire_cli

# Configure (generates firebase_options.dart)
flutterfire configure
```

Then update `main.dart`:

```dart
import 'firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

---

## 8. Run the App

```bash
# Get dependencies
flutter pub get

# Run on connected device / emulator
flutter run
```

---

## 9. Create Your First Admin

1. Register through the app, selecting the **Admin** role
2. The first admin can then manage turfs and approve bookings
3. Coaches create practice sessions; Players book slots & join sessions

---

## Troubleshooting

| Issue                        | Fix                                                          |
| ---------------------------- | ------------------------------------------------------------ |
| `No Firebase App`            | Ensure `google-services.json` / `GoogleService-Info.plist` is placed correctly |
| `PERMISSION_DENIED`          | Deploy Firestore rules: `firebase deploy --only firestore:rules` |
| `MissingPluginException`     | Run `flutter clean && flutter pub get` then rebuild           |
| Double-booking still happens | Ensure `bookedSlots` collection is not bypassed; check rules  |
| FCM not working on iOS       | Upload APNs key in Firebase Console and enable push capability |

---

## Architecture Overview

```
lib/
├── core/           # Constants, enums, utils, errors
├── models/         # Data models (User, Turf, Booking, Session, TimeSlot)
├── services/       # Firebase service layer (Auth, Firestore, FCM)
├── repositories/   # Repository abstractions over services
├── providers/      # ChangeNotifier state management (MVVM)
├── widgets/        # Reusable UI components
├── screens/        # Feature screens (Auth, Dashboard, Booking, etc.)
├── main.dart       # Entry point (Firebase init, MultiProvider)
└── app.dart        # MaterialApp with auth gate routing
```

**Double-Booking Prevention**: Uses Firestore transactions with a `bookedSlots`
collection. Each document has a composite key (`turfId_date_slotKey`). The
transaction atomically checks if the document exists before creating it,
preventing two users from booking the same slot simultaneously.
