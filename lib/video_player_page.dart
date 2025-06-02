// lib/video_player_page.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  final String url;
  final BoxFit fitStyle;

  const VideoPlayerPage({
    Key? key,
    required this.url,
    this.fitStyle = BoxFit.contain,
  }) : super(key: key);

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {}); 
        _ctrl.setVolume(1.0);
        _ctrl.play();          
      })
      ..setLooping(true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: _ctrl.value.isInitialized
        ? SizedBox.expand(
            child: Transform.scale(
              scale: 1,                     
              child: FittedBox(
                fit: widget.fitStyle,
                alignment: Alignment.center,
                child: SizedBox(
                  width: _ctrl.value.size.width,
                  height: _ctrl.value.size.height,
                  child: VideoPlayer(_ctrl),
                ),
              ),
            ),
          )
        : const Center(child: CircularProgressIndicator()),
    );
  }
}