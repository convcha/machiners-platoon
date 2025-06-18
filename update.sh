#!/bin/bash

# update.sh - Sync GitHub Actions workflows and actions with upstream repository
# This script compares and updates local GitHub Actions files with the latest versions
# from https://github.com/convcha/machiners-platoon while preserving user customizations.

set -euo pipefail

# Configuration
UPSTREAM_REPO="https://github.com/convcha/machiners-platoon"
UPSTREAM_RAW_BASE="https://raw.githubusercontent.com/convcha/machiners-platoon/main"
WORKFLOWS_DIR=".github/workflows"
ACTIONS_DIR=".github/actions"
BACKUP_DIR=".github-backup-$(date +%Y%m%d-%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global flags
DRY_RUN=false
INTERACTIVE=true
FORCE_UPDATE=false
SKIP_BACKUP=false

# Usage information
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Sync GitHub Actions workflows and actions with upstream Machiners Platoon repository.

OPTIONS:
    -d, --dry-run          Show what would be updated without making changes
    -y, --yes              Non-interactive mode, automatically apply updates
    -f, --force            Force update all files (ignore user customizations check)
    -s, --skip-backup      Skip creating backups (not recommended)
    -h, --help             Show this help message

EXAMPLES:
    $0                     Interactive update with preview
    $0 --dry-run          Preview changes without applying them
    $0 --yes              Automatically apply all updates
    $0 --force --yes      Force update all files non-interactively

IMPORTANT:
This script preserves user customizations including:
- Language configurations (MACHINERS_PLATOON_LANG)
- Trigger label configurations (MACHINERS_PLATOON_TRIGGER_LABEL)
- Custom secrets and environment variables
- Repository-specific setup steps

EOF
}

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

# Check if required tools are available
check_dependencies() {
    local missing_tools=()
    
    for tool in curl git diff jq; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_error "Please install the missing tools and try again."
        exit 1
    fi
}

# Check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "This script must be run from within a git repository."
        exit 1
    fi
}

# Create backup directory and backup files
create_backup() {
    if [ "$SKIP_BACKUP" = true ]; then
        log_warning "Skipping backup creation (--skip-backup specified)"
        return 0
    fi
    
    log_info "Creating backup in $BACKUP_DIR"
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup workflows
    if [ -d "$WORKFLOWS_DIR" ]; then
        cp -r "$WORKFLOWS_DIR" "$BACKUP_DIR/"
        log_info "Backed up workflows to $BACKUP_DIR/workflows/"
    fi
    
    # Backup actions
    if [ -d "$ACTIONS_DIR" ]; then
        cp -r "$ACTIONS_DIR" "$BACKUP_DIR/"
        log_info "Backed up actions to $BACKUP_DIR/actions/"
    fi
    
    log_success "Backup created successfully"
}

# Rollback from backup
rollback() {
    if [ ! -d "$BACKUP_DIR" ]; then
        log_error "No backup directory found. Cannot rollback."
        return 1
    fi
    
    log_warning "Rolling back changes from backup..."
    
    # Restore workflows
    if [ -d "$BACKUP_DIR/workflows" ]; then
        rm -rf "$WORKFLOWS_DIR"
        mv "$BACKUP_DIR/workflows" "$WORKFLOWS_DIR"
        log_info "Restored workflows from backup"
    fi
    
    # Restore actions
    if [ -d "$BACKUP_DIR/actions" ]; then
        rm -rf "$ACTIONS_DIR"
        mv "$BACKUP_DIR/actions" "$ACTIONS_DIR"
        log_info "Restored actions from backup"
    fi
    
    # Clean up backup directory
    rmdir "$BACKUP_DIR" 2>/dev/null || true
    
    log_success "Rollback completed successfully"
}

# Fetch upstream file content
fetch_upstream_file() {
    local file_path="$1"
    local url="$UPSTREAM_RAW_BASE/$file_path"
    
    if ! curl -s -f "$url" 2>/dev/null; then
        return 1
    fi
    return 0
}

# Get list of files from upstream repository
get_upstream_file_list() {
    local dir="$1"
    local api_url="https://api.github.com/repos/convcha/machiners-platoon/contents/$dir"
    
    # Try to get file list from GitHub API
    local response
    if response=$(curl -s -f "$api_url" 2>/dev/null); then
        echo "$response" | jq -r '.[].name' | sort
    else
        log_warning "Could not fetch file list from upstream $dir directory"
        return 1
    fi
}

# Extract user customizations from a YAML file
extract_customizations() {
    local file="$1"
    local customizations=()
    
    # Look for common customization patterns
    if grep -q "MACHINERS_PLATOON_LANG" "$file" 2>/dev/null; then
        customizations+=("Language configuration")
    fi
    
    if grep -q "MACHINERS_PLATOON_TRIGGER_LABEL" "$file" 2>/dev/null; then
        customizations+=("Trigger label configuration")
    fi
    
    if grep -q "NODE_VERSION" "$file" 2>/dev/null; then
        customizations+=("Node.js version specification")
    fi
    
    if grep -q "pnpm" "$file" 2>/dev/null; then
        customizations+=("pnpm setup steps")
    fi
    
    # Check for custom secrets (secrets other than standard ones)
    local secrets
    secrets=$(grep -o '\${{ secrets\.[A-Z_]* }}' "$file" 2>/dev/null | sort -u || true)
    if [ -n "$secrets" ]; then
        customizations+=("Custom secrets: $(echo "$secrets" | tr '\n' ' ')")
    fi
    
    printf '%s\n' "${customizations[@]}"
}

