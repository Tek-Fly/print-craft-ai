import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class PromptInputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final bool isGenerating;
  final bool hasGenerationsLeft;

  const PromptInputBar({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.isGenerating = false,
    this.hasGenerationsLeft = true,
  });

  @override
  State<PromptInputBar> createState() => _PromptInputBarState();
}

class _PromptInputBarState extends State<PromptInputBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (widget.controller.text.trim().isNotEmpty && !widget.isGenerating) {
      HapticFeedback.lightImpact();
      widget.onSubmit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: _isFocused
            ? (isDark
                ? AppColors.primaryGradientDark
                : AppColors.primaryGradient)
            : null,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _isFocused
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
      padding: _isFocused ? const EdgeInsets.all(2) : EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(22),
          border: !_isFocused
              ? Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1.5,
                )
              : null,
        ),
        child: Row(
          children: [
            // Text Input
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                maxLines: 3,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleSubmit(),
                enabled: !widget.isGenerating,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: widget.hasGenerationsLeft
                      ? 'Describe your perfect design...'
                      : 'Upgrade to Pro for unlimited designs',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Icon(
                      Icons.auto_awesome_outlined,
                      color: _isFocused
                          ? (isDark
                              ? AppColors.primaryDark
                              : AppColors.primaryLight)
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                      size: 22,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                ),
              ),
            ),
            
            // Generate Button
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTapDown: (_) => _animationController.forward(),
                    onTapUp: (_) {
                      _animationController.reverse();
                      _handleSubmit();
                    },
                    onTapCancel: () => _animationController.reverse(),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: widget.isGenerating ? 48 : 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: widget.controller.text.trim().isNotEmpty &&
                                widget.hasGenerationsLeft
                            ? (isDark
                                ? AppColors.primaryGradientDark
                                : AppColors.primaryGradient)
                            : null,
                        color: widget.controller.text.trim().isEmpty ||
                                !widget.hasGenerationsLeft
                            ? (isDark
                                ? AppColors.chipBackgroundDark
                                : AppColors.chipBackgroundLight)
                            : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: widget.controller.text.trim().isNotEmpty &&
                                widget.hasGenerationsLeft
                            ? [
                                BoxShadow(
                                  color: (isDark
                                          ? AppColors.primaryDark
                                          : AppColors.primaryLight)
                                      .withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: widget.isGenerating
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    widget.controller.text.trim().isNotEmpty
                                        ? Colors.white
                                        : (isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight),
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.arrow_upward,
                                color: widget.controller.text.trim().isNotEmpty &&
                                        widget.hasGenerationsLeft
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight),
                                size: 22,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
