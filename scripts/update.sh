#!/bin/bash

# Machiners Platoon Update Script
# This script updates GitHub Actions workflows and custom actions while preserving user customizations

set -e

# Configuration
REPO_URL="https://raw.githubusercontent.com/convcha/machiners-platoon/main"
BACKUP_DIR=".github/backups/$(date +%Y%m%d_%H%M%S)"
TEMP_DIR="/tmp/machiners-platoon-update"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Files to update
WORKFLOW_FILES=(
    "product-manager-bot.yml"
    "system-architect-bot.yml"
    "engineer-bot.yml"
    "architect-review-bot.yml"
    "engineer-fixes-bot.yml"
)

ACTION_FILES=(
    "claude-result-tracker/action.yml"
)

# Function to print colored output
print_status() {
    echo -e "${BLUE}>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists curl; then
        print_error "curl is required but not installed. Please install curl and try again."
        exit 1
    fi
    
    if ! command_exists diff; then
        print_error "diff is required but not installed. Please install diff and try again."
        exit 1
    fi
    
    if [ ! -d ".github" ]; then
        print_error "No .github directory found. Please run this script from a repository root with Machiners Platoon installed."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to create backup
create_backup() {
    print_status "Creating backup in $BACKUP_DIR..."
    
    mkdir -p "$BACKUP_DIR/workflows"
    mkdir -p "$BACKUP_DIR/actions"
    
    # Backup workflow files
    for file in "${WORKFLOW_FILES[@]}"; do
        if [ -f ".github/workflows/$file" ]; then
            cp ".github/workflows/$file" "$BACKUP_DIR/workflows/"
            print_success "Backed up workflow: $file"
        fi
    done
    
    # Backup action files
    for file in "${ACTION_FILES[@]}"; do
        if [ -f ".github/actions/$file" ]; then
            mkdir -p "$BACKUP_DIR/actions/$(dirname "$file")"
            cp ".github/actions/$file" "$BACKUP_DIR/actions/$file"
            print_success "Backed up action: $file"
        fi
    done
    
    print_success "Backup completed"
}

# Function to download latest files
download_latest() {
    print_status "Downloading latest files to temporary directory..."
    
    mkdir -p "$TEMP_DIR/workflows"
    mkdir -p "$TEMP_DIR/actions"
    
    # Download workflow files
    for file in "${WORKFLOW_FILES[@]}"; do
        if curl -s -f "$REPO_URL/.github/workflows/$file" -o "$TEMP_DIR/workflows/$file"; then
            print_success "Downloaded workflow: $file"
        else
            print_error "Failed to download workflow: $file"
            return 1
        fi
    done
    
    # Download action files
    for file in "${ACTION_FILES[@]}"; do
        mkdir -p "$TEMP_DIR/actions/$(dirname "$file")"
        if curl -s -f "$REPO_URL/.github/actions/$file" -o "$TEMP_DIR/actions/$file"; then
            print_success "Downloaded action: $file"
        else
            print_error "Failed to download action: $file"
            return 1
        fi
    done
    
    print_success "Download completed"
}

# Function to preserve user customizations
preserve_customizations() {
    local file="$1"
    local current_file=".github/workflows/$file"
    local new_file="$TEMP_DIR/workflows/$file"
    
    # Check if file has custom setup steps (for engineer bots)
    if [[ "$file" == "engineer-bot.yml" || "$file" == "engineer-fixes-bot.yml" ]]; then
        if [ -f "$current_file" ]; then
            # Extract user's setup steps between the insert comment markers
            local setup_steps
            setup_steps=$(sed -n '/# <!-- INSERT SETUP STEPS HERE -->/,/# <!-- END INSERT SETUP STEPS HERE -->/p' "$current_file" 2>/dev/null || true)
            
            if [ -n "$setup_steps" ] && [ "$setup_steps" != "# <!-- INSERT SETUP STEPS HERE -->" ]; then
                print_status "Preserving custom setup steps in $file"
                
                # Replace the placeholder in new file with preserved setup steps
                if command_exists perl; then
                    # Use perl for more reliable multi-line replacement
                    local escaped_steps
                    # shellcheck disable=SC2001 # Complex regex escaping requires sed
                    escaped_steps=$(echo "$setup_steps" | sed "s/[[\.*^$()+?{|]/\\\\&/g")
                    perl -i -pe "BEGIN{undef \$/;} s/# <!-- INSERT SETUP STEPS HERE -->/$escaped_steps/g" "$new_file"
                else
                    # Fallback to sed (less reliable but more portable)
                    local temp_file="${new_file}.tmp"
                    awk '
                        /# <!-- INSERT SETUP STEPS HERE -->/ {
                            while ((getline line < "'"$current_file"'") > 0) {
                                if (line ~ /# <!-- INSERT SETUP STEPS HERE -->/) {
                                    found_start = 1
                                    print line
                                    continue
                                }
                                if (found_start && line ~ /# <!-- END INSERT SETUP STEPS HERE -->/) {
                                    print line
                                    break
                                }
                                if (found_start) {
                                    print line
                                }
                            }
                            close("'"$current_file"'")
                            next
                        }
                        { print }
                    ' "$new_file" > "$temp_file" && mv "$temp_file" "$new_file"
                fi
                
                print_success "Custom setup steps preserved in $file"
            fi
        fi
    fi
}

