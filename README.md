# PrintCraft AI - Print-on-Demand Platform

## 🎨 Overview

PrintCraft AI is a comprehensive Print-on-Demand (POD) application that leverages AI to generate unique, high-quality designs for t-shirts and other merchandise. The platform combines a Flutter mobile app with a robust Node.js/Express backend and AI-powered image generation through Replicate API.

## 🏗️ Architecture

The project follows a **Sub-Agent Software House** architecture pattern with:
- **Flutter UI Team**: Handles all mobile app development
- **AI Backend Team**: Manages API services, AI integration, and data processing
- **Orchestrator**: Coordinates between teams (planned implementation)

## 📁 Project Structure

```
print-craft-ai/
├── pod_app/                 # Flutter mobile application
│   ├── lib/
│   │   ├── core/           # Core functionality (theme, routing, providers)
│   │   ├── features/       # Feature modules (home, gallery, auth, etc.)
│   │   └── main.dart       # App entry point
│   └── android/            # Android-specific files
│
├── services/
│   └── api-gateway/        # Backend API service
│       ├── src/
│       │   ├── controllers/  # API endpoints
│       │   ├── services/     # Business logic
│       │   ├── middleware/   # Express middleware
│       │   └── models/       # Database models
│       └── prisma/          # Database schema and migrations
│
├── docker-compose.yml      # Local development environment
└── docs/                   # Documentation
```

## 🚀 Getting Started

### Prerequisites

- Node.js (v18+)
- Flutter SDK (3.x)
- Docker Desktop
- Android Studio with Android SDK
- PostgreSQL (via Docker)
- Redis (via Docker)

### Environment Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Tek-Fly/print-craft-ai.git
   cd print-craft-ai
   ```

2. **Backend Setup:**
   ```bash
   # Start Docker containers
   docker-compose up -d
   
   # Navigate to API service
   cd services/api-gateway
   
   # Install dependencies
   npm install
   
   # Run database migrations
   npx prisma migrate deploy
   
   # Generate Prisma client
   npx prisma generate
   
   # Start the development server
   npm run dev
   ```

3. **Flutter App Setup:**
   ```bash
   # Navigate to Flutter app
   cd pod_app
   
   # Get dependencies
   flutter pub get
   
   # Run on Android emulator
   flutter run
   ```

### Configuration

Create `.env` file in `services/api-gateway/`:
```env
# Database
DATABASE_URL=postgresql://printcraft:password@localhost:5432/printcraft_db

# Server
PORT=8000
NODE_ENV=development

# JWT
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRY=7d

# AI Services
REPLICATE_API_TOKEN=your_replicate_api_token
OPENAI_API_KEY=your_openai_api_key

# Storage (Cloudflare R2)
R2_ENDPOINT=https://your-account-id.r2.cloudflarestorage.com
R2_ACCESS_KEY_ID=your_access_key_id
R2_SECRET_ACCESS_KEY=your_secret_access_key
R2_BUCKET_NAME=printcraft-images

# Firebase
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=your-client-email
FIREBASE_PRIVATE_KEY=your-private-key
```

## 💻 Development

### Running the Backend

```bash
# Development mode with hot reload
npm run dev

# Production mode
npm run build
npm start

# Run tests
npm test

# Lint code
npm run lint
```

### Running the Flutter App

```bash
# Run on connected device/emulator
flutter run

# Build APK
flutter build apk

# Build for iOS (Mac only)
flutter build ios
```

### Database Management

```bash
# Create new migration
npx prisma migrate dev --name migration_name

# View database in Prisma Studio
npx prisma studio

# Reset database
npx prisma migrate reset
```

## 🎨 Features

### Current Features
- ✅ AI-powered image generation with 15 unique art styles
- ✅ User authentication (Firebase Auth)
- ✅ Image gallery with favorites
- ✅ Premium subscription system
- ✅ Real-time generation status updates
- ✅ High-resolution downloads (4500x5400 POD-ready)
- ✅ Dark/Light theme support

### In Development
- 🚧 Payment integration (Custom Cat API)
- 🚧 WebSocket real-time updates
- 🚧 Social sharing features
- 🚧 Batch processing
- 🚧 Admin dashboard

## 🛠️ Technology Stack

### Frontend
- **Flutter**: Cross-platform mobile framework
- **Provider**: State management
- **Firebase**: Authentication & analytics
- **Socket.io Client**: Real-time updates

### Backend
- **Node.js + TypeScript**: Runtime and language
- **Express.js**: Web framework
- **PostgreSQL**: Primary database
- **Redis**: Caching and session storage
- **Prisma**: ORM
- **Bull**: Job queue for async processing
- **Socket.io**: WebSocket server

### AI/ML
- **Replicate API**: AI image generation
- **OpenAI API**: Prompt enhancement
- **Sharp**: Image processing and optimization

### Infrastructure
- **Docker**: Containerization
- **Cloudflare R2**: Image storage (S3 compatible)
- **Firebase**: Auth and user management
- **GitHub Actions**: CI/CD (planned)

## 🎯 API Endpoints

### Authentication
```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout
```

### Generation
```
POST   /api/v1/generation/create
GET    /api/v1/generation/status/:id
GET    /api/v1/generation/history
GET    /api/v1/generation/styles
DELETE /api/v1/generation/:id
```

### User
```
GET    /api/v1/user/profile
PUT    /api/v1/user/profile
GET    /api/v1/user/subscription
POST   /api/v1/user/subscription/upgrade
```

## 🐛 Known Issues & TODOs

### High Priority
1. **TypeScript Compilation**: Fix strict mode errors in main server
2. **Authentication Flow**: Complete Firebase integration
3. **Payment Integration**: Implement Custom Cat API
4. **Flutter-Backend Connection**: Wire up API calls

### Medium Priority
1. **WebSocket Implementation**: Real-time generation updates
2. **Image Caching**: Implement proper caching strategy
3. **Error Handling**: Comprehensive error handling
4. **Testing**: Unit and integration tests

### Low Priority
1. **Documentation**: API documentation (Swagger)
2. **Monitoring**: Add logging and monitoring
3. **Performance**: Optimize database queries
4. **Security**: Security audit

## 📝 Code Style & Conventions

### Backend
- Use TypeScript strict mode
- Follow ESLint rules
- Use async/await over callbacks
- Implement proper error handling
- Add JSDoc comments for complex functions

### Flutter
- Follow Flutter style guide
- Use const constructors where possible
- Implement proper widget separation
- Handle null safety
- Add comments for complex logic

## 🤝 Contributing

1. Create feature branch: `git checkout -b feature/your-feature`
2. Commit changes: `git commit -m 'Add your feature'`
3. Push branch: `git push origin feature/your-feature`
4. Open Pull Request

## 📄 License

This project is proprietary software. All rights reserved.

## 👥 Team

- **Project Lead**: Tek-Fly
- **AI Integration**: Claude (Anthropic)
- **Contributors**: Open for collaboration

## 📞 Support

For issues and questions:
- GitHub Issues: https://github.com/Tek-Fly/print-craft-ai/issues
- Email: support@printcraft.ai (placeholder)

---

**Note for Next Developer**: 
- The backend API is fully functional on port 8000
- Flutter app compiles but needs API integration
- All credentials are in Google Cloud secrets
- Check IMPLEMENTATION_SUMMARY.md for detailed status