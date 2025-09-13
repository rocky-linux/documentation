#!/bin/bash

# rockydocs-changelog.sh - Automated Changelog Management Tool
# Manages tools/CHANGELOG.md using git commit messages and script version parsing
#
# Usage:
#   ./tools/rockydocs-changelog.sh [COMMAND] [OPTIONS]
#
# Commands:
#   generate    - Generate complete changelog from git history
#   update      - Update changelog with recent commits  
#   commit      - Enhanced git commit with changelog update
#   show        - Show recent rockydocs commits
#   version     - Show current script version info
#
# Author: Wale Soyinka
# Contributors: 
# Ai-Contributors: Claude (claude-sonnet-4-20250514), Gemini (gemini-2.5-pro)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CHANGELOG_FILE="$SCRIPT_DIR/CHANGELOG.md"
ROCKYDOCS_SCRIPT="$REPO_ROOT/rockydocs.sh"

# Source functions if available
if [ -f "$SCRIPT_DIR/rockydocs-functions.sh" ]; then
    source "$SCRIPT_DIR/rockydocs-functions.sh"
else
    # Minimal print functions if not available
    print_info() { echo "ℹ️  $1"; }
    print_success() { echo "✅ $1"; }
    print_warning() { echo "⚠️  $1"; }
    print_error() { echo "❌ $1"; }
fi

# Extract current version from script
get_current_version() {
    if [ ! -f "$ROCKYDOCS_SCRIPT" ]; then
        echo "unknown-unknown"
        return
    fi
    
    local version=$(grep '^VERSION=' "$ROCKYDOCS_SCRIPT" | cut -d'"' -f2 2>/dev/null || echo "unknown")
    local release=$(grep '^RELEASE=' "$ROCKYDOCS_SCRIPT" | cut -d'"' -f2 2>/dev/null || echo "unknown")
    echo "$version-$release"
}

# Parse commit message for changelog info
parse_commit_message() {
    local commit_msg="$1"
    local commit_hash="$2"
    local commit_date="$3"
    
    # Extract action and description
    # Format: "rockydocs: <action> <description> (bump to <version>)"
    if [[ "$commit_msg" =~ ^rockydocs:\ ([^[:space:]]+)\ (.+)\ \(bump\ to\ ([^\)]+)\)$ ]]; then
        local action="${BASH_REMATCH[1]}"
        local description="${BASH_REMATCH[2]}"
        local version="${BASH_REMATCH[3]}"
        
        # Categorize action
        local category="Changed"
        case "$action" in
            add|new) category="Added" ;;
            fix|resolve) category="Fixed" ;;
            remove|delete) category="Removed" ;;
            update|improve|enhance) category="Changed" ;;
            security) category="Security" ;;
            deprecate) category="Deprecated" ;;
        esac
        
        echo "$version|$category|$description|$commit_hash|$commit_date"
        return 0
    fi
    
    return 1
}

# Generate changelog entry for a version
generate_version_entry() {
    local version="$1"
    local date="$2"
    
    echo ""
    echo "## [$version] - $date"
    echo ""
    
    # Group changes by category
    declare -A categories
    categories["Added"]=""
    categories["Changed"]=""
    categories["Fixed"]=""
    categories["Security"]=""
    categories["Deprecated"]=""
    categories["Removed"]=""
    
    # Parse commits for this version
    while IFS='|' read -r commit_version category description commit_hash commit_date; do
        if [ "$commit_version" = "$version" ]; then
            if [ -n "${categories[$category]}" ]; then
                categories[$category]="${categories[$category]}\n- $description"
            else
                categories[$category]="- $description"
            fi
        fi
    done < <(get_rockydocs_commits | while read -r hash date message; do
        if parse_commit_message "$message" "$hash" "$date"; then
            true
        fi
    done)
    
    # Output categories with content
    for category in "Added" "Changed" "Fixed" "Security" "Deprecated" "Removed"; do
        if [ -n "${categories[$category]}" ]; then
            echo "### $category"
            echo -e "${categories[$category]}"
            echo ""
        fi
    done
}

