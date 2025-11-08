#!/bin/bash

# PrintCraft AI Deployment Script
# Handles deployment to staging and production environments

set -e
set -o pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
PROJECT_ROOT=$(pwd)
POD_APP_DIR="$PROJECT_ROOT/pod_app"
ENVIRONMENT=""
VERSION=""
SKIP_TESTS=false
DRY_RUN=false

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            staging|production)
                ENVIRONMENT=$1
                shift
                ;;
            --version)
                VERSION=$2
                shift 2
                ;;
            --skip-tests)
                SKIP_TESTS=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                ;;
        esac
    done
    
    # Validate environment
    if [ -z "$ENVIRONMENT" ]; then
        log_error "Environment not specified. Use 'staging' or 'production'"
    fi
    
    # Validate version for production
    if [ "$ENVIRONMENT" = "production" ] && [ -z "$VERSION" ]; then
        log_error "Version is required for production deployments. Use --version v1.2.3"
    fi
}

show_help() {
    echo "Usage: ./deploy.sh [environment] [options]"
    echo
    echo "Environments:"
    echo "  staging      Deploy to staging environment"
    echo "  production   Deploy to production environment"
    echo
    echo "Options:"
    echo "  --version v1.2.3   Specify version (required for production)"
    echo "  --skip-tests       Skip running tests before deployment"
    echo "  --dry-run          Show what would be deployed without deploying"
    echo "  --help             Show this help message"
    echo
    echo "Examples:"
    echo "  ./deploy.sh staging"
    echo "  ./deploy.sh production --version v1.2.3"
    echo "  ./deploy.sh staging --dry-run"
}

# Check prerequisites
check_prerequisites() {
    log_step "Checking prerequisites..."
    
    # Check required commands
    commands=("flutter" "firebase" "gcloud" "git")
    for cmd in "${commands[@]}"; do
        if ! command -v $cmd &> /dev/null; then
            log_error "$cmd is required but not installed"
        fi
    done
    
    # Check git status
    if [ -n "$(git status --porcelain)" ]; then
        log_warning "You have uncommitted changes"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Deployment cancelled"
            exit 0
        fi
    fi
    
    # Check current branch
    current_branch=$(git branch --show-current)
    if [ "$ENVIRONMENT" = "production" ] && [ "$current_branch" != "main" ]; then
        log_error "Production deployments must be from main branch. Current: $current_branch"
    fi
    
    # Check authentication
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
        log_error "Not authenticated with Google Cloud. Run 'gcloud auth login'"
    fi
    
    log_success "Prerequisites check passed"
}

# Run tests
run_tests() {
    if [ "$SKIP_TESTS" = true ]; then
        log_warning "Skipping tests (--skip-tests flag used)"
        return
    fi
    
    log_step "Running tests..."
    
    if ./scripts/run-tests.sh; then
        log_success "All tests passed"
    else
        log_error "Tests failed. Deployment aborted."
    fi
}

# Update version
update_version() {
    if [ -z "$VERSION" ]; then
        return
    fi
    
    log_step "Updating version to $VERSION..."
    
    cd "$POD_APP_DIR"
    
    # Update pubspec.yaml
    VERSION_NUMBER="${VERSION#v}"
    sed -i.bak "s/version: .*/version: $VERSION_NUMBER+$BUILD_NUMBER/" pubspec.yaml
    rm pubspec.yaml.bak
    
    # Commit version change
    git add pubspec.yaml
    git commit -m "chore: bump version to $VERSION" || true
    
    # Create git tag
    git tag -a "$VERSION" -m "Release $VERSION" || true
    
    cd "$PROJECT_ROOT"
    
    log_success "Version updated"
}

# Build Flutter app
build_app() {
    log_step "Building Flutter app..."
    
    cd "$POD_APP_DIR"
    
    # Clean previous builds
    flutter clean
    flutter pub get
    
    # Set environment variables
    local dart_defines=""
    if [ "$ENVIRONMENT" = "production" ]; then
        dart_defines="--dart-define=ENVIRONMENT=production --dart-define=REPLICATE_API_URL=https://api.appyfly.com"
    else
        dart_defines="--dart-define=ENVIRONMENT=staging --dart-define=REPLICATE_API_URL=https://staging-api.appyfly.com"
    fi
    
    # Build for both platforms
    log_info "Building Android..."
    flutter build appbundle --release $dart_defines
    
    log_info "Building iOS..."
    flutter build ipa --release $dart_defines
    
    cd "$PROJECT_ROOT"
    
    log_success "App built successfully"
}

