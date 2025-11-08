import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/generation_model.dart';

class GalleryGridItem extends StatelessWidget {
  final GenerationModel generation;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const GalleryGridItem({
    super.key,
    required this.generation,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Image
              Positioned.fill(
                child: generation.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: generation.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.surfaceLight,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark
                                    ? AppColors.primaryDark
                                    : AppColors.primaryLight,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.surfaceLight,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            size: 48,
                            color: AppColors.error,
                          ),
                        ),
                      )
                    : Container(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight,
                        child: const Icon(
                          Icons.image_outlined,
                          size: 48,
                        ),
                      ),
              ),
              
              // Status Indicator
              if (generation.status != GenerationStatus.succeeded)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(generation.status)
                          .withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (generation.isProcessing)
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        if (!generation.isProcessing)
                          Icon(
                            _getStatusIcon(generation.status),
                            size: 12,
                            color: Colors.white,
                          ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusLabel(generation.status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Favorite Indicator
              if (generation.isFavorite)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      size: 16,
                      color: AppColors.error,
                    ),
                  ),
                ),
              
              // Bottom Gradient
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        generation.prompt,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.style_outlined,
                            size: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            generation.style,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(generation.createdAt),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(GenerationStatus status) {
    switch (status) {
      case GenerationStatus.pending:
        return AppColors.info;
      case GenerationStatus.processing:
        return AppColors.warning;
      case GenerationStatus.succeeded:
        return AppColors.success;
      case GenerationStatus.failed:
        return AppColors.error;
      case GenerationStatus.cancelled:
        return AppColors.textSecondaryLight;
    }
  }

  IconData _getStatusIcon(GenerationStatus status) {
    switch (status) {
      case GenerationStatus.pending:
        return Icons.schedule;
      case GenerationStatus.processing:
        return Icons.autorenew;
      case GenerationStatus.succeeded:
        return Icons.check_circle;
      case GenerationStatus.failed:
        return Icons.error;
      case GenerationStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusLabel(GenerationStatus status) {
    switch (status) {
      case GenerationStatus.pending:
        return 'Pending';
      case GenerationStatus.processing:
        return 'Processing';
      case GenerationStatus.succeeded:
        return 'Complete';
      case GenerationStatus.failed:
        return 'Failed';
      case GenerationStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
