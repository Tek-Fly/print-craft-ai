# PrintCraft AI API Gateway

## Overview

The API Gateway is the main backend service for PrintCraft AI, handling authentication, image generation requests, subscriptions, and payments.

## Tech Stack

- **Node.js** with TypeScript
- **Express** for HTTP server
- **Socket.io** for real-time updates
- **PostgreSQL** with Prisma ORM
- **Redis** for caching and queues
- **Bull** for job queue management
- **JWT** for authentication

## Setup

### Prerequisites

- Node.js 18+
- PostgreSQL 14+
- Redis 6+

### Installation

```bash
# Install dependencies
npm install

# Copy environment variables
cp .env.example .env

# Edit .env with your configuration
```

### Database Setup

```bash
# Generate Prisma client
npx prisma generate

# Run migrations
npx prisma migrate dev

# Seed database (optional)
npx prisma db seed
```

### Development

```bash
# Run in development mode
npm run dev

# Run tests
npm test

# Run linting
npm run lint
```

### Production

```bash
# Build TypeScript
npm run build

# Start production server
npm start
```

## API Endpoints

### Authentication
- `POST /api/v1/auth/login` - Login with Firebase token
- `POST /api/v1/auth/refresh` - Refresh access token
- `POST /api/v1/auth/logout` - Logout user
- `GET /api/v1/auth/verify` - Verify current token

### User
- `GET /api/v1/user/profile` - Get user profile
- `PUT /api/v1/user/profile` - Update profile
- `GET /api/v1/user/stats` - Get user statistics
- `DELETE /api/v1/user` - Delete account

### Image Generation
- `POST /api/v1/generation/create` - Create new generation
- `GET /api/v1/generation/status/:id` - Get generation status
- `GET /api/v1/generation/user` - Get user's generations
- `DELETE /api/v1/generation/:id` - Delete generation
- `POST /api/v1/generation/regenerate/:id` - Regenerate image

### Subscription
- `GET /api/v1/subscription/plans` - Get available plans
- `GET /api/v1/subscription/status` - Get subscription status
- `POST /api/v1/subscription/create` - Create subscription
- `PUT /api/v1/subscription/update` - Update subscription
- `POST /api/v1/subscription/cancel` - Cancel subscription

### Payment
- `POST /api/v1/payment/create-intent` - Create payment intent
- `POST /api/v1/payment/confirm` - Confirm payment
- `GET /api/v1/payment/history` - Get payment history

### Styles
- `GET /api/v1/styles/list` - Get available styles
- `GET /api/v1/styles/details/:id` - Get style details

### Health
- `GET /api/v1/health` - Basic health check
- `GET /api/v1/health/detailed` - Detailed health check
- `GET /api/v1/health/ready` - Readiness probe
- `GET /api/v1/health/live` - Liveness probe

## WebSocket Events

### Client → Server
- `subscribe:generation` - Subscribe to generation updates
- `unsubscribe:generation` - Unsubscribe from generation
- `ping` - Keep connection alive

### Server → Client
- `generation:update` - Generation status update
- `generation:complete` - Generation completed
- `generation:failed` - Generation failed
- `queue:update` - Queue position update
- `subscription:update` - Subscription changes
- `system:message` - System notifications

## Environment Variables

See `.env.example` for all required environment variables.

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌────────────┐
│   Flutter   │────▶│  API Gateway │────▶│ PostgreSQL │
│     App     │     └──────────────┘     └────────────┘
└─────────────┘            │                     
                           │              ┌────────────┐
                           ├─────────────▶│   Redis    │
                           │              └────────────┘
                           │                     
                           │              ┌────────────┐
                           └─────────────▶│ Replicate  │
                                          │    API     │
                                          └────────────┘
```

## Security

- JWT-based authentication
- Rate limiting on all endpoints
- API key support for programmatic access
- CORS configuration
- Helmet.js for security headers
- Input validation on all endpoints
- SQL injection protection via Prisma

## Monitoring

- Health check endpoints
- Structured logging with Winston
- Request/response logging
- Error tracking
- Performance metrics

## Development Guidelines

1. Use TypeScript strict mode
2. Follow ESLint rules
3. Write tests for new features
4. Document API changes
5. Use conventional commits
6. Keep dependencies updated

## Deployment

The service is designed to be deployed with:
- Docker containers
- Kubernetes orchestration
- Auto-scaling based on load
- Rolling updates
- Health checks

## License

Copyright (c) 2025 Tekfly Ltd. All rights reserved.