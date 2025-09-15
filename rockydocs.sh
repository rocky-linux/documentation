#!/bin/bash

set -e

# Rocky Linux Documentation - Master Contributor Script
# Production-ready script with NEVRA versioning and modular architecture
# 
# Author: Wale Soyinka
# Changelog: tools/CHANGELOG.md
#

VERSION="1.2.0"
RELEASE="1.el10"
AUTHOR="Wale Soyinka"
FULL_VERSION="rockydocs-${VERSION}-${RELEASE}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTENT_DIR="$SCRIPT_DIR"
REPO_NAME="$(basename "$CONTENT_DIR")"
INITIAL_PWD="$(pwd)"  # Preserve the directory where script was invoked

# Configuration management
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/rockydocs"
CONFIG_FILE="$CONFIG_DIR/config"

# Source function library
source "$(dirname "${BASH_SOURCE[0]}")/tools/rockydocs-functions.sh"

# Load saved workspace configuration
load_workspace_config

# Initialize workspace directories
WORKSPACE_BASE_DIR="${SAVED_WORKSPACE_BASE_DIR:-$(dirname "$CONTENT_DIR")/rockydocs-workspaces}"
APP_DIR="$WORKSPACE_BASE_DIR/docs.rockylinux.org"
APP_COMPAT_LINK="$WORKSPACE_BASE_DIR/app"

# Dependency check (NEW v12)
check_dependencies() {
    local missing_deps=()
    local required_commands=("git" "python3" "lsof" "pgrep" "jq" "curl")
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_info "Please install the missing dependencies and try again."
        exit 1
    fi
}

# Consolidated git operations (NEW v12)
update_repositories() {
    print_info "Updating all repositories with consolidated git operations..."
    
    # Update app repository if it exists
    if [ -d "$APP_DIR/.git" ]; then
        print_info "Updating app repository..."
        cd "$APP_DIR"
        run_cmd "git fetch origin main" || print_warning "Failed to fetch app repository updates"
        run_cmd "git pull origin main" || print_warning "Failed to pull app repository updates"
    fi
    
    # Update cached worktrees if they exist
    local worktree_base="$APP_DIR/worktrees"
    if [ -d "$worktree_base/main/.git" ]; then
        print_info "Updating cached content repositories..."
        cd "$worktree_base/main"
        
        # Fetch all branches safely without forcing updates to checked out branches
        run_cmd "git fetch origin" || print_warning "Failed to fetch from origin"
        
        # Update each worktree individually if they exist
        for worktree_dir in "$worktree_base/rocky-8" "$worktree_base/rocky-9" "$worktree_base/main"; do
            if [ -d "$worktree_dir/.git" ]; then
                local branch_name=$(basename "$worktree_dir")
                if [ "$branch_name" = "main" ]; then
                    cd "$worktree_dir" && run_cmd "git pull origin main" || print_warning "Failed to update main worktree"
                else
                    cd "$worktree_dir" && run_cmd "git pull origin $branch_name" || print_warning "Failed to update $branch_name worktree"
                fi
            fi
        done
    fi
    
    cd "$CONTENT_DIR"
    print_success "Repository updates completed"
}

