#!/bin/bash

# GitHub Repository Setup Script
# This script helps you push the TaskCollab project to GitHub

echo "🚀 TaskCollab - GitHub Setup Script"
echo "===================================="
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install git first."
    exit 1
fi

echo "This script will help you push this project to GitHub."
echo ""

# Initialize git if not already done
if [ ! -d .git ]; then
    echo "📦 Initializing git repository..."
    git init
    echo "✅ Git initialized"
else
    echo "✅ Git repository already initialized"
fi

# Create .gitignore if it doesn't exist
if [ ! -f .gitignore ]; then
    echo "❌ .gitignore not found!"
    exit 1
fi

# Add all files
echo ""
echo "📝 Staging files..."
git add .

# Initial commit
echo ""
echo "💾 Creating initial commit..."
git commit -m "Initial commit: TaskCollab - Production-ready task management platform

Features:
- Ruby on Rails 7.1 API backend
- React TypeScript frontend
- JWT authentication
- Role-based authorization with Pundit
- Comprehensive RSpec test suite
- Background jobs with Sidekiq
- Docker support
- Production-ready configuration

Built as a code sample demonstrating senior-level engineering practices."

echo "✅ Initial commit created"

# Prompt for GitHub repository URL
echo ""
echo "📋 Next steps:"
echo "1. Create a new repository on GitHub (https://github.com/new)"
echo "2. Name it something like 'task-collab-platform' or 'mlh-code-sample'"
echo "3. Do NOT initialize it with README, .gitignore, or license"
echo "4. Copy the repository URL"
echo ""
read -p "Enter your GitHub repository URL (e.g., https://github.com/username/repo.git): " repo_url

if [ -z "$repo_url" ]; then
    echo "❌ No URL provided. Exiting."
    exit 1
fi

# Add remote
echo ""
echo "🔗 Adding remote repository..."
git remote add origin "$repo_url"
echo "✅ Remote added"

# Set main branch
echo ""
echo "🌿 Setting main branch..."
git branch -M main
echo "✅ Main branch set"

# Push to GitHub
echo ""
echo "🚀 Pushing to GitHub..."
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Successfully pushed to GitHub!"
    echo ""
    echo "🎉 Your repository is now live at:"
    echo "$repo_url"
    echo ""
    echo "📝 Next steps:"
    echo "1. Add a nice description to your GitHub repo"
    echo "2. Add topics: ruby, rails, react, typescript, task-management"
    echo "3. Update the README with your actual GitHub URL"
    echo "4. Share the repository URL in your application"
    echo ""
else
    echo ""
    echo "❌ Push failed. Please check:"
    echo "- Your GitHub credentials"
    echo "- The repository URL is correct"
    echo "- You have write access to the repository"
    echo ""
    echo "You can manually push with:"
    echo "  git push -u origin main"
fi
