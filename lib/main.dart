import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:instadown/views/main_screen.dart';
import 'package:instadown/viewmodels/main_viewmodel.dart';
import 'package:instadown/viewmodels/theme_viewmodel.dart';
import 'package:instadown/repositories/user_repository.dart';
import 'package:instadown/repositories/instagram_repository.dart';
import 'package:instadown/services/ad_service.dart';
import 'package:instadown/utils/theme.dart';
import 'package:instadown/constants/app_constants.dart';

void main() {
  runApp(const InstaDownApp());
}

class InstaDownApp extends StatelessWidget {
  const InstaDownApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme Provider
        ChangeNotifierProvider(
          create: (context) => ThemeViewModel()..initialize(),
        ),
        // Main ViewModel Provider
        ChangeNotifierProvider(
          create: (context) => MainViewModel(
            userRepository: UserRepository(),
            instagramRepository: InstagramRepository(),
            adService: AdService(),
          ),
        ),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeViewModel.themeMode,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
