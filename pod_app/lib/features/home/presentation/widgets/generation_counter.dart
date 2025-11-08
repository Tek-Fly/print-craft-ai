import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class GenerationCounter extends StatefulWidget {
  final int freeGenerations;
  final bool isPro;
  final VoidCallback onTap;

  const GenerationCounter({
    super.key,
    required this.freeGenerations,
    required this.isPro,
    required this.onTap,
  });

  @override
  State<GenerationCounter> createState() => _GenerationCounterState();
}

class _GenerationCounterState extends State<GenerationCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    if (!widget.isPro && widget.freeGenerations <= 1) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GenerationCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (!widget.isPro && widget.freeGenerations <= 1) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: !widget.isPro && widget.freeGenerations <= 1
                ? _pulseAnimation.value
                : 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: widget.isPro
                    ? AppColors.proBadgeGradient
                    : null,
                color: !widget.isPro
                    ? _getCounterColor(isDark)
                    : null,
                borderRadius: BorderRadius.circular(20),
                boxShadow: widget.isPro
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
                border: !widget.isPro
                    ? Border.all(
                        color: _getBorderColor(isDark),
                        width: 1.5,
                      )
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isPro
                        ? Icons.workspace_premium
                        : Icons.auto_awesome,
                    size: 16,
                    color: widget.isPro
                        ? Colors.white
                        : _getIconColor(isDark),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.isPro
                        ? 'PRO'
                        : '${widget.freeGenerations}/3',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: widget.isPro
                          ? Colors.white
                          : _getTextColor(isDark),
                    ),
                  ),
                  if (!widget.isPro) ...[
                    const SizedBox(width: 6),
                    Text(
                      'Free',
                      style: TextStyle(
                        fontSize: 11,
                        color: _getSubtextColor(isDark),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getCounterColor(bool isDark) {
    if (widget.freeGenerations == 0) {
      return AppColors.error.withOpacity(0.1);
    } else if (widget.freeGenerations == 1) {
      return AppColors.warning.withOpacity(0.1);
    } else {
      return AppColors.success.withOpacity(0.1);
    }
  }

  Color _getBorderColor(bool isDark) {
    if (widget.freeGenerations == 0) {
      return AppColors.error;
    } else if (widget.freeGenerations == 1) {
      return AppColors.warning;
    } else {
      return AppColors.success;
    }
  }

  Color _getIconColor(bool isDark) {
    if (widget.freeGenerations == 0) {
      return AppColors.error;
    } else if (widget.freeGenerations == 1) {
      return AppColors.warning;
    } else {
      return AppColors.success;
    }
  }

  Color _getTextColor(bool isDark) {
    if (widget.freeGenerations == 0) {
      return AppColors.error;
    } else if (widget.freeGenerations == 1) {
      return AppColors.warning;
    } else {
      return isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    }
  }

  Color _getSubtextColor(bool isDark) {
    if (widget.freeGenerations == 0) {
      return AppColors.error.withOpacity(0.7);
    } else if (widget.freeGenerations == 1) {
      return AppColors.warning.withOpacity(0.7);
    } else {
      return isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    }
  }
}
