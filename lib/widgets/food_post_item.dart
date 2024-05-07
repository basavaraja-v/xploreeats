import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:xploreeats/models/post.dart';
import 'package:xploreeats/services/post_service.dart';
import 'package:xploreeats/utils/app_constants.dart';
import 'package:xploreeats/utils/numberformat.dart';
import 'package:xploreeats/widgets/postvideo_player.dart';

class FoodPostItem extends StatefulWidget {
  final Post post;

  const FoodPostItem({Key? key, required this.post}) : super(key: key);

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
          // Video
          PostVideoPlayer(videoSource: widget.post.videoUrl, isNetwork: true),
          SizedBox(height: 16),
          // Restaurant name and like/share/save buttons
          Row(
            children: [
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
                  _postService.updateLoveStatus(widget.post);
                },
              ),
              Text(
                getFormattedCount(widget.post.likeCount),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(width: 16),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  // Handle share action
                },
              ),
              Text(
                getFormattedCount(widget.post.shareCount),
                style: TextStyle(fontSize: 16),
              ),
              // SizedBox(width: 16),
              // IconButton(
              //   icon: Icon(Icons.bookmark_border),
              //   onPressed: () {
              //     // Handle save action
              //   },
              // ),
              SizedBox(width: 16),
              // Type of food (veg, non-veg)
              Row(
                children: [
                  Icon(
                    widget.post.isVegetarian
                        ? Icons.food_bank
                        : Icons.food_bank,
                    size: 20,
                    color: widget.post.isVegetarian ? Colors.green : Colors.red,
                  ),
                ],
              ),
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
}
