import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:xploreeats/models/post.dart';
import 'dart:math' show atan2, cos, pi, sin, sqrt;
import 'package:xploreeats/models/user.dart';

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}

class PostService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> _uploadVideo(File videoFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference reference =
          _storage.ref().child('postvideos').child(fileName);
      UploadTask uploadTask = reference.putFile(videoFile);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading video: $e');
      return '';
    }
  }

  Future<void> addPost(Post newPost, File videoFile) async {
    try {
      // Upload video and get the download URL
      String videoUrl = await _uploadVideo(videoFile);

      // Add the video URL to the newPost
      newPost.videoUrl = videoUrl;

      // Convert newPost to a map
      Map<String, dynamic> postData = newPost.toMap();

      // Save the newPost to the Firestore collection
      await _db.collection('posts').add(postData);
      print('Post created successfully!');
    } catch (e) {
      print('Error creating post: $e');
    }
  }

  Stream<List<Post>> getNearestPostsStream(double latitude, double longitude,
      [GUser? user]) {
    LatLng userLocation = LatLng(latitude, longitude);

    // Construct the base query
    Query baseQuery = _db.collection('posts');

    // Filter based on user preferences and post properties
    if (user != null) {
      bool isVegetarian = user.isVegetarian;
      bool isNonVegetarian = user.isNonVegetarian;

      // Filter posts based on user preferences and post properties
      if (isVegetarian && isNonVegetarian) {
      } else {
        if (isVegetarian) {
          baseQuery = baseQuery.where('isVegetarian', isEqualTo: true);
        }
        if (isNonVegetarian) {
          baseQuery = baseQuery.where('isNonVegetarian', isEqualTo: true);
        }
      }
    }

    // Sort posts by timestamp in descending order to get most recent posts first
    baseQuery = baseQuery.orderBy('timestamp', descending: true);

    return baseQuery.snapshots().map((snapshot) {
      final List<Post> posts = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Post.fromMap(data, doc.id, user);
      }).toList();

      // Sort filtered posts based on distance from user's location
      posts.sort((a, b) {
        final double distanceA = _calculateDistance(a.latitude, a.longitude,
            userLocation.latitude, userLocation.longitude);
        final double distanceB = _calculateDistance(b.latitude, b.longitude,
            userLocation.latitude, userLocation.longitude);
        return distanceA.compareTo(distanceB);
      });

      return posts;
    });
  }

  // Calculate distance between two points using Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // in kilometers

    final double latDistance = (lat2 - lat1) * (pi / 180);
    final double lonDistance = (lon2 - lon1) * (pi / 180);
    final double a = sin(latDistance / 2) * sin(latDistance / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(lonDistance / 2) *
            sin(lonDistance / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance;
  }

  Future<void> updateLoveStatus(Post post) async {
    if (post.userId != post.currentUserId) {
      bool isLoved = !post.isLikedByCurrentUser!;
      DocumentReference postRef = _db.collection('posts').doc(post.docId);
      if (isLoved) {
        await postRef.update({
          'likeCount': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([post.currentUserId]),
        });
      } else {
        await postRef.update({
          'likeCount': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([post.currentUserId]),
        });
      }
    }
  }

  Future<void> updateShareCount(Post post) async {
    DocumentReference postRef = _db.collection('posts').doc(post.docId);
    await postRef.update({
      'shareCount': FieldValue.increment(1),
    });
  }
}
