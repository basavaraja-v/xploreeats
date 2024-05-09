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
  bool _locationModifiedByUser = false;
  GUser? user;
  final AuthenticationService _authService = AuthenticationService();
  final PostService _postService = PostService();
  bool _isUploadLocationRestaurant = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _requestLocationPermission();
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
      maxDuration: const Duration(seconds: 90),
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
          'Selected video exceeds 90 seconds.',
          backgroundColor: Colors.red,
          textColor: Colors.white,
          duration: const Duration(seconds: 3),
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

        if (!_locationModifiedByUser) {
          // Update only if the location is not modified by the user
          _latitude = position.latitude;
          _longitude = position.longitude;
        }
      });
    } catch (e) {
      // Handle location fetch error
      print('Error fetching location: $e');
      // Additionally, handle potential geocoding errors
    }
  }

  Future<void> _geocodeAddress() async {
    try {
      List<Location> locations = await locationFromAddress(_location);
      setState(() {
        if (locations.isNotEmpty) {
          _latitude = locations[0].latitude;
          _longitude = locations[0].longitude;
        }
      });
    } catch (e) {
      // Handle geocoding error
      print('Error geocoding address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Add Post'),
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
            const SizedBox(height: 10),
            CustomTextFormField(
              labelText: 'Restaurant Name',
              onChanged: (value) {
                _restaurantNameController = value;
              },
            ),
            const SizedBox(height: 10),
            CustomCheckboxListTile(
              title: 'Upload from Restaurant Location',
              value: _isUploadLocationRestaurant,
              onChanged: (value) {
                setState(() {
                  _isUploadLocationRestaurant = value ?? false;
                });
              },
            ),
            if (!_isUploadLocationRestaurant)
              CustomTextFormField(
                labelText: 'Location',
                initialValue: _location,
                onChanged: (value) {
                  setState(() {
                    _location = value;
                    _locationModifiedByUser = true;
                  });
                  _geocodeAddress();
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
            _videoFile != null
                ? PostVideoPlayer(
                    key: UniqueKey(), videoSource: _videoFile!.path)
                : Container(
                    color: Colors.grey[100],
                    height: 100,
                    child: const Center(
                      child: Text(
                        'Please select a video',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _pickVideo(ImageSource.gallery);
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Pick from Gallery'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _pickVideo(ImageSource.camera);
                  },
                  icon: const Icon(Icons.videocam),
                  label: const Text('Record Video'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomButton(
              onPressed: () async {
                // Save the post to Firestore or perform other actions
                if (_videoFile != null) {
                  Post newPost = Post(
                    userId: user!.uid,
                    username: user!.username,
                    displayName: user!.displayName,
                    profileUrl: user!.photoURL,
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
                    const SnackBar(
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
