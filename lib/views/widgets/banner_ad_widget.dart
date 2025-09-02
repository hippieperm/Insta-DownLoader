import 'package:flutter/material.dart';
import 'package:instadown/services/ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBannerAd();
    });
  }

  Future<void> _loadBannerAd() async {
    try {
      await AdService().loadBannerAd();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('배너 광고 로드 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final adService = AdService();
    final bannerAd = adService.bannerAd;

    if (bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: 50,
      color: Theme.of(context).colorScheme.surface,
      child: adService.createBannerAdWidget(),
    );
  }
}