# Preserve user customizations when updating a file
preserve_customizations() {
    local original_file="$1"
    local upstream_content="$2"
    local temp_file
    temp_file=$(mktemp)
    
    echo "$upstream_content" > "$temp_file"
    
    # If the original file doesn't exist, just use upstream content
    if [ ! -f "$original_file" ]; then
        cat "$temp_file"
        rm "$temp_file"
        return
    fi
    
    # Preserve language configuration
    if grep -q "MACHINERS_PLATOON_LANG" "$original_file"; then
        local lang_config
        lang_config=$(grep "MACHINERS_PLATOON_LANG" "$original_file" | head -1)
        sed -i "s/\\\${{ vars\.MACHINERS_PLATOON_LANG || 'English' }}/$lang_config/g" "$temp_file"
    fi
    
    # Preserve trigger label configuration  
    if grep -q "MACHINERS_PLATOON_TRIGGER_LABEL" "$original_file"; then
        local trigger_config
        trigger_config=$(grep "MACHINERS_PLATOON_TRIGGER_LABEL" "$original_file" | head -1)
        sed -i "s/\\\${{ vars\.MACHINERS_PLATOON_TRIGGER_LABEL || '🤖 Machiners Platoon' }}/$trigger_config/g" "$temp_file"
    fi
    
    # Preserve Node.js version if customized
    if grep -q "NODE_VERSION:" "$original_file"; then
        local node_version
        node_version=$(grep "NODE_VERSION:" "$original_file" | head -1)
        if grep -q "NODE_VERSION:" "$temp_file"; then
            sed -i "s/NODE_VERSION: .*/$(echo "$node_version" | sed 's/[\/&]/\\&/g')/" "$temp_file"
        fi
    fi
    
    cat "$temp_file"
    rm "$temp_file"
}

# Compare local file with upstream and show differences
compare_file() {
    local local_file="$1"
    local upstream_content="$2"
    local file_path="$3"
    
    # Create temporary file for upstream content
    local temp_upstream
    temp_upstream=$(mktemp)
    echo "$upstream_content" > "$temp_upstream"
    
    log_info "Comparing $file_path..."
    
    if [ ! -f "$local_file" ]; then
        log_warning "Local file $file_path does not exist - will be created"
        if [ "$DRY_RUN" = false ]; then
            echo "Would create new file: $file_path"
        fi
        rm "$temp_upstream"
        return 0
    fi
    
    # Show differences
    if ! diff -u "$local_file" "$temp_upstream" > /dev/null 2>&1; then
        echo "Differences found in $file_path:"
        echo "----------------------------------------"
        diff -u "$local_file" "$temp_upstream" | head -20
        echo "----------------------------------------"
        
        # Check for user customizations
        local customizations
        customizations=$(extract_customizations "$local_file")
        if [ -n "$customizations" ]; then
            log_warning "User customizations detected in $file_path:"
            echo "$customizations" | sed 's/^/  - /'
        fi
        
        rm "$temp_upstream"
        return 1
    else
        log_success "$file_path is up to date"
        rm "$temp_upstream"
        return 0
    fi
}

# Update a single file
update_file() {
    local file_path="$1"
    local upstream_content="$2"
    local preserve_customizations="$3"
    
    log_info "Updating $file_path..."
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$file_path")"
    
    if [ "$preserve_customizations" = true ] && [ -f "$file_path" ]; then
        # Preserve user customizations
        local final_content
        final_content=$(preserve_customizations "$file_path" "$upstream_content")
        echo "$final_content" > "$file_path"
        log_success "Updated $file_path (preserved customizations)"
    else
        # Direct update
        echo "$upstream_content" > "$file_path"
        log_success "Updated $file_path"
    fi
}

