import 'package:hive/hive.dart';

part 'program.g.dart';

@HiveType(typeId: 1)
enum VideoType {
  @HiveField(0)
  mp4,
  @HiveField(1)
  youtube,
  @HiveField(2)
  hls,
  @HiveField(3)
  dash
}

@HiveType(typeId: 2)
class Program extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String channelId;
  
  @HiveField(3)
  final DateTime startTime;
  
  @HiveField(4)
  final DateTime endTime;
  
  @HiveField(5)
  final int durationSeconds;
  
  @HiveField(6)
  final String videoUrl;
  
  @HiveField(7)
  final VideoType videoType;
  
  @HiveField(8)
  final String? episodeInfo;
  
  @HiveField(9)
  final bool isNew;
  
  @HiveField(10)
  final String? thumbnailUrl;
  
  @HiveField(11)
  final String? description;

  Program({
    required this.id,
    required this.title,
    required this.channelId,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    required this.videoUrl,
    required this.videoType,
    this.episodeInfo,
    this.isNew = false,
    this.thumbnailUrl,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'channelId': channelId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'duration': durationSeconds,
      'videoUrl': videoUrl,
      'videoType': videoType.toString(),
      'episodeInfo': episodeInfo,
      'isNew': isNew,
      'thumbnailUrl': thumbnailUrl,
      'description': description,
    };
  }

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'],
      title: json['title'],
      channelId: json['channelId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      durationSeconds: json['duration'],
      videoUrl: json['videoUrl'],
      videoType: VideoType.values.firstWhere(
        (e) => e.toString() == json['videoType'],
        orElse: () => VideoType.mp4, // Default fallback
      ),
      episodeInfo: json['episodeInfo'],
      isNew: json['isNew'] ?? false,
      thumbnailUrl: json['thumbnailUrl'],
      description: json['description'],
    );
  }

  Program copyWith({
    String? id,
    String? title,
    String? channelId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    String? videoUrl,
    VideoType? videoType,
    String? episodeInfo,
    bool? isNew,
    String? thumbnailUrl,
    String? description,
  }) {
    return Program(
      id: id ?? this.id,
      title: title ?? this.title,
      channelId: channelId ?? this.channelId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      videoUrl: videoUrl ?? this.videoUrl,
      videoType: videoType ?? this.videoType,
      episodeInfo: episodeInfo ?? this.episodeInfo,
      isNew: isNew ?? this.isNew,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      description: description ?? this.description,
    );
  }

  bool get isCurrentlyPlaying {
    final now = DateTime.now();
    return startTime.isBefore(now) && endTime.isAfter(now);
  }

  // Getter for duration
  Duration get duration => Duration(seconds: durationSeconds);

  // Getter for remaining time
  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isAfter(endTime)) {
      return Duration.zero;
    } else if (now.isBefore(startTime)) {
      return endTime.difference(startTime);
    } else {
      return endTime.difference(now);
    }
  }

  String get remainingTimeString {
    final remaining = remainingTime;
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m remaining';
    } else {
      return '${remaining.inMinutes}m remaining';
    }
  }

  // Helper method to validate video URL
  bool get hasValidVideoUrl {
    if (videoUrl.isEmpty) return false;

    switch (videoType) {
      case VideoType.mp4:
        return videoUrl.startsWith('http') &&
            (videoUrl.contains('.mp4') || videoUrl.contains('mp4'));
      case VideoType.youtube:
        return videoUrl.contains('youtube.com') ||
            videoUrl.contains('youtu.be');
      case VideoType.hls:
        return videoUrl.contains('.m3u8');
      case VideoType.dash:
        return videoUrl.contains('.mpd');
      default:
        return videoUrl.startsWith('http');
    }
  }

  // Get a display-friendly video type name
  String get videoTypeDisplayName {
    switch (videoType) {
      case VideoType.mp4:
        return 'MP4 Video';
      case VideoType.youtube:
        return 'YouTube Video';
      case VideoType.hls:
        return 'HLS Stream';
      case VideoType.dash:
        return 'DASH Stream';
    }
  }
}

