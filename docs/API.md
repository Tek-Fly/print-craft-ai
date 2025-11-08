# Appy Fly API Documentation

Base URL: `https://api.appyfly.com/v1`

## Authentication

All API requests require authentication via Bearer token:

```
Authorization: Bearer YOUR_API_TOKEN
```

Obtain tokens via Firebase Authentication:
- Email/Password
- Google OAuth
- Apple Sign In

## Endpoints

### Image Generation

#### POST /generations

Create a new AI image generation.

**Request:**
```json
{
  "prompt": "Bold motivational text: Dream Big",
  "style": "minimalist",
  "mode": "high_quality",
  "quality": "ultra",
  "advancedSettings": {
    "negativePrompt": "blurry, low quality",
    "aspectRatio": "4:3",
    "seed": 12345
  }
}
```

**Response:**
```json
{
  "id": "gen_abc123",
  "userId": "user_123",
  "status": "processing",
  "estimatedTime": 45,
  "estimatedCost": 0.10,
  "createdAt": "2024-11-08T10:30:00Z",
  "modelId": "imagen-4-ultra",
  "webhookUrl": "https://api.appyfly.com/v1/webhooks/generation/gen_abc123"
}
```

**Status Codes:**
- `201`: Generation created
- `400`: Invalid parameters
- `401`: Unauthorized
- `402`: Insufficient credits
- `429`: Rate limited

#### GET /generations/:id

Get generation status and result.

**Response:**
```json
{
  "id": "gen_abc123",
  "userId": "user_123",
  "status": "succeeded",
  "prompt": "Bold motivational text: Dream Big",
  "imageUrl": "https://storage.appyfly.com/generations/gen_abc123/image.png",
  "thumbnailUrl": "https://storage.appyfly.com/generations/gen_abc123/thumb.png",
  "progress": 100,
  "width": 4500,
  "height": 5400,
  "createdAt": "2024-11-08T10:30:00Z",
  "completedAt": "2024-11-08T10:30:45Z",
  "cost": 0.10,
  "modelUsed": "imagen-4-ultra",
  "metadata": {
    "processingTime": 45.2,
    "seed": 12345
  }
}
```

#### GET /generations

List user's generations.

**Query Parameters:**
- `limit` (number): Max results per page (default: 20, max: 100)
- `offset` (number): Pagination offset
- `status` (string): Filter by status
- `style` (string): Filter by style
- `sortBy` (string): Sort field (createdAt, cost)
- `order` (string): Sort order (asc, desc)

**Response:**
```json
{
  "data": [
    {
      "id": "gen_abc123",
      "prompt": "Bold motivational text: Dream Big",
      "status": "succeeded",
      "thumbnailUrl": "https://...",
      "createdAt": "2024-11-08T10:30:00Z"
    }
  ],
  "pagination": {
    "total": 156,
    "limit": 20,
    "offset": 0,
    "hasMore": true
  }
}
```

#### DELETE /generations/:id

Delete a generation and its images.

**Response:**
```json
{
  "message": "Generation deleted successfully"
}
```

### User Management

#### GET /users/profile

Get current user profile.

**Response:**
```json
{
  "id": "user_123",
  "email": "user@example.com",
  "displayName": "John Doe",
  "photoUrl": "https://...",
  "subscription": {
    "status": "active",
    "plan": "pro_monthly",
    "expiresAt": "2024-12-08T00:00:00Z"
  },
  "usage": {
    "freeGenerationsUsed": 3,
    "totalGenerations": 156,
    "creditsRemaining": 450.50
  },
  "preferences": {
    "defaultStyle": "minimalist",
    "defaultQuality": "ultra"
  },
  "createdAt": "2024-01-01T00:00:00Z"
}
```

#### PATCH /users/profile

Update user profile.

**Request:**
```json
{
  "displayName": "Jane Doe",
  "preferences": {
    "defaultStyle": "artistic"
  }
}
```

### Subscription Management

#### GET /subscriptions/plans

