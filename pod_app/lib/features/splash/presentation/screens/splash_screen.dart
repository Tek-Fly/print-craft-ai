import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _shimmerController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textOpacity;
  late Animation<Offset> _shimmerPosition;

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _logoScale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _logoRotation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ));
    
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));
    
    _shimmerPosition = Tween<Offset>(
      begin: const Offset(-2, 0),
      end: const Offset(2, 0),
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));
    
    _initializeApp();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _shimmerController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Start animations
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
    
    // Initialize app
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Check auth status
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    
    // Wait for auth initialization
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Check if first time user
    final hasSeenOnboarding = await StorageService.getBool('has_seen_onboarding') ?? false;
    
    if (!mounted) return;
    
    // Navigate based on auth status and onboarding
    if (authProvider.isAuthenticated) {
      AppRouter.navigateAndRemoveAll('/home');
    } else if (!hasSeenOnboarding) {
      AppRouter.navigateAndRemoveAll('/onboarding');
    } else {
      AppRouter.navigateAndRemoveAll('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
              isDark 
                  ? AppColors.primaryDark.withOpacity(0.3)
                  : AppColors.primaryLight.withOpacity(0.1),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background Pattern
            ...List.generate(5, (index) {
              return Positioned(
                left: (index * 100.0) - 50,
                top: 100.0 * (index % 2),
                bottom: 100.0 * ((index + 1) % 2),
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _shimmerController.value * 2 * math.pi / 5,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              (isDark
                                      ? AppColors.primaryDark
                                      : AppColors.primaryLight)
                                  .withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
            
            // Logo and Text
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Transform.rotate(
                          angle: _logoRotation.value,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              gradient: isDark
                                  ? AppColors.primaryGradientDark
                                  : AppColors.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark
                                          ? AppColors.primaryDark
                                          : AppColors.primaryLight)
                                      .withOpacity(0.5),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Shimmer effect
                                ClipOval(
                                  child: AnimatedBuilder(
                                    animation: _shimmerController,
                                    builder: (context, child) {
                                      return FractionalTranslation(
                                        translation: _shimmerPosition.value,
                                        child: Container(
                                          width: 60,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.transparent,
                                                Colors.white.withOpacity(0.3),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const Icon(
                                  Icons.auto_awesome,
                                  color: Colors.white,
                                  size: 70,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // App Name
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textOpacity.value,
                        child: Column(
                          children: [
                            Text(
                              'PrintCraft AI',
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create Amazing Designs',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 80),
                  
                  // Loading indicator
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textOpacity.value,
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primaryLight,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Version
            Positioned(
              bottom: 32 + MediaQuery.of(context).padding.bottom,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textOpacity.value,
                    child: Text(
                      'Version 1.0.0',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark.withOpacity(0.5)
                                : AppColors.textSecondaryLight.withOpacity(0.5),
                          ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
