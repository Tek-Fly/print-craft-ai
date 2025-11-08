# CLAUDE.md - PrintCraft AI Configuration

## Project Overview

PrintCraft AI is a production-ready Print-on-Demand (POD) mobile application built with Flutter that leverages AI image generation via Replicate API. The project consists of three main components:

1. **Flutter UI** - Complete mobile app interface with dark/light themes
2. **AI Image Generation** - Replicate API integration with multiple models
3. **Backend Services** - Firebase Auth, Firestore, and Storage (managed separately)

## Architecture

```
print-craft-ai/
├── pod_app/              # Flutter application
├── .claude/              # Claude Skills and configuration
├── scripts/              # Development and deployment scripts
├── docs/                 # Professional documentation
└── tools/                # Development tools
```

## Security Protocols

### CRITICAL: No Hardcoded Secrets
- **NEVER** commit API keys, tokens, or secrets to Git
- **NEVER** include secrets in documentation or code comments
- **ALWAYS** use environment variables or secure storage
- **ALWAYS** check for secrets before committing

### Secret Management
```bash
# Use environment variables
export REPLICATE_API_TOKEN="r8_..."
export FIREBASE_API_KEY="..."

# Or use .env files (never commit)
source .env

# Production: Use Google Secret Manager
gcloud secrets versions access latest --secret="replicate-api-token"
```

## Coding Standards

### Flutter/Dart Standards
- **Style**: Follow official Dart style guide
- **Formatting**: Run `dart format` before commits
- **Analysis**: Zero warnings from `flutter analyze`
- **Naming**: 
  - Classes: `PascalCase`
  - Files: `snake_case.dart`
  - Variables/functions: `camelCase`
  - Constants: `SCREAMING_SNAKE_CASE`

### Code Organization
- **Separation of Concerns**: UI, Business Logic, Data layers
- **Component-Based**: Reusable widgets in separate files
- **State Management**: Provider pattern (already implemented)
- **Models**: Immutable with factory constructors
- **Services**: Abstract interfaces with concrete implementations

### File Structure Standards
```dart
// Good: Modular, single responsibility
lib/
  core/
    models/
      generation_model.dart    // One model per file
    services/
      generation_service.dart  // Interface
      generation_service_impl.dart  // Implementation
  features/
    home/
      presentation/
        screens/
        widgets/
```

## Testing Requirements

### Commands
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Specific test file
flutter test test/unit/generation_model_test.dart

# Integration tests
flutter test integration_test/app_test.dart
```

### Coverage Requirements
- Minimum: 80% overall coverage
- Critical paths: 95% coverage
- New features: Must include tests

## Development Workflow

### 1. Feature Development
```bash
# Create feature branch
git checkout -b feature/pod-enhancement

# Make changes following standards
# Run tests and linting
flutter test && flutter analyze

# Commit with conventional commits
git commit -m "feat(generation): add batch processing support"
```

### 2. Pre-commit Checks
```bash
# Automated checks (implement in hooks)
- dart format --set-exit-if-changed .
- flutter analyze
- flutter test
- Security scan for secrets
```

### 3. Deployment Process
```bash
# Staging
./scripts/deploy-staging.sh

# Production (after approval)
./scripts/deploy-production.sh
```

## MCP Server Configurations

### Available MCP Servers

#### 1. Docker (`mcp__docker__*`)
**Purpose**: Container orchestration for microservices
**Use Cases**:
- Running Replicate API mock server locally
- Firebase emulator suite
- PostgreSQL/Redis for development
- Isolated testing environments

**Common Commands**:
```bash
# List all containers
mcp__docker__docker_ps --all

# Start Firebase emulator
mcp__docker__docker_start firebase-emulator

# Check API server logs
mcp__docker__docker_logs --container api-server --tail 100
```

#### 2. SQLite (`mcp__sqlite__*`)
**Purpose**: Local database for development and analytics
**Use Cases**:
- Storing generation metrics locally
- Development user data
- Analytics and reporting
- Offline data caching

**Common Operations**:
```sql
-- Create local analytics table
mcp__sqlite__create_table "CREATE TABLE generation_metrics (...)"

-- Query generation stats
mcp__sqlite__read_query "SELECT style, COUNT(*) FROM generations GROUP BY style"

-- Track business insights
mcp__sqlite__append_insight "Users prefer minimalist style 3x more than others"
```

#### 3. IDE Integration (`mcp__ide__*`)
**Purpose**: VS Code diagnostics and code execution
**Use Cases**:
- Real-time error detection
- Running code snippets
- Automated refactoring
- Test execution in IDE

**Examples**:
```bash
# Get current diagnostics
mcp__ide__getDiagnostics

