import 'package:flutter/material.dart';
import 'package:xploreeats/models/user.dart';
import 'package:xploreeats/services/authentication_service.dart';
import 'package:xploreeats/utils/app_constants.dart';
import 'package:xploreeats/widgets/custom_appbar.dart';
import 'package:xploreeats/screens/post/post_feed_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GUser? user;
  final AuthenticationService _authService = AuthenticationService();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final GUser? userProfile = await _authService.getUserProfile();
    setState(() {
      user = userProfile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'XploreEats',
      ),
      body: PostFeedScreen(),
      bottomNavigationBar: BottomAppBar(
        color: AppConstants.primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: AppConstants.iconColor),
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
            IconButton(
              icon:
                  Icon(Icons.video_file_rounded, color: AppConstants.iconColor),
              onPressed: () async {
                user == null
                    ? showCenterSnackBar(
                        context,
                        'Sign Up to post.',
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        duration: Duration(seconds: 3),
                      )
                    : Navigator.pushNamed(context, '/add_post');
              },
            ),
            IconButton(
              icon: user?.photoURL.isNotEmpty == true
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(user!.photoURL),
                    )
                  : Icon(Icons.person, color: AppConstants.iconColor),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
      ),
    );
  }

  void showCenterSnackBar(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 2),
  }) {
    final snackBar = SnackBar(
      content: Text(message,
          textAlign: TextAlign.center, style: TextStyle(color: textColor)),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
