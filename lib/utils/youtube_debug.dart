import 'package:youtube_player_flutter/youtube_player_flutter.dart' as ytf;

class YouTubeDebug {
  static void testUrlExtraction(String url) {
    print('=== YouTube URL Debug Test ===');
    print('Testing URL: $url');

    // Test Flutter player extraction
    final flutterVideoId = ytf.YoutubePlayer.convertUrlToId(url);
    print('Flutter Player Video ID: $flutterVideoId');

    // Test manual extraction as fallback
    String? manualVideoId;
    if (url.contains('youtube.com/watch?v=')) {
      final parts = url.split('v=');
      if (parts.length > 1) {
        manualVideoId = parts[1].split('&')[0];
      }
    } else if (url.contains('youtu.be/')) {
      final parts = url.split('youtu.be/');
      if (parts.length > 1) {
        manualVideoId = parts[1].split('?')[0];
      }
    }
    print('Manual extraction Video ID: $manualVideoId');

    // Check URL patterns
    print('Contains youtube.com: ${url.contains('youtube.com')}');
    print('Contains youtu.be: ${url.contains('youtu.be')}');
    print('Contains watch: ${url.contains('watch')}');
    print('Contains v=: ${url.contains('v=')}');

    print('=============================');
  }

  static List<String> getTestUrls() {
    return [
      'https://www.youtube.com/watch?v=SHnTocdD7sk',
      'https://youtu.be/SHnTocdD7sk',
      'https://www.youtube.com/watch?v=ltM5jHIJFw4&t=30s',
      'https://youtu.be/ltM5jHIJFw4?t=30',
      'https://www.youtube.com/embed/SHnTocdD7sk',
      'https://www.youtube.com/v/SHnTocdD7sk',
    ];
  }

  static void runAllTests() {
    print('Running YouTube URL extraction tests...');
    for (final url in getTestUrls()) {
      testUrlExtraction(url);
      print('');
    }
  }

  // Test specific URLs from the app
  static void testAppUrls() {
    print('=== Testing App URLs ===');
    final appUrls = [
      'https://www.youtube.com/watch?v=dQw4w9WgXcQ', // Rick Roll (always works)
      'https://www.youtube.com/watch?v=9bZkp7q19f0', // PSY - GANGNAM STYLE
      'https://www.youtube.com/watch?v=kJQP7kiw5Fk', // Luis Fonsi - Despacito
      'https://www.youtube.com/watch?v=ZZ5LpwO-An4', // Ed Sheeran - Shape of You
    ];

    for (final url in appUrls) {
      testUrlExtraction(url);
      print('');
    }
  }

  // Test if a specific video is accessible
  static void testVideoAccessibility(String videoId) {
    print('=== Testing Video Accessibility ===');
    print('Video ID: $videoId');

    // Test different URL formats
    final urls = [
      'https://www.youtube.com/watch?v=$videoId',
      'https://youtu.be/$videoId',
      'https://www.youtube.com/embed/$videoId',
    ];

    for (final url in urls) {
      testUrlExtraction(url);
    }
  }

  // Test popular videos that are known to work
  static void testPopularVideos() {
    print('=== Testing Popular Videos ===');
    final popularVideos = [
      'dQw4w9WgXcQ', // Rick Astley - Never Gonna Give You Up
      '9bZkp7q19f0', // PSY - GANGNAM STYLE
      'kJQP7kiw5Fk', // Luis Fonsi - Despacito
      'ZZ5LpwO-An4', // Ed Sheeran - Shape of You
      'y6120QOlsfU', // Sandstorm - Darude
      'jNQXAC9IVRw', // Me at the zoo (First YouTube video)
    ];

    for (final videoId in popularVideos) {
      testVideoAccessibility(videoId);
      print('');
    }
  }

  // Get a list of reliable test videos
  static List<String> getReliableTestUrls() {
    return [
      'https://www.youtube.com/watch?v=dQw4w9WgXcQ', // Rick Roll (always works)
      'https://www.youtube.com/watch?v=9bZkp7q19f0', // PSY - GANGNAM STYLE
      'https://www.youtube.com/watch?v=kJQP7kiw5Fk', // Luis Fonsi - Despacito
      'https://www.youtube.com/watch?v=ZZ5LpwO-An4', // Ed Sheeran - Shape of You
      'https://www.youtube.com/watch?v=y6120QOlsfU', // Sandstorm - Darude
      'https://www.youtube.com/watch?v=jNQXAC9IVRw', // Me at the zoo (First YouTube video)
    ];
  }
}
