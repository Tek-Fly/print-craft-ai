---
name: professional-documentation
description: Create clear, concise, and professional technical documentation following industry best practices with no fluff, straight to the point accuracy
---

# Professional Documentation Skill

This skill provides expertise in creating high-quality technical documentation that is functional, direct, and immediately useful.

## Core Principles

### 1. Clarity First
- Use simple, direct language
- One concept per paragraph
- Active voice over passive
- Short sentences (15-20 words average)

### 2. No Fluff Policy
- Skip unnecessary introductions
- Remove redundant explanations
- Avoid marketing language
- Focus on actionable information

### 3. Structure & Organization
- Clear hierarchy with headers
- Logical flow of information
- Consistent formatting
- Easy navigation

## Documentation Templates

### 1. README.md Template

```markdown
# Project Name

One-line description of what this project does.

## Quick Start

```bash
git clone <repository>
cd project-name
npm install
npm start
```

## Prerequisites

- Node.js 18+
- PostgreSQL 14+
- Redis 6+

## Installation

1. Clone repository
2. Install dependencies: `npm install`
3. Configure environment: `cp .env.example .env`
4. Run migrations: `npm run migrate`
5. Start server: `npm start`

## Usage

### Basic Example

```javascript
const client = new APIClient({ apiKey: 'your-key' });
const result = await client.generateImage({ prompt: 'sunset' });
```

### Advanced Configuration

```javascript
const client = new APIClient({
  apiKey: 'your-key',
  timeout: 30000,
  retries: 3
});
```

## API Reference

### `generateImage(options)`

Generates an image from text prompt.

**Parameters:**
- `prompt` (string, required): Text description
- `size` (string): Image dimensions (default: "1024x1024")
- `quality` (string): "standard" or "hd" (default: "standard")

**Returns:** Promise<GenerationResult>

**Example:**
```javascript
const result = await client.generateImage({
  prompt: 'mountain landscape',
  size: '1920x1080',
  quality: 'hd'
});
```

## Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| API_KEY | Your API key | Required |
| BASE_URL | API endpoint | https://api.example.com |
| TIMEOUT | Request timeout (ms) | 30000 |

## Error Handling

| Code | Description | Action |
|------|-------------|--------|
| 401 | Invalid API key | Check your credentials |
| 429 | Rate limited | Wait and retry |
| 500 | Server error | Contact support |

## Testing

```bash
npm test           # Run all tests
npm test:unit      # Unit tests only
npm test:e2e       # End-to-end tests
```

## Contributing

1. Fork repository
2. Create feature branch: `git checkout -b feature-name`
3. Commit changes: `git commit -m 'Add feature'`
4. Push branch: `git push origin feature-name`
5. Submit pull request

## License

MIT
```

### 2. API Documentation Template

```markdown
# API Documentation

Base URL: `https://api.example.com/v1`

## Authentication

Bearer token in Authorization header:
```
Authorization: Bearer YOUR_API_TOKEN
```

## Endpoints

### POST /generations

Create new image generation.

**Request:**
```json
{
  "prompt": "sunset over mountains",
  "model": "stable-diffusion-xl",
  "size": "1024x1024"
}
```

**Response:**
```json
{
  "id": "gen_12345",
  "status": "processing",
  "created_at": "2024-01-01T00:00:00Z"
}
```

**Status Codes:**
- 201: Created successfully
- 400: Invalid parameters
- 401: Unauthorized
- 429: Rate limited

### GET /generations/:id

Get generation status.

**Response:**
```json
{
  "id": "gen_12345",
  "status": "completed",
  "image_url": "https://...",
  "created_at": "2024-01-01T00:00:00Z",
  "completed_at": "2024-01-01T00:01:00Z"
}
```

## Rate Limits

- 100 requests per minute
- 1000 requests per hour
- 10000 requests per day

## Webhooks

Configure webhook URL in dashboard.

**Payload:**
```json
{
  "event": "generation.completed",
  "data": {
    "id": "gen_12345",
    "status": "completed"
  }
}
```

## SDKs

- JavaScript: `npm install @example/sdk`
- Python: `pip install example-sdk`
- Go: `go get github.com/example/sdk`
```

### 3. Code Documentation Standards

#### Dart/Flutter Documentation
```dart
/// Generates a POD-optimized image using AI models.
/// 
/// This method handles the complete generation workflow including
/// prompt enhancement, model selection, and progress tracking.
/// 
/// Example:
/// ```dart
/// final result = await generateImage(
///   prompt: 'Motivational quote: Dream Big',
///   quality: GenerationQuality.ultra,
/// );
/// ```
/// 
/// Parameters:
/// - [prompt]: User's design description (max 500 chars)
/// - [quality]: Output quality level, defaults to [GenerationQuality.standard]
/// - [onProgress]: Optional callback for progress updates
/// 
/// Returns: [GenerationModel] containing the generated image URL
/// 
/// Throws:
/// - [GenerationException] if generation fails
/// - [QuotaExceededException] if user has no credits
Future<GenerationModel> generateImage({
  required String prompt,
  GenerationQuality quality = GenerationQuality.standard,
  void Function(double progress)? onProgress,
}) async {
  // Implementation
}
```

#### TypeScript/JavaScript Documentation
```typescript
/**
 * Generates an image from text prompt
 * 
 * @param options - Generation options
 * @param options.prompt - Text description of desired image
 * @param options.model - AI model to use (default: 'stable-diffusion')
 * @param options.size - Image dimensions (default: '1024x1024')
 * @returns Promise resolving to generation result
 * @throws {APIError} When API request fails
 * @throws {ValidationError} When parameters are invalid
 * 
 * @example
 * ```ts
 * const result = await client.generateImage({
 *   prompt: 'sunset over mountains',
 *   size: '1920x1080'
 * });
 * ```
 */
