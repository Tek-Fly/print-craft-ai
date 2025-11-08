---
name: monorepo-management
version: 1.0.0
description: Expertise in managing monorepo structures with tools like Melos, Nx, and Lerna
author: PrintCraft AI Team
tags:
  - development
  - architecture
  - tooling
  - dependencies
---

# Monorepo Management Skill

## Overview
This skill provides expertise in setting up and managing monorepo structures for complex projects, using tools like Melos for Flutter, Nx for JavaScript/TypeScript, and coordinating multi-package development workflows.

## Core Competencies

### 1. Monorepo Architecture
- Workspace organization
- Package dependency management
- Shared configuration
- Build optimization
- Version management

### 2. Tool Expertise

#### Melos (Flutter/Dart)
```yaml
# melos.yaml configuration
name: printcraft_monorepo

packages:
  - apps/*
  - packages/*

scripts:
  analyze:
    run: dart analyze --fatal-infos
    exec:
      concurrency: 5
  
  test:
    run: flutter test
    exec:
      concurrency: 5
      packageFilters:
        flutter: true
  
  format:
    run: dart format . --set-exit-if-changed
    
  publish:dry:
    run: melos publish --dry-run
    
  version:
    run: melos version --all-versions

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.16.0"

command:
  version:
    workspaceChangelog: false
    usePubspec: true
  
  bootstrap:
    runPubGetInParallel: true
```

#### Nx (TypeScript/JavaScript)
```json
{
  "name": "printcraft-backend",
  "version": "1.0.0",
  "nx": {
    "targets": {
      "build": {
        "cache": true,
        "dependsOn": ["^build"],
        "outputs": ["{projectRoot}/dist"]
      },
      "test": {
        "cache": true,
        "dependsOn": ["build"],
        "inputs": ["default", "^production"]
      }
    }
  }
}
```

### 3. Dependency Management

#### Cross-Package Dependencies
```typescript
// Managing internal dependencies
export class DependencyManager {
  async analyzeDependencies(workspaceRoot: string): Promise<DependencyGraph> {
    const packages = await this.discoverPackages(workspaceRoot);
    const graph = new DependencyGraph();
    
    for (const pkg of packages) {
      const deps = await this.getPackageDependencies(pkg);
      graph.addNode(pkg.name, {
        version: pkg.version,
        path: pkg.path,
        dependencies: deps,
      });
    }
    
    // Detect circular dependencies
    const cycles = graph.findCycles();
    if (cycles.length > 0) {
      throw new Error(`Circular dependencies detected: ${cycles.join(', ')}`);
    }
    
    return graph;
  }
}
```

#### Version Synchronization
```bash
#!/bin/bash
# Sync versions across packages

set -e

VERSION=$1
if [ -z "$VERSION" ]; then
  echo "Usage: sync-versions.sh <version>"
  exit 1
fi

# Update Flutter packages
melos exec --scope="@appyfly/*" -- \
  dart pub global run pubspec_version:set $VERSION

# Update Node packages
npx lerna version $VERSION --no-git-tag-version --yes

# Update root version
sed -i "s/\"version\": \".*\"/\"version\": \"$VERSION\"/" package.json

echo "✅ All packages updated to version $VERSION"
```

### 4. Build Orchestration

#### Parallel Builds
```typescript
export class BuildOrchestrator {
  async buildAll(options: BuildOptions): Promise<BuildResult> {
    const graph = await this.dependencyGraph.analyze();
    const buildOrder = graph.topologicalSort();
    
    // Group by build level for parallelization
    const levels = this.groupByLevel(buildOrder);
    
    const results: BuildResult[] = [];
    
    for (const level of levels) {
      // Build all packages at this level in parallel
      const levelResults = await Promise.all(
        level.map(pkg => this.buildPackage(pkg, options))
      );
      results.push(...levelResults);
      
      // Fail fast if any build failed
      if (levelResults.some(r => !r.success)) {
        break;
      }
    }
    
    return {
      success: results.every(r => r.success),
      results,
      duration: this.calculateTotalDuration(results),
    };
  }
}
```

### 5. Testing Strategies

#### Affected Tests
```typescript
export class AffectedTestRunner {
  async runAffectedTests(changedFiles: string[]): Promise<TestResult> {
    // Determine affected packages
    const affectedPackages = await this.getAffectedPackages(changedFiles);
    
    // Build test execution plan
    const testPlan = this.createTestPlan(affectedPackages);
    
    // Execute tests with optimal parallelization
    const results = await this.executeTests(testPlan, {
      parallel: true,
      bail: false,
      coverage: true,
    });
    
    return this.aggregateResults(results);
  }
  
  private async getAffectedPackages(files: string[]): Promise<Package[]> {
    const affected = new Set<Package>();
    
    for (const file of files) {
      const pkg = await this.findPackageForFile(file);
      if (pkg) {
        affected.add(pkg);
        // Add dependent packages
        const dependents = await this.findDependents(pkg);
        dependents.forEach(d => affected.add(d));
      }
    }
    
    return Array.from(affected);
  }
}
```

