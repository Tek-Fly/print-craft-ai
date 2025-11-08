import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class StyleSelector extends StatefulWidget {
  final Function(String) onStyleSelected;
  final String? selectedStyle;

  const StyleSelector({
    super.key,
    required this.onStyleSelected,
    this.selectedStyle,
  });

  @override
  State<StyleSelector> createState() => _StyleSelectorState();
}

class _StyleSelectorState extends State<StyleSelector> {
  late String _selectedStyle;
  late ScrollController _scrollController;

  final List<StyleOption> styles = [
    StyleOption(id: 'realistic', name: 'Realistic', emoji: '📸', color: Colors.blue),
    StyleOption(id: 'artistic', name: 'Artistic', emoji: '🎨', color: Colors.purple),
    StyleOption(id: 'cartoon', name: 'Cartoon', emoji: '🎭', color: Colors.orange),
    StyleOption(id: 'anime', name: 'Anime', emoji: '🌸', color: Colors.pink),
    StyleOption(id: 'vintage', name: 'Vintage', emoji: '📷', color: Colors.brown),
    StyleOption(id: 'minimalist', name: 'Minimal', emoji: '⚪', color: Colors.grey),
    StyleOption(id: 'abstract', name: 'Abstract', emoji: '🌀', color: Colors.indigo),
    StyleOption(id: 'watercolor', name: 'Watercolor', emoji: '💧', color: Colors.cyan),
    StyleOption(id: 'neon', name: 'Neon', emoji: '✨', color: Colors.deepPurple, isPremium: true),
    StyleOption(id: '3d', name: '3D Render', emoji: '🎮', color: Colors.green, isPremium: true),
  ];

  @override
  void initState() {
    super.initState();
    _selectedStyle = widget.selectedStyle ?? 'realistic';
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Choose Style',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              physics: const BouncingScrollPhysics(),
              itemCount: styles.length,
              itemBuilder: (context, index) {
                final style = styles[index];
                final isSelected = style.id == _selectedStyle;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedStyle = style.id;
                      });
                      widget.onStyleSelected(style.id);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 85 : 75,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  style.color.withOpacity(0.3),
                                  style.color.withOpacity(0.1),
                                ],
                              )
                            : null,
                        color: !isSelected
                            ? (isDark
                                ? AppColors.surfaceDark
                                : AppColors.surfaceLight)
                            : null,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? style.color
                              : (isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: style.color.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (style.isPremium)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                gradient: AppColors.proBadgeGradient,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'PRO',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            style.emoji,
                            style: TextStyle(fontSize: isSelected ? 28 : 24),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            style.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected
                                  ? style.color
                                  : (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StyleOption {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final bool isPremium;

  StyleOption({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    this.isPremium = false,
  });
}
