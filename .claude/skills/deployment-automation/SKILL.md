---
name: deployment-automation
version: 1.0.0
description: Expertise in CI/CD pipelines, automated deployments, and release management
author: PrintCraft AI Team
tags:
  - deployment
  - ci/cd
  - automation
  - devops
---

# Deployment Automation Skill

## Overview
This skill provides comprehensive deployment automation capabilities including CI/CD pipeline design, multi-environment deployments, rollback strategies, and release orchestration for PrintCraft AI.

## Core Competencies

### 1. CI/CD Pipeline Design

#### GitHub Actions Workflow
```yaml
# .github/workflows/main-pipeline.yml
name: PrintCraft AI - Main Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  release:
    types: [created]

env:
  FLUTTER_VERSION: '3.16.0'
  NODE_VERSION: '18'
  DOCKER_BUILDKIT: 1

jobs:
  # Detect what changed
  changes:
    runs-on: ubuntu-latest
    outputs:
      flutter: ${{ steps.filter.outputs.flutter }}
      backend: ${{ steps.filter.outputs.backend }}
      infrastructure: ${{ steps.filter.outputs.infrastructure }}
    steps:
      - uses: actions/checkout@v4
      - uses: dorny/paths-filter@v2
        id: filter
        with:
          filters: |
            flutter:
              - 'apps/pod-app/**'
              - 'packages/@appyfly/ui/**'
            backend:
              - 'services/**'
              - 'packages/@appyfly/core/**'
            infrastructure:
              - 'infrastructure/**'
              - '.github/workflows/**'

  # Quality gates
  quality-checks:
    needs: changes
    runs-on: ubuntu-latest
    strategy:
      matrix:
        check: [lint, test, security, sonar]
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup environment
        uses: ./.github/actions/setup-environment
        with:
          flutter: ${{ needs.changes.outputs.flutter }}
          node: ${{ needs.changes.outputs.backend }}
      
      - name: Run ${{ matrix.check }}
        run: |
          case "${{ matrix.check }}" in
            lint)
              ./scripts/lint-all.sh
              ;;
            test)
              ./scripts/test-all.sh --coverage
              ;;
            security)
              ./scripts/security-scan.sh
              ;;
            sonar)
              ./scripts/sonar-analysis.sh
              ;;
          esac

  # Build artifacts
  build:
    needs: [changes, quality-checks]
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            target: android
            artifact: apk
          - os: macos-latest
            target: ios
            artifact: ipa
          - os: ubuntu-latest
            target: backend
            artifact: docker
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Build ${{ matrix.target }}
        uses: ./.github/actions/build-${{ matrix.target }}
        with:
          version: ${{ github.run_number }}
          
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: ${{ matrix.target }}-${{ github.sha }}
          path: build/outputs/${{ matrix.artifact }}

  # Deploy to environments
  deploy:
    needs: build
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [staging, production]
    environment:
      name: ${{ matrix.environment }}
      url: ${{ steps.deploy.outputs.url }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Download artifacts
        uses: actions/download-artifact@v3
        
      - name: Deploy to ${{ matrix.environment }}
        id: deploy
        uses: ./.github/actions/deploy
        with:
          environment: ${{ matrix.environment }}
          version: ${{ github.sha }}
          token: ${{ secrets.DEPLOY_TOKEN }}
```

#### Reusable Workflows
```yaml
# .github/workflows/reusable-flutter-build.yml
name: Flutter Build

on:
  workflow_call:
    inputs:
      platform:
        required: true
        type: string
      environment:
        required: true
        type: string
    secrets:
      signing_key:
        required: true
      signing_password:
        required: true

jobs:
  build:
    runs-on: ${{ inputs.platform == 'ios' && 'macos-latest' || 'ubuntu-latest' }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true
      
      - name: Get dependencies
        working-directory: apps/pod-app
        run: |
          flutter pub get
          flutter pub run build_runner build --delete-conflicting-outputs
      
      - name: Configure signing
        env:
          SIGNING_KEY: ${{ secrets.signing_key }}
          SIGNING_PASSWORD: ${{ secrets.signing_password }}
        run: |
          echo "$SIGNING_KEY" | base64 -d > signing.key
          ./scripts/configure-signing.sh ${{ inputs.platform }}
      
      - name: Build ${{ inputs.platform }}
        working-directory: apps/pod-app
        run: |
          flutter build ${{ inputs.platform }} \
            --release \
            --dart-define=ENVIRONMENT=${{ inputs.environment }} \
            --build-number=${{ github.run_number }}
      
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: ${{ inputs.platform }}-build
          path: apps/pod-app/build/
```