# Execute Flutter tests
mcp__ide__executeCode "flutter test test/generation_test.dart"
```

#### 4. Sequential Thinking (`mcp__sequential-thinking__*`)
**Purpose**: Complex problem solving and planning
**Use Cases**:
- Architecture decisions
- Performance optimization strategies
- Debugging complex issues
- Multi-step implementation planning

#### 5. Memory (`mcp__memory__*`)
**Purpose**: Project knowledge graph
**Use Cases**:
- Storing design decisions
- Tracking API patterns
- Recording optimization strategies
- Building project context

**Examples**:
```bash
# Store design pattern
mcp__memory__create_entities [{
  "name": "ReplicateRetryPattern",
  "entityType": "DesignPattern",
  "observations": ["Exponential backoff", "Max 3 retries", "429 status handling"]
}]

# Create relationships
mcp__memory__create_relations [{
  "from": "GenerationService",
  "to": "ReplicateRetryPattern",
  "relationType": "implements"
}]
```

#### 6. Browser Automation (`mcp__playwright__*`, `mcp__chrome-devtools__*`)
**Purpose**: E2E testing and web automation
**Use Cases**:
- Testing web dashboard
- Automating deployment checks
- Visual regression testing
- Performance profiling

**Examples**:
```bash
# Test generation flow
mcp__playwright__browser_navigate --url "http://localhost:3000"
mcp__playwright__browser_fill_form --fields '[
  {"name": "prompt", "value": "sunset landscape", "type": "textbox"}
]'
mcp__playwright__browser_click --element "Generate" --ref "button#generate"

# Performance analysis
mcp__chrome-devtools__performance_start_trace --reload true --autoStop false
# ... perform actions ...
mcp__chrome-devtools__performance_stop_trace
```

#### 7. Web Tools (`mcp__perplexity__*`, `mcp__youtube-transcript__*`)
**Purpose**: Research and documentation
**Use Cases**:
- Researching latest AI model updates
- Finding optimization techniques
- Gathering user feedback from videos
- Market research

#### 8. Apify Integration (`mcp__actors-mcp-server-desktop__*`)
**Purpose**: Web scraping and automation
**Use Cases**:
- Competitor analysis
- Market trend monitoring
- Gathering design inspirations
- Price monitoring

### Integration Patterns

#### Development Workflow
```bash
# 1. Start development environment
mcp__docker__docker_start postgres redis firebase-emulator

# 2. Check code quality
mcp__ide__getDiagnostics

# 3. Run tests with coverage
mcp__ide__executeCode "flutter test --coverage"

# 4. Analyze performance
mcp__sqlite__read_query "SELECT AVG(generation_time) FROM metrics"
```

#### Debugging Workflow
```bash
# 1. Identify issue
mcp__sequential-thinking__sequentialthinking --thought "API timeout issue"

# 2. Check logs
mcp__docker__docker_logs --container api-server --tail 200

# 3. Query error patterns
mcp__sqlite__read_query "SELECT error_type, COUNT(*) FROM errors GROUP BY error_type"

# 4. Store solution
mcp__memory__create_entities --name "TimeoutSolution" --observations ["Increased timeout to 60s"]
```

#### Testing Workflow
```bash
# 1. Unit tests
mcp__ide__executeCode "flutter test"

# 2. Integration tests
mcp__docker__docker_start test-db
mcp__playwright__browser_navigate --url "http://localhost:8080"

# 3. Visual regression
mcp__chrome-devtools__take_screenshot --fullPage true
```

### Best Practices

1. **Use MCP servers over direct commands** when available
2. **Batch operations** for better performance
3. **Store insights** in memory for future reference
4. **Automate repetitive tasks** with browser tools
5. **Monitor performance** with SQLite analytics

## Environment Setup

### Required Tools
```bash
# Flutter
flutter --version  # 3.x required

# Firebase CLI
firebase --version

# Google Cloud SDK
gcloud --version

