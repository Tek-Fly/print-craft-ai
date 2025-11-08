---
name: flutter-pod-development
description: Professional Flutter development practices for Print-on-Demand applications with Provider state management, Material Design 3, and production-ready architecture
---

# Flutter POD Development Skill

This skill provides comprehensive Flutter development expertise for building production-ready Print-on-Demand applications.

## Core Competencies

### 1. Flutter Architecture

#### Clean Architecture Pattern
```dart
lib/
├── core/                    # Core functionality
│   ├── models/             # Data models
│   ├── services/           # Business logic
│   ├── providers/          # State management
│   └── theme/             # App theming
├── features/               # Feature modules
│   ├── home/
│   │   ├── data/          # Feature data layer
│   │   ├── domain/        # Feature business logic
│   │   └── presentation/  # UI components
│   └── [other_features]/
└── shared/                 # Shared components
```

### 2. Provider State Management

#### Provider Setup
```dart
// main.dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GenerationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserPreferencesProvider()),
      ],
      child: const PrintCraftApp(),
    ),
  );
}
```

#### Provider Best Practices
```dart
// Good: Selective rebuilds with Consumer
Consumer<GenerationProvider>(
  builder: (context, provider, child) {
    return GenerationDisplay(
      generation: provider.currentGeneration,
      isGenerating: provider.isGenerating,
    );
  },
)

// Good: Read without rebuild
final userId = context.read<AuthProvider>().currentUser?.id;

// Good: Selective listening
final isGenerating = context.select<GenerationProvider, bool>(
  (provider) => provider.isGenerating,
);
```

### 3. Material Design 3 Implementation

#### Theme Configuration
```dart
class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryLight,
        brightness: Brightness.light,
      ),
      typography: Typography.material2021(
        platform: defaultTargetPlatform,
      ),
      // Custom components
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
```

### 4. POD-Specific UI Components

#### Image Generation Display
```dart
class GenerationDisplay extends StatelessWidget {
  final GenerationModel? generation;
  final bool isGenerating;
  
  @override
  Widget build(BuildContext context) {
    if (isGenerating) {
      return _buildLoadingState();
    }
    
    if (generation == null) {
      return _buildEmptyState();
    }
    
    return _buildGeneratedImage();
  }
  
  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
```

### 5. Performance Optimization

#### Image Handling
```dart
// Good: Cached network images
CachedNetworkImage(
  imageUrl: generation.imageUrl,
  placeholder: (context, url) => const ShimmerLoading(),
  errorWidget: (context, url, error) => const ErrorPlaceholder(),
  cacheManager: DefaultCacheManager(),
  memCacheWidth: 800,  // Optimize memory usage
)

// Good: Lazy loading in lists
ListView.builder(
  itemCount: generations.length,
  itemBuilder: (context, index) {
    return GenerationTile(
      generation: generations[index],
      onTap: () => _showDetail(generations[index]),
    );
  },
)
```

### 6. Responsive Design

#### Adaptive Layouts
```dart
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 600) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}
```

### 7. Error Handling Patterns

#### User-Friendly Errors
```dart
class ErrorHandler {
  static void handleGenerationError(
    BuildContext context,
    GenerationException error,
  ) {
    final message = _getUserFriendlyMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        action: error.canRetry
            ? SnackBarAction(
                label: 'Retry',
                onPressed: error.retryCallback,
              )
            : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  static String _getUserFriendlyMessage(GenerationException error) {
    switch (error.type) {
      case GenerationErrorType.networkError:
        return 'Connection error. Please check your internet.';
      case GenerationErrorType.quotaExceeded:
        return 'You\'ve used all your free generations.';
      case GenerationErrorType.serverError:
        return 'Server is busy. Please try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
```

### 8. Testing Patterns

#### Widget Testing
```dart
testWidgets('Generation counter shows correct count', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => AuthProvider()..setFreeGenerations(3),
        child: const GenerationCounter(),
      ),
    ),
  );
  
  expect(find.text('3'), findsOneWidget);
  expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
});
```

