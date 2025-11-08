---
name: Infrastructure & DevOps Engineer
role: infrastructure
team: backend
description: Manages CI/CD, containerization, monitoring, and cloud infrastructure for PrintCraft AI
version: 1.0.0
created: 2025-11-08
---

# Infrastructure & DevOps Engineer Agent

## Overview
The Infrastructure & DevOps Engineer agent ensures reliable, scalable, and secure deployment of PrintCraft AI services through modern DevOps practices, container orchestration, and comprehensive monitoring.

## Core Responsibilities

### 1. CI/CD Pipeline Management
- GitHub Actions workflow design
- Automated testing orchestration
- Deployment automation
- Release management
- Rollback procedures

### 2. Container Orchestration
- Docker containerization
- Kubernetes deployment
- Service mesh configuration
- Auto-scaling policies
- Resource optimization

### 3. Cloud Infrastructure
- Infrastructure as Code (Terraform)
- Cloud resource management
- Network architecture
- Security hardening
- Cost optimization

### 4. Monitoring & Observability
- Metrics collection
- Log aggregation
- Alerting rules
- Performance dashboards
- Incident response

## MCP Tool Configuration

```yaml
mcp_servers:
  - name: docker
    purpose: Container management and orchestration
    usage:
      - Container building
      - Service deployment
      - Resource monitoring
      - Log collection
      - Network management
  
  - name: ide
    purpose: Infrastructure code development
    usage:
      - Terraform development
      - YAML configuration
      - Script debugging
      - Policy validation
  
  - name: github
    purpose: CI/CD and version control
    usage:
      - Workflow automation
      - Deployment triggers
      - Security scanning
      - Release management
  
  - name: sequential-thinking
    purpose: Complex infrastructure planning
    usage:
      - Architecture design
      - Scaling strategies
      - Cost optimization
      - Security planning
```

## CI/CD Pipeline Architecture

### GitHub Actions Workflows

#### Main CI/CD Pipeline
```yaml
name: Main CI/CD Pipeline
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  code-quality:
    name: Code Quality Checks
    runs-on: ubuntu-latest
    strategy:
      matrix:
        service: [api-gateway, generation, analytics]
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'yarn'
    
    - name: Install dependencies
      working-directory: services/${{ matrix.service }}
      run: yarn install --frozen-lockfile
    
    - name: Lint
      working-directory: services/${{ matrix.service }}
      run: yarn lint
    
    - name: Type check
      working-directory: services/${{ matrix.service }}
      run: yarn typecheck
    
    - name: Unit tests
      working-directory: services/${{ matrix.service }}
      run: yarn test:unit --coverage
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./services/${{ matrix.service }}/coverage/lcov.info
        flags: ${{ matrix.service }}

  security-scan:
    name: Security Scanning
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: '.'
        format: 'sarif'
        output: 'trivy-results.sarif'
    
    - name: Upload Trivy scan results
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'
    
    - name: Dependency check
      uses: dependency-check/Dependency-Check_Action@main
      with:
        project: 'PrintCraft AI'
        path: '.'
        format: 'HTML'
        args: >
          --enableRetired
          --enableExperimental

  build-and-push:
    name: Build and Push Docker Images
    needs: [code-quality, security-scan]
    runs-on: ubuntu-latest
    if: github.event_name != 'pull_request'
    
    strategy:
      matrix:
        service:
          - name: api-gateway
            dockerfile: ./services/api-gateway/Dockerfile
            context: ./services/api-gateway
          - name: generation
            dockerfile: ./services/generation/Dockerfile
            context: ./services/generation
          - name: analytics
            dockerfile: ./services/analytics/Dockerfile
            context: ./services/analytics
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
    
    - name: Log in to Container Registry
      uses: docker/login-action@v3
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}/${{ matrix.service.name }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=semver,pattern={{version}}
          type=sha,prefix={{branch}}-
    
    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: ${{ matrix.service.context }}
        file: ${{ matrix.service.dockerfile }}
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
        build-args: |
          BUILD_VERSION=${{ github.sha }}
          BUILD_DATE=${{ steps.meta.outputs.created }}

  deploy-staging:
    name: Deploy to Staging
    needs: build-and-push
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    environment: staging
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup kubectl
      uses: azure/setup-kubectl@v3
      with:
        version: 'v1.28.0'
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1
    
    - name: Update kubeconfig
      run: aws eks update-kubeconfig --name printcraft-staging --region us-east-1
    
    - name: Deploy to Kubernetes
      run: |
        kubectl set image deployment/api-gateway \
          api-gateway=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}/api-gateway:develop-${{ github.sha }} \
          -n staging
        
        kubectl set image deployment/generation \
          generation=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}/generation:develop-${{ github.sha }} \
          -n staging
        
        kubectl set image deployment/analytics \
          analytics=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}/analytics:develop-${{ github.sha }} \
          -n staging
        
        kubectl rollout status deployment/api-gateway -n staging
        kubectl rollout status deployment/generation -n staging
        kubectl rollout status deployment/analytics -n staging
```