# Function to compare files and show differences
compare_files() {
    print_status "Comparing files for changes..."
    local changes_found=false
    
    # Compare workflow files
    for file in "${WORKFLOW_FILES[@]}"; do
        local current_file=".github/workflows/$file"
        local new_file="$TEMP_DIR/workflows/$file"
        
        if [ -f "$current_file" ]; then
            # Preserve customizations before comparison
            preserve_customizations "$file"
            
            if ! diff -q "$current_file" "$new_file" >/dev/null 2>&1; then
                print_warning "Changes detected in workflow: $file"
                changes_found=true
                
                if [ "$1" = "--preview" ]; then
                    echo "--- Current version"
                    echo "+++ New version"
                    diff -u "$current_file" "$new_file" || true
                    echo ""
                fi
            else
                print_success "No changes in workflow: $file"
            fi
        else
            print_warning "New workflow file will be created: $file"
            changes_found=true
        fi
    done
    
    # Compare action files
    for file in "${ACTION_FILES[@]}"; do
        local current_file=".github/actions/$file"
        local new_file="$TEMP_DIR/actions/$file"
        
        if [ -f "$current_file" ]; then
            if ! diff -q "$current_file" "$new_file" >/dev/null 2>&1; then
                print_warning "Changes detected in action: $file"
                changes_found=true
                
                if [ "$1" = "--preview" ]; then
                    echo "--- Current version"
                    echo "+++ New version"
                    diff -u "$current_file" "$new_file" || true
                    echo ""
                fi
            else
                print_success "No changes in action: $file"
            fi
        else
            print_warning "New action file will be created: $file"
            changes_found=true
        fi
    done
    
    if [ "$changes_found" = false ]; then
        print_success "All files are up to date!"
        return 1
    fi
    
    return 0
}

# Function to apply updates
apply_updates() {
    print_status "Applying updates..."
    
    # Ensure directories exist
    mkdir -p .github/workflows
    mkdir -p .github/actions/claude-result-tracker
    
    # Update workflow files
    for file in "${WORKFLOW_FILES[@]}"; do
        local current_file=".github/workflows/$file"
        local new_file="$TEMP_DIR/workflows/$file"
        
        # Preserve customizations
        preserve_customizations "$file"
        
        cp "$new_file" "$current_file"
        print_success "Updated workflow: $file"
    done
    
    # Update action files
    for file in "${ACTION_FILES[@]}"; do
        local current_file=".github/actions/$file"
        local new_file="$TEMP_DIR/actions/$file"
        
        mkdir -p "$(dirname "$current_file")"
        cp "$new_file" "$current_file"
        print_success "Updated action: $file"
    done
    
    print_success "All updates applied successfully!"
}

# Function to cleanup temporary files
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Function to show rollback instructions
show_rollback_info() {
    echo ""
    print_status "Rollback Information:"
    echo "  If you need to rollback these changes, use:"
    echo "    cp -r $BACKUP_DIR/workflows/* .github/workflows/"
    echo "    cp -r $BACKUP_DIR/actions/* .github/actions/"
    echo ""
    print_warning "Backup location: $BACKUP_DIR"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --preview    Show what changes would be made without applying them"
    echo "  --help       Show this help message"
    echo ""
    echo "This script updates Machiners Platoon workflows and actions while preserving"
    echo "your custom setup steps and creating backups for safety."
}

# Main execution
main() {
    echo "🤖 Machiners Platoon Update Script"
    echo "=================================="
    echo ""
    
    # Parse command line arguments
    case "${1:-}" in
        --help|-h)
            show_usage
            exit 0
            ;;
        --preview)
            PREVIEW_MODE=true
            ;;
        "")
            PREVIEW_MODE=false
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
    
    # Set up cleanup trap
    trap cleanup EXIT
    
    # Execute update process
    check_prerequisites
    
    if [ "$PREVIEW_MODE" = true ]; then
        print_status "Running in preview mode - no changes will be made"
    else
        create_backup
    fi
    
    download_latest
    
    if compare_files "${1:-}"; then
        if [ "$PREVIEW_MODE" = true ]; then
            echo ""
            print_status "Preview complete. Run without --preview to apply changes."
        else
            echo ""
            read -p "Apply these updates? (y/N): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                apply_updates
                show_rollback_info
                print_success "Update completed successfully!"
                echo ""
                print_status "Next steps:"
                echo "  1. Review the changes in your repository"
                echo "  2. Test your workflows to ensure they work correctly"
                echo "  3. Update any language-specific setup steps if needed"
            else
                print_status "Update cancelled by user"
            fi
        fi
    else
        print_success "No updates needed - all files are current!"
    fi
}

# Run main function
main "$@"