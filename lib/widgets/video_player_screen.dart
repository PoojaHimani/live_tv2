import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../models/program.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Program program;
  const VideoPlayerScreen({super.key, required this.program});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isFullScreen = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _enterFullScreen() {
    setState(() {
      _isFullScreen = true;
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _exitFullScreen() {
    setState(() {
      _isFullScreen = false;
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  void _initializeVideo() {
    // Use a working sample video URL for testing
    String videoUrl =
        'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4';

    // If you want to use the original program URL, uncomment this:
    // String videoUrl = widget.program.videoUrl;

    print('Loading video from: $videoUrl');

    try {
      _controller = VideoPlayerController.network(
        videoUrl,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );

      _controller!
          .initialize()
          .then((_) {
            print('Video initialized successfully');
            print('Video duration: ${_controller!.value.duration}');
            print('Video aspect ratio: ${_controller!.value.aspectRatio}');
            if (mounted) {
              setState(() {
                _hasError = false;
              });
              _controller!.setLooping(true);
              _controller!.setVolume(1.0);
              _controller!.play();

              // Auto-enter fullscreen for landscape videos
              if (_controller!.value.aspectRatio > 1.5) {
                _enterFullScreen();
              }
            }
          })
          .catchError((error) {
            print('Video initialization error: $error');
            if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = error.toString();
              });
            }
          });

      // Listen for video state changes
      _controller!.addListener(() {
        if (_controller != null && mounted) {
          // Print video state changes
          print(
            'Video state changed - Playing: ${_controller!.value.isPlaying}, Position: ${_controller!.value.position}',
          );
          setState(() {});
        }
      });
    } catch (error) {
      print('Controller creation error: $error');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = error.toString();
        });
      }
    }
  }

  // Enhanced toggle with more debugging
  void _togglePlayPause() {
    print('=== TOGGLE PLAY PAUSE CALLED ===');
    print('Controller null: ${_controller == null}');

    if (_controller == null) {
      print('❌ Controller is null - returning');
      return;
    }

    print('Controller initialized: ${_controller!.value.isInitialized}');
    if (!_controller!.value.isInitialized) {
      print('❌ Video not initialized yet - returning');
      return;
    }

    print('Has error: $_hasError');
    if (_hasError) {
      print('❌ Video has error: $_errorMessage - returning');
      return;
    }

    print('Current playing state: ${_controller!.value.isPlaying}');
    print('Current position: ${_controller!.value.position}');
    print('Video duration: ${_controller!.value.duration}');

    try {
      if (_controller!.value.isPlaying) {
        print('🎬 Attempting to PAUSE video');
        _controller!.pause();
        print('✅ Pause command sent');
      } else {
        print('▶️ Attempting to PLAY video');
        _controller!.play();
        print('✅ Play command sent');
      }

      // Force a rebuild
      if (mounted) {
        setState(() {});
      }

      // Check state after a short delay
      Future.delayed(Duration(milliseconds: 100), () {
        if (_controller != null && mounted) {
          print('After 100ms - Playing: ${_controller!.value.isPlaying}');
        }
      });
    } catch (e) {
      print('❌ Error in toggle: $e');
    }

    print('=== TOGGLE PLAY PAUSE END ===\n');
  }

  Widget _buildVideoPlayer() {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Failed to load video',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _errorMessage = '';
                });
                _initializeVideo();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Loading video...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Stack(
        children: [
          // Video Player
          Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          ),

          // Invisible tap detector overlay - MULTIPLE APPROACHES
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                print('🔥 MAIN TAP DETECTED!');
                _togglePlayPause();
              },
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),

          // Alternative: Visible button for testing
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                print('🔥 BUTTON TAP DETECTED!');
                _togglePlayPause();
              },
              backgroundColor: Colors.white.withOpacity(0.8),
              child: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.black,
              ),
            ),
          ),

          // Debug info overlay
          Positioned(
            top: 50,
            left: 10,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Playing: ${_controller!.value.isPlaying}',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    'Position: ${_controller!.value.position.inSeconds}s',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    'Duration: ${_controller!.value.duration.inSeconds}s',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    // Reset orientation when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullScreen
          ? null
          : AppBar(
              backgroundColor: Colors.black,
              title: Text(
                widget.program.title,
                style: const TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
      body: Stack(
        children: [
          _buildVideoPlayer(),
          // Back button for fullscreen mode
          if (_isFullScreen)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
        ],
      ),
    );
  }
}