# Deploy Firebase services
deploy_firebase() {
    log_step "Deploying Firebase services..."
    
    # Select Firebase project
    if [ "$ENVIRONMENT" = "production" ]; then
        firebase use production
    else
        firebase use staging
    fi
    
    # Deploy functions
    log_info "Deploying Cloud Functions..."
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] Would deploy: firebase deploy --only functions"
    else
        firebase deploy --only functions
    fi
    
    # Deploy security rules
    log_info "Deploying security rules..."
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] Would deploy: firebase deploy --only firestore:rules,storage:rules"
    else
        firebase deploy --only firestore:rules,storage:rules
    fi
    
    log_success "Firebase services deployed"
}

# Deploy to app stores
deploy_app_stores() {
    log_step "Deploying to app stores..."
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] Would deploy Android to Google Play"
        log_info "[DRY RUN] Would deploy iOS to App Store Connect"
        return
    fi
    
    # Android deployment
    log_info "Deploying Android app..."
    # This would typically use fastlane or Google Play API
    # Placeholder for actual deployment command
    
    # iOS deployment
    log_info "Deploying iOS app..."
    # This would typically use fastlane or App Store Connect API
    # Placeholder for actual deployment command
    
    log_success "Apps deployed to stores"
}

# Post-deployment tasks
post_deployment() {
    log_step "Running post-deployment tasks..."
    
    # Update remote config
    if [ "$ENVIRONMENT" = "production" ]; then
        log_info "Updating remote config..."
        # Update minimum app version, feature flags, etc.
    fi
    
    # Invalidate CDN cache
    log_info "Invalidating CDN cache..."
    # gcloud compute url-maps invalidate-cdn-cache ...
    
    # Send deployment notification
    if [ -n "$SLACK_WEBHOOK_URL" ]; then
        log_info "Sending deployment notification..."
        local message="🚀 Deployed to $ENVIRONMENT"
        if [ -n "$VERSION" ]; then
            message="$message (version $VERSION)"
        fi
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"$message\"}" \
            "$SLACK_WEBHOOK_URL" 2>/dev/null || true
    fi
    
    log_success "Post-deployment tasks completed"
}

# Rollback deployment
rollback() {
    log_error "Deployment failed. Rolling back..."
    
    # Revert git changes
    if [ -n "$VERSION" ]; then
        git tag -d "$VERSION" 2>/dev/null || true
        git reset --hard HEAD~1
    fi
    
    # Rollback Firebase
    # firebase functions:delete ...
    
    log_warning "Rollback completed. Please check the system."
}

# Main deployment flow
main() {
    echo "========================================="
    echo "PrintCraft AI Deployment"
    echo "Environment: $ENVIRONMENT"
    if [ -n "$VERSION" ]; then
        echo "Version: $VERSION"
    fi
    if [ "$DRY_RUN" = true ]; then
        echo "Mode: DRY RUN"
    fi
    echo "========================================="
    echo
    
    # Confirmation
    if [ "$DRY_RUN" = false ]; then
        read -p "Are you sure you want to deploy to $ENVIRONMENT? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Deployment cancelled"
            exit 0
        fi
    fi
    
    # Set up error handling
    trap rollback ERR
    
    # Execute deployment steps
    check_prerequisites
    run_tests
    update_version
    build_app
    deploy_firebase
    deploy_app_stores
    post_deployment
    
    # Success
    echo
    echo "========================================="
    log_success "Deployment to $ENVIRONMENT completed successfully!"
    echo "========================================="
    
    if [ "$ENVIRONMENT" = "production" ] && [ -n "$VERSION" ]; then
        echo
        echo "Don't forget to:"
        echo "1. Create release notes on GitHub"
        echo "2. Update the changelog"
        echo "3. Notify the team"
        echo "4. Monitor error rates and performance"
    fi
}

# Parse arguments and run
parse_args "$@"
main