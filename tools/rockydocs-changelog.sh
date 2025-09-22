#!/bin/bash

# rockydocs-changelog.sh - Automated Changelog Management Tool (FIXED VERSION)
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
# FIXED: Script path detection, commit parsing, backup protection

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CHANGELOG_FILE="$SCRIPT_DIR/CHANGELOG.md"

# FIXED: Smart script detection - finds versioned scripts automatically
ROCKYDOCS_SCRIPT="$REPO_ROOT/rockydocs.sh"
if [ ! -f "$ROCKYDOCS_SCRIPT" ]; then
    # Look for versioned script
    ROCKYDOCS_SCRIPT=$(find "$REPO_ROOT" -maxdepth 1 -name "rockydocs-v*.sh" | head -1)
fi

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

# FIXED: Enhanced git command wrapper for non-git environments
safe_git_cmd() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        print_warning "Not in a git repository - some features limited"
        return 1
    fi
    git "$@"
}

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

# FIXED: More flexible commit message parsing
parse_commit_message() {
    local commit_msg="$1"
    local commit_hash="$2"
    local commit_date="$3"
    
    # Extract action and description - FIXED: More flexible regex
    # Format: "rockydocs: <action> <description> (bump to <version>)"
    # Also handles variations in spacing and format
    if [[ "$commit_msg" =~ ^rockydocs:[[:space:]]*([^[:space:]]+)[[:space:]]+(.+)[[:space:]]*\(bump[[:space:]]+to[[:space:]]+([^\)]+)\).*$ ]]; then
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
            test|demonstrate) category="Added" ;;  # FIXED: Handle test commits
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
                categories[$category]="${categories[$category]}\\n- $description"
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

# Get rockydocs-related commits with git safety
get_rockydocs_commits() {
    if ! safe_git_cmd log --oneline --grep="^rockydocs:" --format="%H %ci %s" -- rockydocs.sh tools/ 2>/dev/null; then
        return 1
    fi
}

# Show recent commits with git safety
show_commits() {
    local since="${1:-1 week ago}"
    
    print_info "Recent rockydocs commits (since: $since)"
    echo ""
    
    if ! safe_git_cmd log --oneline --grep="^rockydocs:" --since="$since" --format="%C(yellow)%h%C(reset) %C(green)%ci%C(reset) %s" -- rockydocs.sh tools/ 2>/dev/null; then
        print_warning "No rockydocs commits found since $since or not in git repository"
        return 1
    fi
}

