class AppConstants {
  // App Info
  static const String appName = 'InstaDown';
  static const String appVersion = '1.0.0';

  // AdMob IDs (테스트용 - 실제 배포시 변경 필요)
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String rewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  // Instagram URLs
  static const String instagramBaseUrl = 'https://www.instagram.com';
  static const String instagramApiUrl = 'https://www.instagram.com/api/v1';

  // Storage Keys
  static const String coinsKey = 'user_coins';
  static const String downloadCountKey = 'download_count';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String themeModeKey = 'theme_mode';

  // Default Values
  static const int defaultCoins = 30;
  static const int coinsPerRewardedAd = 30;
  static const int maxDownloadsPerDay = 100;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
}
