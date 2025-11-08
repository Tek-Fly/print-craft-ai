# PrintCraft AI Setup Instructions

## Prerequisites

You need to install the following software:

### 1. Docker Desktop (Recommended)
- Download from: https://www.docker.com/products/docker-desktop/
- After installation, run: `docker compose up -d`

### 2. Alternative: Install Locally

#### PostgreSQL
```bash
# macOS
brew install postgresql@16
brew services start postgresql@16

# Create database and user
createdb printcraft_db
psql -d postgres -c "CREATE USER printcraft WITH PASSWORD 'password';"
psql -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE printcraft_db TO printcraft;"
```

#### Redis
```bash
# macOS
brew install redis
brew services start redis
```

## Running the Backend

1. Install dependencies:
```bash
cd services/api-gateway
npm install
```

2. Set up database:
```bash
# Generate Prisma client
npx prisma generate

# Run migrations
npx prisma migrate dev
```

3. Start the server:
```bash
npm run dev
```

## Environment Setup

The `.env` file is already configured with:
- Database connection strings
- Redis URL
- API keys (Replicate, OpenAI, Cloudflare R2)
- Firebase Admin SDK credentials

## Testing the Setup

Once everything is running:
- API Gateway: http://localhost:8000
- Health check: http://localhost:8000/api/v1/health
- pgAdmin: http://localhost:5050 (if using Docker)

## Troubleshooting

### Database Connection Issues
- Ensure PostgreSQL is running
- Check the DATABASE_URL in .env
- Verify user permissions

### Redis Connection Issues
- Ensure Redis is running
- Check the REDIS_URL in .env
- Default port is 6379

### Port Conflicts
- API Gateway uses port 8000
- PostgreSQL uses port 5432
- Redis uses port 6379
- pgAdmin uses port 5050