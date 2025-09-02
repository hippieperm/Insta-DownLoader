import 'package:flutter/material.dart';
import 'package:instadown/models/user_data.dart';
import 'package:instadown/models/media_item.dart';
import 'package:instadown/repositories/user_repository.dart';
import 'package:instadown/repositories/instagram_repository.dart';
import 'package:instadown/services/ad_service.dart';
import 'package:instadown/constants/app_constants.dart';

class MainViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final InstagramRepository _instagramRepository;
  final AdService _adService;

  MainViewModel({
    required UserRepository userRepository,
    required InstagramRepository instagramRepository,
    required AdService adService,
  }) : _userRepository = userRepository,
       _instagramRepository = instagramRepository,
       _adService = adService;

  // 상태 변수들
  UserData _userData = UserData.initial();
  List<MediaItem> _mediaItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _inputUrl = '';
  bool _isAdLoading = false;

  // Getters
  UserData get userData => _userData;
  List<MediaItem> get mediaItems => _mediaItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get inputUrl => _inputUrl;
  bool get isAdLoading => _isAdLoading;
  bool get canDownload =>
      _userData.canDownload && !_userData.isDailyLimitReached;

  /// 초기화
  Future<void> initialize() async {
    await _loadUserData();
    await _adService.initialize();
  }

  /// 사용자 데이터 로드
  Future<void> _loadUserData() async {
    try {
      _userData = await _userRepository.loadUserData();
      notifyListeners();
    } catch (e) {
      _setError('사용자 데이터를 불러오는데 실패했습니다: ${e.toString()}');
    }
  }

  /// URL 입력
  void setInputUrl(String url) {
    _inputUrl = url;
    notifyListeners();
  }

  /// 미디어 추출
  Future<void> extractMedia() async {
    if (_inputUrl.isEmpty) {
      _setError('Instagram URL을 입력해주세요');
      return;
    }

    if (!canDownload) {
      if (!_userData.canDownload) {
        _setError('코인이 부족합니다. 광고를 시청하여 코인을 획득하세요.');
      } else {
        _setError('일일 다운로드 한도를 초과했습니다.');
      }
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final mediaItems = await _instagramRepository.extractMediaFromUrl(
        _inputUrl,
      );
      _mediaItems = mediaItems;

      if (mediaItems.isEmpty) {
        _setError('미디어를 찾을 수 없습니다. URL을 확인해주세요.');
      }
    } catch (e) {
      _setError('미디어 추출 중 오류가 발생했습니다: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 미디어 다운로드
  Future<void> downloadMedia(MediaItem mediaItem) async {
    if (!canDownload) {
      _setError('다운로드할 수 없습니다. 코인을 확인하거나 광고를 시청하세요.');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      // 코인 사용
      _userData = await _userRepository.useCoins(1);

      // 다운로드 기록
      _userData = await _userRepository.recordDownload();

      // 실제 다운로드 로직은 여기에 구현
      // await _downloadMediaFile(mediaItem);

      notifyListeners();
    } catch (e) {
      _setError('다운로드 중 오류가 발생했습니다: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 보상형 광고 시청
  Future<void> watchRewardedAd() async {
    _isAdLoading = true;
    notifyListeners();
    _clearError();

    try {
      final success = await _adService.showRewardedAd();

      if (success) {
        _userData = await _userRepository.addCoins(
          AppConstants.coinsPerRewardedAd,
        );
        notifyListeners();
      } else {
        _setError('광고 시청이 완료되지 않았습니다.');
      }
    } catch (e) {
      _setError('광고 시청 중 오류가 발생했습니다: ${e.toString()}');
    } finally {
      _isAdLoading = false;
      notifyListeners();
    }
  }

  /// URL 클립보드에서 붙여넣기
  Future<void> pasteFromClipboard() async {
    try {
      // 클립보드에서 텍스트 가져오기
      // final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      // if (clipboardData?.text != null) {
      //   setInputUrl(clipboardData!.text!);
      // }
    } catch (e) {
      _setError('클립보드에서 URL을 가져오는데 실패했습니다.');
    }
  }

  /// 미디어 목록 초기화
  void clearMediaItems() {
    _mediaItems = [];
    notifyListeners();
  }

  /// 입력 URL 초기화
  void clearInputUrl() {
    _inputUrl = '';
    notifyListeners();
  }

  /// 에러 메시지 설정
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// 에러 메시지 초기화
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 첫 실행 완료 표시
  Future<void> markFirstLaunchComplete() async {
    _userData = await _userRepository.markFirstLaunchComplete();
    notifyListeners();
  }

  /// 앱 종료시 정리
  void dispose() {
    _adService.dispose();
    super.dispose();
  }
}
