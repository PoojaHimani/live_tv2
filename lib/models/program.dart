enum VideoType { youtube, mp4 }

class Program {
  final String id;
  final String title;
  final String channelId;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final String videoUrl;
  final VideoType videoType;
  final String? episodeInfo;
  final bool isNew;

  Program({
    required this.id,
    required this.title,
    required this.channelId,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.videoUrl,
    required this.videoType,
    this.episodeInfo,
    this.isNew = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'channelId': channelId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'duration': duration.inSeconds,
      'videoUrl': videoUrl,
      'videoType': videoType.toString(),
      'episodeInfo': episodeInfo,
      'isNew': isNew,
    };
  }

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'],
      title: json['title'],
      channelId: json['channelId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      duration: Duration(seconds: json['duration']),
      videoUrl: json['videoUrl'],
      videoType: VideoType.values.firstWhere(
        (e) => e.toString() == json['videoType'],
      ),
      episodeInfo: json['episodeInfo'],
      isNew: json['isNew'] ?? false,
    );
  }

  Program copyWith({
    String? id,
    String? title,
    String? channelId,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    String? videoUrl,
    VideoType? videoType,
    String? episodeInfo,
    bool? isNew,
  }) {
    return Program(
      id: id ?? this.id,
      title: title ?? this.title,
      channelId: channelId ?? this.channelId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      videoUrl: videoUrl ?? this.videoUrl,
      videoType: videoType ?? this.videoType,
      episodeInfo: episodeInfo ?? this.episodeInfo,
      isNew: isNew ?? this.isNew,
    );
  }

  bool get isCurrentlyPlaying {
    final now = DateTime.now();
    return startTime.isBefore(now) && endTime.isAfter(now);
  }

  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isAfter(endTime)) return Duration.zero;
    return endTime.difference(now);
  }

  String get remainingTimeString {
    final remaining = remainingTime;
    if (remaining.inMinutes <= 0) return 'ENDED';
    return '${remaining.inMinutes} MIN LEFT';
  }
}
