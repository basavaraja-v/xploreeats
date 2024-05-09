import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PostVideoPlayer extends StatefulWidget {
  final String videoSource;
  final bool isNetwork;

  const PostVideoPlayer({
    Key? key,
    required this.videoSource,
    this.isNetwork = false,
  }) : super(key: key);

  @override
  _PostVideoPlayerState createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<PostVideoPlayer> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    if (widget.isNetwork) {
      _controller = VideoPlayerController.network(
        widget.videoSource,
      );
    } else {
      _controller = VideoPlayerController.file(
        File(widget.videoSource),
      );
    }

    // Initialize the controller and start loading the video
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      if (widget.isNetwork) _controller.play();
    });

    // Loop the video playback
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.60,
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                  });
                },
                child: VideoPlayer(_controller),
              ),
            ),
          );
        } else {
          // While video is loading, display a placeholder or loading indicator
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
