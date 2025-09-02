import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:instadown/viewmodels/main_viewmodel.dart';
import 'package:instadown/viewmodels/theme_viewmodel.dart';
import 'package:instadown/views/widgets/url_input_widget.dart';
import 'package:instadown/views/widgets/media_grid_widget.dart';
import 'package:instadown/views/widgets/coin_display_widget.dart';
import 'package:instadown/views/widgets/banner_ad_widget.dart';
import 'package:instadown/views/widgets/loading_widget.dart';
import 'package:instadown/views/widgets/error_widget.dart';
import 'package:instadown/constants/app_constants.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MainViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          // 코인 표시
          Consumer<MainViewModel>(
            builder: (context, viewModel, child) {
              return CoinDisplayWidget(
                coins: viewModel.userData.coins,
                onTap: () => _showCoinInfo(context, viewModel),
              );
            },
          ),
          // 테마 토글 버튼
          Consumer<ThemeViewModel>(
            builder: (context, themeViewModel, child) {
              return IconButton(
                icon: Icon(themeViewModel.getThemeModeIcon()),
                onPressed: () => _showThemeDialog(context, themeViewModel),
                tooltip: '테마 변경',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // URL 입력 섹션
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: UrlInputWidget(
              onExtract: () => context.read<MainViewModel>().extractMedia(),
              onPaste: () => context.read<MainViewModel>().pasteFromClipboard(),
            ),
          ),

          // 에러 메시지
          Consumer<MainViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.errorMessage != null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                  ),
                  child: AppErrorWidget(
                    message: viewModel.errorMessage!,
                    onDismiss: () =>
                        context.read<MainViewModel>().clearMediaItems(),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // 로딩 인디케이터
          Consumer<MainViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Expanded(child: Center(child: AppLoadingWidget()));
              }
              return const SizedBox.shrink();
            },
          ),

          // 미디어 그리드
          Expanded(
            child: Consumer<MainViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.mediaItems.isNotEmpty) {
                  return MediaGridWidget(
                    mediaItems: viewModel.mediaItems,
                    onDownload: (mediaItem) =>
                        viewModel.downloadMedia(mediaItem),
                    canDownload: viewModel.canDownload,
                  );
                }

                return _buildEmptyState(context, viewModel);
              },
            ),
          ),

          // 배너 광고
          const BannerAdWidget(),
        ],
      ),
      floatingActionButton: Consumer<MainViewModel>(
        builder: (context, viewModel, child) {
          if (!viewModel.canDownload && viewModel.userData.coins == 0) {
            return FloatingActionButton.extended(
              onPressed: viewModel.isAdLoading
                  ? null
                  : () => viewModel.watchRewardedAd(),
              icon: viewModel.isAdLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_circle_outline),
              label: Text(viewModel.isAdLoading ? '로딩 중...' : '광고 시청'),
              tooltip: '광고를 시청하여 코인을 획득하세요',
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, MainViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'Instagram URL을 입력하세요',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              '사진이나 비디오를 다운로드할 수 있습니다',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.largePadding),
            if (!viewModel.canDownload) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        viewModel.userData.coins == 0
                            ? '코인이 부족합니다'
                            : '일일 다운로드 한도에 도달했습니다',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        '광고를 시청하여 코인을 획득하세요',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCoinInfo(BuildContext context, MainViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('코인 정보'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('보유 코인: ${viewModel.userData.coinsDisplayText}'),
            const SizedBox(height: 8),
            Text('오늘 다운로드: ${viewModel.userData.downloadCountDisplayText}'),
            const SizedBox(height: 8),
            Text('총 다운로드: ${viewModel.userData.totalDownloads}개'),
            const SizedBox(height: 16),
            const Text(
              '• 다운로드 1개당 코인 1개 소모\n'
              '• 광고 시청으로 코인 30개 획득\n'
              '• 일일 다운로드 한도: 100개',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, ThemeViewModel themeViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('테마 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('라이트'),
              value: ThemeMode.light,
              groupValue: themeViewModel.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeViewModel.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('다크'),
              value: ThemeMode.dark,
              groupValue: themeViewModel.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeViewModel.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('시스템'),
              value: ThemeMode.system,
              groupValue: themeViewModel.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeViewModel.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }
}
