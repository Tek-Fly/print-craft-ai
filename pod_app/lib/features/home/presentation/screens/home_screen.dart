import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/generation_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/user_preferences_provider.dart';
import '../../widgets/prompt_input_bar.dart';
import '../../widgets/generation_display.dart';
import '../../widgets/generation_counter.dart';
import '../../widgets/style_selector.dart';
import '../../widgets/advanced_settings_sheet.dart';
import '../../../gallery/presentation/screens/gallery_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../premium/presentation/screens/premium_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _floatingButtonController;
  late AnimationController _pulseController;
  late TextEditingController _promptController;
  late ScrollController _scrollController;
  
  int _selectedIndex = 0;
  bool _showStyleOptions = false;
  
  @override
  void initState() {
    super.initState();
    _floatingButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _promptController = TextEditingController();
    _scrollController = ScrollController();
  }
  
  @override
  void dispose() {
    _floatingButtonController.dispose();
    _pulseController.dispose();
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _handleGenerate() {
    if (_promptController.text.trim().isEmpty) {
      _showEmptyPromptSnackbar();
      return;
    }
    
    final generationProvider = context.read<GenerationProvider>();
    final authProvider = context.read<AuthProvider>();
    
    if (!authProvider.hasGenerationsLeft) {
      Navigator.of(context).pushNamed('/premium');
      return;
    }
    
    HapticFeedback.lightImpact();
    generationProvider.generateImage(_promptController.text.trim());
  }
  
  void _showEmptyPromptSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text('Please describe what you want to create'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.1,
          left: 16,
          right: 16,
        ),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const GalleryScreen();
      case 2:
        return const ProfileScreen();
      default:
        return _buildHomeContent();
    }
  }
  
  Widget _buildHomeContent() {
    final generationProvider = context.watch<GenerationProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.backgroundDark,
                        AppColors.surfaceDark.withOpacity(0.5),
                      ]
                    : [
                        AppColors.backgroundLight,
                        AppColors.surfaceLight.withOpacity(0.8),
                      ],
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // App Header
                _buildHeader(authProvider),
                
                // Main Generation Area
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        
                        // Generation Display
                        GenerationDisplay(
                          generation: generationProvider.currentGeneration,
                          isGenerating: generationProvider.isGenerating,
                          onRetry: () => _handleGenerate(),
                          onShare: () => _shareImage(generationProvider),
                          onDownload: () => _downloadImage(generationProvider),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Style Options
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: _showStyleOptions ? 120 : 0,
                          child: _showStyleOptions
                              ? StyleSelector(
                                  onStyleSelected: (style) {
                                    generationProvider.setSelectedStyle(style);
                                  },
                                )
                              : const SizedBox.shrink(),
                        ),
                        
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Input Area
                _buildBottomInputArea(generationProvider, authProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader(AuthProvider authProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo and Title
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: isDark
                      ? AppColors.primaryGradientDark
                      : AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark
                              ? AppColors.primaryDark
                              : AppColors.primaryLight)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PrintCraft AI',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    'Create Amazing Designs',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          
          // Generation Counter
          GenerationCounter(
            freeGenerations: authProvider.freeGenerationsLeft,
            isPro: authProvider.isPro,
            onTap: () {
              if (!authProvider.isPro) {
                Navigator.of(context).pushNamed('/premium');
              }
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomInputArea(
    GenerationProvider generationProvider,
    AuthProvider authProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.borderDark
                  : AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Style and Settings Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Style Toggle
                _buildActionButton(
                  icon: Icons.palette_outlined,
                  label: 'Style',
                  isActive: _showStyleOptions,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _showStyleOptions = !_showStyleOptions;
                    });
                  },
                ),
                const SizedBox(width: 8),
                
                // Advanced Settings
                _buildActionButton(
                  icon: Icons.tune,
                  label: 'Settings',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showAdvancedSettings();
                  },
                ),
                
                const Spacer(),
                
                // Quick Actions
                if (generationProvider.recentGenerations.isNotEmpty)
                  _buildActionButton(
                    icon: Icons.history,
                    label: 'Recent',
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                  ),
              ],
            ),
          ),
          
          // Prompt Input Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: PromptInputBar(
              controller: _promptController,
              onSubmit: _handleGenerate,
              isGenerating: generationProvider.isGenerating,
              hasGenerationsLeft: authProvider.hasGenerationsLeft,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                    .withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive
                    ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isActive
                          ? (isDark
                              ? AppColors.primaryDark
                              : AppColors.primaryLight)
                          : null,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showAdvancedSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AdvancedSettingsSheet(),
    );
  }
  
  void _shareImage(GenerationProvider provider) {
    if (provider.currentGeneration != null) {
      // Share functionality implementation
      HapticFeedback.mediumImpact();
    }
  }
  
  void _downloadImage(GenerationProvider provider) {
    if (provider.currentGeneration != null) {
      // Download functionality implementation
      HapticFeedback.mediumImpact();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: Container(
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
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Create',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_outlined),
                activeIcon: Icon(Icons.grid_view),
                label: 'Gallery',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
