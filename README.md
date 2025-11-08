# PrintCraft AI - Print-on-Demand Platform

## 🎨 Overview

PrintCraft AI is a comprehensive Print-on-Demand (POD) application that leverages AI to generate unique, high-quality designs for t-shirts and other merchandise. The platform combines a Flutter mobile app with a robust Node.js/Express backend and AI-powered image generation through Replicate API.

## 🏗️ Architecture

The project follows a **Sub-Agent Software House** architecture pattern with:
- **Flutter UI Team**: Handles all mobile app development.
- **AI Backend Team**: Manages API services, AI integration, and data processing.
- **Orchestrator**: Coordinates between teams.

##  وضعیت پروژه (Project Status)

**Backend**: The core Express.js server is now **stable and compiles correctly**. The basic infrastructure for handling requests, queuing jobs (Redis/Bull), and communicating with the database (PostgreSQL/Prisma) is in place. However, many features are still in early development.

**Frontend**: The Flutter application **compiles and runs on an emulator**, but it is **not yet connected** to the backend. The UI is largely built with mock data.

## 📁 Project Structure

```
print-craft-ai/
├── pod_app/                 # Flutter mobile application
├── services/
│   └── api-gateway/        # Backend API service
├── docker-compose.yml      # Local development environment
└── docs/                   # Documentation
```

## 🚀 Getting Started

### Prerequisites

- Node.js (v18+)
- Flutter SDK (3.x)
- Docker Desktop
- Android Studio with Android SDK

### Environment Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Tek-Fly/print-craft-ai.git
    cd print-craft-ai
    ```

2.  **Backend Setup:**
    ```bash
    # Start Docker containers (PostgreSQL and Redis)
    docker-compose up -d
   
    # Navigate to the API service directory
    cd services/api-gateway
   
    # Install dependencies
    npm install
   
    # Run database migrations to create the schema
    npx prisma migrate deploy
   
    # Start the development server
    npm run dev
    ```

3.  **Flutter App Setup:**
    ```bash
    # Navigate to the Flutter app directory
    cd pod_app
   
    # Install dependencies
    flutter pub get
   
    # Run the app on an Android emulator
    flutter run
    ```

### Configuration

Create a `.env` file in `services/api-gateway/`. A `.env.example` is provided in the root.

```env
# Database
DATABASE_URL=postgresql://printcraft:password@localhost:5432/printcraft_db

# Server
PORT=8000
NODE_ENV=development

# JWT
JWT_SECRET=your_jwt_secret_key_here
JWT_EXPIRY=7d

# AI Services
REPLICATE_API_TOKEN=your_replicate_api_token_here

# Storage (Cloudflare R2)
R2_ENDPOINT=https://<your-account-id>.r2.cloudflarestorage.com
R2_ACCESS_KEY_ID=your_access_key_id_here
R2_SECRET_ACCESS_KEY=your_secret_access_key_here
R2_BUCKET_NAME=printcraft-images

# Firebase (for authentication)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=your-client-email
FIREBASE_PRIVATE_KEY="your-private-key"
```

## 🎨 Features

### Foundational Features (In Place)
- ✅ **Backend Server**: Express.js server is stable and running.
- ✅ **Database**: PostgreSQL schema is defined with Prisma.
- ✅ **Job Queue**: Redis and Bull are configured for background job processing.
- ✅ **Docker Environment**: `docker-compose.yml` for easy local setup.

### In Development
- 🚧 **AI Image Generation**: The API endpoint exists, but the background worker that calls the Replicate API is not yet implemented.
- 🚧 **User Authentication**: API routes for auth exist, but the Firebase Admin SDK integration is not complete.
- 🚧 **Flutter <-> Backend Connection**: The Flutter app uses only mock data and does not yet make API calls.
- 🚧 **Payment Integration**: Stubbed out but not implemented.
- 🚧 **Real-time Updates**: WebSocket server is set up, but no events are being sent.
- 🚧 **Image Storage**: Cloudflare R2 service is written but not yet integrated into the generation flow.

## 🛠️ Technology Stack

- **Frontend**: Flutter, Provider
- **Backend**: Node.js, Express.js, TypeScript, PostgreSQL, Prisma, Redis, Bull, Socket.io
- **AI/ML**: Replicate API (to be implemented)
- **Infrastructure**: Docker, Cloudflare R2

## 🎯 API Endpoints

The following endpoints are available but may not be fully implemented.

### Authentication
`POST   /api/v1/auth/login`
`POST   /api/v1/auth/refresh`

### Generation
`POST   /api/v1/generation`
`GET    /api/v1/generation/styles`
`GET    /api/v1/generation/history`
`GET    /api/v1/generation/:id`
`DELETE /api/v1/generation/:id`

### User (Placeholder)
`GET    /api/v1/user/profile`
`PUT    /api/v1/user/profile`

## 🐛 High-Priority TODOs

1.  **Implement AI Worker**: Create the worker process that consumes jobs from the Bull queue, calls the Replicate API, and updates the generation status in the database.
2.  **Complete Firebase Auth**: Finish the `validateFirebaseToken` function in `auth.service.ts` using the Firebase Admin SDK to allow real user logins.
3.  **Connect Flutter to Backend**: Refactor the Flutter `generation_provider.dart` and create an `api_service.dart` to make real network requests to the backend.
4.  **Implement Image Upload**: In the AI worker, after a successful generation, upload the resulting image to Cloudflare R2 using the `StorageService`.
5.  **Flesh out Stubbed Routes**: Implement the logic for the user, subscription, and payment routes.

---
For project history and older documentation, please refer to the Git history. This README reflects the current, post-refactoring state of the project.