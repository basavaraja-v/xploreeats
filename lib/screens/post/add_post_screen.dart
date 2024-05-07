import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:xploreeats/models/post.dart';
import 'package:xploreeats/models/user.dart';
import 'package:xploreeats/services/authentication_service.dart';
import 'package:xploreeats/services/permission_service.dart';
import 'package:xploreeats/widgets/custom_appbar.dart';
import 'package:xploreeats/widgets/custom_button.dart';
import 'package:xploreeats/widgets/custom_checkbox.dart';
import 'package:xploreeats/widgets/custom_textformfield.dart';
import 'package:xploreeats/services/post_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:xploreeats/widgets/postvideo_player.dart';

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  File? _videoFile;
  String? _captionController;
  String? _restaurantNameController;
  String _location = '';
  double _latitude = 0.0;
  double _longitude = 0.0;
  bool _isVeg = false;
  bool _isNonVeg = false;
  bool _isFree = false;
  GUser? user;
  final AuthenticationService _authService = AuthenticationService();
  final PostService _postService = PostService();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _requestLocationPermission();
    _pickVideo(ImageSource.gallery);
  }

  Future<void> _loadUserProfile() async {
    final GUser? userProfile = await _authService.getUserProfile();
    setState(() {
      user = userProfile;
    });
  }

  Future<void> _pickVideo(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(
      source: source,
      maxDuration: Duration(seconds: 90),
    );

    if (pickedFile != null) {
      final videoFile = File(pickedFile.path);
      final videoLength = await _getVideoDuration(videoFile);
      if (videoLength <= 90) {
        setState(() {
          _videoFile = videoFile;
        });
      } else {
        showCenterSnackBar(
          context,
          'Selected video exceeds 30 seconds.',
          backgroundColor: Colors.red,
          textColor: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    }
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

  Future<int> _getVideoDuration(File videoFile) async {
    final videoController = VideoPlayerController.file(videoFile);
    await videoController.initialize();
    final duration = videoController.value.duration;
    await videoController.dispose();
    return duration.inSeconds;
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
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      setState(() {
        // Extract relevant details from the first placemark
        String street = placemarks[0].street ?? '';
        String locality = placemarks[0].locality ?? '';
        String subLocality = placemarks[0].subLocality ?? '';

        // Combine the details into a formatted address
        _location = '$street, $subLocality, $locality';
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
      appBar: CustomAppBar(title: 'Add Post'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            CustomTextFormField(
              labelText: 'Caption',
              onChanged: (value) {
                _captionController = value;
              },
            ),
            SizedBox(height: 10),
            CustomTextFormField(
              labelText: 'Restaurant Name',
              onChanged: (value) {
                _restaurantNameController = value;
              },
            ),
            CustomCheckboxListTile(
              title: 'Vegetarian',
              value: _isVeg,
              onChanged: (value) {
                setState(() {
                  _isVeg = value ?? false;
                });
              },
            ),
            CustomCheckboxListTile(
              title: 'Non-Vegetarian',
              value: _isNonVeg,
              onChanged: (value) {
                setState(() {
                  _isNonVeg = value!;
                });
              },
            ),
            CustomCheckboxListTile(
              title: 'Free',
              value: _isFree,
              onChanged: (value) {
                setState(() {
                  _isFree = value!;
                });
              },
            ),
            _videoFile != null
                ? PostVideoPlayer(
                    key: UniqueKey(), videoSource: _videoFile!.path)
                : Container(
                    color: Colors.grey[200],
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
            SizedBox(height: 20),
            CustomButton(
              onPressed: () async {
                // Save the post to Firestore or perform other actions
                if (_videoFile != null) {
                  Post newPost = Post(
                    userId: user!.uid,
                    username: user!.username,
                    displayName: user!.displayName,
                    videoUrl: '',
                    caption: _captionController!,
                    restaurantName: _restaurantNameController!,
                    latitude: _latitude,
                    longitude: _longitude,
                    location: _location,
                    isVegetarian: _isVeg,
                    isNonVegetarian: _isNonVeg,
                    isFree: _isFree,
                    timestamp: DateTime.now(),
                  );
                  _postService.addPost(newPost, _videoFile!);
                  Navigator.of(context).pushReplacementNamed('/home');
                } else {
                  // Show a message to the user if no video is selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select a video to post.'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              text: 'Post',
            ),
          ],
        ),
      ),
    );
  }
}
