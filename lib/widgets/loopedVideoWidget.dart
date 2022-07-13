import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

// Returns a looped GIF-like video player
class LoopedVideo extends StatefulWidget {
  const LoopedVideo(this.vidPath);

  final String vidPath;

  @override
  _LoopedVideoState createState() => _LoopedVideoState();
}

class _LoopedVideoState extends State<LoopedVideo> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Initializes video player controller
    _controller = VideoPlayerController.asset(
      widget.vidPath,
    )..initialize().then((_) {
        _controller.play();
        _controller.setLooping(true);
        _controller.setVolume(0.0);
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    // Wait to show until the controller is initialized
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : Container();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