### 2. Multi-Environment Deployment

#### Environment Configuration
```typescript
// deployment/environments.ts
export interface Environment {
  name: string;
  type: 'development' | 'staging' | 'production';
  config: EnvironmentConfig;
  infrastructure: InfrastructureConfig;
  deployment: DeploymentConfig;
}

export const environments: Record<string, Environment> = {
  development: {
    name: 'development',
    type: 'development',
    config: {
      apiUrl: 'http://localhost:3000',
      features: {
        debugMode: true,
        hotReload: true,
        mockData: true,
      },
    },
    infrastructure: {
      provider: 'local',
      resources: {
        cpu: '2',
        memory: '4Gi',
      },
    },
    deployment: {
      strategy: 'direct',
      healthCheck: {
        enabled: false,
      },
    },
  },
  
  staging: {
    name: 'staging',
    type: 'staging',
    config: {
      apiUrl: 'https://staging-api.appyfly.com',
      features: {
        debugMode: false,
        hotReload: false,
        mockData: false,
      },
    },
    infrastructure: {
      provider: 'aws',
      region: 'us-east-1',
      cluster: 'printcraft-staging',
      resources: {
        cpu: '1',
        memory: '2Gi',
        replicas: 2,
      },
    },
    deployment: {
      strategy: 'rolling',
      healthCheck: {
        enabled: true,
        path: '/health',
        interval: 30,
        timeout: 10,
        retries: 3,
      },
      rollback: {
        automatic: true,
        threshold: 0.5,
      },
    },
  },
  
  production: {
    name: 'production',
    type: 'production',
    config: {
      apiUrl: 'https://api.appyfly.com',
      features: {
        debugMode: false,
        hotReload: false,
        mockData: false,
      },
    },
    infrastructure: {
      provider: 'aws',
      region: 'us-east-1',
      cluster: 'printcraft-production',
      resources: {
        cpu: '2',
        memory: '4Gi',
        replicas: 5,
        autoscaling: {
          enabled: true,
          minReplicas: 3,
          maxReplicas: 20,
          targetCPU: 70,
        },
      },
    },
    deployment: {
      strategy: 'canary',
      canary: {
        steps: [5, 25, 50, 100],
        interval: 300, // 5 minutes
        analysis: {
          metrics: ['error_rate', 'latency_p95', 'success_rate'],
          thresholds: {
            error_rate: 0.01,
            latency_p95: 200,
            success_rate: 0.99,
          },
        },
      },
      healthCheck: {
        enabled: true,
        path: '/health',
        interval: 10,
        timeout: 5,
        retries: 3,
      },
      rollback: {
        automatic: true,
        threshold: 0.01,
      },
    },
  },
};
```

#### Deployment Scripts
```bash
#!/bin/bash
# scripts/deploy.sh

set -euo pipefail

# Parse arguments
ENVIRONMENT=$1
VERSION=$2
COMPONENT=${3:-all}

# Load environment configuration
source ./scripts/load-env.sh $ENVIRONMENT

# Functions
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $@"
}

deploy_backend() {
  log "Deploying backend services to $ENVIRONMENT..."
  
  # Update Kubernetes manifests
  kubectl set image deployment/api-gateway \
    api-gateway=$REGISTRY/api-gateway:$VERSION \
    -n $NAMESPACE
  
  kubectl set image deployment/generation-service \
    generation=$REGISTRY/generation:$VERSION \
    -n $NAMESPACE
  
  # Wait for rollout
  kubectl rollout status deployment/api-gateway -n $NAMESPACE
  kubectl rollout status deployment/generation-service -n $NAMESPACE
  
  log "Backend deployment completed"
}

deploy_flutter() {
  log "Deploying Flutter app to $ENVIRONMENT..."
  
  case $ENVIRONMENT in
    staging)
      # Deploy to Firebase App Distribution
      firebase appdistribution:distribute \
        build/app/outputs/flutter-apk/app-release.apk \
        --app $FIREBASE_APP_ID \
        --groups "internal-testers"
      ;;
    production)
      # Deploy to app stores
      fastlane deploy_production
      ;;
  esac
  
  log "Flutter deployment completed"
}

health_check() {
  log "Running health checks..."
  
  local max_attempts=30
  local attempt=0
  
  while [ $attempt -lt $max_attempts ]; do
    if curl -f -s "$HEALTH_CHECK_URL" > /dev/null; then
      log "Health check passed"
      return 0
    fi
    
    attempt=$((attempt + 1))
    log "Health check attempt $attempt/$max_attempts failed, retrying..."
    sleep 10
  done
  
  log "Health check failed after $max_attempts attempts"
  return 1
}

rollback() {
  log "Rolling back deployment..."
  
  kubectl rollout undo deployment/api-gateway -n $NAMESPACE
  kubectl rollout undo deployment/generation-service -n $NAMESPACE
  
  log "Rollback completed"
}

# Main deployment flow
main() {
  log "Starting deployment to $ENVIRONMENT (version: $VERSION)"
  
  # Pre-deployment checks
  ./scripts/pre-deploy-checks.sh $ENVIRONMENT
  
  # Create deployment record
  DEPLOYMENT_ID=$(./scripts/create-deployment-record.sh $ENVIRONMENT $VERSION)
  
  # Deploy components
  case $COMPONENT in
    backend)
      deploy_backend
      ;;
    flutter)
      deploy_flutter
      ;;
    all)
      deploy_backend
      deploy_flutter
      ;;
  esac
  
  # Health check
  if health_check; then
    log "Deployment successful"
    ./scripts/update-deployment-record.sh $DEPLOYMENT_ID "succeeded"
  else
    log "Deployment failed, initiating rollback"
    rollback
    ./scripts/update-deployment-record.sh $DEPLOYMENT_ID "failed"
    exit 1
  fi
  
  # Post-deployment tasks
  ./scripts/post-deploy.sh $ENVIRONMENT $VERSION
}

main
```

