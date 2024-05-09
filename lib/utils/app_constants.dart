// constants.dart

import 'package:flutter/material.dart';

class AppConstants {
  // Firestore collection names
  static const String usersCollection = 'users';

  // Field names in Firestore documents
  static const String displayNameField = 'displayName';
  static const String usernameField = 'username';
  static const String emailField = 'email';
  static const String photoURLField = 'photoURL';
  static const String isVegetarianField = 'isVegetarian';
  static const String isNonVegetarianField = 'isNonVegetarian';
  static const String locationField = 'location';

  // Default profile picture asset path
  static const String defaultProfilePicPath =
      'assets/images/default_profile_pic.png';

  // Snack bar messages
  static const String usernameExistsMessage =
      'Username already exists. Please choose a different one.';
  static const String profileUpdatedMessage = 'Profile updated successfully!';
  static const String locationPermissionDeniedMessage =
      'Location permission denied.';

  // Colors
  static const Color primaryColor = Color(0xFFFF5722);
  static const Color secondaryColor = Color.fromARGB(255, 252, 143, 110);
  static const Color errorColor = Colors.red;
  static const Color borderColor = Colors.grey;
  static const Color iconColor = Colors.white;

  // Fonts
  static const String primaryFontFamily = 'Roboto'; // Example font family

  // Text styles
  static const TextStyle headingTextStyle = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    color: Colors.black,
  );

  static const TextStyle appBarTitleTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle titleTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle subtitleTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: Colors.grey,
  );

  static const TextStyle labelTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.black,
  );
}
