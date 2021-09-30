import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
 // const VideoWidget({Key? key}) : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {

  VideoPlayerController _controller;
  @override
  void initState()
  {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video/splashvideo.mp4')
    ..initialize().then((_){
      _controller.setLooping(false); // keeps playing (No)
      _controller.setVolume(0.0) ;// I guess we don't need volume
      _controller.play();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _controller.value.isInitialized ?
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,

      //AspectRatio(aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),) : Container(),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }
}