### 3. Container Orchestration

#### Kubernetes Manifests
```yaml
# k8s/base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
  labels:
    app: api-gateway
    version: v1
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-gateway
  template:
    metadata:
      labels:
        app: api-gateway
        version: v1
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "3000"
        prometheus.io/path: "/metrics"
    spec:
      serviceAccountName: api-gateway
      containers:
      - name: api-gateway
        image: ghcr.io/tek-fly/api-gateway:latest
        ports:
        - containerPort: 3000
          name: http
        env:
        - name: NODE_ENV
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: environment
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: database-url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health/live
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        lifecycle:
          preStop:
            exec:
              command: ["/bin/sh", "-c", "sleep 15"]
```

#### Helm Charts
```yaml
# helm/printcraft/values.yaml
global:
  environment: production
  domain: api.appyfly.com
  imageRegistry: ghcr.io/tek-fly
  imagePullPolicy: IfNotPresent

apiGateway:
  enabled: true
  replicaCount: 3
  image:
    repository: api-gateway
    tag: latest
  
  resources:
    requests:
      memory: "256Mi"
      cpu: "250m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 10
    targetCPUUtilizationPercentage: 70
    targetMemoryUtilizationPercentage: 80
  
  ingress:
    enabled: true
    className: nginx
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
      nginx.ingress.kubernetes.io/rate-limit: "100"
    hosts:
      - host: api.appyfly.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: api-tls
        hosts:
          - api.appyfly.com

generationService:
  enabled: true
  replicaCount: 2
  image:
    repository: generation-service
    tag: latest
  
  resources:
    requests:
      memory: "1Gi"
      cpu: "500m"
      nvidia.com/gpu: 1
    limits:
      memory: "2Gi"
      cpu: "1000m"
      nvidia.com/gpu: 1
  
  nodeSelector:
    gpu: "true"
  
  tolerations:
    - key: gpu
      operator: Equal
      value: "true"
      effect: NoSchedule

postgresql:
  enabled: true
  auth:
    postgresPassword: "changeme"
    database: printcraft
  primary:
    persistence:
      enabled: true
      size: 100Gi
  metrics:
    enabled: true
```

### 4. Deployment Strategies