# Node.js (for tools)
node --version  # 18+ required
```

### VS Code Extensions
- Flutter
- Dart
- Firebase
- GitLens
- Error Lens
- TODO Highlight

## Performance Standards

### Flutter App
- App startup: < 2 seconds
- Screen transitions: < 300ms
- Image generation UI response: < 100ms
- Memory usage: < 200MB baseline

### API Response Times
- Generation initiation: < 500ms
- Status polling: < 200ms
- Image download: < 3s (depends on size)

## Documentation Standards

### Code Documentation
```dart
/// Generates a POD-optimized image using AI.
/// 
/// Parameters:
/// - [prompt]: User's design description
/// - [style]: Visual style selection
/// - [quality]: Output quality level
/// 
/// Returns: [GenerationModel] with image URL
/// 
/// Throws: [GenerationException] on API errors
Future<GenerationModel> generateImage({
  required String prompt,
  required String style,
  GenerationQuality quality = GenerationQuality.ultra,
}) async {
  // Implementation
}
```

### README Files
- Clear purpose statement
- Quick start section
- API documentation
- Examples
- Troubleshooting

## Sub-Agent Software House Structure

### Agent Organization
The PrintCraft AI development is managed by a team of specialized AI agents working as a software house:

#### 1. Lead Developer (Orchestrator)
**Role**: Project coordination and technical leadership
**Location**: `.claude/agents/orchestrator/`
**Responsibilities**:
- Sprint planning and task distribution
- Cross-team coordination
- Architecture decisions
- Release management

#### 2. Team Alpha: Flutter UI Development
**Location**: `.claude/agents/flutter-team/`
- **UI Developer**: Component development, state management
- **Mobile QA**: Testing, performance profiling
- **UX Specialist**: Design system, accessibility

#### 3. Team Beta: AI Backend Development  
**Location**: `.claude/agents/backend-team/`
- **Backend Developer**: API development, integrations
- **AI Specialist**: Prompt engineering, model optimization
- **Infrastructure Engineer**: CI/CD, deployment automation

#### 4. Shared Services
**Location**: `.claude/agents/shared/`
- **Documentation Specialist**: Technical docs, guides
- **Security Officer**: Compliance, vulnerability management

### Agent Communication
```yaml
# Message format for cross-team communication
message:
  from: 
    team: flutter
    agent: ui-developer
  to:
    team: backend
    agent: backend-developer
  type: api_contract_proposal
  priority: high
  content:
    endpoint: /api/v1/generations/batch
    requirements:
      - Batch size limit: 10
      - Response format: streaming
```

### Agent Skills
Additional specialized skills for sub-agents:
- `monorepo-management`: Managing complex monorepo structures
- `cross-team-communication`: Facilitating team coordination
- `performance-optimization`: App and API optimization
- `deployment-automation`: CI/CD pipeline management
- `user-analytics`: Behavior tracking and insights

### Workflow Example
```bash
# 1. Orchestrator assigns task
Task: Implement batch generation feature
Teams: Flutter (UI) + Backend (API)

# 2. Teams collaborate
- Backend designs API contract
- Flutter reviews and provides feedback
- Both teams implement in parallel

# 3. Integration testing
- QA agents test integration
- Security agent reviews

# 4. Deployment
- Infrastructure agent handles deployment
- Documentation agent updates guides
```

## Monorepo Structure

### Melos Configuration
The project uses Melos for Flutter/Dart package management:

```bash
# Bootstrap all packages
melos bootstrap

# Run tests across all packages
melos run test

# Check code quality
melos run analyze

# Format all code
melos run format

# Build all packages
melos run build:runner
```

### Package Organization
```
packages/
  @appyfly/core        # Shared TypeScript utilities
  @appyfly/ui          # Flutter UI component library
  @appyfly/sdk         # Multi-platform SDK
    ├── dart/          # Dart/Flutter SDK
    ├── typescript/    # TypeScript SDK
    └── python/        # Python SDK
```

## Progress Tracking

### Development Logs
```bash
# Log format
[YYYY-MM-DD HH:MM] [COMPONENT] [ACTION] Description

# Example
[2024-11-08 10:30] [SKILL] [CREATE] flutter-pod-development skill implemented
[2024-11-08 11:15] [API] [UPDATE] Added retry logic to generation service
[2025-11-08 14:00] [AGENT] [CREATE] Sub-agent software house structure implemented
[2025-11-08 15:30] [MONOREPO] [SETUP] Melos configuration for Flutter packages
```

### Git Commit Convention
```
type(scope): description

feat(ui): add dark mode toggle
fix(api): handle timeout errors
docs(readme): update setup instructions
test(generation): add unit tests
refactor(models): simplify generation model
```

## Error Handling

### Standard Pattern
```dart
try {
  // Operation
} on SpecificException catch (e) {
  // Handle specific error
  logger.error('Specific error', e);
  throw UserFriendlyException(message: 'Clear user message');
} catch (e) {
  // Handle general error
  logger.error('Unexpected error', e);
  throw UserFriendlyException(message: 'Something went wrong');
}
```

## Production Checklist

Before deploying:
- [ ] All tests passing
- [ ] No hardcoded secrets
- [ ] Performance benchmarks met
- [ ] Documentation updated
- [ ] Security scan completed
- [ ] Error tracking configured
- [ ] Monitoring enabled

## Support Contacts

- Technical Lead: Use GitHub issues
- Security Issues: security@appyfly.com
- Documentation: Update via PR

---

Last Updated: 2024-11-08
Version: 1.0.0