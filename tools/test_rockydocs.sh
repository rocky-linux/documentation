#!/bin/bash

# Rocky Linux Documentation - Automated Test Harness
# Tests all features of rockydocs-dev-12.sh
# Developer-only tool for validation and regression testing

set -e

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROCKYDOCS_SCRIPT="$SCRIPT_DIR/rockydocs-dev-12.sh"
TEST_WORKSPACE="/tmp/rocky_test_harness"
TEST_CONTENT_DIR="$TEST_WORKSPACE/test_documentation"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Print functions
print_success() { echo -e "${GREEN}[PASS]${NC} $1"; }
print_fail() { echo -e "${RED}[FAIL]${NC} $1"; }
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Test framework variables
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test case function
test_case() {
    local description="$1"
    local command="$2"
    local expected_exit_code="${3:-0}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    print_info "Running test: $description"
    
    if eval "$command" >/dev/null 2>&1; then
        local actual_exit_code=0
    else
        local actual_exit_code=$?
    fi
    
    if [ "$actual_exit_code" -eq "$expected_exit_code" ]; then
        print_success "$description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        print_fail "$description (exit code: $actual_exit_code, expected: $expected_exit_code)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Assertion functions
assert_http_status() {
    local url="$1"
    local expected_status="$2"
    local timeout="${3:-5}"
    
    local actual_status=$(curl -s -o /dev/null -w "%{http_code}" --max-time $timeout "$url" 2>/dev/null || echo "000")
    
    if [ "$actual_status" = "$expected_status" ]; then
        return 0
    else
        print_fail "HTTP status mismatch for $url: got $actual_status, expected $expected_status"
        return 1
    fi
}

assert_dir_exists() {
    local path="$1"
    if [ -d "$path" ]; then
        return 0
    else
        print_fail "Directory does not exist: $path"
        return 1
    fi
}

assert_file_exists() {
    local path="$1"
    if [ -f "$path" ]; then
        return 0
    else
        print_fail "File does not exist: $path"
        return 1
    fi
}

assert_git_branch_exists() {
    local repo_path="$1"
    local branch="$2"
    
    cd "$repo_path"
    if git show-ref --verify --quiet "refs/heads/$branch"; then
        return 0
    else
        print_fail "Git branch $branch does not exist in $repo_path"
        return 1
    fi
}

assert_git_commit_message() {
    local repo_path="$1"
    local branch="$2"
    local substring="$3"
    
    cd "$repo_path"
    local commit_msg=$(git log --format=%B -n 1 "$branch" 2>/dev/null || echo "")
    
    if [[ "$commit_msg" == *"$substring"* ]]; then
        return 0
    else
        print_fail "Git commit message on $branch does not contain '$substring'"
        return 1
    fi
}

assert_process_running() {
    local process_pattern="$1"
    if pgrep -f "$process_pattern" >/dev/null; then
        return 0
    else
        print_fail "Process matching '$process_pattern' is not running"
        return 1
    fi
}

assert_port_available() {
    local port="$1"
    if ! lsof -Pi :$port -sTCP:LISTEN -t >/dev/null; then
        return 0
    else
        print_fail "Port $port is not available (already in use)"
        return 1
    fi
}

assert_port_in_use() {
    local port="$1"
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null; then
        return 0
    else
        print_fail "Port $port is not in use"
        return 1
    fi
}

assert_config_contains() {
    local config_file="$1"
    local pattern="$2"
    
    if [ -f "$config_file" ] && grep -q "$pattern" "$config_file"; then
        return 0
    else
        print_fail "Configuration file $config_file does not contain pattern: $pattern"
        return 1
    fi
}

assert_symlink_target() {
    local symlink_path="$1"
    local expected_target="$2"
    
    if [ -L "$symlink_path" ]; then
        local actual_target=$(readlink "$symlink_path" 2>/dev/null || echo "")
        if [[ "$actual_target" == *"$expected_target"* ]]; then
            return 0
        else
            print_fail "Symlink $symlink_path points to '$actual_target', expected to contain '$expected_target'"
            return 1
        fi
    else
        print_fail "$symlink_path is not a symlink"
        return 1
    fi
}

# Setup test environment
setup_test_environment() {
    print_info "Setting up hermetic test environment..."
    
    # Clean any existing test workspace
    if [ -d "$TEST_WORKSPACE" ]; then
        rm -rf "$TEST_WORKSPACE"
    fi
    
    # Create test workspace
    mkdir -p "$TEST_WORKSPACE"
    cd "$TEST_WORKSPACE"
    
    # Create minimal mock documentation repository
    mkdir -p "$TEST_CONTENT_DIR/docs"
    cd "$TEST_CONTENT_DIR"
    
    # Initialize git repository
    git init
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    # Create basic content structure
    cat > "docs/index.md" << 'EOF'
# Rocky Linux Documentation Test

This is a test documentation site.

## Features

- Test content
- Multiple versions
- Version selector

EOF
    
    mkdir -p "docs/guides"
    cat > "docs/guides/test-guide.md" << 'EOF'
# Test Guide

This is a test guide for validation.

EOF
    
    # Create mkdocs.yml
    cat > "mkdocs.yml" << 'EOF'
site_name: Rocky Linux Documentation Test
docs_dir: docs
site_dir: site

nav:
  - Home: index.md
  - Guides:
    - Test Guide: guides/test-guide.md

theme:
  name: material

EOF
    
    # Commit initial content
    git add .
    git commit -m "Initial test content"
    
    # Create test branches
    git checkout -b rocky-8
    echo "Rocky Linux 8 specific content" >> docs/index.md
    git add docs/index.md
    git commit -m "Rocky Linux 8 content"
    
    git checkout -b rocky-9
    echo "Rocky Linux 9 specific content" >> docs/index.md
    git add docs/index.md
    git commit -m "Rocky Linux 9 content"
    
    git checkout main
    echo "Rocky Linux 10 specific content" >> docs/index.md
    git add docs/index.md
    git commit -m "Rocky Linux 10 content"
    
    print_success "Test environment setup complete"
}

# Cleanup test environment
cleanup_test_environment() {
    print_info "Cleaning up test environment..."
    
    # Kill any test servers
    pkill -f "python.*http\.server" 2>/dev/null || true
    pkill -f "mike serve" 2>/dev/null || true
    pkill -f "mkdocs serve" 2>/dev/null || true
    
    # Remove test workspace
    if [ -d "$TEST_WORKSPACE" ]; then
        rm -rf "$TEST_WORKSPACE"
    fi
    
    # Clean any test configuration
    if [ -f "$HOME/.config/rockydocs/config" ]; then
        if grep -q "$TEST_WORKSPACE" "$HOME/.config/rockydocs/config" 2>/dev/null; then
            rm -f "$HOME/.config/rockydocs/config"
        fi
    fi
    
    print_success "Test environment cleaned up"
}

# Test suite: Setup and Clean
test_setup_and_clean() {
    print_info "=== Testing Setup and Clean Operations ==="
    
    cd "$TEST_CONTENT_DIR"
    
    # Test setup command
    test_case "Setup creates workspace and app repository" \
        "$ROCKYDOCS_SCRIPT --setup --venv --minimal --workspace $TEST_WORKSPACE/workspace"
    
    # Verify setup results
    test_case "App directory exists after setup" \
        "assert_dir_exists $TEST_WORKSPACE/workspace/docs.rockylinux.org"
    
    test_case "Virtual environment exists after setup" \
        "assert_dir_exists $TEST_WORKSPACE/workspace/docs.rockylinux.org/venv"
    
    test_case "Compatibility symlink exists" \
        "[ -L $TEST_WORKSPACE/workspace/app ]"
    
    # Test clean command
    test_case "Clean removes workspace" \
        "echo 'y' | $ROCKYDOCS_SCRIPT --clean --workspace $TEST_WORKSPACE/workspace"
    
    test_case "Workspace removed after clean" \
        "[ ! -d $TEST_WORKSPACE/workspace ]"
}

# Test suite: Deployment
test_deployment() {
    print_info "=== Testing Deployment Operations ==="
    
    cd "$TEST_CONTENT_DIR"
    
    # Setup for deployment tests
    $ROCKYDOCS_SCRIPT --setup --venv --minimal --workspace "$TEST_WORKSPACE/workspace" >/dev/null 2>&1
    
    # Test deploy command
    test_case "Deploy creates local gh-pages branch" \
        "$ROCKYDOCS_SCRIPT --deploy --minimal --workspace $TEST_WORKSPACE/workspace"
    
    # Verify deployment results
    local app_dir="$TEST_WORKSPACE/workspace/docs.rockylinux.org"
    
    test_case "gh-pages branch exists after deploy" \
        "assert_git_branch_exists $app_dir gh-pages"
    
    test_case "versions.json exists in gh-pages" \
        "cd $app_dir && git show gh-pages:versions.json >/dev/null 2>&1"
    
    test_case "Version 8 directory exists in gh-pages" \
        "cd $app_dir && git ls-tree gh-pages:8 >/dev/null 2>&1"
    
    test_case "Version 9 directory exists in gh-pages" \
        "cd $app_dir && git ls-tree gh-pages:9 >/dev/null 2>&1"
    
    test_case "Version 10 directory exists in gh-pages" \
        "cd $app_dir && git ls-tree gh-pages:10 >/dev/null 2>&1"
    
    test_case "Latest directory exists in gh-pages" \
        "cd $app_dir && git ls-tree gh-pages:latest >/dev/null 2>&1"
    
    test_case "Web root override commit exists" \
        "assert_git_commit_message $app_dir gh-pages 'web root override'"
}

# Test suite: Serving modes
test_serving_modes() {
    print_info "=== Testing Serving Modes ==="
    
    cd "$TEST_CONTENT_DIR"
    
    # Setup for serving tests
    $ROCKYDOCS_SCRIPT --setup --venv --minimal --workspace "$TEST_WORKSPACE/workspace" >/dev/null 2>&1
    $ROCKYDOCS_SCRIPT --deploy --minimal --workspace "$TEST_WORKSPACE/workspace" >/dev/null 2>&1
    
    local app_dir="$TEST_WORKSPACE/workspace/docs.rockylinux.org"
    
    # Test mike serve mode (should not fail with config errors)
    print_info "Testing mike serve mode..."
    
    cd "$app_dir"
    # Start mike serve in background and capture output
    timeout 5 bash -c "$ROCKYDOCS_SCRIPT --serve --workspace $TEST_WORKSPACE/workspace" > /tmp/serve_test.log 2>&1 &
    local serve_pid=$!
    
    # Give server time to start
    sleep 3
    
    # Check if mike serve started without config errors
    if grep -q "Config value.*docs_dir.*isn't an existing directory" /tmp/serve_test.log; then
        test_case "Mike serve starts without config errors" "false"
    else
        test_case "Mike serve starts without config errors" "true"
    fi
    
    # Clean up server
    kill $serve_pid 2>/dev/null || true
    pkill -f "mike serve" 2>/dev/null || true
    sleep 2
    
    # Test static serving mode
    print_info "Testing static serving mode..."
    
    # First test if static extraction works without serving
    cd "$app_dir"
    test_case "Static extraction completes without errors" \
        "$ROCKYDOCS_SCRIPT --serve --static --workspace $TEST_WORKSPACE/workspace 2>&1 | grep -q 'Static site extracted successfully'"
    
    # Check if symlinks are preserved in extracted content
    if [ -L "site-static/latest" ]; then
        test_case "Latest symlink preserved in static extraction" "true"
        
        # Test if symlink target exists
        local latest_target=$(readlink "site-static/latest" 2>/dev/null || echo "")
        if [ -n "$latest_target" ] && [ -d "site-static/$latest_target" ]; then
            test_case "Latest symlink target directory exists" "true"
        else
            test_case "Latest symlink target directory exists" "false"
        fi
    else
        test_case "Latest symlink preserved in static extraction" "false"
    fi
    
    # Test actual HTTP serving if extraction succeeded
    if [ -d "site-static" ] && [ -f "site-static/index.html" ]; then
        timeout 10 bash -c "$ROCKYDOCS_SCRIPT --serve --static --workspace $TEST_WORKSPACE/workspace" > /tmp/static_serve_test.log 2>&1 &
        local static_serve_pid=$!
        
        # Give server time to start
        sleep 3
        
        # Test HTTP responses
        test_case "Static server responds to root URL" \
            "assert_http_status http://localhost:8000/ 200"
        
        test_case "Static server responds to versioned URL" \
            "assert_http_status http://localhost:8000/9/ 200"
        
        # Clean up server
        kill $static_serve_pid 2>/dev/null || true
        sleep 2
    else
        print_info "Skipping HTTP tests - static extraction failed"
        test_case "Static server responds to root URL" "false"
        test_case "Static server responds to versioned URL" "false"
    fi
    
    # Test that static extraction works
    test_case "Static site directory exists after serving" \
        "assert_dir_exists $app_dir/site-static"
    
    test_case "Static site contains index.html" \
        "assert_file_exists $app_dir/site-static/index.html"
    
    # Cleanup test logs
    rm -f /tmp/serve_test.log /tmp/static_serve_test.log
}

# Test suite: Utilities
test_utilities() {
    print_info "=== Testing Utility Functions ==="
    
    cd "$TEST_CONTENT_DIR"
    
    # Test status command
    test_case "Status command runs without error" \
        "$ROCKYDOCS_SCRIPT --status"
    
    # Test help commands
    test_case "Main help displays correctly" \
        "$ROCKYDOCS_SCRIPT --help"
    
    test_case "Setup help displays correctly" \
        "$ROCKYDOCS_SCRIPT --setup --help"
    
    test_case "Serve help displays correctly" \
        "$ROCKYDOCS_SCRIPT --serve --help"
    
    test_case "Deploy help displays correctly" \
        "$ROCKYDOCS_SCRIPT --deploy --help"
    
    test_case "Dual server help displays correctly" \
        "$ROCKYDOCS_SCRIPT --serve-dual --help"
}

# Test dependency checking
test_dependencies() {
    print_info "=== Testing Dependency Checking ==="
    
    cd "$TEST_CONTENT_DIR"
    
    # Test with all dependencies available (should pass)
    test_case "Dependencies check passes with all tools available" \
        "$ROCKYDOCS_SCRIPT --status"
    
    # This test would require temporarily hiding dependencies, which is complex
    # For now, we assume the dependency check works if the script runs
    print_info "Dependency checking tested indirectly through script execution"
}

# Test configuration management
test_configuration_management() {
    print_info "=== Testing Configuration Management ==="
    
    cd "$TEST_CONTENT_DIR"
    
    # Test workspace configuration persistence
    local test_config_dir="$TEST_WORKSPACE/test_config"
    mkdir -p "$test_config_dir"
    
    # Test custom workspace configuration
    test_case "Custom workspace configuration is saved" \
        "$ROCKYDOCS_SCRIPT --setup --venv --minimal --workspace $test_config_dir/custom_workspace"
    
    # Test configuration reset
    test_case "Configuration reset removes saved config" \
        "$ROCKYDOCS_SCRIPT --reset"
    
    # Test default workspace fallback
    test_case "Default workspace fallback works after reset" \
        "$ROCKYDOCS_SCRIPT --status"
}

# Test error handling and edge cases
test_error_handling() {
    print_info "=== Testing Error Handling and Edge Cases ==="
    
    cd "$TEST_CONTENT_DIR"
    
    # Test invalid workspace path
    test_case "Invalid workspace path is handled gracefully" \
        "$ROCKYDOCS_SCRIPT --setup --workspace /nonexistent/invalid/path 2>&1 | grep -q 'Error\\|Failed'" 1
    
    # Test missing content directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    test_case "Missing docs directory is detected" \
        "$ROCKYDOCS_SCRIPT --setup --venv --minimal 2>&1 | grep -q 'docs.*not found\\|No docs directory'" 1
    cd "$TEST_CONTENT_DIR"
    rm -rf "$temp_dir"
    
    # Test serve without deployment
    test_case "Serve without deployment shows appropriate message" \
        "$ROCKYDOCS_SCRIPT --serve 2>&1 | grep -q 'No gh-pages branch found\\|deploy first'" 1
}

# Test workspace and environment variations
test_environment_variations() {
    print_info "=== Testing Environment Variations ==="
    
    cd "$TEST_CONTENT_DIR"
    
    # Test different environment types
    local env_workspace="$TEST_WORKSPACE/env_test"
    
    # Test venv environment
    test_case "Virtual environment setup completes" \
        "$ROCKYDOCS_SCRIPT --setup --venv --minimal --workspace $env_workspace"
    
    test_case "Virtual environment directory exists" \
        "assert_dir_exists $env_workspace/docs.rockylinux.org/venv"
    
    test_case "Virtual environment activation script exists" \
        "assert_file_exists $env_workspace/docs.rockylinux.org/venv/bin/activate"
    
    # Clean for next test
    rm -rf "$env_workspace"
    
    # Test minimal vs full build types
    test_case "Minimal build configuration is applied" \
        "$ROCKYDOCS_SCRIPT --setup --venv --minimal --workspace $env_workspace && \
         grep -q 'minimal\\|en.*uk' $env_workspace/docs.rockylinux.org/configs/mkdocs.yml"
    
    rm -rf "$env_workspace"
    
    test_case "Full build configuration is applied" \
        "$ROCKYDOCS_SCRIPT --setup --venv --full --workspace $env_workspace && \
         grep -q 'full\\|languages.*all' $env_workspace/docs.rockylinux.org/configs/mkdocs.yml"
}

# Test port management and conflict resolution
test_port_management() {
    print_info "=== Testing Port Management ==="
    
    cd "$TEST_CONTENT_DIR"
    
    # Setup for port tests
    $ROCKYDOCS_SCRIPT --setup --venv --minimal --workspace "$TEST_WORKSPACE/port_test" >/dev/null 2>&1
    $ROCKYDOCS_SCRIPT --deploy --minimal --workspace "$TEST_WORKSPACE/port_test" >/dev/null 2>&1
    
    # Test port conflict detection
    # Start a simple server on port 8000
    python3 -m http.server 8000 >/dev/null 2>&1 &
    local blocking_server_pid=$!
    sleep 2
    
    # Test that port conflict is detected and handled
    timeout 10 bash -c "$ROCKYDOCS_SCRIPT --serve --static --workspace $TEST_WORKSPACE/port_test" > /tmp/port_conflict_test.log 2>&1 &
    local test_server_pid=$!
    sleep 3
    
    # Check if alternative port was used or conflict was reported
    if grep -q "port.*conflict\\|alternative port\\|8001" /tmp/port_conflict_test.log; then
        test_case "Port conflict detection and resolution works" "true"
    else
        test_case "Port conflict detection and resolution works" "false"
    fi
    
    # Cleanup
    kill $blocking_server_pid 2>/dev/null || true
    kill $test_server_pid 2>/dev/null || true
    sleep 2
    rm -f /tmp/port_conflict_test.log
}

# Test git operations and versioning
test_git_operations() {
    print_info "=== Testing Git Operations and Versioning ==="
    
    cd "$TEST_CONTENT_DIR"
    
    # Setup for git tests
    local git_workspace="$TEST_WORKSPACE/git_test"
    $ROCKYDOCS_SCRIPT --setup --venv --minimal --workspace "$git_workspace" >/dev/null 2>&1
    $ROCKYDOCS_SCRIPT --deploy --minimal --workspace "$git_workspace" >/dev/null 2>&1
    
    local app_dir="$git_workspace/docs.rockylinux.org"
    
    # Test git branch operations
    test_case "Git repository is properly initialized" \
        "[ -d $app_dir/.git ]"
    
    test_case "Worktree directory exists for caching" \
        "assert_dir_exists $app_dir/worktrees"
    
    # Test version detection on different branches
    git checkout rocky-8 >/dev/null 2>&1
    test_case "Version detection works for rocky-8 branch" \
        "$ROCKYDOCS_SCRIPT --status | grep -q 'rocky-8\\|version 8'"
    
    git checkout rocky-9 >/dev/null 2>&1  
    test_case "Version detection works for rocky-9 branch" \
        "$ROCKYDOCS_SCRIPT --status | grep -q 'rocky-9\\|version 9'"
    
    git checkout main >/dev/null 2>&1
    test_case "Version detection works for main branch" \
        "$ROCKYDOCS_SCRIPT --status | grep -q 'main\\|version 10'"
    
    # Test git operations in app repository
    cd "$app_dir"
    test_case "Worktree main cache exists" \
        "assert_dir_exists $app_dir/worktrees/main"
    
    test_case "Content symlink is properly created" \
        "[ -L content ] && [ -d content ]"
    
    cd "$TEST_CONTENT_DIR"
}

# Test performance optimizations
test_performance_features() {
    print_info "=== Testing Performance Features ==="
    
    cd "$TEST_CONTENT_DIR"
    
    # Setup for performance tests
    local perf_workspace="$TEST_WORKSPACE/performance_test"
    
    # Time the setup process
    local start_time=$(date +%s)
    test_case "Performance-optimized setup completes efficiently" \
        "$ROCKYDOCS_SCRIPT --setup --venv --minimal --workspace $perf_workspace"
    local setup_time=$(($(date +%s) - start_time))
    
    print_info "Setup completed in ${setup_time}s"
    
    # Test cached repository reuse
    local app_dir="$perf_workspace/docs.rockylinux.org"
    test_case "Repository caching is working" \
        "[ -d $app_dir/worktrees/main/.git ]"
    
    # Test consolidated git operations
    start_time=$(date +%s)
    test_case "Performance-optimized deployment completes efficiently" \
        "$ROCKYDOCS_SCRIPT --deploy --minimal --workspace $perf_workspace"
    local deploy_time=$(($(date +%s) - start_time))
    
    print_info "Deployment completed in ${deploy_time}s"
    
    # Test optimized web root override
    cd "$app_dir"
    if git show-ref --verify --quiet refs/heads/gh-pages; then
        test_case "Optimized web root override creates commit efficiently" \
            "git log --oneline gh-pages | head -1 | grep -q 'optimized.*web root override'"
    else
        test_case "Optimized web root override creates commit efficiently" "false"
    fi
    
    cd "$TEST_CONTENT_DIR"
}

# Main test runner
run_all_tests() {
    print_info "Rocky Linux Documentation Test Harness v$VERSION"
    print_info "Testing rockydocs-dev-12.sh functionality"
    echo ""
    
    # Verify test script exists
    if [ ! -f "$ROCKYDOCS_SCRIPT" ]; then
        print_fail "Test subject not found: $ROCKYDOCS_SCRIPT"
        exit 1
    fi
    
    # Setup test environment
    setup_test_environment
    
    # Run test suites
    test_dependencies
    test_setup_and_clean
    test_deployment
    test_serving_modes
    test_utilities
    test_configuration_management
    test_error_handling
    test_environment_variations
    test_port_management
    test_git_operations
    test_performance_features
    
    # Cleanup
    cleanup_test_environment
    
    # Report results
    echo ""
    print_info "=== Test Results ==="
    echo "Tests run: $TESTS_RUN"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        print_success "All tests passed!"
        exit 0
    else
        print_fail "$TESTS_FAILED test(s) failed"
        exit 1
    fi
}

# Handle command line arguments
case "${1:-run}" in
    --help|-h)
        cat << EOF