# Get rockydocs-related commits
get_rockydocs_commits() {
    git log --oneline --grep="^rockydocs:" --format="%H %ci %s" -- rockydocs.sh tools/ 2>/dev/null || true
}

# Show recent commits
show_commits() {
    local since="${1:-1 week ago}"
    
    print_info "Recent rockydocs commits (since: $since)"
    echo ""
    
    git log --oneline --grep="^rockydocs:" --since="$since" --format="%C(yellow)%h%C(reset) %C(green)%ci%C(reset) %s" -- rockydocs.sh tools/ 2>/dev/null || {
        print_warning "No rockydocs commits found since $since"
        return
    }
}

# Generate complete changelog
generate_changelog() {
    local backup_existing="$1"
    
    if [ -f "$CHANGELOG_FILE" ] && [ "$backup_existing" = "true" ]; then
        cp "$CHANGELOG_FILE" "$CHANGELOG_FILE.backup"
        print_info "Existing changelog backed up to: $CHANGELOG_FILE.backup"
    fi
    
    print_info "Generating complete changelog from git history..."
    
    # Create changelog header
    cat > "$CHANGELOG_FILE" << 'EOF'
# Rocky Linux Documentation Script Changelog

All notable changes to the `rockydocs.sh` script will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to NEVRA versioning (Name-Version-Release).

EOF
    
    # Get unique versions from commits, sorted by date (newest first)
    local versions=$(get_rockydocs_commits | while read -r hash date message; do
        if parse_commit_message "$message" "$hash" "$date"; then
            echo "$date|$(parse_commit_message "$message" "$hash" "$date" | cut -d'|' -f1)"
        fi
    done | sort -r | cut -d'|' -f2 | sort -u -r)
    
    if [ -z "$versions" ]; then
        print_warning "No versioned rockydocs commits found"
        echo "No versioned commits found yet." >> "$CHANGELOG_FILE"
        return
    fi
    
    # Generate entries for each version
    while read -r version; do
        if [ -n "$version" ]; then
            # Get the date of the first commit for this version
            local version_date=$(get_rockydocs_commits | while read -r hash date message; do
                if parse_commit_message "$message" "$hash" "$date" >/dev/null; then
                    local commit_version=$(parse_commit_message "$message" "$hash" "$date" | cut -d'|' -f1)
                    if [ "$commit_version" = "$version" ]; then
                        echo "$date"
                        break
                    fi
                fi
            done | head -1 | cut -d' ' -f1)
            
            generate_version_entry "$version" "$version_date" >> "$CHANGELOG_FILE"
        fi
    done <<< "$versions"
    
    print_success "Changelog generated: $CHANGELOG_FILE"
}

# Update changelog with recent commits
update_changelog() {
    local since="${1:-1 week ago}"
    
    if [ ! -f "$CHANGELOG_FILE" ]; then
        print_warning "Changelog doesn't exist. Use 'generate' command first."
        return 1
    fi
    
    print_info "Updating changelog with commits since: $since"
    
    # Get recent commits
    local recent_commits=$(git log --oneline --grep="^rockydocs:" --since="$since" --format="%H %ci %s" -- rockydocs.sh tools/ 2>/dev/null || true)
    
    if [ -z "$recent_commits" ]; then
        print_info "No recent rockydocs commits to add"
        return
    fi
    
    # For simplicity, append recent commits to a temporary section
    local temp_file=$(mktemp)
    
    # Add header for recent changes
    echo "" >> "$temp_file"
    echo "## Recent Changes ($(date +%Y-%m-%d))" >> "$temp_file"
    echo "" >> "$temp_file"
    echo "### Added" >> "$temp_file"
    
    # Parse and add recent commits
    echo "$recent_commits" | while read -r hash date message; do
        if parse_commit_message "$message" "$hash" "$date" >/dev/null; then
            local description=$(parse_commit_message "$message" "$hash" "$date" | cut -d'|' -f3)
            echo "- $description" >> "$temp_file"
        fi
    done
    
    # Prepend to existing changelog (after header)
    local header_lines=$(grep -n "^# Rocky Linux" "$CHANGELOG_FILE" | head -1 | cut -d':' -f1)
    local insert_line=$((header_lines + 5))  # After header block
    
    head -$insert_line "$CHANGELOG_FILE" > "${temp_file}.full"
    cat "$temp_file" >> "${temp_file}.full"
    tail -n +$((insert_line + 1)) "$CHANGELOG_FILE" >> "${temp_file}.full"
    
    mv "${temp_file}.full" "$CHANGELOG_FILE"
    rm -f "$temp_file"
    
    print_success "Changelog updated with recent commits"
}

