import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:instadown/constants/app_constants.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  BannerAd? _bannerAd;
  RewardedAd? _rewardedAd;
  bool _isInitialized = false;

  // Getters
  BannerAd? get bannerAd => _bannerAd;
  bool get isInitialized => _isInitialized;

  /// AdMob 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      await _loadRewardedAd();
    } catch (e) {
      print('AdMob 초기화 오류: $e');
    }
  }

  /// 배너 광고 로드
  Future<void> loadBannerAd() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      _bannerAd = BannerAd(
        adUnitId: AppConstants.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            print('배너 광고 로드 완료');
          },
          onAdFailedToLoad: (ad, error) {
            print('배너 광고 로드 실패: $error');
            ad.dispose();
            _bannerAd = null;
          },
          onAdOpened: (ad) {
            print('배너 광고 열림');
          },
          onAdClosed: (ad) {
            print('배너 광고 닫힘');
          },
        ),
      );

      await _bannerAd!.load();
    } catch (e) {
      print('배너 광고 로드 오류: $e');
    }
  }

  /// 보상형 광고 로드
  Future<void> _loadRewardedAd() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await RewardedAd.load(
        adUnitId: AppConstants.rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            print('보상형 광고 로드 완료');
          },
          onAdFailedToLoad: (error) {
            print('보상형 광고 로드 실패: $error');
            _rewardedAd = null;
          },
        ),
      );
    } catch (e) {
      print('보상형 광고 로드 오류: $e');
    }
  }

  /// 보상형 광고 표시
  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      await _loadRewardedAd();
    }

    if (_rewardedAd == null) {
      throw Exception('보상형 광고를 로드할 수 없습니다');
    }

    bool adCompleted = false;

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          print('보상 획득: ${reward.amount} ${reward.type}');
          adCompleted = true;
        },
      );

      // 광고가 닫힌 후 새로운 광고 로드
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('보상형 광고 표시 실패: $error');
          ad.dispose();
          _loadRewardedAd();
        },
      );
    } catch (e) {
      print('보상형 광고 표시 오류: $e');
      throw Exception('광고 표시 중 오류가 발생했습니다');
    }

    return adCompleted;
  }

  /// 배너 광고 위젯 생성
  Widget? createBannerAdWidget() {
    if (_bannerAd == null) return null;

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  /// 리소스 정리
  void dispose() {
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd = null;
    _rewardedAd = null;
  }
}