#### Integration Testing
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Complete generation flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    
    // Enter prompt
    await tester.enterText(
      find.byType(PromptInputBar),
      'Bold motivational quote',
    );
    
    // Select style
    await tester.tap(find.text('Minimalist'));
    await tester.pumpAndSettle();
    
    // Generate
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();
    
    // Verify generation started
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

### 9. Accessibility

#### Semantic Labels
```dart
Semantics(
  label: 'Generate image button',
  hint: 'Double tap to generate image with current prompt',
  child: GenerateButton(
    onPressed: _handleGenerate,
  ),
)

// Image descriptions
CachedNetworkImage(
  imageUrl: generation.imageUrl,
  semanticsLabel: 'Generated ${generation.style} design: ${generation.prompt}',
)
```

### 10. Common Patterns

#### Debounced Search
```dart
class SearchDebouncer {
  final int milliseconds;
  Timer? _timer;
  
  SearchDebouncer({this.milliseconds = 500});
  
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
  
  void dispose() => _timer?.cancel();
}

// Usage
final _searchDebouncer = SearchDebouncer();

void _onSearchChanged(String query) {
  _searchDebouncer.run(() {
    context.read<GalleryProvider>().searchGenerations(query);
  });
}
```

#### Pull to Refresh
```dart
RefreshIndicator(
  onRefresh: () async {
    await context.read<GenerationProvider>().refreshGenerations();
  },
  child: ListView.builder(
    physics: const AlwaysScrollableScrollPhysics(),
    itemCount: generations.length,
    itemBuilder: (context, index) => GenerationTile(
      generation: generations[index],
    ),
  ),
)
```

### 11. Navigation Patterns

#### Named Routes
```dart
class AppRouter {
  static const String home = '/';
  static const String gallery = '/gallery';
  static const String premium = '/premium';
  static const String generationDetail = '/generation/:id';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      case gallery:
        return MaterialPageRoute(
          builder: (_) => const GalleryScreen(),
        );
      case premium:
        return MaterialPageRoute(
          builder: (_) => const PremiumScreen(),
          fullscreenDialog: true,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundScreen(),
        );
    }
  }
}
```

### 12. Platform-Specific Code

#### Conditional Imports
```dart
// platform_service.dart
export 'platform_service_stub.dart'
    if (dart.library.io) 'platform_service_mobile.dart'
    if (dart.library.html) 'platform_service_web.dart';

// Usage
final deviceInfo = await PlatformService.getDeviceInfo();
```

## Best Practices Checklist

- [ ] Use `const` constructors wherever possible
- [ ] Implement proper disposal in StatefulWidgets
- [ ] Handle loading, error, and empty states
- [ ] Use semantic widgets for accessibility
- [ ] Implement proper error boundaries
- [ ] Cache expensive computations
- [ ] Use keys for list items when needed
- [ ] Follow Material Design guidelines
- [ ] Test on multiple screen sizes
- [ ] Profile performance regularly

## Common Anti-Patterns to Avoid

1. **Rebuilding entire widget tree**
   ```dart
   // Bad
   setState(() {
     // Updates entire screen
   });
   
   // Good
   Consumer<SpecificProvider>(
     // Updates only affected widgets
   )
   ```

2. **Business logic in widgets**
   ```dart
   // Bad
   onPressed: () async {
     final response = await http.post(...);
     // Processing logic
   }
   
   // Good
   onPressed: () => context.read<Provider>().performAction(),
   ```

3. **Not handling async properly**
   ```dart
   // Bad
   FutureBuilder without error handling
   
   // Good
   FutureBuilder<T>(
     future: future,
     builder: (context, snapshot) {
       if (snapshot.hasError) return ErrorWidget();
       if (!snapshot.hasData) return LoadingWidget();
       return SuccessWidget(snapshot.data!);
     },
   )
   ```

## Performance Metrics

- App launch: < 2s
- Screen transition: < 300ms
- List scrolling: 60 FPS
- Image loading: Progressive with placeholder
- Memory usage: < 200MB baseline