import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import '../models/program.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Program program;

  const VideoPlayerScreen({super.key, required this.program});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    if (widget.program.videoType == VideoType.youtube) {
      _initializeYouTubePlayer();
    } else {
      _initializeVideoPlayer();
    }
  }

  void _initializeYouTubePlayer() {
    final videoId = YoutubePlayer.convertUrlToId(widget.program.videoUrl);
    if (videoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: false,
          hideControls: false,
          controlsVisibleAtStart: false,
          forceHD: false,
          startAt: 0,
        ),
      );
      setState(() {
        _isInitialized = true;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid YouTube URL')));
    }
  }

  void _initializeVideoPlayer() async {
    if (widget.program.videoUrl.startsWith('http')) {
      _videoController = VideoPlayerController.network(widget.program.videoUrl);
    } else {
      _videoController = VideoPlayerController.file(
        File(widget.program.videoUrl),
      );
    }

    try {
      await _videoController!.initialize();
      await _videoController!.play();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading video: $e')));
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.program.title,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.white),
            onPressed: () {
              // Toggle fullscreen
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: _isInitialized
              ? _buildVideoPlayer()
              : const CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (widget.program.videoType == VideoType.youtube) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        constraints: const BoxConstraints.expand(),
        child: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
          progressColors: const ProgressBarColors(
            playedColor: Colors.red,
            handleColor: Colors.redAccent,
            backgroundColor: Colors.grey,
            bufferedColor: Colors.grey,
          ),
          onReady: () {
            print('YouTube player is ready');
          },
          onEnded: (YoutubeMetaData metaData) {
            Navigator.pop(context);
          },
          bottomActions: [
            CurrentPosition(),
            ProgressBar(isExpanded: true),
            RemainingDuration(),
          ],
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      );
    }
  }
}
