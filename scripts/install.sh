#!/bin/bash

# Machiners Platoon Installation Script
# This script installs GitHub Actions workflows and custom actions

set -e

echo "> Installing Machiners Platoon..."

# Create required directories
echo "> Creating directories..."
mkdir -p .github/workflows
mkdir -p .github/actions/claude-result-tracker
mkdir -p .github/actions/validate-base-branch

# Download workflow files
echo "> Downloading workflow files..."
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/product-manager-bot.yml -o .github/workflows/product-manager-bot.yml
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/system-architect-bot.yml -o .github/workflows/system-architect-bot.yml
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/engineer-bot.yml -o .github/workflows/engineer-bot.yml
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/architect-review-bot.yml -o .github/workflows/architect-review-bot.yml
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/workflows/engineer-fixes-bot.yml -o .github/workflows/engineer-fixes-bot.yml

# Download custom action files
echo "> Downloading custom action files..."
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/actions/claude-result-tracker/action.yml -o .github/actions/claude-result-tracker/action.yml
curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/main/.github/actions/validate-base-branch/action.yml -o .github/actions/validate-base-branch/action.yml

echo "> Installation complete!"
