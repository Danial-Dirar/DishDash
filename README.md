Installation & Execution

1. Prerequisites
   Flutter SDK (stable channel)
   Dart (bundled with Flutter)
   Android Studio (Android SDK / emulator)
   Xcode (for iOS) – optional
   Git
   A Firebase project (console.firebase.google.com)
2. Clone
3. Check Environment
   Fix any reported issues (licenses, missing toolchains, etc.).

4. Configure Firebase (Recommended via FlutterFire CLI)
   Install FlutterFire CLI (once):

Login and configure:

Select your Firebase project, choose platforms (android, ios, web). This generates lib/firebase_options.dart.

If not using FlutterFire CLI manually:

Add google-services.json to app
Add GoogleService-Info.plist to Runner
For web, add config to index.html (inside firebase init script) 5. pubspec Dependencies (ensure these exist)
Get packages:

6. Initialize Firebase (main.dart)
   Ensure your main.dart has:

7. Platform Specific (Android)
   android/build.gradle (project level) should include:

android/app/build.gradle:

Set correct applicationId matching the one registered in Firebase.

8. iOS (if building)
   Open Runner.xcworkspace in Xcode once so it fetches pods.
   Run:
9. Location Permissions
   Android AndroidManifest.xml (example):

iOS Info.plist (example):

10. Run
    Select a device/emulator.

11. Testing Authentication
    Use Register User or Register Restaurant screens to create accounts (Firebase Authentication Email/Password must be enabled in Firebase Console).
    Sign in via Sign In screen.
12. Hot Reload / Restart
    Press r (hot reload) or R (hot restart) in terminal while running.
13. Build Release (Android example)
    For Play Store, set up signing (key.properties) and update build.gradle.

14. Troubleshooting
    If Firebase errors: confirm firebase_options.dart exists and initializeApp is called.
    If location fails: ensure emulator has location enabled or grant runtime permissions.
    If build fails on iOS: run pod repo update then pod install.
15. Optional: Web
    Enable web:
