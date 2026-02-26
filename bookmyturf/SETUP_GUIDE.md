# 🏟️ BookMyTurf – Complete Setup Guide

> Follow these steps **in order**. Each step takes ~2–5 min. Total time: ~30–45 min.

---

## ✅ WHAT YOU NEED TO DO (checklist)

- [ ] Install Flutter SDK
- [ ] Install Android Studio + emulator
- [ ] Create Firebase project
- [ ] Run FlutterFire configure
- [ ] Run the app

---

## STEP 1 — Install Flutter SDK

1. Go to: https://docs.flutter.dev/get-started/install
2. Select your OS (Windows / Mac / Linux)
3. Download Flutter SDK and extract it
4. Add Flutter to your PATH (follow instructions on that page)
5. Run in terminal: `flutter doctor`
   - Fix any issues it lists (especially Android SDK)

---

## STEP 2 — Install Android Studio

1. Download from: https://developer.android.com/studio
2. Install it and open it
3. Go to **More Actions → Virtual Device Manager**
4. Create a virtual device (Pixel 6, Android 13 recommended)
5. Start the emulator

---

## STEP 3 — Create Firebase Project

1. Go to: https://console.firebase.google.com
2. Click **"Add Project"**
3. Name it: `BookMyTurf`
4. Disable Google Analytics (optional)
5. Click **Create Project**

### Enable Authentication:
- In Firebase Console → **Authentication → Get Started**
- Enable **Email/Password** sign-in method

### Enable Firestore:
- In Firebase Console → **Firestore Database → Create Database**
- Choose **"Start in test mode"** (we'll update rules later)
- Select a region (e.g., `asia-south1` for India)

### Set Security Rules:
- In Firestore → **Rules tab**
- Copy-paste the contents of `firestore.rules` from this project
- Click **Publish**

---

## STEP 4 — Connect Flutter to Firebase

In your terminal, from the project folder:

```bash
# Install the FlutterFire CLI
dart pub global activate flutterfire_cli

# Connect to your Firebase project
flutterfire configure
```

- Select your `BookMyTurf` Firebase project
- Select Android (and iOS if needed)
- This auto-fills `lib/firebase_options.dart` ✅

---

## STEP 5 — Run the App

```bash
# From the project directory:
flutter pub get
flutter run
```

The app will:
1. Show splash screen
2. Go to Login (first time)
3. Let you sign up → creates account in Firebase Auth
4. Auto-seed 3 turf venues into Firestore
5. Let you browse turfs, check availability, and book slots

---

## APP FEATURES OVERVIEW

| Feature | What it does |
|--------|-------------|
| **Sign Up / Login** | Firebase Auth – email + password |
| **Browse Turfs** | Search and filter by sport |
| **Availability Calendar** | Shows which slots are booked (real-time) |
| **Book a Slot** | Date + time selection; auto-checks for conflicts |
| **Double-booking prevention** | Server-side check before confirming |
| **Community Schedule** | All upcoming bookings visible to everyone |
| **My Bookings** | Personal booking history + cancel option |
| **Real-time sync** | Firestore listeners update UI instantly |

---

## PROJECT STRUCTURE

```
lib/
├── main.dart              # App entry point
├── theme.dart             # Colors, typography
├── firebase_options.dart  # Auto-filled by FlutterFire CLI
├── models/
│   └── booking_model.dart # Turf + TurfBooking data models
├── services/
│   ├── auth_service.dart  # Firebase Auth wrapper
│   └── booking_service.dart # Firestore booking logic
├── screens/
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── home/
│   │   ├── home_screen.dart      # Bottom nav container
│   │   ├── dashboard_tab.dart    # Home feed
│   │   ├── turfs_tab.dart        # Browse turfs
│   │   ├── schedule_tab.dart     # Calendar view
│   │   ├── my_bookings_tab.dart  # My bookings
│   │   └── profile_tab.dart      # User profile
│   └── booking/
│       ├── turf_detail_screen.dart
│       └── booking_form_screen.dart  # Core booking flow
└── widgets/
    ├── booking_card.dart       # Reusable booking item
    └── custom_text_field.dart  # Styled input
```

---

## FIRESTORE DATA STRUCTURE

```
users/
  {uid}/
    name: "Rahul Sharma"
    email: "rahul@example.com"
    teamName: "FC Warriors"
    createdAt: timestamp

turfs/
  {turfId}/
    name: "GreenField Sports Arena"
    location: "Koregaon Park, Pune"
    sports: ["Football", "Cricket"]
    pricePerHour: 800
    rating: 4.7

bookings/
  {bookingId}/
    turfId: "..."
    turfName: "GreenField Sports Arena"
    userId: "..."
    userName: "Rahul Sharma"
    teamName: "FC Warriors"
    sport: "Football"
    date: timestamp
    timeSlot: "6:00 AM – 7:00 AM"
    startHour: 6
    endHour: 7
    status: "confirmed" | "cancelled"
    notes: "Practice session"
    createdAt: timestamp
```

---

## TROUBLESHOOTING

**`flutter: No Firebase App '[DEFAULT]' has been created`**
→ Run `flutterfire configure` again and make sure `firebase_options.dart` is not the placeholder version.

**`PERMISSION_DENIED` from Firestore**
→ Check your Firestore rules. During dev, you can temporarily set rules to allow all (not for production).

**Emulator not showing**
→ Run `flutter devices` to see available devices.

**Build fails with package errors**
→ Run `flutter pub get` then `flutter clean && flutter run`

---

Built with ❤️ for the BookMyTurf sprint project.
