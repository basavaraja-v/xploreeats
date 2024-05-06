import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:xploreeats/screens/profile/profile_screen.dart'; // Import profile screen
import 'package:xploreeats/services/authentication_service.dart';
import 'package:xploreeats/utils/app_constants.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthenticationService().getUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          // Check if user is already authenticated
          final isUserLoggedIn = snapshot.hasData;
          if (isUserLoggedIn) {
            // If user is already logged in, navigate to profile screen
            return ProfileScreen();
          } else {
            // If user is not logged in, display login screen
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome to XploreEats',
                      style: AppConstants.headingTextStyle,
                    ),
                    SizedBox(height: 50),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Call sign in with Google method
                        auth.User? firebaseUser =
                            await AuthenticationService().signInWithGoogle();
                        if (firebaseUser != null) {
                          Navigator.of(context).pushReplacementNamed('/home');
                        }
                      },
                      icon: Image.asset('assets/images/google_icon.png',
                          height: 24.0),
                      label: Text('Sign in with Google'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: AppConstants.primaryColor,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }
      },
    );
  }
}