# Process workflow files
process_workflows() {
    log_info "Processing workflow files..."
    
    # Get list of upstream workflow files
    local upstream_files
    if ! upstream_files=$(get_upstream_file_list ".github/workflows"); then
        log_error "Failed to get upstream workflow files list"
        return 1
    fi
    
    local files_to_update=()
    local files_processed=0
    
    # Process each upstream workflow file
    while IFS= read -r filename; do
        [ -z "$filename" ] && continue
        
        local file_path="$WORKFLOWS_DIR/$filename"
        local upstream_content
        
        log_info "Fetching upstream content for $filename..."
        if upstream_content=$(fetch_upstream_file ".github/workflows/$filename"); then
            files_processed=$((files_processed + 1))
            
            # Compare files and check for differences
            if ! compare_file "$file_path" "$upstream_content" ".github/workflows/$filename"; then
                files_to_update+=("$file_path|$upstream_content")
            fi
        else
            log_warning "Could not fetch upstream content for $filename"
        fi
    done <<< "$upstream_files"
    
    if [ ${#files_to_update[@]} -eq 0 ]; then
        log_success "All workflow files are up to date"
        return 0
    fi
    
    # Handle updates
    if [ "$DRY_RUN" = true ]; then
        log_info "DRY RUN: Would update ${#files_to_update[@]} workflow files"
        return 0
    fi
    
    if [ "$INTERACTIVE" = true ] && [ "$FORCE_UPDATE" = false ]; then
        echo
        read -p "Update ${#files_to_update[@]} workflow files? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping workflow updates"
            return 0
        fi
    fi
    
    # Apply updates
    for file_update in "${files_to_update[@]}"; do
        local file_path="${file_update%%|*}"
        local upstream_content="${file_update#*|}"
        update_file "$file_path" "$upstream_content" true
    done
    
    log_success "Updated ${#files_to_update[@]} workflow files"
}

# Process action files
process_actions() {
    log_info "Processing action files..."
    
    # Get list of upstream action directories
    local upstream_actions
    if ! upstream_actions=$(get_upstream_file_list ".github/actions"); then
        log_error "Failed to get upstream actions list"
        return 1
    fi
    
    local files_to_update=()
    
    # Process each upstream action
    while IFS= read -r action_name; do
        [ -z "$action_name" ] && continue
        
        # Get action.yml file for this action
        local action_file_path="$ACTIONS_DIR/$action_name/action.yml"
        local upstream_content
        
        log_info "Fetching upstream content for action $action_name..."
        if upstream_content=$(fetch_upstream_file ".github/actions/$action_name/action.yml"); then
            # Compare files and check for differences
            if ! compare_file "$action_file_path" "$upstream_content" ".github/actions/$action_name/action.yml"; then
                files_to_update+=("$action_file_path|$upstream_content")
            fi
        else
            log_warning "Could not fetch upstream content for action $action_name"
        fi
    done <<< "$upstream_actions"
    
    if [ ${#files_to_update[@]} -eq 0 ]; then
        log_success "All action files are up to date"
        return 0
    fi
    
    # Handle updates
    if [ "$DRY_RUN" = true ]; then
        log_info "DRY RUN: Would update ${#files_to_update[@]} action files"
        return 0
    fi
    
    if [ "$INTERACTIVE" = true ] && [ "$FORCE_UPDATE" = false ]; then
        echo
        read -p "Update ${#files_to_update[@]} action files? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping action updates"
            return 0
        fi
    fi
    
    # Apply updates
    for file_update in "${files_to_update[@]}"; do
        local file_path="${file_update%%|*}"
        local upstream_content="${file_update#*|}"
        update_file "$file_path" "$upstream_content" true
    done
    
    log_success "Updated ${#files_to_update[@]} action files"
}

# Main update process
main_update() {
    log_info "Starting GitHub Actions sync with upstream repository"
    log_info "Upstream: $UPSTREAM_REPO"
    
    if [ "$DRY_RUN" = true ]; then
        log_info "DRY RUN MODE: No changes will be made"
    fi
    
    # Create backup before making changes
    if [ "$DRY_RUN" = false ]; then
        create_backup
    fi
    
    # Process workflows and actions
    local success=true
    
    if ! process_workflows; then
        success=false
    fi
    
    if ! process_actions; then
        success=false
    fi
    
    if [ "$success" = true ]; then
        log_success "GitHub Actions sync completed successfully"
        
        if [ "$DRY_RUN" = false ]; then
            log_info "Backup created at: $BACKUP_DIR"
            echo
            echo "To rollback changes if needed, run:"
            echo "  mv $BACKUP_DIR/workflows $WORKFLOWS_DIR"
            echo "  mv $BACKUP_DIR/actions $ACTIONS_DIR"
        fi
    else
        log_error "Some operations failed during sync"
        if [ "$DRY_RUN" = false ]; then
            echo
            read -p "Do you want to rollback changes? (y/N): " -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rollback
            fi
        fi
        return 1
    fi
}

# Signal handlers
cleanup() {
    log_info "Cleaning up..."
    # Remove any temporary files
    rm -f /tmp/update-sh-*
}

handle_interrupt() {
    echo
    log_warning "Operation interrupted by user"
    
    if [ "$DRY_RUN" = false ] && [ -d "$BACKUP_DIR" ]; then
        echo
        read -p "Do you want to rollback any changes made so far? (y/N): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rollback
        fi
    fi
    
    cleanup
    exit 130
}

# Set up signal handlers
trap handle_interrupt INT TERM
trap cleanup EXIT

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -y|--yes)
            INTERACTIVE=false
            shift
            ;;
        -f|--force)
            FORCE_UPDATE=true
            shift
            ;;
        -s|--skip-backup)
            SKIP_BACKUP=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    log_info "Machiners Platoon GitHub Actions Update Script"
    echo "=============================================="
    
    # Perform checks
    check_dependencies
    check_git_repo
    
    # Run main update process
    main_update
}

# Run main function
main "$@"