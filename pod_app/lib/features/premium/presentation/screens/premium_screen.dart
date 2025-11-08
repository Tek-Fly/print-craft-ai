import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _scaleController;
  late AnimationController _floatController;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatAnimation;
  
  int _selectedPlanIndex = 1; // Default to most popular

  final List<PlanOption> _plans = [
    PlanOption(
      id: 'weekly',
      title: 'Weekly',
      price: '\$4.99',
      period: 'week',
      description: 'Perfect for trying out',
      savings: null,
      isPopular: false,
    ),
    PlanOption(
      id: 'monthly',
      title: 'Monthly',
      price: '\$14.99',
      period: 'month',
      description: 'Most popular choice',
      savings: 'Save 25%',
      isPopular: true,
    ),
    PlanOption(
      id: 'yearly',
      title: 'Yearly',
      price: '\$99.99',
      period: 'year',
      description: 'Best value',
      savings: 'Save 45%',
      isPopular: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _shimmerAnimation = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _floatAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    _scaleController.forward();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _scaleController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _handleSubscribe() {
    HapticFeedback.heavyImpact();
    // Handle subscription logic
    final authProvider = context.read<AuthProvider>();
    authProvider.upgradeToPro();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('Welcome to PrintCraft Pro!'),
          ],
        ),
        backgroundColor: AppColors.success,
      ),
    );
    
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Animated Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                            .withOpacity(0.05),
                        (isDark ? AppColors.secondaryDark : AppColors.secondaryLight)
                            .withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: CustomPaint(
                    painter: PremiumBackgroundPainter(
                      offset: _floatAnimation.value,
                      isDark: isDark,
                    ),
                  ),
                );
              },
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Restore purchases
                        },
                        child: Text(
                          'Restore',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.primaryDark
                                : AppColors.primaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Pro Badge
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: AnimatedBuilder(
                            animation: _shimmerAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: AppColors.proBadgeGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD700).withOpacity(0.5),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(
                                      Icons.workspace_premium,
                                      color: Colors.white,
                                      size: 60,
                                    ),
                                    // Shimmer effect
                                    Positioned.fill(
                                      child: ClipOval(
                                        child: Transform.translate(
                                          offset: Offset(
                                            _shimmerAnimation.value * 100 - 100,
                                            0,
                                          ),
                                          child: Container(
                                            width: 50,
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
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Title
                        Text(
                          'Unlock PrintCraft Pro',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'Create unlimited AI designs',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Features
                        ..._buildFeatures(isDark),
                        
                        const SizedBox(height: 32),
                        
                        // Plans
                        Text(
                          'Choose Your Plan',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Container(
                          height: 160,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _plans.length,
                            itemBuilder: (context, index) {
                              return _buildPlanCard(
                                _plans[index],
                                index == _selectedPlanIndex,
                                () {
                                  setState(() {
                                    _selectedPlanIndex = index;
                                  });
                                },
                                isDark,
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Subscribe Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: GestureDetector(
                            onTapDown: (_) => _scaleController.reverse(),
                            onTapUp: (_) {
                              _scaleController.forward();
                              _handleSubscribe();
                            },
                            onTapCancel: () => _scaleController.forward(),
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                width: double.infinity,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: isDark
                                      ? AppColors.primaryGradientDark
                                      : AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isDark
                                              ? AppColors.primaryDark
                                              : AppColors.primaryLight)
                                          .withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'Start Free Trial',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          '7-day free trial, then ${_plans[_selectedPlanIndex].price}/${_plans[_selectedPlanIndex].period}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'Cancel anytime',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeatures(bool isDark) {
    final features = [
      FeatureItem(
        icon: Icons.all_inclusive,
        title: 'Unlimited Generations',
        description: 'Create as many designs as you want',
      ),
      FeatureItem(
        icon: Icons.high_quality,
        title: 'Ultra HD Quality',
        description: '4500x5400px transparent PNGs',
      ),
      FeatureItem(
        icon: Icons.speed,
        title: 'Priority Processing',
        description: 'Faster generation times',
      ),
      FeatureItem(
        icon: Icons.palette,
        title: 'Premium Styles',
        description: 'Exclusive artistic styles',
      ),
      FeatureItem(
        icon: Icons.download,
        title: 'Bulk Downloads',
        description: 'Download all designs at once',
      ),
      FeatureItem(
        icon: Icons.support_agent,
        title: 'Priority Support',
        description: '24/7 customer support',
      ),
    ];
    
    return features.map((feature) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                        .withOpacity(0.1),
                    (isDark ? AppColors.secondaryDark : AppColors.secondaryLight)
                        .withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                feature.icon,
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    feature.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildPlanCard(
    PlanOption plan,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? (isDark
                  ? AppColors.primaryGradientDark
                  : AppColors.primaryGradient)
              : null,
          color: !isSelected
              ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
              : null,
          borderRadius: BorderRadius.circular(16),
          border: !isSelected
              ? Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1.5,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark
                            ? AppColors.primaryDark
                            : AppColors.primaryLight)
                        .withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (plan.isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : AppColors.accentLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'POPULAR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : AppColors.accentLight,
                  ),
                ),
              ),
            if (plan.isPopular) const SizedBox(height: 8),
            Text(
              plan.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              plan.price,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
              ),
            ),
            Text(
              '/${plan.period}',
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Colors.white.withOpacity(0.8)
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
            ),
            if (plan.savings != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  plan.savings!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.success,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PlanOption {
  final String id;
  final String title;
  final String price;
  final String period;
  final String description;
  final String? savings;
  final bool isPopular;

  PlanOption({
    required this.id,
    required this.title,
    required this.price,
    required this.period,
    required this.description,
    this.savings,
    required this.isPopular,
  });
}

class FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class PremiumBackgroundPainter extends CustomPainter {
  final double offset;
  final bool isDark;

  PremiumBackgroundPainter({
    required this.offset,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw floating circles
    for (int i = 0; i < 5; i++) {
      final radius = 50 + (i * 30).toDouble();
      final x = size.width * (0.2 + i * 0.2);
      final y = size.height * (0.1 + i * 0.15) + offset * (i.isEven ? 1 : -1);
      
      paint.shader = RadialGradient(
        colors: [
          (isDark ? AppColors.primaryDark : AppColors.primaryLight)
              .withOpacity(0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(x, y),
        radius: radius,
      ));
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
