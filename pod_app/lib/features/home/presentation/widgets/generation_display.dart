import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/generation_model.dart';
import 'generation_shimmer.dart';

class GenerationDisplay extends StatefulWidget {
  final GenerationModel? generation;
  final bool isGenerating;
  final VoidCallback onRetry;
  final VoidCallback onShare;
  final VoidCallback onDownload;

  const GenerationDisplay({
    super.key,
    this.generation,
    required this.isGenerating,
    required this.onRetry,
    required this.onShare,
    required this.onDownload,
  });

  @override
  State<GenerationDisplay> createState() => _GenerationDisplayState();
}

class _GenerationDisplayState extends State<GenerationDisplay>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isImageLoaded = false;

  @override
  void initState() {
    super.initState();
    
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _floatAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final displayHeight = screenSize.height * 0.5;
    
    if (widget.isGenerating) {
      return _buildGeneratingState(isDark, displayHeight);
    }
    
    if (widget.generation == null) {
      return _buildEmptyState(isDark, displayHeight);
    }
    
    return _buildGeneratedImage(isDark, displayHeight);
  }
  
  Widget _buildEmptyState(bool isDark, double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
            (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
                .withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: DotPatternPainter(
                color: isDark
                    ? AppColors.borderDark.withOpacity(0.3)
                    : AppColors.borderLight.withOpacity(0.3),
              ),
            ),
          ),
          
          // Center Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: Container(
                        width: 100,
                        height: 100,
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
                                  .withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate_outlined,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Start Creating',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your AI-generated designs will appear here',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGeneratingState(bool isDark, double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
            (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                .withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Animated Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _rotateController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateController.value * 2 * math.pi,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: SweepGradient(
                        colors: [
                          Colors.transparent,
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
          ),
          
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Loading Animation
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isDark
                          ? AppColors.primaryGradientDark
                          : AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: (isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primaryLight)
                              .withOpacity(0.4),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Spinning rings
                        ...List.generate(3, (index) {
                          return AnimatedBuilder(
                            animation: _rotateController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _rotateController.value *
                                    2 *
                                    math.pi *
                                    (index + 1),
                                child: Container(
                                  width: 80 + (index * 20).toDouble(),
                                  height: 80 + (index * 20).toDouble(),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(
                                          0.3 - (index * 0.1)),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 40,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Status Text
                Text(
                  'Creating Magic',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.primaryDark
                            : AppColors.primaryLight,
                      ),
                ),
                const SizedBox(height: 8),
                
                // Progress Messages
                StreamBuilder<String>(
                  stream: _generateProgressMessages(),
                  builder: (context, snapshot) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        snapshot.data ?? 'Initializing AI...',
                        key: ValueKey(snapshot.data),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Progress Bar
                Container(
                  width: 200,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(seconds: 15),
                            width: constraints.maxWidth * 0.9,
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: isDark
                                  ? AppColors.primaryGradientDark
                                  : AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGeneratedImage(bool isDark, double height) {
    return Hero(
      tag: 'generation_${widget.generation!.id}',
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                ),
                child: Image.network(
                  widget.generation!.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: height,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return GenerationShimmer(height: height);
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: widget.onRetry,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Action Buttons
            Positioned(
              top: 16,
              right: 16,
              child: Row(
                children: [
                  _buildActionButton(
                    Icons.share_outlined,
                    widget.onShare,
                    isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    Icons.download_outlined,
                    widget.onDownload,
                    isDark,
                  ),
                ],
              ),
            ),
            
            // Metadata
            if (widget.generation != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
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
                      bottom: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.generation!.prompt,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(widget.generation!.createdAt),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton(IconData icon, VoidCallback onTap, bool isDark) {
    return Material(
      color: isDark
          ? AppColors.surfaceDark.withOpacity(0.9)
          : AppColors.surfaceLight.withOpacity(0.9),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 20,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }
  
  Stream<String> _generateProgressMessages() async* {
    final messages = [
      'Analyzing your prompt...',
      'Preparing the canvas...',
      'Adding creative elements...',
      'Applying artistic style...',
      'Enhancing details...',
      'Finalizing your design...',
      'Almost ready...',
    ];
    
    for (final message in messages) {
      yield message;
      await Future.delayed(const Duration(seconds: 2));
    }
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class DotPatternPainter extends CustomPainter {
  final Color color;
  
  DotPatternPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    
    const spacing = 20.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
