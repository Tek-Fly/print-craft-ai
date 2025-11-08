import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/generation_model.dart';

class GenerationDetailModal extends StatefulWidget {
  final GenerationModel generation;
  
  const GenerationDetailModal({
    super.key,
    required this.generation,
  });

  @override
  State<GenerationDetailModal> createState() => _GenerationDetailModalState();
}

class _GenerationDetailModalState extends State<GenerationDetailModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _showDetails = true;
  double _currentScale = 1.0;
  Offset _currentOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleShare() {
    HapticFeedback.mediumImpact();
    if (widget.generation.imageUrl != null) {
      Share.share(
        'Check out this amazing design I created with PrintCraft AI!\n\n'
        'Prompt: ${widget.generation.prompt}\n'
        'Style: ${widget.generation.style}',
      );
    }
  }

  void _handleDownload() {
    HapticFeedback.mediumImpact();
    // Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Downloading in HD...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleRegenerate() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop('regenerate');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    
    return Container(
      height: size.height * 0.95,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                Text(
                  'Generation Details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showDetails = !_showDetails;
                    });
                  },
                  icon: Icon(
                    _showDetails ? Icons.info : Icons.info_outline,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          
          // Image
          Expanded(
            child: Stack(
              children: [
                // Zoomable Image
                InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Hero(
                        tag: 'generation_${widget.generation.id}',
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: widget.generation.imageUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: widget.generation.imageUrl!,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => Container(
                                      color: isDark
                                          ? AppColors.surfaceDark
                                          : AppColors.surfaceLight,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: isDark
                                          ? AppColors.surfaceDark
                                          : AppColors.surfaceLight,
                                      child: const Icon(
                                        Icons.error_outline,
                                        size: 48,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: double.infinity,
                                    height: 400,
                                    color: isDark
                                        ? AppColors.surfaceDark
                                        : AppColors.surfaceLight,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 64,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Details Overlay
                if (_showDetails)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Prompt
                          Text(
                            'Prompt',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.generation.prompt,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          
                          if (widget.generation.negativePrompt != null &&
                              widget.generation.negativePrompt!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Negative Prompt',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.generation.negativePrompt!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 12),
                          
                          // Metadata
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              _buildMetadataChip(
                                Icons.style,
                                widget.generation.style,
                              ),
                              _buildMetadataChip(
                                Icons.high_quality,
                                widget.generation.qualityLabel,
                              ),
                              _buildMetadataChip(
                                Icons.aspect_ratio,
                                widget.generation.aspectRatio,
                              ),
                              if (widget.generation.fileSize != null)
                                _buildMetadataChip(
                                  Icons.storage,
                                  widget.generation.formattedSize,
                                ),
                              _buildMetadataChip(
                                Icons.calendar_today,
                                _formatDate(widget.generation.createdAt),
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
          
          // Actions
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _handleRegenerate,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Regenerate'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 56),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _handleShare,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 56),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handleDownload,
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 56),
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

  Widget _buildMetadataChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white.withOpacity(0.7),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