### 6. Release Management

#### Coordinated Releases
```typescript
export class ReleaseCoordinator {
  async prepareRelease(type: ReleaseType): Promise<ReleasePrep> {
    // Update versions
    const version = await this.determineNextVersion(type);
    
    // Update changelogs
    await this.updateChangelogs(version);
    
    // Update dependencies
    await this.updateInternalDependencies(version);
    
    // Create release commit
    await this.createReleaseCommit(version);
    
    // Tag release
    await this.tagRelease(version);
    
    return {
      version,
      packages: await this.getPackagesToPublish(),
      changelog: await this.generateReleaseNotes(version),
    };
  }
}
```

## Best Practices

### 1. Workspace Organization
```
monorepo/
├── apps/                 # Deployable applications
│   ├── mobile/          # Flutter app
│   ├── web/            # Web app
│   └── admin/          # Admin portal
├── packages/            # Shared packages
│   ├── core/           # Core utilities
│   ├── ui/             # UI components
│   └── api-client/     # API client
├── services/            # Backend services
│   ├── api/            # API service
│   ├── auth/           # Auth service
│   └── workers/        # Background workers
└── tools/              # Build tools
    ├── scripts/        # Build scripts
    └── generators/     # Code generators
```

### 2. Configuration Management
```typescript
// Shared configuration
export class MonorepoConfig {
  static readonly sharedTsConfig = {
    compilerOptions: {
      target: 'ES2022',
      module: 'commonjs',
      lib: ['ES2022'],
      strict: true,
      esModuleInterop: true,
      skipLibCheck: true,
      forceConsistentCasingInFileNames: true,
    },
  };
  
  static readonly sharedEslintConfig = {
    extends: [
      'eslint:recommended',
      'plugin:@typescript-eslint/recommended',
    ],
    rules: {
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/explicit-function-return-type': 'warn',
    },
  };
}
```

### 3. CI/CD Integration
```yaml
# GitHub Actions for monorepo
name: Monorepo CI

on:
  pull_request:
    branches: [main, develop]

jobs:
  affected:
    runs-on: ubuntu-latest
    outputs:
      packages: ${{ steps.affected.outputs.packages }}
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          
      - id: affected
        run: |
          AFFECTED=$(npx nx affected:apps --base=origin/main --json)
          echo "packages=$AFFECTED" >> $GITHUB_OUTPUT
  
  test:
    needs: affected
    strategy:
      matrix:
        package: ${{ fromJson(needs.affected.outputs.packages) }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npx nx test ${{ matrix.package }}
```

## Common Patterns

### 1. Shared Types
```typescript
// packages/shared-types/src/index.ts
export interface ApiResponse<T> {
  data: T;
  error?: ApiError;
  metadata?: ResponseMetadata;
}

export interface User {
  id: string;
  email: string;
  profile: UserProfile;
}

// Used across all packages
import { User, ApiResponse } from '@printcraft/shared-types';
```

### 2. Cross-Platform Code Sharing
```dart
// packages/core/lib/src/models/generation.dart
class Generation {
  final String id;
  final String prompt;
  final GenerationStatus status;
  
  // Shared across Flutter apps
  Generation({
    required this.id,
    required this.prompt,
    required this.status,
  });
}
```

### 3. Workspace Scripts
```json
{
  "scripts": {
    "dev": "nx run-many --target=serve --all",
    "build": "nx run-many --target=build --all",
    "test": "nx run-many --target=test --all",
    "lint": "nx workspace-lint && nx run-many --target=lint --all",
    "affected:test": "nx affected:test --base=main",
    "affected:build": "nx affected:build --base=main"
  }
}
```

## Troubleshooting

### Common Issues

1. **Dependency Conflicts**
   - Use workspace resolutions
   - Pin shared dependencies
   - Regular dependency audits

2. **Build Performance**
   - Enable caching
   - Use incremental builds
   - Parallelize tasks

3. **Version Mismatches**
   - Automated version sync
   - Pre-commit hooks
   - CI version checks

## Performance Optimization

### 1. Build Caching
```typescript
export class BuildCache {
  async getCacheKey(pkg: Package): Promise<string> {
    const sources = await this.getSourceFiles(pkg);
    const hashes = await Promise.all(
      sources.map(f => this.hashFile(f))
    );
    
    return crypto
      .createHash('sha256')
      .update(hashes.join(''))
      .digest('hex');
  }
}
```

### 2. Selective Testing
```bash
# Only test affected packages
melos run test --diff="main...HEAD"

# Only build changed services
nx affected:build --base=main --head=HEAD
```

## Integration Examples

### With CI/CD
- Optimized build pipelines
- Affected package detection
- Parallel job execution
- Cache optimization

### With Development Teams
- Consistent tooling
- Shared configurations
- Dependency management
- Version coordination

---

*This skill enables efficient monorepo management for large-scale projects.*