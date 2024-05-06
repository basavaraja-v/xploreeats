import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xploreeats/models/user.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkUsernameExists(String username, String uid) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: username)
              .limit(1)
              .get();

      // Check if any documents with the same username exist
      if (snapshot.docs.isNotEmpty) {
        // Check if the document ID (user ID) is not equal to the user's ID
        final existingUserId = snapshot.docs.first.id;
        return existingUserId != uid;
      }
      // If no documents with the same username exist, return false
      return false;
    } catch (e) {
      print('Error checking username existence: $e');
      return false;
    }
  }

  Future<void> updateUserProfile(GUser user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'displayName': user.displayName,
        'username': user.username,
        'photoURL': user.photoURL,
        'location': user.location,
        'isVegetarian': user.isVegetarian,
        'isNonVegetarian': user.isNonVegetarian,
        'latitude': user.latitude,
        'longitude': user.longitude,
      });
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }
}