// Updated sample programs with working video URLs
final programs = [
  Program(
    id: '1',
    channelId: 'channel_1',
    title: 'Big Buck Bunny',
    description: 'A short computer-animated comedy film featuring a rabbit.',
    videoUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    thumbnailUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg',
    videoType: VideoType.mp4,
    startTime: DateTime.now(),
    endTime: DateTime.now().add(const Duration(minutes: 30)),
    durationSeconds: 1800, // 30 minutes
    isNew: true,
  ),
  Program(
    id: '2',
    channelId: 'channel_2',
    title: 'Elephant Dream',
    description: 'A computer-animated short film.',
    videoUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    thumbnailUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg',
    videoType: VideoType.mp4,
    startTime: DateTime.now().add(const Duration(minutes: 30)),
    endTime: DateTime.now().add(const Duration(minutes: 60)),
    durationSeconds: 1800, // 30 minutes
  ),
  Program(
    id: '3',
    channelId: 'channel_3',
    title: 'For Bigger Blazes',
    description: 'A sample video for testing purposes.',
    videoUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    thumbnailUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg',
    videoType: VideoType.mp4,
    startTime: DateTime.now().add(const Duration(hours: 1)),
    endTime: DateTime.now().add(const Duration(hours: 1, minutes: 30)),
    durationSeconds: 1800, // 30 minutes
  ),
  Program(
    id: '4',
    channelId: 'channel_1',
    title: 'Sintel',
    description: 'A fantasy adventure short film.',
    videoUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    thumbnailUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/Sintel.jpg',
    videoType: VideoType.mp4,
    startTime: DateTime.now().add(const Duration(hours: 1, minutes: 30)),
    endTime: DateTime.now().add(const Duration(hours: 2)),
    durationSeconds: 1800, // 30 minutes
  ),
  Program(
    id: '5',
    channelId: 'channel_2',
    title: 'Tears of Steel',
    description: 'A science fiction short film.',
    videoUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    thumbnailUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/TearsOfSteel.jpg',
    videoType: VideoType.mp4,
    startTime: DateTime.now().add(const Duration(hours: 2)),
    endTime: DateTime.now().add(const Duration(hours: 2, minutes: 30)),
    durationSeconds: 1800, // 30 minutes
  ),
  Program(
    id: '6',
    channelId: 'channel_3',
    title: 'We Are Going On Bullrun',
    description: 'A sample automotive video.',
    videoUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
    thumbnailUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/WeAreGoingOnBullrun.jpg',
    videoType: VideoType.mp4,
    startTime: DateTime.now().add(const Duration(hours: 2, minutes: 30)),
    endTime: DateTime.now().add(const Duration(hours: 3)),
    durationSeconds: 1800, // 30 minutes
  ),
  // Alternative URLs if the above don't work
  Program(
    id: '7',
    channelId: 'channel_1',
    title: 'Sample Video (Alternative)',
    description: 'Alternative sample video for testing.',
    videoUrl: 'https://www.w3schools.com/html/mov_bbb.mp4',
    videoType: VideoType.mp4,
    startTime: DateTime.now().add(const Duration(hours: 3)),
    endTime: DateTime.now().add(const Duration(hours: 3, minutes: 15)),
    durationSeconds: 900, // 15 minutes
  ),
  Program(
    id: '8',
    channelId: 'channel_2',
    title: 'Test Video Stream',
    description: 'Another test video for verification.',
    videoUrl:
        'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
    videoType: VideoType.mp4,
    startTime: DateTime.now().add(const Duration(hours: 3, minutes: 15)),
    endTime: DateTime.now().add(const Duration(hours: 3, minutes: 30)),
    durationSeconds: 900, // 15 minutes
  ),
];

// Debugging helper function
void debugProgramUrls() {
  print('=== Program URL Debug Info ===');
  for (final program in programs) {
    print('Program: ${program.title}');
    print('  URL: ${program.videoUrl}');
    print('  Type: ${program.videoType}');
    print('  Valid: ${program.hasValidVideoUrl}');
    print('  ---');
  }
}