# FIXED: Generate complete changelog with backup protection
generate_changelog() {
    local backup_existing="${1:-true}"  # FIXED: Always backup by default
    
    # FIXED: Automatic backup with timestamp
    if [ -f "$CHANGELOG_FILE" ]; then
        local backup_file="$CHANGELOG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$CHANGELOG_FILE" "$backup_file"
        print_info "Existing changelog backed up to: $backup_file"
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
    local versions
    if ! versions=$(get_rockydocs_commits | while read -r hash date message; do
        if parse_commit_message "$message" "$hash" "$date"; then
            echo "$date|$(parse_commit_message "$message" "$hash" "$date" | cut -d'|' -f1)"
        fi
    done | sort -r | cut -d'|' -f2 | sort -u -r); then
        print_warning "Could not retrieve git history - using simple format"
        echo "No versioned commits found yet." >> "$CHANGELOG_FILE"
        return
    fi
    
    if [ -z "$versions" ]; then
        print_warning "No versioned rockydocs commits found"
        echo "No versioned commits found yet." >> "$CHANGELOG_FILE"
        return
    fi
    
    # Generate entries for each version
    while read -r version; do
        if [ -n "$version" ]; then
            # Get the date of the first commit for this version
            local version_date
            version_date=$(get_rockydocs_commits | while read -r hash date message; do
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

# FIXED: Update changelog with improved commit handling and duplicate prevention
update_changelog() {
    local since="${1:-1 week ago}"
    
    if [ ! -f "$CHANGELOG_FILE" ]; then
        print_warning "Changelog doesn't exist. Use 'generate' command first."
        return 1
    fi
    
    print_info "Updating changelog with commits since: $since"
    
    # Get recent commits with git safety
    local recent_commits
    if ! recent_commits=$(safe_git_cmd log --oneline --grep="^rockydocs:" --since="$since" --format="%H %ci %s" -- rockydocs.sh tools/ 2>/dev/null); then
        print_info "Cannot access git history or no recent commits"
        return
    fi
    
    if [ -z "$recent_commits" ]; then
        print_info "No recent rockydocs commits to add"
        return
    fi
    
    # FIXED: Check for existing entries to prevent duplicates
    local temp_new_entries=$(mktemp)
    local entries_to_add=()
    
    # Build list of new entries not already in changelog
    while read -r hash date message; do
        local short_hash="${hash:0:8}"
        
        # Check if this commit is already in changelog
        if ! grep -q "commit: $short_hash" "$CHANGELOG_FILE"; then
            # Try structured parsing first
            if parse_commit_message "$message" "$hash" "$date" >/dev/null; then
                local description=$(parse_commit_message "$message" "$hash" "$date" | cut -d'|' -f3)
                echo "- $description (commit: $short_hash)" >> "$temp_new_entries"
            else
                # Fallback: extract description after "rockydocs:"
                local simple_desc=$(echo "$message" | sed 's/^rockydocs:[[:space:]]*//' | sed 's/[[:space:]]*(.*)$//')
                echo "- $simple_desc (commit: $short_hash)" >> "$temp_new_entries"
            fi
        fi
    done <<< "$recent_commits"
    
    # Check if we have new entries to add
    if [ ! -s "$temp_new_entries" ]; then
        print_info "No new commits to add (all commits already in changelog)"
        rm -f "$temp_new_entries"
        return
    fi
    
    # FIXED: Update existing "Recent Changes" section or create new one
    local temp_changelog=$(mktemp)
    local today_section="## Recent Changes ($(date +%Y-%m-%d))"
    local found_today_section=false
    local in_today_section=false
    local added_new_entries=false
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^##\ Recent\ Changes\ \([0-9]{4}-[0-9]{2}-[0-9]{2}\) ]]; then
            if [ "$line" = "$today_section" ]; then
                found_today_section=true
                in_today_section=true
                echo "$line" >> "$temp_changelog"
            else
                in_today_section=false
                # If we found today's section and added entries, close it
                if [ "$found_today_section" = "true" ] && [ "$added_new_entries" = "false" ]; then
                    echo "" >> "$temp_changelog"
                    echo "### Added" >> "$temp_changelog"
                    cat "$temp_new_entries" >> "$temp_changelog"
                    added_new_entries=true
                fi
                echo "$line" >> "$temp_changelog"
            fi
        elif [ "$in_today_section" = "true" ] && [ "$line" = "### Added" ]; then
            echo "$line" >> "$temp_changelog"
            # Add new entries right after "### Added"
            cat "$temp_new_entries" >> "$temp_changelog"
            added_new_entries=true
        else
            echo "$line" >> "$temp_changelog"
        fi
    done < "$CHANGELOG_FILE"
    
    # If no today section was found, add it at the top
    if [ "$found_today_section" = "false" ]; then
        local temp_final=$(mktemp)
        local header_lines=$(grep -n "^# Rocky Linux" "$CHANGELOG_FILE" | head -1 | cut -d':' -f1)
        local insert_line=$((header_lines + 5))  # After header block
        
        head -$insert_line "$CHANGELOG_FILE" > "$temp_final"
        echo "" >> "$temp_final"
        echo "$today_section" >> "$temp_final"
        echo "" >> "$temp_final"
        echo "### Added" >> "$temp_final"
        cat "$temp_new_entries" >> "$temp_final"
        tail -n +$((insert_line + 1)) "$CHANGELOG_FILE" >> "$temp_final"
        
        mv "$temp_final" "$CHANGELOG_FILE"
    else
        mv "$temp_changelog" "$CHANGELOG_FILE"
    fi
    
    rm -f "$temp_new_entries" "$temp_changelog"
    
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
    
    # FIXED: More flexible commit message validation
    if [[ ! "$message" =~ ^rockydocs:[[:space:]]*[^[:space:]]+[[:space:]]+.+[[:space:]]*\(bump[[:space:]]+to[[:space:]]+[^\)]+\) ]]; then
        print_error "Invalid commit message format"
        echo "Required format: 'rockydocs: <action> <description> (bump to <version>-<release>)'"
        echo "Example: 'rockydocs: add --feature-x option (bump to 1.1.0-1.el10)'"
        return 1
    fi
    
    # Extract version from commit message
    local version=$(echo "$message" | grep -o '(bump to [^)]*)' | sed 's/(bump to \(.*\))/\1/')
    
    # Check if version matches script (show info but don't block)
    local current_version=$(get_current_version)
    if [ "$version" != "$current_version" ]; then
        print_info "Version info:"
        echo "  Commit message version: $version"
        echo "  Script version: $current_version"
        echo "  (Different versions allowed for testing)"
    fi
    
    # Check if we're on rockydocs-tool branch (optional enforcement)
    local current_branch
    if current_branch=$(safe_git_cmd branch --show-current 2>/dev/null); then
        if [ "$current_branch" != "rockydocs-tool" ]; then
            print_warning "Not on rockydocs-tool branch (current: $current_branch)"
            echo "Consider using 'git checkout -b rockydocs-tool' for rockydocs commits"
            echo ""
            read -p "Continue anyway? [y/N]: " confirm
            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                print_info "Commit cancelled"
                return 1
            fi
        fi
    fi
    
    # Stage only specific rockydocs-related files (not all of tools/)
    safe_git_cmd add rockydocs.sh 2>/dev/null || true
    safe_git_cmd add rockydocs-v*.sh 2>/dev/null || true  # FIXED: Handle versioned scripts
    safe_git_cmd add tools/rockydocs-*.sh 2>/dev/null || true
    safe_git_cmd add tools/CHANGELOG.md 2>/dev/null || true
    
    # Update changelog BEFORE committing to avoid chicken-and-egg problem
    if [ -f "$CHANGELOG_FILE" ]; then
        print_info "Pre-updating changelog..."
        # Create temporary commit to establish commit for changelog parsing
        safe_git_cmd commit -m "temp: $message" --allow-empty 2>/dev/null || true
        update_changelog "1 minute ago"
        safe_git_cmd add tools/CHANGELOG.md 2>/dev/null || true
        # Amend with the real commit message and updated changelog
        safe_git_cmd commit --amend -m "$message"
    else
        # Just commit without changelog update
        safe_git_cmd commit -m "$message"
    fi
    
    print_success "Commit completed with changelog update"
}

# Show current version info
show_version() {
    local current_version=$(get_current_version)
    local latest_commit
    if latest_commit=$(safe_git_cmd log -1 --oneline --grep="^rockydocs:" --format="%h %s" -- rockydocs.sh tools/ 2>/dev/null); then
        if [ -z "$latest_commit" ]; then
            latest_commit="No commits found"
        fi
    else
        latest_commit="Git not available"
    fi
    
    print_info "Version Information"
    echo "  Current script version: $current_version"
    echo "  Script path: $ROCKYDOCS_SCRIPT"  # FIXED: Show detected script path
    echo "  Latest rockydocs commit: $latest_commit"
    echo "  Changelog file: $CHANGELOG_FILE"
    echo "  Repository root: $REPO_ROOT"
}

# Show help
show_help() {
    cat << EOF
rockydocs-changelog.sh - Automated Changelog Management Tool
Rocky Linux Documentation System v1.3.0-1.el10

USAGE:
  $0 COMMAND [OPTIONS]

COMMANDS:
  version                 Show current script version and git information
  show [SINCE]            Show recent rockydocs commits (default: 1 week ago)
  update [SINCE]          Update changelog with recent commits (prevents duplicates)
  generate [--backup]     Generate complete changelog from git history (with backup)
  commit MESSAGE          Enhanced git commit with automatic changelog update
  help                    Show this help message

WORKING EXAMPLES:
  # Check script version and latest commit
  $0 version
  
  # Show recent rockydocs commits
  $0 show
  $0 show "2 weeks ago"
  
  # Update changelog with recent commits (smart duplicate prevention)
  $0 update
  $0 update "1 month ago"
  
  # Generate complete changelog (creates backup automatically)
  $0 generate
  
  # Enhanced commit workflow (recommended)
  echo "# Add new feature" >> rockydocs.sh
  $0 commit "rockydocs: add new feature (bump to 1.3.0-1.el10)"

COMMIT MESSAGE FORMAT:
  rockydocs: <action> <description> (bump to <version>-<release>)
  
  Valid Actions: add, fix, update, remove, security, deprecate, test, demonstrate
  
  Real Examples:
  • "rockydocs: add Docker support (bump to 1.3.0-1.el10)"
  • "rockydocs: fix changelog duplicates (bump to 1.3.1-1.el10)"
  • "rockydocs: test new feature (bump to 1.4.0-1.el10)"

SSH USAGE (Remote Server):
  ssh root@192.168.2.80 "cd /root/docs-v1-claude/documentation && ./tools/rockydocs-changelog.sh version"
  ssh root@192.168.2.80 "cd /root/docs-v1-claude/documentation && ./tools/rockydocs-changelog.sh update"

KEY FEATURES:
  ✅ Smart script detection (finds rockydocs.sh or rockydocs-v*.sh automatically)
  ✅ Duplicate prevention (update command only adds new commits)
  ✅ Automatic backups (generate command creates timestamped backups)
  ✅ Version-aware commits (handles version mismatches gracefully)
  ✅ Git-safe operations (works in non-git environments)
  ✅ Enhanced error handling and validation

WORKFLOW:
  1. Make changes to rockydocs.sh or tools/
  2. Use: $0 commit "rockydocs: describe change (bump to version)"
  3. Use: $0 update (to refresh changelog if needed)
  4. Use: $0 show (to verify commits)

FILE LOCATIONS:
  Script: tools/rockydocs-changelog.sh
  Target: rockydocs.sh or rockydocs-v*.sh (auto-detected)
  Output: tools/CHANGELOG.md (with automatic backups)

EOF
}

# Main command processing
case "${1:-help}" in
    generate)
        generate_changelog "${2:-true}"
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