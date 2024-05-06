import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
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

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  File? _image;
  String? _dishController;
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
    _getImage();
  }

  Future<void> _loadUserProfile() async {
    final GUser? userProfile = await _authService.getUserProfile();
    setState(() {
      user = userProfile;
    });
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
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
            _image != null
                ? Image.file(_image!)
                : Container(
                    color: Colors.grey[200],
                    height: 200,
                    child: Center(
                      child:
                          CircularProgressIndicator(), // Show a loading indicator while picking the image
                    ),
                  ),
            SizedBox(height: 10),
            CustomTextFormField(
              labelText: 'Dish',
              onChanged: (value) {
                setState(() {
                  _dishController = value;
                });
              },
            ),
            SizedBox(height: 10),
            CustomTextFormField(
              labelText: 'Restaurant Name',
              onChanged: (value) {
                setState(() {
                  _restaurantNameController = value;
                });
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
            SizedBox(height: 20),
            CustomButton(
              onPressed: () {
                // Save the post to Firestore or perform other actions
                Post newPost = Post(
                    userId: user!.uid,
                    username: user!.username,
                    displayName: user!.displayName,
                    imageUrl: '',
                    dish: _dishController!,
                    restaurantName: _restaurantNameController!,
                    latitude: _latitude,
                    longitude: _longitude,
                    location: _location,
                    isVegetarian: _isVeg,
                    isNonVegetarian: _isNonVeg,
                    isFree: _isFree,
                    timestamp: DateTime.timestamp());
                _postService.addPost(newPost, _image!);
                Navigator.of(context).pushReplacementNamed('/home');
              },
              text: 'Post',
            ),
          ],
        ),
      ),
    );
  }
}
