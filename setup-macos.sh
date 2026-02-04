#!/bin/bash
# Rocky Linux Documentation - macOS Setup Script
# This script sets up a complete documentation validation environment on macOS.
# Supports both Apple Silicon (M1/M2/M3/M4) and Intel Macs.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "\n${BLUE}==>${NC} ${1}"
}

print_success() {
    echo -e "${GREEN}✓${NC} ${1}"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} ${1}"
}

print_error() {
    echo -e "${RED}✗${NC} ${1}"
}

# Detect architecture
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    HOMEBREW_PREFIX="/opt/homebrew"
    print_step "Detected Apple Silicon Mac (M1/M2/M3/M4)"
else
    HOMEBREW_PREFIX="/usr/local"
    print_step "Detected Intel Mac"
fi

echo "=============================================="
echo "Rocky Linux Documentation - macOS Setup"
echo "=============================================="
echo ""

# Step 1: Xcode Command Line Tools
print_step "Step 1/8: Checking Xcode Command Line Tools..."
if xcode-select -p &>/dev/null; then
    print_success "Xcode Command Line Tools already installed"
else
    print_warning "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Please complete the installation dialog, then press Enter to continue..."
    read -r
fi

# Step 2: Homebrew
print_step "Step 2/8: Checking Homebrew..."
if command -v brew &>/dev/null; then
    print_success "Homebrew already installed"
else
    print_warning "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Configure Homebrew PATH
if [[ "$ARCH" == "arm64" ]]; then
    if ! grep -q 'brew shellenv' ~/.zprofile 2>/dev/null; then
        print_warning "Configuring Homebrew PATH for Apple Silicon..."
        echo '' >> ~/.zprofile
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Verify Homebrew
if brew doctor &>/dev/null; then
    print_success "Homebrew is working correctly"
else
    print_warning "Homebrew has some warnings (usually safe to ignore)"
fi

# Step 3: System Dependencies
print_step "Step 3/8: Installing system dependencies..."
brew install git python node aspell lychee 2>/dev/null || true
print_success "System dependencies installed (git, python, node, aspell, lychee)"

# Step 4: Python Packages
print_step "Step 4/8: Installing Python packages..."

# Create and use a virtual environment for cleaner setup
VENV_DIR="$HOME/.rocky-docs-venv"
if [[ -d "$VENV_DIR" ]]; then
    print_warning "Virtual environment already exists at $VENV_DIR"
else
    python3 -m venv "$VENV_DIR"
    print_success "Created virtual environment at $VENV_DIR"
fi

# Activate and install packages
source "$VENV_DIR/bin/activate"
pip install --upgrade pip >/dev/null 2>&1
pip install pre-commit pyspelling >/dev/null 2>&1
print_success "Python packages installed (pre-commit, pyspelling)"

# Add activation to shell config if not already present
SHELL_RC="$HOME/.zshrc"
if [[ -f "$HOME/.bashrc" ]] && [[ ! -f "$HOME/.zshrc" ]]; then
    SHELL_RC="$HOME/.bashrc"
fi

ACTIVATION_LINE="# Rocky Linux Documentation virtual environment"
if ! grep -q "$ACTIVATION_LINE" "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo "$ACTIVATION_LINE" >> "$SHELL_RC"
    echo "alias rocky-docs-env='source $VENV_DIR/bin/activate'" >> "$SHELL_RC"
    print_success "Added 'rocky-docs-env' alias to $SHELL_RC"
fi

# Step 5: Node.js Packages
print_step "Step 5/8: Installing Node.js packages..."

# Configure npm to avoid permission issues
NPM_GLOBAL_DIR="$HOME/.npm-global"
if [[ ! -d "$NPM_GLOBAL_DIR" ]]; then
    mkdir -p "$NPM_GLOBAL_DIR"
    npm config set prefix "$NPM_GLOBAL_DIR"
fi

# Add npm global to PATH if not present
if ! grep -q '.npm-global/bin' "$SHELL_RC" 2>/dev/null; then
    echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$SHELL_RC"
fi
export PATH="$HOME/.npm-global/bin:$PATH"

npm install -g markdownlint-cli >/dev/null 2>&1
print_success "Node.js packages installed (markdownlint-cli)"

# Step 6: Clone Repository
print_step "Step 6/8: Setting up documentation repository..."