async function generateImage(options: GenerationOptions): Promise<GenerationResult> {
  // Implementation
}
```

### 4. Progress Logs Template

```markdown
## Development Log

### [2024-11-08 10:30] [INIT] Project Setup
- Created repository structure
- Initialized Flutter project
- Configured development environment

### [2024-11-08 11:15] [FEAT] Authentication Implementation
- Added Firebase Auth integration
- Implemented email/password sign-in
- Added Google OAuth support
- Created auth state management

### [2024-11-08 14:20] [FIX] Generation Service
- Fixed timeout issue in API calls
- Added exponential backoff for retries
- Improved error messages

### [2024-11-08 16:45] [REFACTOR] State Management  
- Migrated from setState to Provider
- Separated business logic from UI
- Added proper disposal methods

### [2024-11-08 17:30] [TEST] Unit Tests
- Added tests for generation model
- Added tests for auth provider
- Coverage now at 85%
```

### 5. Security Documentation Template

```markdown
# SECURITY.md

## Reporting Security Issues

**DO NOT** report security vulnerabilities through public GitHub issues.

Email: security@example.com

Include:
- Description of vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

## Security Measures

### Authentication
- JWT tokens with 1-hour expiration
- Refresh tokens rotated on use
- Password requirements: 8+ chars, mixed case, numbers

### API Security
- Rate limiting: 100 req/min per IP
- Input validation on all endpoints
- SQL injection protection via parameterized queries

### Data Protection
- Encryption at rest: AES-256
- Encryption in transit: TLS 1.3
- PII data retention: 90 days
- GDPR compliant data deletion

## Security Headers

```nginx
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Strict-Transport-Security: max-age=31536000; includeSubDomains
Content-Security-Policy: default-src 'self'
```

## Dependencies

Regular security audits with:
```bash
npm audit
flutter pub outdated
safety check  # Python
```

## Incident Response

1. Identify and contain
2. Assess impact
3. Notify affected users within 72h
4. Document lessons learned
```

### 6. Contributing Guidelines Template

```markdown
# CONTRIBUTING.md

## Code Style

### Flutter/Dart
- Follow official Dart style guide
- Run `dart format` before commits
- No warnings from `flutter analyze`

### Git Commits
```
type(scope): subject

body (optional)

footer (optional)
```

Types: feat, fix, docs, style, refactor, test, chore

Examples:
```
feat(auth): add biometric authentication
fix(generation): resolve timeout on slow networks
docs(api): update endpoint documentation
```

## Pull Request Process

1. Fork and create feature branch
2. Make changes with tests
3. Ensure CI passes
4. Update documentation
5. Submit PR with description

### PR Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guide
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings
```

## Testing Requirements

- New features need tests
- Bug fixes need regression tests  
- Maintain 80%+ code coverage

## Review Process

1. Automated checks must pass
2. One approval required
3. No merge conflicts
4. Documentation updated
```

## Documentation Best Practices

### 1. Structure
- Start with most important information
- Use consistent heading hierarchy
- Include table of contents for long docs
- Provide quick navigation

### 2. Code Examples
- Show real, working examples
- Include both basic and advanced usage
- Highlight common pitfalls
- Test all code samples

### 3. Visual Elements
- Use tables for comparisons
- Use lists for steps or options
- Use code blocks with syntax highlighting
- Include diagrams when helpful

### 4. Maintenance
- Date all documentation
- Version documentation with code
- Review quarterly for accuracy
- Remove outdated content

### 5. Accessibility
- Use semantic HTML/Markdown
- Provide alt text for images
- Ensure sufficient contrast
- Keep language simple

## Common Anti-Patterns

### 1. Over-Documentation
```markdown
# Bad: Too verbose
The generateImage function is a method that takes parameters
and uses them to generate an image. It accepts a prompt parameter
which is a string that describes what image you want...

# Good: Direct
Generates an image from text description.
```

### 2. Under-Documentation
```markdown
# Bad: Too brief
generateImage(prompt) - generates image

# Good: Complete
generateImage(prompt: string, options?: GenerationOptions): Promise<Image>
Generates an AI image from text prompt with optional configuration.
```

### 3. Outdated Examples
```markdown
# Bad: Version mismatch
// Works in v1.0
client.generate(prompt)  

# Good: Version noted
// v2.0+
client.generateImage({ prompt })
```

### 4. Missing Context
```markdown
# Bad: No context
Set API_KEY in environment

# Good: With context  
Set API_KEY in environment variables:
- Development: .env file
- Production: Server environment
- CI/CD: GitHub secrets
```

## Automation Tools

### 1. Documentation Generation
```bash
# Generate API docs from code
npx typedoc src --out docs/api

# Generate Flutter docs
dart doc .
```

### 2. Link Checking
```bash
# Check for broken links
npx linkinator docs --recurse
```

### 3. Spell Checking
```bash
# Check spelling
npx cspell "docs/**/*.md"
```

### 4. Format Validation
```bash
# Validate Markdown
npx markdownlint docs/
```

## Metrics for Good Documentation

1. **Time to First Success** < 5 minutes
2. **Support Tickets** decrease after doc updates
3. **Search Success Rate** > 80%
4. **Documentation Coverage** = 100% of public APIs
5. **Freshness** = Updated within 30 days of code changes