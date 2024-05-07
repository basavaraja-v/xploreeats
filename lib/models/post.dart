import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String? docId;
  final String userId;
  final String username;
  final String displayName;
  final String restaurantName;
  final double latitude;
  final double longitude;
  final String location;
  final bool isVegetarian;
  final bool isNonVegetarian;
  final bool isFree;
  late String videoUrl;
  final String dish;
  final DateTime timestamp;
  double likeCount;
  double shareCount;
  bool? isLikedByCurrentUser = false;

  Post(
      {this.docId,
      required this.userId,
      required this.username,
      required this.displayName,
      required this.restaurantName,
      required this.latitude,
      required this.longitude,
      required this.location,
      required this.isVegetarian,
      required this.isNonVegetarian,
      required this.isFree,
      required this.videoUrl,
      required this.dish,
      required this.timestamp,
      this.likeCount = 0,
      this.shareCount = 0,
      this.isLikedByCurrentUser});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'displayName': displayName,
      'restaurantName': restaurantName,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'isVegetarian': isVegetarian,
      'isNonVegetarian': isNonVegetarian,
      'isFree': isFree,
      'videoUrl': videoUrl,
      'dish': dish,
      'timestamp': timestamp,
      'likeCount': likeCount,
      'shareCount': shareCount,
    };
  }

  factory Post.fromMap(Map<String, dynamic> data, String docId) {
    return Post(
        docId: docId,
        userId: data['userId'],
        username: data['username'],
        displayName: data['displayName'],
        restaurantName: data['restaurantName'],
        latitude: data['latitude'],
        longitude: data['longitude'],
        location: data['location'],
        isVegetarian: data['isVegetarian'],
        isNonVegetarian: data['isNonVegetarian'],
        isFree: data['isFree'],
        videoUrl: data['videoUrl'],
        dish: data['dish'],
        timestamp: (data['timestamp'] as Timestamp).toDate(),
        likeCount: data['likeCount'],
        shareCount: data['shareCount'],
        isLikedByCurrentUser: data['userId'] != null
            ? data['likedBy']?.contains(data['userId']) ?? false
            : false);
  }
}
