import 'package:flutter/material.dart';
import 'package:xploreeats/models/post.dart';
import 'package:xploreeats/services/post_service.dart';
import 'package:xploreeats/widgets/food_post_item.dart';

class PostFeedScreen extends StatefulWidget {
  @override
  _PostFeedScreenState createState() => _PostFeedScreenState();
}

class _PostFeedScreenState extends State<PostFeedScreen> {
  late final PostService _postService;

  @override
  void initState() {
    super.initState();
    _postService = PostService();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Post>>(
        stream: _postService.getPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final List<Post> posts = snapshot.data!;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return FoodPostItem(
                post: posts[index],
              );
            },
          );
        },
      ),
    );
  }
}
