#!/usr/bin/env bash

# Script to install Git hooks

set -e

HOOK_DIR=$(git rev-parse --git-dir)/hooks
SCRIPT_DIR=$(dirname "$0")

echo "Installing Git hooks..."

# Create hooks directory if it doesn't exist
mkdir -p "$HOOK_DIR"

# Copy pre-commit hook
cp "$SCRIPT_DIR/pre-commit" "$HOOK_DIR/pre-commit"
chmod +x "$HOOK_DIR/pre-commit"

echo "Git hooks installed successfully!"
echo "The following hooks are now active:"
echo "- pre-commit: Runs RuboCop and Brakeman before each commit"