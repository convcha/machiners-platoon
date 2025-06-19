#!/bin/bash

#==============================================================================
# MACHINERS PLATOON INSTALLATION SCRIPT
#==============================================================================
#
# DESCRIPTION:
#   This script installs the Machiners Platoon automated development agent 
#   squadron into your GitHub repository. It sets up 5 specialized AI bots
#   that work together to implement a complete development workflow from 
#   issue creation to pull request deployment.
#
# PREREQUISITES:
#   - Bash shell environment
#   - curl command available
#   - Internet connection for downloading files
#   - Write permissions to .github directory
#   - GitHub repository with proper secrets configured:
#     * ANTHROPIC_API_KEY - Your Anthropic API key for Claude
#     * GH_PERSONAL_ACCESS_TOKEN - GitHub token with repo permissions
#
# USAGE:
#   ./scripts/install.sh
#   
#   Or from repository root:
#   bash scripts/install.sh
#
# POST-INSTALLATION:
#   After running this script, you need to:
#   1. Configure repository secrets (ANTHROPIC_API_KEY, GH_PERSONAL_ACCESS_TOKEN)
#   2. Set repository variables if desired:
#      - MACHINERS_PLATOON_TRIGGER_LABEL (default: "🤖 Machiners Platoon")
#      - MACHINERS_PLATOON_LANG (default: "English")
#      - MACHINERS_PLATOON_BASE_BRANCH_PREFIX (optional)
#   3. Create an issue with the trigger label to test the system
#
# TROUBLESHOOTING:
#   - If curl fails: Check internet connection and GitHub repository access
#   - If mkdir fails: Ensure write permissions to repository directory
#   - If workflows don't trigger: Verify secrets are configured correctly
#   - For permission errors: Check that GH_PERSONAL_ACCESS_TOKEN has repo scope
#
#==============================================================================

# Enable strict error handling - script will exit immediately if any command fails
# This ensures partial installations don't leave the repository in an inconsistent state
set -e

echo "> Installing Machiners Platoon..."
echo "  Setting up automated development agent squadron..."

#==============================================================================
# DIRECTORY SETUP
#==============================================================================
# Create the required GitHub Actions directory structure
# .github/workflows: Contains the main bot workflow files
# .github/actions/claude-result-tracker: Contains custom action for cost tracking
echo "> Creating directories..."
echo "  - .github/workflows (for bot workflow files)"
echo "  - .github/actions/claude-result-tracker (for cost tracking action)"
mkdir -p .github/workflows
mkdir -p .github/actions/claude-result-tracker

#==============================================================================
# BOT WORKFLOW INSTALLATION
#==============================================================================
# Download the 5 specialized bot workflows that form the development pipeline:
echo "> Downloading bot workflow files..."

# Product Manager Bot - Enhances issues and routes to appropriate bots
# Triggered by: Issues with the trigger label
# Function: Analyzes and enhances issue requirements, creates architectural decisions
echo "  - product-manager-bot.yml (enhances issues and routes tasks)"
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/product-manager-bot.yml -o .github/workflows/product-manager-bot.yml

# System Architect Bot - Creates technical implementation plans  
# Triggered by: Repository dispatch event "🏛️ Architecture Review"
# Function: Designs technical architecture and implementation strategies
echo "  - system-architect-bot.yml (creates technical implementation plans)"
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/system-architect-bot.yml -o .github/workflows/system-architect-bot.yml

# Engineer Bot - Implements features and creates pull requests
# Triggered by: Repository dispatch event "🛠️ Lets Build This"  
# Function: Writes code, implements features, creates PRs with comprehensive testing
echo "  - engineer-bot.yml (implements features and creates PRs)"
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/engineer-bot.yml -o .github/workflows/engineer-bot.yml

# Architect Review Bot - Reviews PRs with cycle protection
# Triggered by: Repository dispatch event "🏗️ Architect PR Review"
# Function: Performs code reviews, provides feedback, manages review cycles
echo "  - architect-review-bot.yml (reviews PRs with cycle protection)"
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/architect-review-bot.yml -o .github/workflows/architect-review-bot.yml

# Engineer Fixes Bot - Addresses review feedback and implements changes
# Triggered by: Repository dispatch event "🔧 Fixes Required"
# Function: Implements fixes based on review feedback, updates PRs
echo "  - engineer-fixes-bot.yml (addresses review feedback)"
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/engineer-fixes-bot.yml -o .github/workflows/engineer-fixes-bot.yml

#==============================================================================
# CUSTOM ACTION INSTALLATION  
#==============================================================================
# Download the custom action for tracking bot execution costs and performance
# This action provides transparency into AI usage costs and execution metrics
echo "> Downloading custom action files..."
echo "  - claude-result-tracker/action.yml (tracks bot costs and performance)"
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/actions/claude-result-tracker/action.yml -o .github/actions/claude-result-tracker/action.yml

#==============================================================================
# INSTALLATION COMPLETE
#==============================================================================
echo "> Installation complete!"
echo ""
echo "🎉 Machiners Platoon has been successfully installed!"
echo ""
echo "📋 NEXT STEPS:"
echo "   1. Configure repository secrets in Settings → Secrets and variables → Actions:"
echo "      • ANTHROPIC_API_KEY - Your Anthropic API key"
echo "      • GH_PERSONAL_ACCESS_TOKEN - GitHub token with repo permissions"
echo ""
echo "   2. Optional: Configure repository variables for customization:"
echo "      • MACHINERS_PLATOON_TRIGGER_LABEL (default: '🤖 Machiners Platoon')"
echo "      • MACHINERS_PLATOON_LANG (default: 'English')"
echo "      • MACHINERS_PLATOON_BASE_BRANCH_PREFIX (for custom base branches)"
echo ""
echo "   3. Test the system by creating an issue with the trigger label"
echo ""
echo "📖 For detailed documentation, see: https://github.com/convcha/machiners-platoon"