# Optimized web root override (NEW v12)
apply_web_root_override_local() {
    print_info "Applying optimized local web root override..."
    
    local original_branch
    original_branch=$(git rev-parse --abbrev-ref HEAD)
    
    # Use low-level git commands to avoid expensive checkouts
    if ! git show-ref --verify --quiet refs/heads/gh-pages; then
        print_error "No gh-pages branch found for web root override"
        return 1
    fi
    
    # Find the source for web root content (latest symlink or version 10 directory)
    local content_source=""
    if git ls-tree gh-pages | grep -q "latest"; then
        # Check if latest is a symlink and resolve it
        local latest_target=$(git show gh-pages:latest 2>/dev/null || echo "")
        if [ -n "$latest_target" ] && git ls-tree "gh-pages:$latest_target" >/dev/null 2>&1; then
            content_source="$latest_target"
            print_info "Found latest symlink pointing to version $latest_target"
        elif git ls-tree gh-pages:latest >/dev/null 2>&1; then
            content_source="latest"
            print_info "Found latest directory"
        fi
    fi
    
    # Fallback to version 10 if latest not found
    if [ -z "$content_source" ] && git ls-tree gh-pages:10 >/dev/null 2>&1; then
        content_source="10"
        print_info "Using version 10 as content source"
    fi
    
    if [ -z "$content_source" ]; then
        print_error "No suitable content source found (latest or version 10) on gh-pages branch"
        return 1
    fi
    
    print_info "Creating optimized commit for web root override using content from: $content_source"
    
    # Create a merged tree that preserves versioned directories AND adds root content
    local parent_commit=$(git rev-parse gh-pages)
    local parent_tree=$(git rev-parse "gh-pages^{tree}")
    local source_tree=$(git rev-parse "gh-pages:$content_source")
    
    # Use a temporary worktree approach to create merged tree
    # This preserves existing versioned structure while adding root content
    local temp_worktree=".git/temp-merge-$(date +%s)"
    run_cmd "git worktree add $temp_worktree gh-pages"
    
    # In the temporary worktree, copy the latest content to root, preserving versioned dirs
    (
        cd "$temp_worktree"
        # Remove existing root content (but keep versioned directories and versions.json)
        for item in *; do
            if [[ "$item" != "8" && "$item" != "9" && "$item" != "10" && "$item" != "latest" && "$item" != "versions.json" && "$item" != ".nojekyll" ]]; then
                rm -rf "$item"
            fi
        done
        
        # Copy the latest version content to root
        if [ -L latest ]; then
            local target=$(readlink latest)
            cp -r "${target}"/* ./
        elif [ -d "10" ]; then
            cp -r 10/* ./
        fi
        
        # Stage all changes
        git add -A
        local merged_tree=$(git write-tree)
        echo "$merged_tree" > /tmp/merged_tree_sha
    )
    
    # Clean up the temporary worktree (force removal since it contains our changes)
    run_cmd "git worktree remove --force $temp_worktree"
    local merged_tree=$(cat /tmp/merged_tree_sha)
    rm -f /tmp/merged_tree_sha
    
    # Create new commit with the merged tree
    local new_commit=$(git commit-tree $merged_tree -p $parent_commit -m "feat: Apply optimized local-only web root override from $content_source")
    
    # Update gh-pages branch to point to new commit
    run_cmd "git update-ref refs/heads/gh-pages $new_commit"
    
    print_success "Optimized web root override applied successfully from $content_source"
}

# Streamlined static serving (NEW v12)
serve_static() {
    
    print_info "🔧 STREAMLINED STATIC MODE: Fast static file extraction and serving"
    
    # Basic validation
    if [ ! -d "$APP_DIR" ]; then
        print_error "App directory not found: $APP_DIR"
        return 1
    fi
    
    cd "$APP_DIR"
    
    # Only extract static site if not already done or if deployment is newer
    if ! extract_static_site; then
        print_error "Failed to extract static site"
        return 1
    fi
    
    # Start static server immediately
    print_success "🚀 Starting STREAMLINED static server"
    print_info "   • Instant startup - no rebuild needed"
    print_info "   • Production-identical behavior"
    print_info "   • Access: http://localhost:8000"
    
    # Check for port conflicts and resolve them
    local port=8000
    if ! check_and_resolve_port_conflict $port true; then
        print_error "Could not resolve port conflict on port $port"
        return 1
    fi
    
    # Start static server with PID tracking
    cd "$APP_DIR/site-static"
    python3 -m http.server 8000 &
    local server_pid=$!
    add_cleanup_resource "pid:$server_pid"
    cd - > /dev/null
    wait $server_pid
}

# Docker serving function
serve_docker() {
    local static_mode="$1"
    
    print_info "🐳 DOCKER SERVING MODE: Container-based documentation serving"
    
    # Validate Docker setup
    if [ ! -d "$APP_DIR" ]; then
        print_error "App directory not found: $APP_DIR"
        print_info "Run setup first: $0 --setup --docker"
        return 1
    fi
    
    # Check if Docker image exists
    if ! docker image inspect rockydocs-dev >/dev/null 2>&1; then
        print_error "Docker image 'rockydocs-dev' not found"
        print_info "Run setup first: $0 --setup --docker"
        return 1
    fi
    
    cd "$APP_DIR"
    
    # Get container name and manage lifecycle
    local container_name=$(get_docker_container_name "serve")
    stop_docker_container "$container_name"
    
    # Find available port
    local port=$(find_available_port 8000 8001 8002)
    if [ -z "$port" ]; then
        print_error "No available ports (8000, 8001, 8002). Kill existing processes."
        return 1
    fi
    
    print_success "🚀 Starting Docker container: $container_name"
    print_info "   • Port: $port"
    print_info "   • Access: http://localhost:$port"
    print_info "   • Static mode: $static_mode"
    
    # Start container based on mode
    if [ "$static_mode" = "true" ]; then
        # Static mode: serve pre-built content
        print_info "   • Mode: Static (production-like)"
        docker run -d --name "$container_name" \
            -p "$port:8000" \
            -v "$APP_DIR:/app" \
            -v "$CONTENT_DIR/docs:/app/content" \
            --workdir /app \
            rockydocs-dev \
            python3 -m http.server 8000 -d /app/site-static
    else
        # Live mode: MkDocs development server with proper environment
        print_info "   • Mode: Live (development with auto-reload)"
        docker run -d --name "$container_name" \
            -p "$port:8000" \
            -v "$APP_DIR:/app" \
            -v "$CONTENT_DIR/docs:/app/content" \
            --workdir /app \
            rockydocs-dev \
            bash -c "source venv/bin/activate && mkdocs serve -a 0.0.0.0:8000"
    fi
    
    # Add container to cleanup
    add_cleanup_resource "container:$container_name"
    
    # Health check with longer timeout for mkdocs build
    print_info "Waiting for container to be ready (mkdocs build can take 1-2 minutes)..."
    if check_docker_health "$container_name" "$port" 120; then
        print_success "✅ Docker container ready!"
        print_info "Access your documentation at: http://localhost:$port"
        
        # Show container logs briefly
        print_info ""
        print_info "Container logs (last 10 lines):"
        docker logs --tail 10 "$container_name" 2>/dev/null || true
        print_info ""
        print_warning "Press Ctrl+C to stop the container"
        
        # Follow container logs
        docker logs -f "$container_name"
    else
        print_error "Container failed to start properly"
        docker logs "$container_name" 2>/dev/null || true
        stop_docker_container "$container_name"
        return 1
    fi
}

# Podman serving function
serve_podman() {
    local static_mode="$1"
    
    print_info "📦 PODMAN SERVING MODE: Container-based documentation serving"
    
    # Validate Podman setup
    if [ ! -d "$APP_DIR" ]; then
        print_error "App directory not found: $APP_DIR"
        print_info "Run setup first: $0 --setup --podman"
        return 1
    fi
    
    # Check if Podman image exists
    if ! podman image inspect rockydocs-dev >/dev/null 2>&1; then
        print_error "Podman image 'rockydocs-dev' not found"
        print_info "Run setup first: $0 --setup --podman"
        return 1
    fi
    
    cd "$APP_DIR"
    
    # Get container name and manage lifecycle
    local container_name=$(get_podman_container_name "serve")
    stop_podman_container "$container_name"
    
    # Find available port
    local port=$(find_available_port 8000 8001 8002)
    if [ -z "$port" ]; then
        print_error "No available ports (8000, 8001, 8002). Kill existing processes."
        return 1
    fi
    
    print_success "🚀 Starting Podman container: $container_name"
    print_info "   • Port: $port"
    print_info "   • Access: http://localhost:$port"
    print_info "   • Static mode: $static_mode"
    
    # Start container based on mode
    if [ "$static_mode" = "true" ]; then
        # Static mode: serve pre-built content
        print_info "   • Mode: Static (production-like)"
        podman run -d --name "$container_name" \
            -p "$port:8000" \
            -v "$APP_DIR:/app" \
            -v "$CONTENT_DIR/docs:/app/content" \
            --workdir /app \
            rockydocs-dev \
            python3 -m http.server 8000 --bind 0.0.0.0 -d /app/site-static
    else
        # Live mode: MkDocs development server with proper environment
        print_info "   • Mode: Live (development with auto-reload)"
        podman run -d --name "$container_name" \
            -p "$port:8000" \
            -v "$APP_DIR:/app" \
            -v "$CONTENT_DIR/docs:/app/content" \
            --workdir /app \
            rockydocs-dev \
            bash -c "source venv/bin/activate && mkdocs serve -a 0.0.0.0:8000"
    fi
    
    # Add container to cleanup
    add_cleanup_resource "container:$container_name"
    
    # Health check with longer timeout for mkdocs build
    print_info "Waiting for container to be ready (mkdocs build can take 1-2 minutes)..."
    if check_podman_health "$container_name" "$port" 120; then
        print_success "✅ Podman container ready!"
        print_info "Access your documentation at: http://localhost:$port"
        
        # Show container logs briefly
        print_info ""
        print_info "Container logs (last 10 lines):"
        podman logs --tail 10 "$container_name" 2>/dev/null || true
        print_info ""
        print_warning "Press Ctrl+C to stop the container"
        
        # Follow container logs
        podman logs -f "$container_name"
    else
        print_error "Container failed to start properly"
        podman logs "$container_name" 2>/dev/null || true
        stop_podman_container "$container_name"
        return 1
    fi
}

# Parse arguments
COMMAND=""
ENVIRONMENT="venv"
BUILD_TYPE="minimal"
STATIC_MODE=false
LIST_MODE=false
CUSTOM_WORKSPACE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --setup)
            COMMAND="setup"
            shift
            ;;
        --serve)
            COMMAND="serve"
            shift
            ;;
        --serve-dual)
            COMMAND="serve-dual"
            shift
            ;;
        --deploy)
            COMMAND="deploy"
            shift
            ;;
        --clean)
            COMMAND="clean"
            shift
            ;;
        --reset)
            COMMAND="reset"
            shift
            ;;
        --status)
            COMMAND="status"
            shift
            ;;
        --version)
            COMMAND="version"
            shift
            ;;
        --stop)
            COMMAND="stop"
            shift
            ;;
        --venv|--docker|--podman)
            ENVIRONMENT="${1#--}"
            shift
            ;;
        --minimal)
            BUILD_TYPE="minimal"
            shift
            ;;
        --full)
            BUILD_TYPE="full"
            shift
            ;;
        --static)
            STATIC_MODE=true
            shift
            ;;
        --list)
            LIST_MODE=true
            shift
            ;;
        --workspace)
            if [ -n "$2" ]; then
                CUSTOM_WORKSPACE="$2"
                # Create directory if it doesn't exist, then get realpath
                mkdir -p "$2"
                WORKSPACE_BASE_DIR="$(realpath "$2")"
                APP_DIR="$WORKSPACE_BASE_DIR/docs.rockylinux.org"
                APP_COMPAT_LINK="$WORKSPACE_BASE_DIR/app"
                print_info "Using custom workspace: $WORKSPACE_BASE_DIR"
                
                # Save new workspace configuration
                print_info "Saving new workspace configuration..."
                save_workspace_config "$WORKSPACE_BASE_DIR"
                shift 2
            else
                print_error "--workspace requires a path"
                exit 1
            fi
            ;;
        -h|--help)
            if [ -n "$COMMAND" ]; then
                case "$COMMAND" in
                    setup) show_setup_help ;;
                    serve) show_serve_help ;;
                    serve-dual) show_serve_dual_help ;;
                    deploy) show_deploy_help ;;
                    stop) show_stop_help ;;
                    *) show_help ;;
                esac
            else
                show_help
            fi
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Handle subcommand help
if [[ "$2" == "-h" ]]; then
    case "$1" in
        --setup) show_setup_help ;;
        --serve) show_serve_help ;;
        --serve-dual) show_serve_dual_help ;;
        --deploy) show_deploy_help ;;
        --stop) show_stop_help ;;
        *) show_help ;;
    esac
    exit 0
fi

# Check dependencies before any operation
check_dependencies

# Execute command
case "$COMMAND" in
    setup)
        update_repositories
        setup_environment "$ENVIRONMENT" "$BUILD_TYPE"
        ;;
    serve)
        if [ "$ENVIRONMENT" = "docker" ]; then
            serve_docker "$STATIC_MODE"
        elif [ "$ENVIRONMENT" = "podman" ]; then
            serve_podman "$STATIC_MODE"
        elif [ "$STATIC_MODE" = "true" ]; then
            serve_static
        else
            serve_site "" "$STATIC_MODE"
        fi
        ;;
    serve-dual)
        if [ "$ENVIRONMENT" = "podman" ]; then
            serve_dual_podman
        elif [ "$ENVIRONMENT" = "docker" ]; then
            serve_dual_docker
        else
            serve_dual
        fi
        ;;
    deploy)
        if [ "$LIST_MODE" = "true" ]; then
            list_versions
        elif [ "$ENVIRONMENT" = "docker" ]; then
            update_repositories
            deploy_docker
        elif [ "$ENVIRONMENT" = "podman" ]; then
            update_repositories
            deploy_podman
        else
            update_repositories
            deploy_site
        fi
        ;;
    clean)
        clean_workspace
        ;;
    reset)
        reset_configuration
        ;;
    status)
        show_status
        ;;
    version)
        echo "$FULL_VERSION"
        echo "Author: $AUTHOR"
        echo "Rocky Linux Documentation Script"
        ;;
    stop)
        stop_all_services
        ;;
    *)
        print_error "No command specified"
        show_help
        exit 1
        ;;
esac
