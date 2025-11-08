#!/bin/bash

# PrintCraft AI Development Environment Setup Script
# This script sets up a complete development environment for PrintCraft AI

set -e  # Exit on error
set -o pipefail  # Exit on pipe failure

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    else
        log_error "Unsupported OS: $OSTYPE"
    fi
    log_info "Detected OS: $OS"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Homebrew (macOS)
install_homebrew() {
    if [[ "$OS" == "macos" ]] && ! command_exists brew; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        log_success "Homebrew installed"
    fi
}

# Install Flutter
install_flutter() {
    if command_exists flutter; then
        log_info "Flutter already installed"
        flutter --version
    else
        log_info "Installing Flutter..."
        if [[ "$OS" == "macos" ]]; then
            brew install --cask flutter
        else
            # Linux installation
            git clone https://github.com/flutter/flutter.git -b stable ~/flutter
            echo 'export PATH="$PATH:~/flutter/bin"' >> ~/.bashrc
            source ~/.bashrc
        fi
        log_success "Flutter installed"
    fi
    
    # Run Flutter doctor
    log_info "Running Flutter doctor..."
    flutter doctor
}

# Install Firebase CLI
install_firebase_cli() {
    if command_exists firebase; then
        log_info "Firebase CLI already installed"
    else
        log_info "Installing Firebase CLI..."
        npm install -g firebase-tools
        log_success "Firebase CLI installed"
    fi
}

# Install Google Cloud SDK
install_gcloud() {
    if command_exists gcloud; then
        log_info "Google Cloud SDK already installed"
    else
        log_info "Installing Google Cloud SDK..."
        if [[ "$OS" == "macos" ]]; then
            brew install --cask google-cloud-sdk
        else
            # Linux installation
            curl https://sdk.cloud.google.com | bash
            exec -l $SHELL
        fi
        log_success "Google Cloud SDK installed"
    fi
}

# Setup project
setup_project() {
    log_info "Setting up PrintCraft AI project..."
    
    # Create .env file from example
    if [ ! -f .env ]; then
        if [ -f .env.example ]; then
            cp .env.example .env
            log_warning ".env file created from .env.example - Please update with your actual values"
        else
            log_warning ".env.example not found"
        fi
    else
        log_info ".env file already exists"
    fi
    
    # Flutter setup
    cd pod_app
    log_info "Getting Flutter dependencies..."
    flutter pub get
    
    # Generate code if needed
    if [ -f "pubspec.yaml" ] && grep -q "build_runner" pubspec.yaml; then
        log_info "Running code generation..."
        flutter pub run build_runner build --delete-conflicting-outputs
    fi
    
    cd ..
    
    # Setup git hooks
    setup_git_hooks
    
    log_success "Project setup complete"
}

# Setup git hooks
setup_git_hooks() {
    log_info "Setting up git hooks..."
    
    # Create hooks directory if it doesn't exist
    mkdir -p .git/hooks
    
    # Pre-commit hook
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# Pre-commit hook for PrintCraft AI

echo "Running pre-commit checks..."

# Check for secrets
if git diff --cached --name-only | xargs grep -E "(api_key|API_KEY|secret|SECRET|password|PASSWORD|token|TOKEN)" | grep -v ".example" | grep -v "SKILL.md"; then
    echo "ERROR: Possible secrets detected in staged files"
    echo "Please remove sensitive information before committing"
    exit 1
fi

# Run Flutter analyze
cd pod_app
if ! flutter analyze; then
    echo "ERROR: Flutter analyze failed"
    exit 1
fi

# Check formatting
if ! dart format --set-exit-if-changed .; then
    echo "ERROR: Dart formatting issues found"
    echo "Run 'dart format .' to fix"
    exit 1
fi

cd ..

echo "Pre-commit checks passed"
EOF
    
    chmod +x .git/hooks/pre-commit
    log_success "Git hooks installed"
}

# Install VS Code extensions
install_vscode_extensions() {
    if command_exists code; then
        log_info "Installing VS Code extensions..."
        
        extensions=(
            "Dart-Code.dart-code"
            "Dart-Code.flutter"
            "toba.vsfire"
            "eamodio.gitlens"
            "usernamehw.errorlens"
            "Gruntfuggly.todo-tree"
            "esbenp.prettier-vscode"
            "dbaeumer.vscode-eslint"
        )
        
        for ext in "${extensions[@]}"; do
            code --install-extension "$ext" || true
        done
        
        log_success "VS Code extensions installed"
    else
        log_warning "VS Code CLI not found - skipping extension installation"
    fi
}

# Check all requirements
check_requirements() {
    log_info "Checking requirements..."
    
    required_commands=("git" "node" "npm")
    missing_commands=()
    
    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd"; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [ ${#missing_commands[@]} -ne 0 ]; then
        log_error "Missing required commands: ${missing_commands[*]}"
    fi
    
    # Check Node version
    node_version=$(node -v | cut -d'v' -f2)
    required_version="18.0.0"
    if ! [ "$(printf '%s\n' "$required_version" "$node_version" | sort -V | head -n1)" = "$required_version" ]; then
        log_error "Node.js version must be 18.0.0 or higher. Current: $node_version"
    fi
    
    log_success "All requirements met"
}

# Main setup flow
main() {
    echo "========================================="
    echo "PrintCraft AI Development Setup"
    echo "========================================="
    echo
    
    detect_os
    check_requirements
    
    # Install dependencies
    install_homebrew
    install_flutter
    install_firebase_cli
    install_gcloud
    
    # Setup project
    setup_project
    
    # Optional: Install VS Code extensions
    read -p "Install VS Code extensions? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_vscode_extensions
    fi
    
    echo
    echo "========================================="
    log_success "Setup complete!"
    echo "========================================="
    echo
    echo "Next steps:"
    echo "1. Update .env file with your API keys and configuration"
    echo "2. Run 'gcloud auth login' to authenticate with Google Cloud"
    echo "3. Run './scripts/run-tests.sh' to verify everything is working"
    echo "4. Start developing with 'cd pod_app && flutter run'"
    echo
}

# Run main function
main "$@"