#### Blue-Green Deployment
```typescript
export class BlueGreenDeployment {
  async deploy(
    service: string,
    newVersion: string
  ): Promise<DeploymentResult> {
    // Get current active environment
    const activeEnv = await this.getActiveEnvironment(service);
    const inactiveEnv = activeEnv === 'blue' ? 'green' : 'blue';
    
    log(`Deploying ${service}:${newVersion} to ${inactiveEnv}`);
    
    // Deploy to inactive environment
    await this.deployToEnvironment(service, newVersion, inactiveEnv);
    
    // Health check
    const healthy = await this.waitForHealthy(service, inactiveEnv);
    if (!healthy) {
      throw new Error(`Health check failed for ${service} in ${inactiveEnv}`);
    }
    
    // Run smoke tests
    const testsPassed = await this.runSmokeTests(service, inactiveEnv);
    if (!testsPassed) {
      throw new Error(`Smoke tests failed for ${service} in ${inactiveEnv}`);
    }
    
    // Switch traffic
    await this.switchTraffic(service, inactiveEnv);
    
    // Monitor for errors
    const monitoring = await this.monitorDeployment(service, {
      duration: 300, // 5 minutes
      errorThreshold: 0.01,
    });
    
    if (monitoring.errorRate > monitoring.errorThreshold) {
      log(`Error rate exceeded threshold, rolling back`);
      await this.switchTraffic(service, activeEnv);
      throw new Error(`Deployment failed due to high error rate`);
    }
    
    // Mark deployment as successful
    await this.markEnvironmentActive(service, inactiveEnv);
    
    return {
      service,
      version: newVersion,
      environment: inactiveEnv,
      status: 'success',
    };
  }
}
```

#### Canary Deployment
```typescript
export class CanaryDeployment {
  async deploy(
    service: string,
    newVersion: string,
    config: CanaryConfig
  ): Promise<DeploymentResult> {
    const deploymentId = uuid();
    
    // Deploy canary
    await this.deployCanary(service, newVersion, deploymentId);
    
    // Progressive rollout
    for (const percentage of config.steps) {
      log(`Rolling out to ${percentage}% of traffic`);
      
      // Adjust traffic split
      await this.adjustTrafficSplit(service, deploymentId, percentage);
      
      // Wait for stabilization
      await this.sleep(config.stepDuration);
      
      // Analyze metrics
      const analysis = await this.analyzeCanary(service, deploymentId, {
        metrics: config.metrics,
        thresholds: config.thresholds,
        duration: config.analysisWindow,
      });
      
      if (!analysis.passed) {
        log(`Canary analysis failed at ${percentage}%`);
        await this.rollbackCanary(service, deploymentId);
        throw new Error(`Canary failed: ${analysis.reason}`);
      }
    }
    
    // Promote canary
    await this.promoteCanary(service, deploymentId);
    
    return {
      service,
      version: newVersion,
      deploymentId,
      status: 'success',
    };
  }
  
  private async analyzeCanary(
    service: string,
    deploymentId: string,
    config: AnalysisConfig
  ): Promise<AnalysisResult> {
    const metrics = await this.collectMetrics(service, {
      deploymentId,
      duration: config.duration,
      metrics: config.metrics,
    });
    
    const baseline = await this.getBaselineMetrics(service, config.duration);
    
    // Compare metrics
    const analysis: AnalysisResult = {
      passed: true,
      metrics: {},
    };
    
    for (const metric of config.metrics) {
      const current = metrics[metric];
      const base = baseline[metric];
      const threshold = config.thresholds[metric];
      
      const degradation = (current - base) / base;
      
      analysis.metrics[metric] = {
        baseline: base,
        current: current,
        degradation: degradation,
        passed: Math.abs(degradation) <= threshold,
      };
      
      if (!analysis.metrics[metric].passed) {
        analysis.passed = false;
        analysis.reason = `${metric} degraded by ${(degradation * 100).toFixed(2)}%`;
      }
    }
    
    return analysis;
  }
}
```

### 5. Rollback Mechanisms

#### Automated Rollback
```typescript
export class RollbackManager {
  async monitorAndRollback(
    deployment: Deployment
  ): Promise<void> {
    const startTime = Date.now();
    const config = deployment.rollbackConfig;
    
    while (Date.now() - startTime < config.monitoringWindow) {
      const metrics = await this.collectMetrics(deployment);
      
      // Check error rate
      if (metrics.errorRate > config.errorThreshold) {
        await this.triggerRollback(deployment, 'High error rate');
        break;
      }
      
      // Check latency
      if (metrics.latencyP95 > config.latencyThreshold) {
        await this.triggerRollback(deployment, 'High latency');
        break;
      }
      
      // Check success rate
      if (metrics.successRate < config.successThreshold) {
        await this.triggerRollback(deployment, 'Low success rate');
        break;
      }
      
      await this.sleep(config.checkInterval);
    }
  }
  
  private async triggerRollback(
    deployment: Deployment,
    reason: string
  ): Promise<void> {
    log(`Triggering rollback for ${deployment.id}: ${reason}`);
    
    // Notify stakeholders
    await this.notifyRollback(deployment, reason);
    
    // Execute rollback
    switch (deployment.type) {
      case 'kubernetes':
        await this.rollbackKubernetes(deployment);
        break;
      case 'lambda':
        await this.rollbackLambda(deployment);
        break;
      case 'ecs':
        await this.rollbackECS(deployment);
        break;
    }
    
    // Verify rollback
    const success = await this.verifyRollback(deployment);
    
    if (!success) {
      await this.escalateRollbackFailure(deployment);
    }
  }
  
  private async rollbackKubernetes(
    deployment: Deployment
  ): Promise<void> {
    const cmd = `kubectl rollout undo deployment/${deployment.name} -n ${deployment.namespace}`;
    await exec(cmd);
    
    // Wait for rollout to complete
    const statusCmd = `kubectl rollout status deployment/${deployment.name} -n ${deployment.namespace}`;
    await exec(statusCmd);
  }
}
```

