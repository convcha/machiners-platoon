#!/bin/bash

# Machiners Platoon Update Script
# This script updates GitHub Actions workflows and actions by comparing with the reference repository
# while preserving language-specific setup steps

set -e

echo "> Machiners Platoon Update Script"
echo "> This script will update your GitHub Actions workflows and actions"
echo

# Check if Claude Code CLI is available
if ! command -v claude &> /dev/null; then
    echo "Error: Claude Code CLI is not installed or not in PATH"
    echo "Please install Claude Code CLI first: https://claude.ai/code"
    exit 1
fi

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "Error: This script must be run from the root of a git repository"
    exit 1
fi

echo "> Checking for existing GitHub Actions..."
if [ ! -d ".github" ]; then
    echo "Warning: No .github directory found. Creating it..."
    mkdir -p .github/workflows
    mkdir -p .github/actions
fi

echo "> Running Claude Code to update GitHub Actions workflows and actions..."
echo "> This may take a few moments..."
echo

# Execute the Claude Code command
claude "Properly compare my current GitHub Actions in .github/workflows/ and .github/actions/ with the latest version from https://github.com/convcha/machiners-platoon and update them while preserving my language-specific setup steps"

echo
echo "> Update process completed!"
echo "> Please review the changes made to your GitHub Actions files"
echo "> If you're satisfied with the changes, commit them to your repository"