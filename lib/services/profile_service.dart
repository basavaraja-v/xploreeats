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
        'isVegetarian': user.isVegetarian,
        'isNonVegetarian': user.isNonVegetarian,
      });
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  Future<void> followUser(String currentUserId, String userIdToFollow) async {
    try {
      final followingRef = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(userIdToFollow);
      await followingRef.set({'timestamp': FieldValue.serverTimestamp()});

      final followersRef = _firestore
          .collection('users')
          .doc(userIdToFollow)
          .collection('followers')
          .doc(currentUserId);
      await followersRef.set({'timestamp': FieldValue.serverTimestamp()});

      // Update the followingCount for the current user
      final currentUserRef = _firestore.collection('users').doc(currentUserId);
      await _firestore.runTransaction((transaction) async {
        final currentUserDoc = await transaction.get(currentUserRef);
        final currentFollowingCount =
            currentUserDoc.data()!['followingCount'] ?? 0;
        transaction.update(currentUserRef, {
          'followingCount': currentFollowingCount + 1,
        });
      });

      // Update the followersCount for the user being followed
      final userToFollowRef =
          _firestore.collection('users').doc(userIdToFollow);
      await _firestore.runTransaction((transaction) async {
        final userToFollowDoc = await transaction.get(userToFollowRef);
        final currentFollowersCount =
            userToFollowDoc.data()!['followersCount'] ?? 0;
        transaction.update(userToFollowRef, {
          'followersCount': currentFollowersCount + 1,
        });
      });
    } catch (e) {
      print('Error following user: $e');
    }
  }

  Future<void> unfollowUser(
      String currentUserId, String userIdToUnfollow) async {
    try {
      final followingRef = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('following')
          .doc(userIdToUnfollow);
      await followingRef.delete();

      final followersRef = _firestore
          .collection('users')
          .doc(userIdToUnfollow)
          .collection('followers')
          .doc(currentUserId);
      await followersRef.delete();

      // Update the followingCount for the current user
      final currentUserRef = _firestore.collection('users').doc(currentUserId);
      await _firestore.runTransaction((transaction) async {
        final currentUserDoc = await transaction.get(currentUserRef);
        final currentFollowingCount =
            currentUserDoc.data()!['followingCount'] ?? 0;
        transaction.update(currentUserRef, {
          'followingCount': currentFollowingCount - 1,
        });
      });

      // Update the followersCount for the user being unfollowed
      final userToUnfollowRef =
          _firestore.collection('users').doc(userIdToUnfollow);
      await _firestore.runTransaction((transaction) async {
        final userToUnfollowDoc = await transaction.get(userToUnfollowRef);
        final currentFollowersCount =
            userToUnfollowDoc.data()!['followersCount'] ?? 0;
        transaction.update(userToUnfollowRef, {
          'followersCount': currentFollowersCount - 1,
        });
      });
    } catch (e) {
      print('Error unfollowing user: $e');
    }
  }
}
