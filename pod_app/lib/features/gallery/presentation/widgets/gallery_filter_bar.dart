import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class GalleryFilterBar extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const GalleryFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final filters = [
      FilterOption('all', 'All', Icons.grid_view),
      FilterOption('recent', 'Recent', Icons.schedule),
      FilterOption('favorites', 'Favorites', Icons.favorite),
    ];
    
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter.id == selectedFilter;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onFilterChanged(filter.id);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? (isDark
                          ? AppColors.primaryGradientDark
                          : AppColors.primaryGradient)
                      : null,
                  color: !isSelected
                      ? (isDark
                          ? AppColors.chipBackgroundDark
                          : AppColors.chipBackgroundLight)
                      : null,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      filter.icon,
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      filter.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FilterOption {
  final String id;
  final String label;
  final IconData icon;

  FilterOption(this.id, this.label, this.icon);
}