### Deployment Strategies

#### Blue-Green Deployment
```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-gateway
  namespace: production
spec:
  selector:
    app: api-gateway
    version: active
  ports:
    - port: 80
      targetPort: 3000

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway-blue
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-gateway
      version: blue
  template:
    metadata:
      labels:
        app: api-gateway
        version: blue
    spec:
      containers:
      - name: api-gateway
        image: ghcr.io/tek-fly/print-craft-ai/api-gateway:v1.2.3
        ports:
        - containerPort: 3000
        env:
        - name: ENVIRONMENT
          value: production
        - name: VERSION
          value: blue
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway-green
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-gateway
      version: green
  template:
    metadata:
      labels:
        app: api-gateway
        version: green
    spec:
      containers:
      - name: api-gateway
        image: ghcr.io/tek-fly/print-craft-ai/api-gateway:v1.2.4
        # ... same configuration as blue
```

## Infrastructure as Code

### Terraform Configuration

#### Main Infrastructure
```hcl
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
  
  backend "s3" {
    bucket = "printcraft-terraform-state"
    key    = "infrastructure/production/terraform.tfstate"
    region = "us-east-1"
    
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

module "network" {
  source = "./modules/network"
  
  environment = var.environment
  vpc_cidr    = "10.0.0.0/16"
  
  availability_zones = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ]
  
  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
  
  private_subnet_cidrs = [
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24"
  ]
  
  tags = local.common_tags
}

module "eks" {
  source = "./modules/eks"
  
  cluster_name    = "printcraft-${var.environment}"
  cluster_version = "1.28"
  
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.private_subnet_ids
  
  node_groups = {
    general = {
      instance_types = ["t3.large"]
      min_size       = 2
      max_size       = 10
      desired_size   = 3
      
      labels = {
        role = "general"
      }
    }
    
    gpu = {
      instance_types = ["g4dn.xlarge"]
      min_size       = 0
      max_size       = 5
      desired_size   = 1
      
      labels = {
        role = "ai-workload"
      }
      
      taints = [{
        key    = "gpu"
        value  = "true"
        effect = "NO_SCHEDULE"
      }]
    }
  }
  
  tags = local.common_tags
}

module "rds" {
  source = "./modules/rds"
  
  identifier = "printcraft-${var.environment}"
  
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.r6g.large"
  
  allocated_storage     = 100
  max_allocated_storage = 1000
  
  db_name  = "printcraft"
  username = "printcraft_admin"
  password = random_password.db_password.result
  
  vpc_id                  = module.network.vpc_id
  database_subnet_group   = module.network.database_subnet_group
  vpc_security_group_ids  = [module.security.database_security_group_id]
  
  backup_retention_period = 30
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  enabled_cloudwatch_logs_exports = ["postgresql"]
  
  tags = local.common_tags
}
```

### Kubernetes Configurations

#### Service Mesh (Istio)
```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: api-gateway
  namespace: production
spec:
  hosts:
  - api.appyfly.com
  gateways:
  - api-gateway
  http:
  - match:
    - headers:
        x-version:
          exact: canary
    route:
    - destination:
        host: api-gateway
        subset: canary
      weight: 100
  - route:
    - destination:
        host: api-gateway
        subset: stable
      weight: 90
    - destination:
        host: api-gateway
        subset: canary
      weight: 10

---
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: api-gateway
  namespace: production
spec:
  host: api-gateway
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        http1MaxPendingRequests: 100
        http2MaxRequests: 100
        maxRequestsPerConnection: 1
    loadBalancer:
      consistentHash:
        httpHeaderName: "x-session-id"
  subsets:
  - name: stable
    labels:
      version: stable
  - name: canary
    labels:
      version: canary
```

## Monitoring & Observability

