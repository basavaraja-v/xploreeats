import 'package:flutter/material.dart';
import 'package:xploreeats/models/post.dart';
import 'package:xploreeats/models/user.dart';
import 'package:xploreeats/services/authentication_service.dart';
import 'package:xploreeats/services/permission_service.dart';
import 'package:xploreeats/services/post_service.dart';
import 'package:xploreeats/widgets/food_post_item.dart';
import 'package:geolocator/geolocator.dart';

class PostFeedScreen extends StatefulWidget {
  @override
  _PostFeedScreenState createState() => _PostFeedScreenState();
}

class _PostFeedScreenState extends State<PostFeedScreen> {
  late final PostService _postService;
  GUser? user;
  final AuthenticationService _authService = AuthenticationService();
  double _latitude = 0.0;
  double _longitude = 0.0;

  @override
  void initState() {
    super.initState();
    _postService = PostService();
    _requestLocationPermission();
    _loadUserProfile();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final GUser? userProfile = await _authService.getUserProfile();
    setState(() {
      user = userProfile;
    });
  }

  Future<void> _requestLocationPermission() async {
    if (await PermissionHandlerService.requestLocationPermission()) {
      _fetchLocation();
    }
  }

  Future<void> _fetchLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      // Handle location fetch error
      print('Error fetching location: $e');
      // Additionally, handle potential geocoding errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: user != null
          ? StreamBuilder<List<Post>>(
              stream: _postService.getNearestPostsStream(
                  _latitude, _longitude, user!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print('Error: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final List<Post> posts = snapshot.data!;

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return FoodPostItem(
                      post: posts[index],
                    );
                  },
                );
              },
            )
          : StreamBuilder<List<Post>>(
              stream: _postService.getNearestPostsStream(_latitude, _longitude),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print('Error: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final List<Post> posts = snapshot.data!;

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return FoodPostItem(
                      post: posts[index],
                    );
                  },
                );
              },
            ),
    );
  }
}
