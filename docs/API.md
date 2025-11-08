# PrintCraft AI API Documentation

**Base URL**: `/api/v1`

## Authentication

All API requests to protected endpoints require authentication via a JWT Bearer token.

**Authorization Header:**
`Authorization: Bearer YOUR_JWT_TOKEN`

Tokens are obtained by logging in via the `/auth/login` endpoint using a Firebase ID token.

---

## Endpoints

### Authentication

#### `POST /auth/login`
Authenticates a user with a Firebase ID token and returns a JWT session token.

**Request Body:**
```json
{
  "idToken": "<USER_FIREBASE_ID_TOKEN>"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": { "..." },
    "tokens": {
      "accessToken": "...",
      "refreshToken": "..."
    }
  }
}
```

#### `POST /auth/refresh`
Refreshes an expired access token using a valid refresh token.

**Request Body:**
```json
{
  "refreshToken": "<YOUR_REFRESH_TOKEN>"
}
```

### Image Generation

#### `POST /generation`
Creates and queues a new AI image generation task.

**Request Body:**
```json
{
  "prompt": "A majestic lion wearing a crown, vintage poster style",
  "style": "VINTAGE_POSTER"
}
```

**Response (`202 Accepted`):**
```json
{
  "success": true,
  "message": "Generation has been queued.",
  "data": {
    "generationId": "clx...",
    "status": "PENDING"
  }
}
```

#### `GET /generation/history`
Retrieves a paginated list of the user's past generations.

**Query Parameters:**
- `page` (number, optional, default: 1)
- `limit` (number, optional, default: 10)

**Response:**
```json
{
    "success": true,
    "data": [
        {
            "id": "clx...",
            "prompt": "A majestic lion...",
            "status": "COMPLETED",
            "imageUrl": "https://<...>.r2.cloudflarestorage.com/...",
            "createdAt": "..."
        }
    ],
    "pagination": {
        "currentPage": 1,
        "totalPages": 5,
        "totalGenerations": 50
    }
}
```

#### `GET /generation/styles`
Returns a list of available art styles for generation.

**Response:**
```json
{
    "success": true,
    "data": [
        { "id": "VINTAGE_POSTER", "name": "Vintage Poster" },
        { "id": "MINIMALIST_LINE", "name": "Minimalist Line Art" }
    ]
}
```

#### `GET /generation/:id`
Gets the status and details of a specific generation.

**Response:**
```json
{
    "success": true,
    "data": {
        "id": "clx...",
        "status": "COMPLETED",
        "prompt": "A majestic lion...",
        "imageUrl": "https://<...>.r2.cloudflarestorage.com/...",
        "storageKey": "...",
        "width": 4500,
        "height": 5400,
        "createdAt": "...",
        "updatedAt": "...",
        "completedAt": "..."
    }
}
```

#### `DELETE /generation/:id`
Deletes a user's generation.

**Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Generation deleted successfully."
}
```

### User (Placeholders)

These endpoints are not yet implemented.

- `GET /user/profile`
- `PUT /user/profile`

---

## Status Codes

- `200 OK`: Request was successful.
- `201 Created`: Resource was successfully created.
- `202 Accepted`: Request was accepted for processing, but is not yet complete.
- `400 Bad Request`: The request was invalid (e.g., missing parameters).
- `401 Unauthorized`: Authentication failed or was not provided.
- `403 Forbidden`: The authenticated user does not have permission.
- `404 Not Found`: The requested resource could not be found.
- `500 Internal Server Error`: An unexpected error occurred on the server.
