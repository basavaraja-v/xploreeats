import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String? docId;
  final String userId;
  final String username;
  final String displayName;
  final String profileUrl;
  final String restaurantName;
  final double latitude;
  final double longitude;
  final String location;
  final bool isVegetarian;
  final bool isNonVegetarian;
  final bool isFree;
  late String videoUrl;
  final String caption;
  final DateTime timestamp;
  double likeCount;
  double shareCount;
  String? currentUserId;
  bool? isLikedByCurrentUser = false;

  Post(
      {this.docId,
      required this.userId,
      required this.username,
      required this.displayName,
      required this.profileUrl,
      required this.restaurantName,
      required this.latitude,
      required this.longitude,
      required this.location,
      required this.isVegetarian,
      required this.isNonVegetarian,
      required this.isFree,
      required this.videoUrl,
      required this.caption,
      required this.timestamp,
      this.likeCount = 0,
      this.shareCount = 0,
      this.currentUserId,
      this.isLikedByCurrentUser});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'displayName': displayName,
      'profileUrl': profileUrl,
      'restaurantName': restaurantName,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'isVegetarian': isVegetarian,
      'isNonVegetarian': isNonVegetarian,
      'isFree': isFree,
      'videoUrl': videoUrl,
      'caption': caption,
      'timestamp': timestamp,
      'likeCount': likeCount,
      'shareCount': shareCount,
    };
  }

  factory Post.fromMap(Map<String, dynamic> data, String docId, user) {
    return Post(
        docId: docId,
        userId: data['userId'],
        currentUserId: user != null ? user.uid : '',
        username: data['username'],
        displayName: data['displayName'],
        profileUrl: data['profileUrl'],
        restaurantName: data['restaurantName'],
        latitude: data['latitude'],
        longitude: data['longitude'],
        location: data['location'],
        isVegetarian: data['isVegetarian'],
        isNonVegetarian: data['isNonVegetarian'],
        isFree: data['isFree'],
        videoUrl: data['videoUrl'],
        caption: data['caption'],
        timestamp: (data['timestamp'] as Timestamp).toDate(),
        likeCount: data['likeCount'],
        shareCount: data['shareCount'],
        isLikedByCurrentUser: user != null
            ? data['likedBy']?.contains(user.uid) ?? false
            : false);
  }
}