# Enhanced git commit with automatic changelog update
enhanced_commit() {
    local message="$1"
    
    if [ -z "$message" ]; then
        print_error "Commit message required"
        echo "Usage: $0 commit 'rockydocs: action description (bump to version-release)'"
        return 1
    fi
    
    # Validate commit message format
    if [[ ! "$message" =~ ^rockydocs:\ [^[:space:]]+\ .+\ \(bump\ to\ [^\)]+\)$ ]]; then
        print_error "Invalid commit message format"
        echo "Required format: 'rockydocs: <action> <description> (bump to <version>-<release>)'"
        echo "Example: 'rockydocs: add --feature-x option (bump to 1.1.0-1.el10)'"
        return 1
    fi
    
    # Extract version from commit message
    local version=$(echo "$message" | grep -o '(bump to [^)]*)' | sed 's/(bump to \(.*\))/\1/')
    
    # Check if version matches script
    local current_version=$(get_current_version)
    if [ "$version" != "$current_version" ]; then
        print_warning "Version mismatch:"
        echo "  Commit message: $version"
        echo "  Script version: $current_version"
        echo "  Update script version first or fix commit message"
    fi
    
    # Stage rockydocs-related files
    git add rockydocs.sh tools/ 2>/dev/null || true
    
    # Commit with message
    git commit -m "$message"
    
    # Update changelog if it exists
    if [ -f "$CHANGELOG_FILE" ]; then
        print_info "Updating changelog..."
        update_changelog "1 hour ago"
    fi
    
    print_success "Commit completed with changelog update"
}

# Show current version info
show_version() {
    local current_version=$(get_current_version)
    local latest_commit=$(git log -1 --oneline --grep="^rockydocs:" --format="%h %s" -- rockydocs.sh tools/ 2>/dev/null || echo "No commits found")
    
    print_info "Version Information"
    echo "  Current script version: $current_version"
    echo "  Latest rockydocs commit: $latest_commit"
    echo "  Changelog file: $CHANGELOG_FILE"
    echo "  Repository root: $REPO_ROOT"
}

# Show help
show_help() {
    cat << EOF
rockydocs-changelog.sh - Automated Changelog Management Tool

USAGE:
  $0 COMMAND [OPTIONS]

COMMANDS:
  generate [--backup]     Generate complete changelog from git history
  update [SINCE]          Update changelog with recent commits (default: 1 week ago)
  commit MESSAGE          Enhanced git commit with changelog update
  show [SINCE]            Show recent rockydocs commits (default: 1 week ago)  
  version                 Show current script version information
  help                    Show this help message

EXAMPLES:
  # Generate complete changelog
  $0 generate

  # Update with recent commits
  $0 update "2 weeks ago"
  
  # Enhanced commit (auto-updates changelog)
  $0 commit "rockydocs: add --feature-x option (bump to 1.1.0-1.el10)"
  
  # Show recent commits
  $0 show "1 month ago"

COMMIT MESSAGE FORMAT:
  rockydocs: <action> <description> (bump to <version>-<release>)
  
  Actions: add, fix, update, remove, security, deprecate
  Example: rockydocs: add --version option (bump to 1.0.0-13.el10)

NOTES:
  - Requires standardized commit message format
  - Automatically categorizes changes based on action keywords
  - Updates changelog using git history and version parsing
  - Integrates with existing rockydocs-functions.sh if available

EOF
}

# Main command processing
case "${1:-help}" in
    generate)
        generate_changelog "${2:-false}"
        ;;
    update)
        update_changelog "${2:-1 week ago}"
        ;;
    commit)
        enhanced_commit "$2"
        ;;
    show)
        show_commits "${2:-1 week ago}"
        ;;
    version)
        show_version
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac