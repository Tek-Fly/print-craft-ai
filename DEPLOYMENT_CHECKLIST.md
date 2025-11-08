# PrintCraft AI - Deployment Checklist

## 🚀 Pre-Deployment Checklist

### 1. API Configuration ✓

#### Get Replicate API Token
- [ ] Sign up at [replicate.com](https://replicate.com)
- [ ] Navigate to Account Settings
- [ ] Copy API token (starts with `r8_`)
- [ ] Store securely (never commit to git)

#### Configure Environment
```bash
# Development (.env file)
REPLICATE_API_TOKEN=r8_your_token_here

# Or export in shell
export REPLICATE_API_TOKEN=r8_your_token_here
```

### 2. Dependencies ✓

#### Install Required Packages
```bash
cd pod_app
flutter pub get
```

#### Verify Dependencies in pubspec.yaml
- [x] dio: ^5.4.0
- [x] flutter_secure_storage: ^9.0.0
- [x] provider: ^6.1.1
- [x] uuid: ^4.3.1
- [x] All other existing dependencies

### 3. Code Integration 🔧

#### Copy New Files
All files are in `/mnt/user-data/outputs/pod_app_with_replicate/`:

**Core Services:**
- [ ] `lib/core/models/ai_model.dart` (NEW)
- [ ] `lib/core/services/replicate_service.dart` (NEW)
- [ ] `lib/core/services/prompt_enhancement_service.dart` (NEW)
- [ ] `lib/core/services/integrated_generation_service.dart` (NEW)

**Configuration:**
- [ ] `lib/config/replicate_config.dart` (NEW)

**Updated Files:**
- [ ] `lib/core/models/generation_model.dart` (UPDATED - has new fields)
- [ ] `pubspec.yaml` (UPDATED - added flutter_secure_storage)

**Examples & Documentation:**
- [ ] `lib/core/providers/generation_provider_example.dart` (EXAMPLE)
- [ ] `IMPLEMENTATION_PLAN.md`
- [ ] `REPLICATE_INTEGRATION.md`
- [ ] `USAGE_GUIDE.md`
- [ ] `PROJECT_SUMMARY.md`

#### Update Existing Code

1. **Update Generation Provider**
```dart
// Replace existing generation_provider.dart with:
import '../services/integrated_generation_service.dart';
import '../models/ai_model.dart';

class GenerationProvider with ChangeNotifier {
  final IntegratedGenerationService _service;
  
  GenerationProvider() 
      : _service = IntegratedGenerationService() {
    _service.initialize();
  }
  
  // Use new service methods...
}
```

2. **Update Main App**
```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GenerationProvider()..initialize(),
        ),
      ],
      child: MyApp(),
    ),
  );
}
```

### 4. API Token Setup 🔐

#### Option A: Development (Environment Variable)
```dart
// Automatically loaded from environment
final service = IntegratedGenerationService();
await service.initialize(); // Reads from env var
```

#### Option B: Production (Secure Storage)
```dart
// First time setup screen
final service = IntegratedGenerationService();
await service.setApiToken('r8_your_token_here');
await service.initialize();
```

#### Option C: User Configuration
```dart
// Settings screen where user enters their own token
TextField(
  controller: apiTokenController,
  obscureText: true,
  decoration: InputDecoration(
    labelText: 'Replicate API Token',
    hintText: 'r8_...',
  ),
);

ElevatedButton(
  onPressed: () async {
    await provider.setApiToken(apiTokenController.text);
  },
  child: Text('Save'),
);
```

### 5. UI Integration 🎨

#### Update Generation Screen
```dart
// Use the example in generation_provider_example.dart
// Or integrate into your existing home_screen.dart

// Key components needed:
- Mode selector (High Quality / Credit Efficiency)
- Cost estimator widget
- Progress indicator
- Result display
- Error handling
```

#### Add Mode Switcher
```dart
PopupMenuButton<GenerationMode>(
  onSelected: (mode) => provider.setMode(mode),
  itemBuilder: (context) => [
    PopupMenuItem(
      value: GenerationMode.highQuality,
      child: Text('⭐ High Quality'),
    ),
    PopupMenuItem(
      value: GenerationMode.creditEfficiency,
      child: Text('⚡ Fast & Cheap'),
    ),
  ],
);
```

### 6. Testing 🧪

#### Basic Tests
- [ ] Test with quick preview (FLUX Schnell)
  ```dart
  await provider.generateQuickPreview(
    userId: 'test_user',
    prompt: 'Test design',
    style: 'minimalist',
  );
  ```

- [ ] Test with high quality (Imagen 4)
  ```dart
  await provider.generateHighQuality(
    userId: 'test_user',
    prompt: 'Test design',
    style: 'realistic',
  );
  ```

- [ ] Test progress updates
- [ ] Test error handling (invalid token)
- [ ] Test cancellation
- [ ] Test cost estimation

#### Integration Tests
- [ ] Full generation workflow
- [ ] Image download
- [ ] Storage integration
- [ ] Firebase integration
- [ ] Payment integration

### 7. Platform Configuration 📱

#### iOS
```xml
<!-- ios/Runner/Info.plist -->
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to save your generated designs</string>
```

#### Android
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### 8. Security Review 🔒

- [ ] API token never in source code
- [ ] API token never in git history
- [ ] Using FlutterSecureStorage for token
- [ ] .env file in .gitignore
- [ ] No console.log of sensitive data
- [ ] HTTPS only for API calls

### 9. Cost Management 💰

#### Set Up Monitoring
- [ ] Track generations per user
- [ ] Track total cost
- [ ] Set up alerts for high usage
- [ ] Implement rate limiting

#### User Limits
```dart
class GenerationLimits {
  static const int freeUserLimit = 3;
  static const int premiumUserLimit = 100;
  
  bool canGenerate(User user) {
    return user.generationCount < getLimit(user);
  }
  
  int getLimit(User user) {
    return user.isPremium 
        ? premiumUserLimit 
        : freeUserLimit;
  }
}
```

### 10. Error Handling 🚨

#### Implement Global Error Handler
```dart
try {
  await generateImage(...);
} on ReplicateException catch (e) {
  if (e.code == ReplicateErrorCodes.unauthorized) {
    // Show API token setup dialog
    showApiTokenDialog();
  } else if (e.code == ReplicateErrorCodes.rateLimited) {
    // Show rate limit message
    showSnackBar('Too many requests. Please wait.');
  } else {
    // Show generic error
    showErrorDialog(e.message);
  }
}
```

### 11. Analytics 📊

#### Track Important Events
```dart
// Generation started
analytics.logEvent(
  name: 'generation_started',
  parameters: {
    'mode': mode.name,
    'style': style,
  },
);

// Generation completed
analytics.logEvent(
  name: 'generation_completed',
  parameters: {
    'model': generation.aiModel,
    'time_seconds': duration.inSeconds,
    'cost': estimatedCost,
  },
);

// Generation failed
analytics.logEvent(
  name: 'generation_failed',
  parameters: {
    'error_code': error.code,
    'error_message': error.message,
  },
);
```

### 12. Performance Optimization ⚡

- [ ] Implement image caching
- [ ] Use CDN for generated images
- [ ] Lazy load generation history
- [ ] Optimize polling frequency
- [ ] Implement request debouncing

### 13. Documentation 📚

- [ ] Read IMPLEMENTATION_PLAN.md
- [ ] Read REPLICATE_INTEGRATION.md
- [ ] Read USAGE_GUIDE.md
- [ ] Read PROJECT_SUMMARY.md
- [ ] Update team documentation

## 🎯 Quick Start Verification

Run this checklist to verify everything works:

```dart
// 1. Can initialize?
final service = IntegratedGenerationService();
final initialized = await service.initialize();
print('Initialized: $initialized'); // Should be true

// 2. Can estimate cost?
final cost = service.estimateCost(
  mode: GenerationMode.creditEfficiency,
  count: 1,
);
print('Cost: \$${cost.toStringAsFixed(3)}'); // Should be $0.003

// 3. Can generate?
final generation = await service.generateImage(
  userId: 'test',
  prompt: 'Simple test',
  style: 'minimalist',
  mode: GenerationMode.creditEfficiency,
  onProgress: (gen) => print('Progress: ${gen.progress}%'),
);
print('Success: ${generation.imageUrl}'); // Should have URL

// 4. Can download?
final bytes = await service.downloadImage(generation.imageUrl!);
print('Downloaded: ${bytes.length} bytes'); // Should have data
```

## ✅ Final Checks Before Launch

- [ ] All tests passing
- [ ] No API token in code
- [ ] Error handling working
- [ ] Progress indicators showing
- [ ] Cost tracking enabled
- [ ] Analytics configured
- [ ] Rate limiting active
- [ ] User limits enforced
- [ ] Image storage working
- [ ] Payment integration tested
- [ ] Both platforms (iOS/Android) tested
- [ ] Documentation updated

## 🚀 Deploy!

Once all checks pass:

1. **Build app**
   ```bash
   flutter build apk --release  # Android
   flutter build ios --release  # iOS
   ```

2. **Test in production environment**

3. **Monitor first users carefully**

4. **Track costs and usage**

5. **Gather user feedback**

## 📞 Support

If you need help:
- Check documentation in `/docs`
- Review examples in `generation_provider_example.dart`
- Check Replicate API status
- Contact: info@tekfly.io

---

**Remember:** Start with Credit Efficiency mode for testing to minimize costs!

**Estimated Setup Time:** 2-4 hours
**Estimated Testing Time:** 2-3 hours

Good luck! 🚀