DOCS_DIR="$HOME/rocky-documentation"
echo ""
echo "Where would you like to clone the repository?"
echo "  1) $DOCS_DIR (default)"
echo "  2) Current directory ($(pwd))"
echo "  3) Custom path"
echo ""
read -r -p "Enter choice [1-3, default=1]: " CLONE_CHOICE

case "$CLONE_CHOICE" in
    2)
        DOCS_DIR="$(pwd)/documentation"
        ;;
    3)
        read -r -p "Enter custom path: " CUSTOM_PATH
        DOCS_DIR="${CUSTOM_PATH/#\~/$HOME}"
        ;;
    *)
        DOCS_DIR="$HOME/rocky-documentation"
        ;;
esac

if [[ -d "$DOCS_DIR" ]]; then
    print_warning "Directory $DOCS_DIR already exists"
    read -r -p "Use existing directory? [Y/n]: " USE_EXISTING
    if [[ "$USE_EXISTING" =~ ^[Nn] ]]; then
        print_error "Please remove the existing directory and run this script again"
        exit 1
    fi
else
    echo ""
    read -r -p "Enter your GitHub username (for forking): " GITHUB_USER

    if [[ -z "$GITHUB_USER" ]]; then
        print_warning "No username provided, cloning upstream repository (read-only)..."
        git clone https://github.com/rocky-linux/documentation.git "$DOCS_DIR"
    else
        echo ""
        echo "Cloning your fork: https://github.com/$GITHUB_USER/documentation.git"
        echo "(Make sure you've forked the repository first!)"
        echo ""

        if git clone "https://github.com/$GITHUB_USER/documentation.git" "$DOCS_DIR" 2>/dev/null; then
            print_success "Repository cloned successfully"
            # Add upstream remote
            cd "$DOCS_DIR"
            git remote add upstream https://github.com/rocky-linux/documentation.git 2>/dev/null || true
            print_success "Added upstream remote"
        else
            print_error "Failed to clone. Make sure you've forked the repository."
            print_warning "Cloning upstream repository instead (read-only)..."
            git clone https://github.com/rocky-linux/documentation.git "$DOCS_DIR"
        fi
    fi
fi

cd "$DOCS_DIR"
print_success "Repository ready at $DOCS_DIR"

# Step 7: Install Pre-commit Hooks
print_step "Step 7/8: Installing pre-commit hooks..."
pre-commit install
print_success "Pre-commit hooks installed"

# Step 8: Verify Setup
print_step "Step 8/8: Verifying setup..."
echo ""

VERIFY_PASSED=true

# Check each tool
echo "Checking installed tools:"

if command -v git &>/dev/null; then
    print_success "git $(git --version | cut -d' ' -f3)"
else
    print_error "git not found"
    VERIFY_PASSED=false
fi

if command -v python3 &>/dev/null; then
    print_success "python3 $(python3 --version | cut -d' ' -f2)"
else
    print_error "python3 not found"
    VERIFY_PASSED=false
fi

if command -v pre-commit &>/dev/null; then
    print_success "pre-commit $(pre-commit --version | cut -d' ' -f2)"
else
    print_error "pre-commit not found"
    VERIFY_PASSED=false
fi

if command -v pyspelling &>/dev/null; then
    print_success "pyspelling installed"
else
    print_error "pyspelling not found"
    VERIFY_PASSED=false
fi

if command -v markdownlint &>/dev/null; then
    print_success "markdownlint $(markdownlint --version)"
else
    print_error "markdownlint not found"
    VERIFY_PASSED=false
fi

if command -v lychee &>/dev/null; then
    print_success "lychee $(lychee --version | head -1 | cut -d' ' -f2)"
else
    print_error "lychee not found"
    VERIFY_PASSED=false
fi

if command -v aspell &>/dev/null; then
    print_success "aspell $(aspell --version | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?')"
else
    print_error "aspell not found"
    VERIFY_PASSED=false
fi

echo ""
echo "=============================================="

if [[ "$VERIFY_PASSED" == true ]]; then
    print_success "Setup complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Open a new terminal (or run: source ~/.zshrc)"
    echo "  2. Navigate to: cd $DOCS_DIR"
    echo "  3. Activate the environment: rocky-docs-env"
    echo "  4. Run validation: pre-commit run --all-files"
    echo ""
    echo "To validate a single document:"
    echo "  markdownlint docs/guides/your-document.md"
    echo "  pyspelling -S docs/guides/your-document.md"
    echo "  lychee docs/guides/your-document.md"
    echo ""
else
    print_error "Some tools failed to install. Please check the errors above."
fi

echo "=============================================="
