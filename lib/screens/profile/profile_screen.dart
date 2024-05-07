import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:xploreeats/models/user.dart';
import 'package:xploreeats/services/authentication_service.dart';
import 'package:xploreeats/services/profile_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:xploreeats/services/permission_service.dart';
import 'package:xploreeats/utils/app_constants.dart';
import 'package:xploreeats/widgets/custom_checkbox.dart';
import 'package:xploreeats/widgets/custom_textformfield.dart';
import 'package:xploreeats/widgets/custom_button.dart';
import 'package:xploreeats/utils/numberformat.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthenticationService _authService = AuthenticationService();
  final ProfileService _profileService = ProfileService();
  GUser? _user;
  String? _name;
  String? _username;
  bool _isVegetarian = false;
  bool _isNonVegetarian = false;
  bool _isLoading = false;
  double _postsCount = 0;
  double _followersCount = 0;
  double _followingCount = 0;

  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  Future<void> _checkUserLoggedIn() async {
    final GUser? user = await _authService.getUserProfile();
    if (user == null) {
      // User is not logged in, navigate to login page
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      setState(() {
        _user = user;
        _name = user.displayName;
        _username = user.username;
        _isVegetarian = user.isVegetarian;
        _isNonVegetarian = user.isNonVegetarian;
        _postsCount = user.postsCount!;
        _followersCount = user.followersCount!;
        _followingCount = user.followingCount!;
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    // Check if the username already exists
    bool usernameExists =
        await _profileService.checkUsernameExists(_username!, _user!.uid);
    if (usernameExists) {
      // Username already exists, display message to user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Username already exists. Please choose a different one.'),
      ));
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Update the user profile locally with the new information
      setState(() {
        _user = GUser(
          uid: _user!.uid,
          displayName: _name ?? _user!.displayName,
          username: _username ?? _user!.username,
          email: _user!.email,
          photoURL: _user!.photoURL,
          isVegetarian: _isVegetarian,
          isNonVegetarian: _isNonVegetarian,
        );
      });

      await _profileService.updateUserProfile(_user!);

      // Show a snackbar to inform the user about the successful update
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile updated successfully!'),
      ));
    } catch (e) {
      print('Error updating user profile: $e');
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Profile',
            style: AppConstants.titleTextStyle,
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: _user != null
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _user!.photoURL.isNotEmpty
                            ? NetworkImage(_user!.photoURL)
                            : AssetImage(
                                    'assets/images/default_profile_pic.png')
                                as ImageProvider,
                      ),
                      SizedBox(height: 20),
                      Text(
                        _user!.displayName,
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Posts',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                getFormattedCount(_postsCount),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Followers',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                getFormattedCount(_followersCount),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Following',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                getFormattedCount(_followingCount),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      CustomTextFormField(
                        initialValue: _user!.username,
                        labelText: 'Username',
                        onChanged: (value) {
                          setState(() {
                            _username = value;
                          });
                        },
                      ),
                      CustomCheckboxListTile(
                        title: 'Vegetarian',
                        value: _isVegetarian,
                        onChanged: (value) {
                          setState(() {
                            _isVegetarian = value ?? false;
                          });
                        },
                      ),
                      CustomCheckboxListTile(
                        title: 'Non-Vegetarian',
                        value: _isNonVegetarian,
                        onChanged: (value) {
                          setState(() {
                            _isNonVegetarian = value!;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      _isLoading
                          ? CircularProgressIndicator()
                          : CustomButton(
                              onPressed: _updateProfile,
                              text: 'Update Profile',
                            ),
                      SizedBox(height: 20),
                      CustomButton(
                        onPressed: () async {
                          await _authService.signOut();
                          Navigator.of(context).pushReplacementNamed('/home');
                        },
                        text: 'Sign Out',
                      ),
                    ],
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ));
  }
}
