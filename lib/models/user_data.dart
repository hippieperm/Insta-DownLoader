class UserData {
  final int coins;
  final int downloadCount;
  final DateTime lastDownloadDate;
  final bool isFirstLaunch;
  final int totalDownloads;

  UserData({
    required this.coins,
    required this.downloadCount,
    required this.lastDownloadDate,
    required this.isFirstLaunch,
    required this.totalDownloads,
  });

  factory UserData.initial() {
    return UserData(
      coins: 30, // 기본 코인 30개
      downloadCount: 0,
      lastDownloadDate: DateTime.now(),
      isFirstLaunch: true,
      totalDownloads: 0,
    );
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      coins: json['coins'] ?? 30,
      downloadCount: json['downloadCount'] ?? 0,
      lastDownloadDate: json['lastDownloadDate'] != null
          ? DateTime.parse(json['lastDownloadDate'])
          : DateTime.now(),
      isFirstLaunch: json['isFirstLaunch'] ?? true,
      totalDownloads: json['totalDownloads'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coins': coins,
      'downloadCount': downloadCount,
      'lastDownloadDate': lastDownloadDate.toIso8601String(),
      'isFirstLaunch': isFirstLaunch,
      'totalDownloads': totalDownloads,
    };
  }

  UserData copyWith({
    int? coins,
    int? downloadCount,
    DateTime? lastDownloadDate,
    bool? isFirstLaunch,
    int? totalDownloads,
  }) {
    return UserData(
      coins: coins ?? this.coins,
      downloadCount: downloadCount ?? this.downloadCount,
      lastDownloadDate: lastDownloadDate ?? this.lastDownloadDate,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      totalDownloads: totalDownloads ?? this.totalDownloads,
    );
  }

  bool get canDownload {
    return coins > 0;
  }

  bool get isDailyLimitReached {
    final now = DateTime.now();
    final lastDownload = lastDownloadDate;

    // 같은 날인지 확인
    if (now.year == lastDownload.year &&
        now.month == lastDownload.month &&
        now.day == lastDownload.day) {
      return downloadCount >= 100; // 일일 다운로드 제한
    }

    return false;
  }

  String get coinsDisplayText {
    return '$coins개';
  }

  String get downloadCountDisplayText {
    return '$downloadCount/100';
  }
}
