import 'package:flutter/material.dart';
import 'package:xploreeats/models/user.dart';
import 'package:xploreeats/services/authentication_service.dart';
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
      body: PostFeedScreen(), // Replace Center widget with PostFeedScreen
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
            IconButton(
              icon: Icon(Icons.add_a_photo),
              onPressed: () async {
                Navigator.pushNamed(context, '/add_post');
              },
            ),
            IconButton(
              icon: user?.photoURL.isNotEmpty == true
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(user!.photoURL),
                    )
                  : Icon(Icons.person),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
      ),
    );
  }
}