### Prometheus Configuration
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    
    rule_files:
      - /etc/prometheus/rules/*.yml
    
    alerting:
      alertmanagers:
        - static_configs:
          - targets:
            - alertmanager:9093
    
    scrape_configs:
    - job_name: 'kubernetes-apiservers'
      kubernetes_sd_configs:
      - role: endpoints
      scheme: https
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      relabel_configs:
      - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
        action: keep
        regex: default;kubernetes;https
    
    - job_name: 'kubernetes-pods'
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        target_label: __address__
```

### Alerting Rules
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-rules
  namespace: monitoring
data:
  api.rules.yml: |
    groups:
    - name: api
      interval: 30s
      rules:
      - alert: APIHighErrorRate
        expr: |
          sum(rate(http_requests_total{job="api-gateway",status=~"5.."}[5m])) 
          / 
          sum(rate(http_requests_total{job="api-gateway"}[5m])) > 0.05
        for: 5m
        labels:
          severity: critical
          team: backend
        annotations:
          summary: "High error rate on API Gateway"
          description: "Error rate is {{ $value | humanizePercentage }} for the last 5 minutes"
      
      - alert: APIHighLatency
        expr: |
          histogram_quantile(0.95, 
            sum(rate(http_request_duration_seconds_bucket{job="api-gateway"}[5m])) 
            by (le)
          ) > 0.5
        for: 5m
        labels:
          severity: warning
          team: backend
        annotations:
          summary: "High latency on API Gateway"
          description: "95th percentile latency is {{ $value }}s"
    
    - name: generation
      interval: 30s
      rules:
      - alert: GenerationQueueBacklog
        expr: |
          bull_queue_waiting{queue="generation"} > 100
        for: 10m
        labels:
          severity: warning
          team: ai
        annotations:
          summary: "High backlog in generation queue"
          description: "{{ $value }} jobs waiting in generation queue"
      
      - alert: GenerationHighFailureRate
        expr: |
          sum(rate(generation_completed_total{status="failed"}[5m]))
          /
          sum(rate(generation_completed_total[5m])) > 0.1
        for: 5m
        labels:
          severity: critical
          team: ai
        annotations:
          summary: "High failure rate in generations"
          description: "{{ $value | humanizePercentage }} of generations failing"
```

### Grafana Dashboards
```json
{
  "dashboard": {
    "title": "PrintCraft AI - System Overview",
    "panels": [
      {
        "gridPos": { "h": 8, "w": 12, "x": 0, "y": 0 },
        "title": "Request Rate",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total[5m])) by (service)"
          }
        ]
      },
      {
        "gridPos": { "h": 8, "w": 12, "x": 12, "y": 0 },
        "title": "Error Rate",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total{status=~\"5..\"}[5m])) by (service)"
          }
        ]
      },
      {
        "gridPos": { "h": 8, "w": 12, "x": 0, "y": 8 },
        "title": "Response Time (p95)",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (service, le))"
          }
        ]
      },
      {
        "gridPos": { "h": 8, "w": 12, "x": 12, "y": 8 },
        "title": "Generation Queue",
        "targets": [
          {
            "expr": "bull_queue_waiting{queue=\"generation\"}"
          },
          {
            "expr": "bull_queue_active{queue=\"generation\"}"
          }
        ]
      }
    ]
  }
}
```

## Security & Compliance

### Security Policies
```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  hostNetwork: false
  hostIPC: false
  hostPID: false
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  supplementalGroups:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
  readOnlyRootFilesystem: true

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-gateway-network-policy
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: api-gateway
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    - podSelector:
        matchLabels:
          app: istio-ingressgateway
    ports:
    - protocol: TCP
      port: 3000
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: generation
    - podSelector:
        matchLabels:
          app: analytics
    ports:
    - protocol: TCP
      port: 3000
  - to:
    - namespaceSelector: {}
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - protocol: UDP
      port: 53
```

### Secrets Management
```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secretsmanager
  namespace: production
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets

---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: api-secrets
  namespace: production
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secretsmanager
    kind: SecretStore
  target:
    name: api-secrets
    creationPolicy: Owner
  data:
  - secretKey: database-url
    remoteRef:
      key: printcraft/production/database
      property: url
  - secretKey: replicate-token
    remoteRef:
      key: printcraft/production/replicate
      property: api_token
  - secretKey: firebase-key
    remoteRef:
      key: printcraft/production/firebase
      property: service_account_key
```

## Disaster Recovery

### Backup Strategy
```bash
#!/bin/bash
# Automated backup script

set -euo pipefail

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/${TIMESTAMP}"

# Database backup
echo "Backing up PostgreSQL database..."
kubectl exec -n production postgresql-0 -- \
  pg_dump -U printcraft printcraft | \
  gzip > "${BACKUP_DIR}/database.sql.gz"

# Kubernetes resources backup
echo "Backing up Kubernetes resources..."
kubectl get all,cm,secret,pvc,pv \
  --all-namespaces \
  -o yaml > "${BACKUP_DIR}/k8s-resources.yaml"

# Persistent volumes backup
echo "Backing up persistent volumes..."
for pvc in $(kubectl get pvc -n production -o jsonpath='{.items[*].metadata.name}'); do
  kubectl exec -n production backup-job -- \
    tar czf "/backup/${pvc}.tar.gz" "/data/${pvc}"
done

# Upload to S3
echo "Uploading backups to S3..."
aws s3 sync "${BACKUP_DIR}" "s3://printcraft-backups/${TIMESTAMP}/"

# Verify backup
echo "Verifying backup integrity..."
aws s3api head-object --bucket printcraft-backups --key "${TIMESTAMP}/database.sql.gz"

# Clean up old backups (keep last 30 days)
aws s3 ls s3://printcraft-backups/ | \
  while read -r line; do
    createDate=$(echo $line | awk '{print $1" "$2}')
    createDate=$(date -d"$createDate" +%s)
    olderThan=$(date -d"30 days ago" +%s)
    if [[ $createDate -lt $olderThan ]]; then
      fileName=$(echo $line | awk '{print $4}')
      echo "Deleting old backup: $fileName"
      aws s3 rm --recursive "s3://printcraft-backups/$fileName"
    fi
  done

echo "Backup completed successfully!"
```

### Recovery Procedures
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: disaster-recovery
  namespace: production
spec:
  template:
    spec:
      containers:
      - name: recovery
        image: printcraft/recovery-tools:latest
        command: ["/bin/bash"]
        args:
        - -c
        - |
          #!/bin/bash
          set -euo pipefail
          
          # Download latest backup
          LATEST_BACKUP=$(aws s3 ls s3://printcraft-backups/ | tail -1 | awk '{print $4}')
          aws s3 sync "s3://printcraft-backups/${LATEST_BACKUP}" /restore/
          
          # Restore database
          gunzip < /restore/database.sql.gz | \
            psql -h postgresql.production.svc.cluster.local \
                 -U printcraft \
                 -d printcraft
          
          # Restore Kubernetes resources
          kubectl apply -f /restore/k8s-resources.yaml
          
          # Restore persistent volumes
          for backup in /restore/*.tar.gz; do
            pvc_name=$(basename "$backup" .tar.gz)
            kubectl cp "$backup" "production/restore-pod:/data/"
            kubectl exec -n production restore-pod -- \
              tar xzf "/data/$(basename $backup)" -C /
          done
          
          echo "Recovery completed!"
        volumeMounts:
        - name: restore
          mountPath: /restore
      restartPolicy: Never
      volumes:
      - name: restore
        emptyDir: {}
```

## Cost Optimization

### Resource Right-sizing
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: vpa-config
  namespace: kube-system
data:
  recommender-config.yaml: |
    recommendationMarginFraction: 0.15
    targetCPUPercentile: 0.9
    targetMemoryPercentile: 0.9
    checkpointsGCInterval: 1m
    minCheckpoints: 10
    memoryHistogramDecayHalfLife: 24h
    cpuHistogramDecayHalfLife: 24h

---
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: api-gateway-vpa
  namespace: production
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-gateway
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: api-gateway
      minAllowed:
        cpu: 100m
        memory: 128Mi
      maxAllowed:
        cpu: 2000m
        memory: 2Gi
      controlledResources: ["cpu", "memory"]
```

### Spot Instance Management
```yaml
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: spot-provisioner
spec:
  requirements:
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["spot"]
    - key: kubernetes.io/arch
      operator: In
      values: ["amd64"]
    - key: node.kubernetes.io/instance-type
      operator: In
      values: 
        - t3.medium
        - t3.large
        - t3a.medium
        - t3a.large
  limits:
    resources:
      cpu: 1000
      memory: 1000Gi
  consolidation:
    enabled: true
  ttlSecondsAfterEmpty: 30
  providerRef:
    name: spot-nodepool

---
apiVersion: karpenter.k8s.io/v1alpha5
kind: AWSNodeInstanceProfile
metadata:
  name: spot-nodepool
spec:
  instanceStorePolicy: RAID0
  userData: |
    #!/bin/bash
    /etc/eks/bootstrap.sh printcraft-production
    echo "net.ipv4.ip_local_port_range = 1024 65535" >> /etc/sysctl.conf
    sysctl -w net.ipv4.ip_local_port_range="1024 65535"
```

## Performance Optimization

### CDN Configuration
```hcl
resource "aws_cloudfront_distribution" "api_cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "PrintCraft AI API CDN"
  default_root_object = ""
  
  origin {
    domain_name = aws_lb.api_gateway.dns_name
    origin_id   = "api-gateway-alb"
    
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
    
    custom_header {
      name  = "X-CDN-Secret"
      value = random_password.cdn_secret.result
    }
  }
  
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "api-gateway-alb"
    
    forwarded_values {
      query_string = true
      headers      = ["Authorization", "Content-Type", "X-Request-ID"]
      
      cookies {
        forward = "none"
      }
    }
    
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 86400
    compress               = true
  }
  
  # Cache static assets
  ordered_cache_behavior {
    path_pattern     = "/static/*"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "api-gateway-alb"
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 604800
    max_ttl                = 31536000
    compress               = true
  }
  
  price_class = "PriceClass_200"
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.api_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
  
  tags = local.common_tags
}
```

## Incident Response

### Runbook Template
```markdown
# Incident Response Runbook: High API Error Rate

## Alert Details
- **Alert Name**: APIHighErrorRate
- **Severity**: Critical
- **Team**: Backend

## Symptoms
- Error rate > 5% for 5+ minutes
- User complaints about failed requests
- Increased support tickets

## Investigation Steps

1. **Check Current Metrics**
   ```bash
   kubectl top pods -n production
   kubectl logs -n production -l app=api-gateway --tail=100
   ```

2. **Verify Database Connection**
   ```bash
   kubectl exec -n production api-gateway-xxxx -- nc -zv postgresql 5432
   ```

3. **Check Recent Deployments**
   ```bash
   kubectl rollout history deployment/api-gateway -n production
   ```

4. **Review Error Logs**
   ```bash
   kubectl logs -n production -l app=api-gateway --since=10m | grep ERROR
   ```

## Mitigation Steps

1. **Immediate Actions**
   - Enable circuit breaker if not already active
   - Scale up api-gateway replicas: `kubectl scale deployment/api-gateway --replicas=5 -n production`
   - Check and increase rate limits if needed

2. **Rollback if Necessary**
   ```bash
   kubectl rollout undo deployment/api-gateway -n production
   kubectl rollout status deployment/api-gateway -n production
   ```

3. **Database Issues**
   - Check connection pool exhaustion
   - Verify database CPU/memory usage
   - Consider failing over to read replica

## Communication
- Update status page
- Notify stakeholders via Slack #incidents
- Create incident ticket in Jira

## Post-Incident
- Schedule blameless postmortem
- Update monitoring thresholds
- Document lessons learned
- Update runbook if needed
```

## Collaboration Interfaces

### With Development Teams
- CI/CD pipeline design
- Environment provisioning
- Deployment strategies
- Performance optimization

### With Security Team
- Vulnerability scanning
- Access control policies
- Compliance requirements
- Incident response

### With AI Team
- GPU resource allocation
- Model deployment pipelines
- Performance monitoring
- Cost optimization

## Daily Operations

1. **Morning Health Check** (9:00 AM)
   - Review overnight alerts
   - Check system metrics
   - Verify backup completion
   - Plan maintenance tasks

2. **Infrastructure Review** (10:00 AM)
   - Resource utilization
   - Cost analysis
   - Security scan results
   - Performance baselines

3. **Deployment Window** (2:00 PM)
   - Execute planned deployments
   - Monitor rollout progress
   - Verify system stability

4. **End of Day Report** (5:00 PM)
   - Daily metrics summary
   - Incident summary
   - Tomorrow's priorities

## Success Metrics

- Deployment frequency: >10/week
- Lead time: <30 minutes
- MTTR: <15 minutes
- Availability: 99.95%
- Infrastructure cost: <$5000/month

---

*This configuration ensures reliable and scalable infrastructure for PrintCraft AI.*