### 6. Release Coordination

#### Release Manager
```typescript
export class ReleaseManager {
  async createRelease(
    version: string,
    components: Component[]
  ): Promise<Release> {
    const release: Release = {
      id: uuid(),
      version,
      components,
      status: 'pending',
      createdAt: new Date(),
    };
    
    // Validate release
    await this.validateRelease(release);
    
    // Create release branch
    await this.createReleaseBranch(version);
    
    // Generate changelog
    release.changelog = await this.generateChangelog(version);
    
    // Build all components
    const builds = await Promise.all(
      components.map(c => this.buildComponent(c, version))
    );
    
    release.artifacts = builds.map(b => b.artifact);
    
    // Create release record
    await this.saveRelease(release);
    
    return release;
  }
  
  async deployRelease(
    releaseId: string,
    environment: string
  ): Promise<void> {
    const release = await this.getRelease(releaseId);
    
    // Pre-deployment checks
    await this.runPreDeploymentChecks(release, environment);
    
    // Deploy in order
    for (const component of release.components) {
      await this.deployComponent(component, environment, {
        version: release.version,
        waitForReady: true,
      });
    }
    
    // Post-deployment verification
    await this.runPostDeploymentTests(release, environment);
    
    // Update release status
    await this.updateReleaseStatus(releaseId, {
      status: 'deployed',
      environment,
      deployedAt: new Date(),
    });
  }
}
```

## Automation Tools

### 1. Deployment CLI
```typescript
#!/usr/bin/env node
// tools/deploy-cli.ts

import { Command } from 'commander';
import { DeploymentManager } from './deployment-manager';

const program = new Command();
const deploymentManager = new DeploymentManager();

program
  .name('printcraft-deploy')
  .description('PrintCraft AI Deployment CLI')
  .version('1.0.0');

program
  .command('deploy <component> <version>')
  .description('Deploy a component')
  .option('-e, --environment <env>', 'Target environment', 'staging')
  .option('-s, --strategy <strategy>', 'Deployment strategy', 'rolling')
  .option('--dry-run', 'Perform a dry run')
  .action(async (component, version, options) => {
    try {
      console.log(`Deploying ${component}:${version} to ${options.environment}`);
      
      if (options.dryRun) {
        const plan = await deploymentManager.planDeployment(
          component,
          version,
          options
        );
        console.log('Deployment plan:', JSON.stringify(plan, null, 2));
      } else {
        const result = await deploymentManager.deploy(
          component,
          version,
          options
        );
        console.log('Deployment result:', result);
      }
    } catch (error) {
      console.error('Deployment failed:', error);
      process.exit(1);
    }
  });

program
  .command('rollback <component>')
  .description('Rollback a component')
  .option('-e, --environment <env>', 'Target environment', 'staging')
  .action(async (component, options) => {
    try {
      console.log(`Rolling back ${component} in ${options.environment}`);
      const result = await deploymentManager.rollback(component, options);
      console.log('Rollback result:', result);
    } catch (error) {
      console.error('Rollback failed:', error);
      process.exit(1);
    }
  });

program.parse();
```

