🚀 Installation & Execution

Follow these steps to set up and run the DishDash app on your local machine:

1️⃣ Clone the Repository

git clone https://github.com/your-username/dishdash.git
cd dishdash

2️⃣ Install Flutter SDK

Make sure you have Flutter

flutter doctor

3️⃣ Install Dependencies

flutter pub get

4️⃣ Firebase Setup

1. Go to Firebase Console
2. Create or select your Firebase project (dishdash-3136e)
3. Enable:

Authentication → Email/Password

Cloud Firestore → Start in test mode (then secure later)

Storage → Enable + Update Rules

Download google-services.json and paste it in android/app/google-services.json

Make sure you have a valid firebase_options.dart file generated using:

flutterfire configure

5️⃣ Google Maps Setup

1. Get a Google Maps API key from Google Cloud Console
2. Enable Maps SDK for Android
3. Add your API key in: android/app/src/main/AndroidManifest.xml
   example:
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_API_KEY_HERE"/>

6️⃣ Run the App

7️⃣ Minimum Requirements

1. Android SDK 23+ (Android 6.0 or higher)
2. JDK 17+
3. Flutter 3.16 or newer
