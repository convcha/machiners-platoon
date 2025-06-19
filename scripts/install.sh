#!/bin/bash

#==============================================================================
# Machiners Platoon Installation Script
#==============================================================================
#
# PURPOSE:
#   This script installs the complete Machiners Platoon automated development
#   agent squadron into a GitHub repository. It sets up 5 specialized AI bots
#   that work together through repository dispatch events to implement a 
#   complete development workflow from issue creation to pull request deployment.
#
# DESCRIPTION:
#   The Machiners Platoon consists of:
#   - Product Manager Bot: Enhances issues and routes to appropriate bots
#   - System Architect Bot: Creates technical implementation plans
#   - Engineer Bot: Implements features and creates PRs
#   - Architect Review Bot: Reviews PRs with cycle protection
#   - Engineer Fixes Bot: Addresses review feedback
#
# PREREQUISITES:
#   - bash shell (version 4.0 or higher recommended)
#   - curl command available in PATH
#   - Internet connectivity to download files from GitHub
#   - Write permissions to create .github/ directory structure
#   - Running from the root directory of your Git repository
#
# USAGE:
#   ./scripts/install.sh
#
#   OR
#
#   bash scripts/install.sh
#
# PERMISSIONS:
#   This script requires write permissions to create directories and files
#   under the .github/ folder in your repository root.
#
# EXIT CODES:
#   0 - Installation completed successfully
#   1 - Installation failed (due to set -e error handling)
#
# AUTHOR:
#   Machiners Platoon Project
#
# VERSION:
#   1.0.0
#
#==============================================================================

# ERROR HANDLING STRATEGY:
# Enable strict error handling - script will exit immediately if any command
# returns a non-zero exit status. This ensures that installation failures
# are caught early and don't result in a partially installed system.
set -e

echo "> Installing Machiners Platoon..."

#==============================================================================
# DIRECTORY STRUCTURE SETUP
#==============================================================================
# Create the required directory structure for GitHub Actions workflows and
# custom actions. The -p flag ensures parent directories are created if they
# don't exist and prevents errors if directories already exist.

echo "> Creating directories..."

# Create the workflows directory to store GitHub Actions workflow files
# This directory will contain all the bot workflow YAML files
mkdir -p .github/workflows

# Create the custom actions directory for the claude-result-tracker action
# This action tracks bot execution costs, duration, and token usage
mkdir -p .github/actions/claude-result-tracker

#==============================================================================
# WORKFLOW FILES DOWNLOAD
#==============================================================================
# Download all GitHub Actions workflow files that define the bot behaviors.
# Each workflow implements a specialized bot in the development pipeline.
# The -s flag suppresses curl's progress output for cleaner installation logs.

echo "> Downloading workflow files..."

# Download Product Manager Bot workflow
# This bot enhances issues with detailed requirements and routes them to 
# appropriate downstream bots for implementation or architectural planning
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/product-manager-bot.yml -o .github/workflows/product-manager-bot.yml

# Download System Architect Bot workflow  
# This bot creates technical implementation plans and architectural designs
# for complex features that require upfront planning and design decisions
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/system-architect-bot.yml -o .github/workflows/system-architect-bot.yml

# Download Engineer Bot workflow
# This bot implements features according to architectural plans, creates
# pull requests, and handles the core development work of the pipeline
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/engineer-bot.yml -o .github/workflows/engineer-bot.yml

# Download Architect Review Bot workflow
# This bot reviews pull requests from an architectural perspective, ensuring
# code quality, design patterns, and technical standards are maintained
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/architect-review-bot.yml -o .github/workflows/architect-review-bot.yml

# Download Engineer Fixes Bot workflow
# This bot addresses review feedback and implements requested changes to
# pull requests, completing the development cycle with iterative improvements
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/engineer-fixes-bot.yml -o .github/workflows/engineer-fixes-bot.yml

#==============================================================================
# CUSTOM ACTION FILES DOWNLOAD
#==============================================================================
# Download custom action files that provide specialized functionality used
# by the workflow bots. These actions extend GitHub Actions capabilities
# with project-specific features.

echo "> Downloading custom action files..."

# Download claude-result-tracker custom action
# This action tracks and reports bot execution metrics including:
# - Execution duration and performance timing
# - AI token usage (input/output tokens)
# - Cost calculations for transparency and budget management
# - Standardized reporting format for cost control
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/actions/claude-result-tracker/action.yml -o .github/actions/claude-result-tracker/action.yml

#==============================================================================
# INSTALLATION COMPLETION
#==============================================================================
# Installation successful! The Machiners Platoon is now ready for use.
# 
# NEXT STEPS:
# 1. Set up required GitHub secrets in your repository:
#    - ANTHROPIC_API_KEY: Your Anthropic API key for Claude access
#    - GH_PERSONAL_ACCESS_TOKEN: GitHub token with appropriate permissions
# 
# 2. Configure repository variables (optional):
#    - MACHINERS_PLATOON_TRIGGER_LABEL: Custom trigger label (default: "🤖 Machiners Platoon")
#    - MACHINERS_PLATOON_LANG: Language for bot responses (default: "English")
# 
# 3. Create an issue with the trigger label to test the installation
# 
# For more information, see the project documentation at:
# https://github.com/convcha/machiners-platoon

echo "> Installation complete!"
