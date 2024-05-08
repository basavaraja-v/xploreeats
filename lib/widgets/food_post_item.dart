import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xploreeats/models/post.dart';
import 'package:xploreeats/services/post_service.dart';
import 'package:xploreeats/services/profile_service.dart';
import 'package:xploreeats/utils/app_constants.dart';
import 'package:xploreeats/utils/numberformat.dart';
import 'package:xploreeats/widgets/postvideo_player.dart';

class FoodPostItem extends StatefulWidget {
  final Post post;
  final isUserlogin;
  var isFollowing;

  FoodPostItem(
      {Key? key,
      required this.post,
      this.isUserlogin = false,
      this.isFollowing = false})
      : super(key: key);

  @override
  _FoodPostItemState createState() => _FoodPostItemState();
}

class _FoodPostItemState extends State<FoodPostItem> {
  final PostService _postService = PostService();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration:
          BoxDecoration(border: Border.all(color: AppConstants.borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video with profile picture, user name, and follow button overlay
          Stack(
            children: [
              PostVideoPlayer(
                  videoSource: widget.post.videoUrl, isNetwork: true),
              Positioned(
                top: 16,
                left: 16,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.post.profileUrl),
                    ),
                    SizedBox(width: 16),
                    Text(
                      widget.post.username,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (widget.isUserlogin == false) {
                          showCenterSnackBar(
                            context,
                            'Sign Up to follow.',
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            duration: Duration(seconds: 3),
                          );
                        } else if (widget.isFollowing) {
                          await _unfollowUser();
                        } else {
                          await _followUser();
                        }
                      },
                      child: Text(
                        widget.isFollowing ? 'Following' : 'Follow',
                        style: AppConstants.labelTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Row(
                children: [
                  if (widget.post.isVegetarian)
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green, // Circle color
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(width: 16),
                  if (widget.post.isNonVegetarian)
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 16),
              IconButton(
                icon: Icon(
                  widget.post.isLikedByCurrentUser!
                      ? Icons.favorite
                      : Icons.favorite_border,
                  key: ValueKey<bool>(widget.post.isLikedByCurrentUser!),
                  color: widget.post.isLikedByCurrentUser!
                      ? Colors.red
                      : Colors.grey,
                ),
                onPressed: () {
                  widget.isUserlogin == false
                      ? showCenterSnackBar(
                          context,
                          'Sign Up to like.',
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          duration: Duration(seconds: 3),
                        )
                      : _postService.updateLoveStatus(widget.post);
                },
              ),
              Text(
                getFormattedCount(widget.post.likeCount),
                style: TextStyle(fontSize: 16),
              ),
              // SizedBox(width: 16),
              // IconButton(
              //   icon: Icon(Icons.share),
              //   onPressed: () {
              //     // Handle share action
              //   },
              // ),
              // Text(
              //   getFormattedCount(widget.post.shareCount),
              //   style: TextStyle(fontSize: 16),
              // ),
            ],
          ),
          // Caption
          Row(
            children: [
              Text(
                widget.post.caption,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: 8),
          // Restaurant name
          Row(
            children: [
              Icon(Icons.restaurant, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.post.restaurantName,
                  style: TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          // Location
          InkWell(
            onTap: () {
              _launchMaps(widget.post.latitude, widget.post.longitude);
            },
            child: Row(
              children: [
                Icon(Icons.directions_sharp, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.post.location,
                    style: TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _launchMaps(double latitude, double longitude) async {
    String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
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

  Future<void> _followUser() async {
    try {
      if (widget.post.currentUserId! == widget.post.userId) {
        print('Cannot follow yourself');
        return;
      }
      await ProfileService()
          .followUser(widget.post.currentUserId!, widget.post.userId);
      setState(() {
        widget.isFollowing = true;
      });
    } catch (e) {
      print('Error following user: $e');
    }
  }

  Future<void> _unfollowUser() async {
    try {
      await ProfileService()
          .unfollowUser(widget.post.currentUserId!, widget.post.userId);
      setState(() {
        widget.isFollowing = false;
      });
    } catch (e) {
      print('Error unfollowing user: $e');
    }
  }
}
