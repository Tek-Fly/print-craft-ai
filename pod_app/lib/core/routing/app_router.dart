import 'package:flutter/material.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/gallery/presentation/screens/gallery_screen.dart';
import '../../features/gallery/presentation/screens/generation_detail_screen.dart';
import '../../features/premium/presentation/screens/premium_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../models/generation_model.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
        
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
        
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
        
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
        
      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
        
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
        
      case '/gallery':
        return MaterialPageRoute(builder: (_) => const GalleryScreen());
        
      case '/generation-detail':
        final generation = settings.arguments as GenerationModel;
        return MaterialPageRoute(
          builder: (_) => GenerationDetailScreen(generation: generation),
        );
        
      case '/premium':
        return MaterialPageRoute(builder: (_) => const PremiumScreen());
        
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
        
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
    }
  }
  
  static Future<void> navigateTo(String routeName, {Object? arguments}) async {
    await navigatorKey.currentState?.pushNamed(
      routeName,
      arguments: arguments,
    );
  }
  
  static Future<void> navigateAndReplace(String routeName, {Object? arguments}) async {
    await navigatorKey.currentState?.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }
  
  static Future<void> navigateAndRemoveAll(String routeName, {Object? arguments}) async {
    await navigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
  
  static void pop<T extends Object?>([T? result]) {
    navigatorKey.currentState?.pop(result);
  }
  
  static bool canPop() {
    return navigatorKey.currentState?.canPop() ?? false;
  }
}
