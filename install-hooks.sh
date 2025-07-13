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

# Copy post-commit hook
cp "$SCRIPT_DIR/post-commit" "$HOOK_DIR/post-commit"
chmod +x "$HOOK_DIR/post-commit"

echo "Git hooks installed successfully!"
echo "The following hooks are now active:"
echo "- pre-commit: Runs RuboCop and Brakeman before each commit"
echo "- post-commit: Performs actions after each commit"
