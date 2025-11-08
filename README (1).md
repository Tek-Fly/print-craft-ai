# PrintCraft AI - Replicate Integration Package

## 📦 What's Included

This package contains a complete, production-ready implementation of AI image generation for PrintCraft AI using the Replicate API.

## 🎯 Overview

**What it does:**
- Generates high-quality POD t-shirt designs using AI
- Supports multiple models (Imagen 4, FLUX variants)
- Two modes: High Quality & Credit Efficiency
- Automatic prompt enhancement using PrintMaster Pro
- Full progress tracking and error handling
- Cost estimation and optimization

**Cost Range:**
- Quick Preview: $0.003 per image (~2 seconds)
- Standard Quality: $0.025 per image (~15 seconds)  
- Premium Quality: $0.06-0.10 per image (~45-50 seconds)

## 🚀 Quick Start (5 Minutes)

### Step 1: Get Your API Token
1. Visit [replicate.com](https://replicate.com)
2. Sign up/login
3. Go to Settings → API Tokens
4. Copy your token (starts with `r8_`)

### Step 2: Set Up Environment
```bash
# Create .env file (don't commit this!)
echo "REPLICATE_API_TOKEN=r8_your_token_here" > .env

# Or export in your shell
export REPLICATE_API_TOKEN=r8_your_token_here
```

### Step 3: Install Dependencies
```bash
cd pod_app_with_replicate
flutter pub get
```

### Step 4: Test Integration
```dart
// In your main.dart or test file
final service = IntegratedGenerationService();
await service.initialize();

final generation = await service.generateImage(
  userId: 'test_user',
  prompt: 'Bold motivational text: "Never Give Up"',
  style: 'minimalist',
  mode: GenerationMode.creditEfficiency, // Start cheap!
  onProgress: (gen) => print('Progress: ${gen.progress}%'),
);

print('✅ Success! Image: ${generation.imageUrl}');
```

## 📖 Documentation

**Essential Reading (in order):**

1. **PROJECT_SUMMARY.md** ⭐ START HERE
2. **USAGE_GUIDE.md** 📱
3. **REPLICATE_INTEGRATION.md** 🔧
4. **IMPLEMENTATION_PLAN.md** 🏗️
5. **DEPLOYMENT_CHECKLIST.md** ✅

## 📁 Package Structure

```
pod_app_with_replicate/
├── lib/core/
│   ├── models/
│   │   ├── ai_model.dart                      ⭐ NEW
│   │   └── generation_model.dart              🔄 UPDATED
│   ├── services/
│   │   ├── replicate_service.dart             ⭐ NEW
│   │   ├── prompt_enhancement_service.dart    ⭐ NEW
│   │   └── integrated_generation_service.dart ⭐ NEW
│   ├── providers/
│   │   └── generation_provider_example.dart   📝 EXAMPLE
│   └── config/
│       └── replicate_config.dart              ⭐ NEW
├── pubspec.yaml                                🔄 UPDATED
└── [Documentation Files]                       📚 NEW
```

## 🎨 AI Models Available

### High Quality Mode
- **Imagen 4 Ultra**: $0.10/image, 45s, professional quality
- **FLUX 1.1 Pro Ultra**: $0.06/image, 50s, 4MP output

### Credit Efficiency Mode
- **FLUX Schnell**: $0.003/image, 2s, rapid iteration ⚡
- **SeeDream 4**: $0.025/image, 15s, balanced quality

## 💡 Recommended Workflow

```dart
// 1. Quick preview for iteration (cheap & fast)
await service.generateQuickPreview(...);

// 2. Final high-quality version (when user is happy)
await service.generateHighQuality(...);
```

**Saves ~$0.10 per iteration!**

## 🔐 Security

**⚠️ Never commit API tokens!**

✅ Use environment variables  
✅ Use Flutter Secure Storage  
✅ Use `.env` files (in .gitignore)

## 📊 Cost Examples

- **Development** (100 previews): $0.30
- **Production** (10 finals): $1.00
- **Mixed workflow**: $1.15 for 60 generations

## 🔧 Integration (2-4 hours)

1. Copy files (5 min)
2. Configure API (5 min)
3. Update UI (30-60 min)
4. Test (30 min)
5. Deploy (varies)

See **DEPLOYMENT_CHECKLIST.md** for details.

## 🆘 Support

- Check the 5 documentation files
- Review examples in code
- Visit https://replicate.com/docs
- Email: info@tekfly.io

## 🎉 Ready to Go!

Everything you need:
- ✅ Production-ready code
- ✅ Complete documentation
- ✅ Working examples
- ✅ Security best practices

**Start with PROJECT_SUMMARY.md** 📖

---

**Version**: 1.0.0 | **Created**: November 2025
