import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:xploreeats/firebase_options.dart';
import 'package:xploreeats/screens/auth/login_screen.dart';
import 'package:xploreeats/screens/home_screen.dart';
import 'package:xploreeats/screens/post/add_post_screen.dart';
import 'package:xploreeats/screens/profile/profile_screen.dart';
import 'package:xploreeats/utils/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(XploreEatsApp());
}

class XploreEatsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XploreEats',
      theme: ThemeData(
        primaryColor: AppConstants.primaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/login': (context) => LoginScreen(),
        '/add_post': (context) => AddPostScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