List available subscription plans.

**Response:**
```json
{
  "plans": [
    {
      "id": "pro_monthly",
      "name": "Pro Monthly",
      "price": 9.99,
      "currency": "USD",
      "interval": "month",
      "features": {
        "unlimitedGenerations": true,
        "premiumStyles": true,
        "priorityProcessing": true,
        "commercialLicense": true
      }
    }
  ]
}
```

#### POST /subscriptions/create

Create a new subscription.

**Request:**
```json
{
  "planId": "pro_monthly",
  "paymentMethodId": "pm_abc123"
}
```

### Styles & Models

#### GET /styles

List available generation styles.

**Response:**
```json
{
  "styles": [
    {
      "id": "minimalist",
      "name": "Minimalist",
      "description": "Clean, simple designs",
      "isPremium": false,
      "examples": ["https://..."]
    }
  ]
}
```

#### GET /models

List available AI models.

**Response:**
```json
{
  "models": [
    {
      "id": "imagen-4-ultra",
      "name": "Google Imagen 4 Ultra",
      "costPerImage": 0.10,
      "averageTime": 45,
      "quality": "ultra",
      "supportedStyles": ["all"]
    }
  ]
}
```

## Webhooks

Configure webhooks to receive real-time updates.

### Generation Completed
```json
{
  "event": "generation.completed",
  "timestamp": "2024-11-08T10:30:45Z",
  "data": {
    "id": "gen_abc123",
    "status": "succeeded",
    "imageUrl": "https://..."
  }
}
```

Verify webhook signatures:
```javascript
const signature = request.headers['x-appyfly-signature'];
const payload = JSON.stringify(request.body);
const expectedSignature = crypto
  .createHmac('sha256', WEBHOOK_SECRET)
  .update(payload)
  .digest('hex');

if (signature !== expectedSignature) {
  throw new Error('Invalid signature');
}
```

## Rate Limits

| Plan | Requests/Minute | Concurrent Generations |
|------|----------------|----------------------|
| Free | 10 | 1 |
| Pro | 100 | 5 |
| Enterprise | 1000 | 20 |

Rate limit headers:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1699439400
```

## Error Responses

```json
{
  "error": {
    "code": "insufficient_credits",
    "message": "You don't have enough credits for this operation",
    "details": {
      "required": 0.10,
      "available": 0.05
    }
  }
}
```

Common error codes:
- `invalid_prompt`: Prompt validation failed
- `insufficient_credits`: Not enough credits
- `rate_limited`: Too many requests
- `model_unavailable`: Selected model is offline
- `generation_failed`: AI model error

## SDKs

### JavaScript/TypeScript
```bash
npm install @appyfly/sdk
```

```javascript
import { AppyFlyClient } from '@appyfly/sdk';

const client = new AppyFlyClient({
  apiKey: 'YOUR_API_KEY'
});

const generation = await client.generations.create({
  prompt: 'Sunset landscape',
  style: 'watercolor'
});
```

### Flutter/Dart
```yaml
dependencies:
  appyfly_sdk: ^1.0.0
```

```dart
final client = AppyFlyClient(apiKey: 'YOUR_API_KEY');

final generation = await client.generateImage(
  prompt: 'Sunset landscape',
  style: 'watercolor',
);
```

## Pagination

Use cursor-based pagination for large datasets:

```
GET /generations?limit=20&cursor=eyJjcmVhdGVkQXQiOjE2OTk0Mzk0MDB9
```

Response includes next cursor:
```json
{
  "data": [...],
  "nextCursor": "eyJjcmVhdGVkQXQiOjE2OTk0Mzk1MDB9",
  "hasMore": true
}
```

## Versioning

API version in URL: `/v1/`

Deprecated endpoints return:
```
Sunset: Sat, 1 Jan 2025 00:00:00 GMT
```

## Status Page

Monitor API status: https://status.appyfly.com

Subscribe to updates via:
- Email notifications
- RSS feed
- Webhook notifications