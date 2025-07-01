#!/bin/bash

#==============================================================================
# Machiners Platoon Installation Script
#==============================================================================
#
# DESCRIPTION:
#   This script installs the complete Machiners Platoon system - a GitHub 
#   Actions-powered automated development agent squadron that implements a 
#   complete development workflow from issue creation to pull request deployment.
#   
#   The system consists of 5 specialized AI bots that work together through 
#   repository dispatch events to handle the entire development lifecycle.
#
# USAGE:
#   bash scripts/install.sh
#   
#   Run this script from the root directory of your GitHub repository to 
#   install all required workflow files and custom actions.
#
# PREREQUISITES:
#   - bash (version 4.0 or higher recommended)
#   - curl (for downloading files from GitHub)
#   - write permissions to the current directory
#   - internet connection to download files from GitHub
#   - .git directory (must be run in a Git repository)
#
# SYSTEM REQUIREMENTS:
#   - GitHub repository with Actions enabled
#   - ANTHROPIC_API_KEY secret configured in repository settings
#   - GH_PERSONAL_ACCESS_TOKEN secret configured in repository settings
#
# POST-INSTALLATION SETUP:
#   After running this script, configure the following in your repository:
#   1. Set ANTHROPIC_API_KEY in Settings → Secrets and variables → Actions
#   2. Set GH_PERSONAL_ACCESS_TOKEN in Settings → Secrets and variables → Actions
#   3. Optionally set MACHINERS_PLATOON_TRIGGER_LABEL variable (default: "🤖 Machiners Platoon")
#   4. Optionally set MACHINERS_PLATOON_LANG variable for language support (default: "English")
#   5. Optionally set MACHINERS_PLATOON_BASE_BRANCH_PREFIX for base branch configuration
#
# SUCCESS INDICATORS:
#   - All echo statements show progress without errors
#   - .github/workflows/ directory contains 5 workflow files
#   - .github/actions/ directory contains 2 custom action subdirectories
#   - "Installation complete!" message appears at the end
#
#==============================================================================

# Enable strict error handling - script will exit immediately if any command fails
# This ensures installation integrity and prevents partial installations
set -e

echo "> Installing Machiners Platoon..."

# STEP 1: Create Required Directory Structure
# ==========================================
# Create the necessary directory structure for GitHub Actions workflows and custom actions
# - .github/workflows: Contains the 5 bot workflow files
# - .github/actions/claude-result-tracker: Custom action for tracking bot execution costs and results
# - .github/actions/validate-base-branch: Custom action for validating base branch configuration
echo "> Creating directories..."
mkdir -p .github/workflows
mkdir -p .github/actions/claude-result-tracker
mkdir -p .github/actions/validate-base-branch

# STEP 2: Download Core Bot Workflow Files
# ========================================
# Download the 5 specialized AI bot workflows that form the complete development pipeline:
echo "> Downloading workflow files..."

# Product Manager Bot - Enhances issues and routes them to appropriate bots
# Triggered by: Issues with the trigger label
# Function: Analyzes and enhances issue descriptions, determines if architectural planning is needed
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/product-manager-bot.yml -o .github/workflows/product-manager-bot.yml

# System Architect Bot - Creates technical implementation plans
# Triggered by: Repository dispatch event "🏛️ Architecture Review"
# Function: Analyzes requirements and creates detailed technical architecture plans
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/system-architect-bot.yml -o .github/workflows/system-architect-bot.yml

# Engineer Bot - Implements features and creates pull requests
# Triggered by: Repository dispatch event "🛠️ Lets Build This"
# Function: Implements code changes, creates branches, writes tests, and creates pull requests
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/engineer-bot.yml -o .github/workflows/engineer-bot.yml

# Architect Review Bot - Reviews pull requests with cycle protection
# Triggered by: Repository dispatch event "🏗️ Architect PR Review"
# Function: Performs code reviews on pull requests with automatic cycle limit protection
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/architect-review-bot.yml -o .github/workflows/architect-review-bot.yml

# Engineer Fixes Bot - Addresses review feedback and implements requested changes
# Triggered by: Repository dispatch event "🔧 Fixes Required"
# Function: Analyzes review feedback and implements necessary code changes
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/engineer-fixes-bot.yml -o .github/workflows/engineer-fixes-bot.yml

# STEP 3: Download Custom Action Files
# ====================================
# Download custom actions that provide specialized functionality for the bot system:
echo "> Downloading custom action files..."

# Claude Result Tracker - Tracks bot execution costs, duration, and token usage
# Purpose: Provides cost transparency and execution metrics for each bot run
# Used by: All bot workflows to track and report execution statistics
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/actions/claude-result-tracker/action.yml -o .github/actions/claude-result-tracker/action.yml

# Validate Base Branch - Validates base branch configuration for feature branches
# Purpose: Ensures proper base branch handling when MACHINERS_PLATOON_BASE_BRANCH_PREFIX is configured
# Used by: Bot workflows that need to determine the correct base branch for operations
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/actions/validate-base-branch/action.yml -o .github/actions/validate-base-branch/action.yml

# STEP 4: Installation Complete
# =============================
# All files have been successfully downloaded and the directory structure is in place
# The Machiners Platoon system is now ready for configuration and use
echo "> Installation complete!"
echo ""
echo "Next steps:"
echo "1. Configure ANTHROPIC_API_KEY in repository secrets"
echo "2. Configure GH_PERSONAL_ACCESS_TOKEN in repository secrets"
echo "3. Create an issue with the '🤖 Machiners Platoon' label to test the system"
echo "4. Review the documentation for additional configuration options"
