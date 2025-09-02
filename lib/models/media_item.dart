class MediaItem {
  final String id;
  final String url;
  final String thumbnailUrl;
  final MediaType type;
  final int? duration; // 비디오의 경우 초 단위
  final String? caption;
  final String? username;
  final DateTime? timestamp;
  final int? width;
  final int? height;

  MediaItem({
    required this.id,
    required this.url,
    required this.thumbnailUrl,
    required this.type,
    this.duration,
    this.caption,
    this.username,
    this.timestamp,
    this.width,
    this.height,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      type: MediaType.values.firstWhere(
        (e) => e.toString() == 'MediaType.${json['type']}',
        orElse: () => MediaType.image,
      ),
      duration: json['duration'],
      caption: json['caption'],
      username: json['username'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
      width: json['width'],
      height: json['height'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'type': type.toString().split('.').last,
      'duration': duration,
      'caption': caption,
      'username': username,
      'timestamp': timestamp?.toIso8601String(),
      'width': width,
      'height': height,
    };
  }

  MediaItem copyWith({
    String? id,
    String? url,
    String? thumbnailUrl,
    MediaType? type,
    int? duration,
    String? caption,
    String? username,
    DateTime? timestamp,
    int? width,
    int? height,
  }) {
    return MediaItem(
      id: id ?? this.id,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      caption: caption ?? this.caption,
      username: username ?? this.username,
      timestamp: timestamp ?? this.timestamp,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

enum MediaType { image, video, carousel }

extension MediaTypeExtension on MediaType {
  String get displayName {
    switch (this) {
      case MediaType.image:
        return '이미지';
      case MediaType.video:
        return '비디오';
      case MediaType.carousel:
        return '캐러셀';
    }
  }
}