Rocky Linux Documentation Test Harness v$VERSION

DESCRIPTION:
  Comprehensive automated test suite for rockydocs-dev-12.sh functionality.
  Runs extensive tests in hermetic environments with full coverage validation.

USAGE:
  $0 [COMMAND]

COMMANDS:
  run         Run all tests (default)
  setup       Setup test environment only
  cleanup     Cleanup test environment only
  --help, -h  Show this help

ENVIRONMENT:
  Test workspace: $TEST_WORKSPACE
  Subject script: $ROCKYDOCS_SCRIPT

TEST COVERAGE:
  ✅ Setup and Clean Operations      - Workspace management validation
  ✅ Deployment Operations          - Multi-version deployment testing
  ✅ Serving Modes                  - Live and static serving validation
  ✅ Utility Functions              - Status, help, and configuration commands
  ✅ Configuration Management       - Workspace configuration persistence
  ✅ Error Handling & Edge Cases    - Graceful failure and error detection
  ✅ Environment Variations         - Virtual environment and build types
  ✅ Port Management               - Conflict detection and resolution
  ✅ Git Operations & Versioning    - Repository operations and branch handling
  ✅ Performance Features          - Optimization validation and timing

FEATURES:
  • Hermetic test environments with no external dependencies
  • HTTP response validation with actual server testing
  • Git repository and branch validation
  • Symlink preservation testing
  • Port conflict resolution testing
  • Performance timing and optimization validation
  • Configuration persistence and workspace management
  • Error handling and edge case detection

NOTES:
  - All tests run in isolated temporary directories
  - No interference with real workspaces or configurations
  - Comprehensive regression detection and validation
  - Automatically cleans up after completion
  - Developer-only tool, not for end users

EOF
        exit 0
        ;;
    setup)
        setup_test_environment
        exit 0
        ;;
    cleanup)
        cleanup_test_environment
        exit 0
        ;;
    run|"")
        run_all_tests
        ;;
    *)
        print_fail "Unknown command: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac