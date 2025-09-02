import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:instadown/models/media_item.dart';

class InstagramRepository {
  final Dio _dio;

  InstagramRepository({Dio? dio}) : _dio = dio ?? Dio();

  /// Instagram URL에서 미디어 정보를 추출합니다
  Future<List<MediaItem>> extractMediaFromUrl(String url) async {
    try {
      // URL 유효성 검사
      if (!_isValidInstagramUrl(url)) {
        throw Exception('유효하지 않은 Instagram URL입니다');
      }

      // Instagram 페이지에서 미디어 정보 추출
      final response = await _dio.get(url);
      final html = response.data as String;

      // JSON 데이터 추출 (Instagram의 __additionalDataLoaded 스크립트에서)
      final mediaItems = _parseInstagramHtml(html);

      if (mediaItems.isEmpty) {
        throw Exception('미디어를 찾을 수 없습니다');
      }

      return mediaItems;
    } catch (e) {
      throw Exception('미디어 추출 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// Instagram URL 유효성 검사
  bool _isValidInstagramUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    return uri.host.contains('instagram.com') &&
        (uri.path.contains('/p/') ||
            uri.path.contains('/reel/') ||
            uri.path.contains('/tv/'));
  }

  /// HTML에서 미디어 정보 파싱
  List<MediaItem> _parseInstagramHtml(String html) {
    final List<MediaItem> mediaItems = [];

    try {
      // Instagram의 JSON 데이터 추출
      final jsonMatch = RegExp(
        r'window\._sharedData\s*=\s*({.+?});',
      ).firstMatch(html);
      if (jsonMatch != null) {
        final jsonString = jsonMatch.group(1);
        if (jsonString != null) {
          final data = json.decode(jsonString);
          final mediaItems = _extractMediaFromSharedData(data);
          if (mediaItems.isNotEmpty) {
            return mediaItems;
          }
        }
      }

      // 추가 데이터 로드 스크립트에서 추출
      final additionalDataMatch = RegExp(
        r'window\.__additionalDataLoaded\([^,]+,\s*({.+?})\);',
      ).firstMatch(html);
      if (additionalDataMatch != null) {
        final jsonString = additionalDataMatch.group(1);
        if (jsonString != null) {
          final data = json.decode(jsonString);
          final mediaItems = _extractMediaFromAdditionalData(data);
          if (mediaItems.isNotEmpty) {
            return mediaItems;
          }
        }
      }

      // GraphQL 데이터에서 추출
      final graphqlMatch = RegExp(r'"GraphImage":\s*({.+?})').firstMatch(html);
      if (graphqlMatch != null) {
        final jsonString = graphqlMatch.group(1);
        if (jsonString != null) {
          final data = json.decode('{$jsonString}');
          final mediaItems = _extractMediaFromGraphQL(data);
          if (mediaItems.isNotEmpty) {
            return mediaItems;
          }
        }
      }
    } catch (e) {
      print('HTML 파싱 오류: $e');
    }

    return mediaItems;
  }

  /// SharedData에서 미디어 추출
  List<MediaItem> _extractMediaFromSharedData(Map<String, dynamic> data) {
    final List<MediaItem> mediaItems = [];

    try {
      final entryData =
          data['entry_data']?['PostPage']?[0]?['graphql']?['shortcode_media'];
      if (entryData != null) {
        final mediaItem = _createMediaItemFromGraphQL(entryData);
        if (mediaItem != null) {
          mediaItems.add(mediaItem);
        }
      }
    } catch (e) {
      print('SharedData 파싱 오류: $e');
    }

    return mediaItems;
  }

  /// AdditionalData에서 미디어 추출
  List<MediaItem> _extractMediaFromAdditionalData(Map<String, dynamic> data) {
    final List<MediaItem> mediaItems = [];

    try {
      final items = data['items'] as List?;
      if (items != null) {
        for (final item in items) {
          final mediaItem = _createMediaItemFromGraphQL(item);
          if (mediaItem != null) {
            mediaItems.add(mediaItem);
          }
        }
      }
    } catch (e) {
      print('AdditionalData 파싱 오류: $e');
    }

    return mediaItems;
  }

  /// GraphQL 데이터에서 미디어 추출
  List<MediaItem> _extractMediaFromGraphQL(Map<String, dynamic> data) {
    final List<MediaItem> mediaItems = [];

    try {
      final mediaItem = _createMediaItemFromGraphQL(data);
      if (mediaItem != null) {
        mediaItems.add(mediaItem);
      }
    } catch (e) {
      print('GraphQL 파싱 오류: $e');
    }

    return mediaItems;
  }

  /// GraphQL 데이터로부터 MediaItem 생성
  MediaItem? _createMediaItemFromGraphQL(Map<String, dynamic> data) {
    try {
      final id =
          data['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final isVideo = data['is_video'] == true;
      final mediaType = isVideo ? MediaType.video : MediaType.image;

      String? url;
      String? thumbnailUrl;

      if (isVideo) {
        final videoVersions = data['video_versions'] as List?;
        if (videoVersions != null && videoVersions.isNotEmpty) {
          url = videoVersions[0]['url'] as String?;
        }
        thumbnailUrl = data['display_url'] as String?;
      } else {
        url = data['display_url'] as String?;
        thumbnailUrl = url;
      }

      if (url == null) return null;

      final caption =
          data['edge_media_to_caption']?['edges']?[0]?['node']?['text']
              as String?;
      final owner = data['owner'] as Map<String, dynamic>?;
      final username = owner?['username'] as String?;
      final timestamp = data['taken_at_timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (data['taken_at_timestamp'] as int) * 1000,
            )
          : null;

      return MediaItem(
        id: id,
        url: url,
        thumbnailUrl: thumbnailUrl ?? url,
        type: mediaType,
        caption: caption,
        username: username,
        timestamp: timestamp,
        width: data['dimensions']?['width'],
        height: data['dimensions']?['height'],
      );
    } catch (e) {
      print('MediaItem 생성 오류: $e');
      return null;
    }
  }

  /// 미디어 다운로드
  Future<String> downloadMedia(String url, String fileName) async {
    try {
      await _dio.download(url, fileName);
      return fileName;
    } catch (e) {
      throw Exception('다운로드 중 오류가 발생했습니다: ${e.toString()}');
    }
  }
}
