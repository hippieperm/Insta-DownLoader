import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:instadown/models/user_data.dart';

class UserRepository {
  static const String _userDataKey = 'user_data';

  /// 사용자 데이터 로드
  Future<UserData> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userDataKey);

      if (userDataString != null) {
        final userDataMap = json.decode(userDataString) as Map<String, dynamic>;
        return UserData.fromJson(userDataMap);
      }

      return UserData.initial();
    } catch (e) {
      print('사용자 데이터 로드 오류: $e');
      return UserData.initial();
    }
  }

  /// 사용자 데이터 저장
  Future<void> saveUserData(UserData userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = json.encode(userData.toJson());
      await prefs.setString(_userDataKey, userDataString);
    } catch (e) {
      print('사용자 데이터 저장 오류: $e');
    }
  }

  /// 코인 추가
  Future<UserData> addCoins(int coins) async {
    final userData = await loadUserData();
    final updatedUserData = userData.copyWith(coins: userData.coins + coins);
    await saveUserData(updatedUserData);
    return updatedUserData;
  }

  /// 코인 사용
  Future<UserData> useCoins(int coins) async {
    final userData = await loadUserData();
    if (userData.coins < coins) {
      throw Exception('코인이 부족합니다');
    }

    final updatedUserData = userData.copyWith(coins: userData.coins - coins);
    await saveUserData(updatedUserData);
    return updatedUserData;
  }

  /// 다운로드 기록
  Future<UserData> recordDownload() async {
    final userData = await loadUserData();
    final now = DateTime.now();
    final lastDownload = userData.lastDownloadDate;

    int newDownloadCount = userData.downloadCount;
    int newTotalDownloads = userData.totalDownloads + 1;

    // 같은 날인지 확인
    if (now.year == lastDownload.year &&
        now.month == lastDownload.month &&
        now.day == lastDownload.day) {
      newDownloadCount = userData.downloadCount + 1;
    } else {
      // 새로운 날이면 카운트 리셋
      newDownloadCount = 1;
    }

    final updatedUserData = userData.copyWith(
      downloadCount: newDownloadCount,
      lastDownloadDate: now,
      totalDownloads: newTotalDownloads,
    );

    await saveUserData(updatedUserData);
    return updatedUserData;
  }

  /// 첫 실행 완료 표시
  Future<UserData> markFirstLaunchComplete() async {
    final userData = await loadUserData();
    final updatedUserData = userData.copyWith(isFirstLaunch: false);
    await saveUserData(updatedUserData);
    return updatedUserData;
  }

  /// 사용자 데이터 초기화
  Future<void> resetUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
    } catch (e) {
      print('사용자 데이터 초기화 오류: $e');
    }
  }

  /// 특정 키 값 가져오기
  Future<T?> getValue<T>(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (T == String) {
        return prefs.getString(key) as T?;
      } else if (T == int) {
        return prefs.getInt(key) as T?;
      } else if (T == bool) {
        return prefs.getBool(key) as T?;
      } else if (T == double) {
        return prefs.getDouble(key) as T?;
      }

      return null;
    } catch (e) {
      print('값 가져오기 오류: $e');
      return null;
    }
  }

  /// 특정 키 값 저장하기
  Future<void> setValue<T>(String key, T value) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (T == String) {
        await prefs.setString(key, value as String);
      } else if (T == int) {
        await prefs.setInt(key, value as int);
      } else if (T == bool) {
        await prefs.setBool(key, value as bool);
      } else if (T == double) {
        await prefs.setDouble(key, value as double);
      }
    } catch (e) {
      print('값 저장 오류: $e');
    }
  }
}
