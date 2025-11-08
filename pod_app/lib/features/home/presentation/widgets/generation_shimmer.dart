import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';

class GenerationShimmer extends StatelessWidget {
  final double height;
  final double? width;

  const GenerationShimmer({
    super.key,
    required this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark 
          ? AppColors.surfaceDark 
          : AppColors.borderLight,
      highlightColor: isDark 
          ? AppColors.borderDark.withOpacity(0.3)
          : AppColors.surfaceLight,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
