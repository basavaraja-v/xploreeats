import 'package:flutter/material.dart';
import 'package:xploreeats/models/user.dart';
import 'package:xploreeats/services/authentication_service.dart';
import 'package:xploreeats/services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthenticationService _authService = AuthenticationService();
  final ProfileService _ProfileService = ProfileService();
  TextEditingController _displayNameController = TextEditingController();
  late final String uid;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final GUser? user = await _authService.getUserProfile();
    if (user != null) {
      _displayNameController.text = user.displayName;
      uid = user.uid;
    }
  }

  Future<void> _saveProfileChanges() async {
    setState(() {
      _isLoading = true;
    });
    final String displayName = _displayNameController.text.trim();
    final String photoURL = ''; // Implement photo URL logic if needed
    // await _ProfileService.updateUserProfile(uid, displayName, photoURL);
    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _displayNameController,
                    decoration: InputDecoration(labelText: 'Display Name'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveProfileChanges,
                    child: Text('Save Changes'),
                  ),
                ],
              ),
            ),
    );
  }
}
