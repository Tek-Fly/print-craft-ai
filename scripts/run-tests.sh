#!/bin/bash

# PrintCraft AI Test Runner Script
# Runs all tests with coverage and quality checks

set -e
set -o pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
COVERAGE_THRESHOLD=80
PROJECT_ROOT=$(pwd)
POD_APP_DIR="$PROJECT_ROOT/pod_app"

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
}

# Test tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Parse command line arguments
TEST_TYPE="all"
WATCH_MODE=false
COVERAGE=true
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --unit)
            TEST_TYPE="unit"
            shift
            ;;
        --integration)
            TEST_TYPE="integration"
            shift
            ;;
        --e2e)
            TEST_TYPE="e2e"
            shift
            ;;
        --watch)
            WATCH_MODE=true
            shift
            ;;
        --no-coverage)
            COVERAGE=false
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

show_help() {
    echo "Usage: ./run-tests.sh [options]"
    echo
    echo "Options:"
    echo "  --unit          Run only unit tests"
    echo "  --integration   Run only integration tests"
    echo "  --e2e           Run only end-to-end tests"
    echo "  --watch         Run tests in watch mode"
    echo "  --no-coverage   Skip coverage generation"
    echo "  --verbose       Show verbose output"
    echo "  --help          Show this help message"
    echo
}

# Check Flutter environment
check_flutter() {
    log_info "Checking Flutter environment..."
    
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter not found. Please run setup-dev-environment.sh first."
        exit 1
    fi
    
    cd "$POD_APP_DIR"
    
    # Update dependencies
    log_info "Getting dependencies..."
    flutter pub get
    
    cd "$PROJECT_ROOT"
}

# Run static analysis
run_analysis() {
    log_info "Running static analysis..."
    
    cd "$POD_APP_DIR"
    
    # Flutter analyze
    if flutter analyze --no-fatal-infos; then
        log_success "Static analysis passed"
        ((PASSED_TESTS++))
    else
        log_error "Static analysis failed"
        ((FAILED_TESTS++))
        return 1
    fi
    
    # Dart format check
    log_info "Checking code formatting..."
    if dart format --set-exit-if-changed .; then
        log_success "Code formatting check passed"
        ((PASSED_TESTS++))
    else
        log_error "Code formatting issues found. Run 'dart format .' to fix."
        ((FAILED_TESTS++))
        return 1
    fi
    
    cd "$PROJECT_ROOT"
}

# Run unit tests
run_unit_tests() {
    log_info "Running unit tests..."
    
    cd "$POD_APP_DIR"
    
    test_cmd="flutter test"
    
    if [ "$COVERAGE" = true ]; then
        test_cmd="$test_cmd --coverage"
    fi
    
    if [ "$VERBOSE" = true ]; then
        test_cmd="$test_cmd --verbose"
    fi
    
    if [ "$WATCH_MODE" = true ]; then
        $test_cmd --watch
    else
        if $test_cmd; then
            log_success "Unit tests passed"
            ((PASSED_TESTS++))
        else
            log_error "Unit tests failed"
            ((FAILED_TESTS++))
            return 1
        fi
    fi
    
    cd "$PROJECT_ROOT"
}

# Run integration tests
run_integration_tests() {
    log_info "Running integration tests..."
    
    cd "$POD_APP_DIR"
    
    # Check if integration tests exist
    if [ ! -d "integration_test" ]; then
        log_warning "No integration tests found"
        return 0
    fi
    
    # For CI environment
    if [ -n "$CI" ]; then
        flutter test integration_test --dart-define=CI=true
    else
        # For local development
        log_info "Starting iOS Simulator..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # Start iOS simulator
            xcrun simctl boot "iPhone 14" 2>/dev/null || true
            
            # Run integration tests
            if flutter test integration_test; then
                log_success "Integration tests passed"
                ((PASSED_TESTS++))
            else
                log_error "Integration tests failed"
                ((FAILED_TESTS++))
                return 1
            fi
        else
            log_warning "Integration tests skipped (iOS Simulator not available)"
        fi
    fi
    
    cd "$PROJECT_ROOT"
}

