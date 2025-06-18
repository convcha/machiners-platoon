#!/bin/bash

# Machiners Platoon Update Script
# This script updates existing GitHub Actions workflows and custom actions to the latest version

set -e

# Parse command line arguments
FORCE_UPDATE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE_UPDATE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--force]"
            echo "  --force    Update files even if they are identical"
            exit 1
            ;;
    esac
done

echo "> Updating Machiners Platoon..."

# Check if Machiners Platoon is installed
echo "> Checking for existing installation..."
if [ ! -f ".github/workflows/product-manager-bot.yml" ] && [ ! -f ".github/workflows/system-architect-bot.yml" ] && [ ! -f ".github/workflows/engineer-bot.yml" ]; then
    echo "> Error: Machiners Platoon does not appear to be installed."
    echo "> Please run the install.sh script first to install Machiners Platoon."
    exit 1
fi

echo "> Existing installation found. Proceeding with update..."

# Create required directories (in case they don't exist)
echo "> Ensuring directories exist..."
mkdir -p .github/workflows
mkdir -p .github/actions/claude-result-tracker

# Function to download file with comparison
download_file() {
    local url=$1
    local path=$2
    local temp_file=$(mktemp)
    
    echo ">   Downloading $path..."
    
    if curl -sf "$url" -o "$temp_file"; then
        if [ -f "$path" ] && [ "$FORCE_UPDATE" = false ]; then
            if cmp -s "$temp_file" "$path"; then
                echo ">   $path is already up to date."
                rm "$temp_file"
                return 0
            fi
        fi
        
        mv "$temp_file" "$path"
        echo ">   $path updated successfully."
    else
        rm -f "$temp_file"
        echo ">   Error: Failed to download $path"
        return 1
    fi
}

# Download workflow files
echo "> Updating workflow files..."
download_file "https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/product-manager-bot.yml" ".github/workflows/product-manager-bot.yml" || exit 1
download_file "https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/system-architect-bot.yml" ".github/workflows/system-architect-bot.yml" || exit 1
download_file "https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/engineer-bot.yml" ".github/workflows/engineer-bot.yml" || exit 1
download_file "https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/architect-review-bot.yml" ".github/workflows/architect-review-bot.yml" || exit 1
download_file "https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/engineer-fixes-bot.yml" ".github/workflows/engineer-fixes-bot.yml" || exit 1

# Download custom action files
echo "> Updating custom action files..."
download_file "https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/actions/claude-result-tracker/action.yml" ".github/actions/claude-result-tracker/action.yml" || exit 1

echo "> Update complete!"
echo "> All Machiners Platoon components have been updated to the latest version."