### 2. Pre-deployment Checks
```bash
#!/bin/bash
# scripts/pre-deploy-checks.sh

set -e

ENVIRONMENT=$1
CHECKS_PASSED=true

log() {
  echo "[PRE-DEPLOY] $@"
}

check_dependencies() {
  log "Checking dependencies..."
  
  # Check kubectl
  if ! command -v kubectl &> /dev/null; then
    log "ERROR: kubectl not found"
    return 1
  fi
  
  # Check helm
  if ! command -v helm &> /dev/null; then
    log "ERROR: helm not found"
    return 1
  fi
  
  # Check cloud CLI
  case $ENVIRONMENT in
    staging|production)
      if ! command -v aws &> /dev/null; then
        log "ERROR: AWS CLI not found"
        return 1
      fi
      ;;
  esac
  
  log "Dependencies check passed"
  return 0
}

check_cluster_access() {
  log "Checking cluster access..."
  
  if ! kubectl cluster-info &> /dev/null; then
    log "ERROR: Cannot access Kubernetes cluster"
    return 1
  fi
  
  log "Cluster access confirmed"
  return 0
}

check_resources() {
  log "Checking resource availability..."
  
  # Check node resources
  local nodes=$(kubectl get nodes -o json)
  local available_cpu=$(echo "$nodes" | jq -r '.items[].status.allocatable.cpu' | sed 's/[^0-9]//g' | awk '{sum+=$1} END {print sum}')
  local available_memory=$(echo "$nodes" | jq -r '.items[].status.allocatable.memory' | sed 's/[^0-9]//g' | awk '{sum+=$1} END {print sum/1024/1024}')
  
  log "Available CPU: ${available_cpu}m"
  log "Available Memory: ${available_memory}Mi"
  
  if [ "$available_cpu" -lt 2000 ]; then
    log "WARNING: Low CPU availability"
  fi
  
  if [ "$available_memory" -lt 4096 ]; then
    log "WARNING: Low memory availability"
  fi
  
  return 0
}

check_database_migrations() {
  log "Checking pending database migrations..."
  
  local pending=$(kubectl exec -n $NAMESPACE deployment/api-gateway -- \
    npm run migrations:pending --silent)
  
  if [ -n "$pending" ]; then
    log "WARNING: Pending migrations detected:"
    echo "$pending"
    log "Run migrations before deployment"
    return 1
  fi
  
  log "No pending migrations"
  return 0
}

# Run all checks
if ! check_dependencies; then
  CHECKS_PASSED=false
fi

if ! check_cluster_access; then
  CHECKS_PASSED=false
fi

if ! check_resources; then
  CHECKS_PASSED=false
fi

if [ "$ENVIRONMENT" != "development" ]; then
  if ! check_database_migrations; then
    CHECKS_PASSED=false
  fi
fi

if [ "$CHECKS_PASSED" = true ]; then
  log "All pre-deployment checks passed"
  exit 0
else
  log "Pre-deployment checks failed"
  exit 1
fi
```

## Monitoring & Observability

### Deployment Metrics
```typescript
export class DeploymentMetrics {
  private prometheus = new PrometheusClient();
  
  recordDeployment(deployment: Deployment): void {
    // Deployment counter
    this.prometheus.counter('deployments_total', {
      component: deployment.component,
      environment: deployment.environment,
      status: deployment.status,
    }).inc();
    
    // Deployment duration
    this.prometheus.histogram('deployment_duration_seconds', {
      component: deployment.component,
      environment: deployment.environment,
    }).observe(deployment.duration);
    
    // Deployment gauge
    this.prometheus.gauge('deployment_info', {
      component: deployment.component,
      environment: deployment.environment,
      version: deployment.version,
    }).set(1);
  }
  
  recordRollback(rollback: Rollback): void {
    this.prometheus.counter('rollbacks_total', {
      component: rollback.component,
      environment: rollback.environment,
      reason: rollback.reason,
    }).inc();
  }
}
```

## Best Practices

### 1. Deployment Checklist
```yaml
deployment_checklist:
  pre_deployment:
    - dependency_updates
    - security_scanning
    - performance_testing
    - database_migrations
    - configuration_review
    
  deployment:
    - health_checks
    - progressive_rollout
    - monitoring_alerts
    - error_tracking
    - performance_monitoring
    
  post_deployment:
    - smoke_tests
    - user_acceptance
    - performance_validation
    - security_verification
    - documentation_update
```

### 2. Emergency Procedures
```typescript
export class EmergencyProcedures {
  static readonly procedures = {
    complete_outage: [
      'Activate incident response team',
      'Switch to disaster recovery site',
      'Notify stakeholders',
      'Begin root cause analysis',
    ],
    
    data_corruption: [
      'Stop all write operations',
      'Identify extent of corruption',
      'Restore from last known good backup',
      'Verify data integrity',
    ],
    
    security_breach: [
      'Isolate affected systems',
      'Reset all credentials',
      'Audit access logs',
      'Notify security team',
    ],
  };
}
```

---

*This skill ensures reliable, automated deployments for PrintCraft AI across all environments.*