# Run e2e tests
run_e2e_tests() {
    log_info "Running end-to-end tests..."
    
    # Check if e2e directory exists
    if [ ! -d "e2e" ]; then
        log_warning "No e2e tests found"
        return 0
    fi
    
    cd e2e
    
    # Install dependencies if package.json exists
    if [ -f "package.json" ]; then
        npm install
        
        if npm test; then
            log_success "E2E tests passed"
            ((PASSED_TESTS++))
        else
            log_error "E2E tests failed"
            ((FAILED_TESTS++))
            return 1
        fi
    else
        log_warning "E2E test configuration not found"
    fi
    
    cd "$PROJECT_ROOT"
}

# Check test coverage
check_coverage() {
    if [ "$COVERAGE" = false ]; then
        return 0
    fi
    
    log_info "Checking test coverage..."
    
    cd "$POD_APP_DIR"
    
    if [ -f "coverage/lcov.info" ]; then
        # Generate coverage report
        if command -v lcov &> /dev/null; then
            lcov --list coverage/lcov.info
            
            # Check coverage threshold
            COVERAGE_PERCENT=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines......:" | sed 's/.*: \(.*\)%.*/\1/' | cut -d'.' -f1)
            
            if [ -n "$COVERAGE_PERCENT" ]; then
                log_info "Current coverage: ${COVERAGE_PERCENT}%"
                
                if [ "$COVERAGE_PERCENT" -lt "$COVERAGE_THRESHOLD" ]; then
                    log_warning "Coverage is below ${COVERAGE_THRESHOLD}% threshold"
                else
                    log_success "Coverage meets threshold"
                fi
            fi
        else
            log_warning "lcov not installed - skipping coverage analysis"
        fi
        
        # Generate HTML report
        if [ -d "coverage/html" ]; then
            rm -rf coverage/html
        fi
        
        if command -v genhtml &> /dev/null; then
            genhtml coverage/lcov.info -o coverage/html
            log_info "Coverage report generated at: pod_app/coverage/html/index.html"
        fi
    else
        log_warning "No coverage data found"
    fi
    
    cd "$PROJECT_ROOT"
}

# Run security checks
run_security_checks() {
    log_info "Running security checks..."
    
    # Check for secrets in code
    if git grep -E "(api_key|API_KEY|secret|SECRET|password|PASSWORD|token|TOKEN)" --cached | grep -v ".example" | grep -v "SKILL.md"; then
        log_error "Possible secrets detected in code"
        ((FAILED_TESTS++))
        return 1
    else
        log_success "No secrets detected"
        ((PASSED_TESTS++))
    fi
    
    # Check dependencies for vulnerabilities
    cd "$POD_APP_DIR"
    
    log_info "Checking for outdated packages..."
    flutter pub outdated
    
    cd "$PROJECT_ROOT"
}

# Generate test report
generate_report() {
    echo
    echo "========================================="
    echo "Test Results Summary"
    echo "========================================="
    echo
    echo "Total test suites run: $TOTAL_TESTS"
    echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
    echo
    
    if [ "$FAILED_TESTS" -eq 0 ]; then
        log_success "All tests passed! ✨"
        exit 0
    else
        log_error "Some tests failed"
        exit 1
    fi
}

# Main test execution
main() {
    echo "========================================="
    echo "PrintCraft AI Test Runner"
    echo "========================================="
    echo
    
    # Setup
    check_flutter
    
    # Always run analysis
    ((TOTAL_TESTS++))
    run_analysis || true
    
    # Always run security checks
    ((TOTAL_TESTS++))
    run_security_checks || true
    
    # Run specific test types
    case $TEST_TYPE in
        unit)
            ((TOTAL_TESTS++))
            run_unit_tests || true
            ;;
        integration)
            ((TOTAL_TESTS++))
            run_integration_tests || true
            ;;
        e2e)
            ((TOTAL_TESTS++))
            run_e2e_tests || true
            ;;
        all)
            ((TOTAL_TESTS++))
            run_unit_tests || true
            ((TOTAL_TESTS++))
            run_integration_tests || true
            ((TOTAL_TESTS++))
            run_e2e_tests || true
            ;;
    esac
    
    # Check coverage if enabled
    if [ "$COVERAGE" = true ] && [ "$WATCH_MODE" = false ]; then
        check_coverage
    fi
    
    # Generate report
    if [ "$WATCH_MODE" = false ]; then
        generate_report
    fi
}

# Run main function
main