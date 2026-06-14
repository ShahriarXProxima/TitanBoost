#!/bin/bash
# TitanBoost GitHub Upload & Installation Guide

echo "╔═══════════════════════════════════════════════════════╗"
echo "║   TitanBoost - GitHub Upload & Installation Guide    ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""

echo "════════════════════════════════════════════════════════"
echo "PART 1: UPLOAD TO GITHUB (Do This Once)"
echo "════════════════════════════════════════════════════════"
echo ""
echo "Step 1: Install Git (if you don't have it)"
echo "  On Linux/Mac:"
echo "    brew install git  # Mac"
echo "    sudo apt install git  # Ubuntu"
echo ""
echo "Step 2: Navigate to TitanBoost folder"
echo "  cd /path/to/TitanBoost"
echo ""
echo "Step 3: Initialize Git"
echo "  git init"
echo "  git config user.name 'Your Name'"
echo "  git config user.email 'your.email@example.com'"
echo ""
echo "Step 4: Add files"
echo "  git add ."
echo ""
echo "Step 5: First commit"
echo "  git commit -m 'Initial commit: TitanBoost Termux Edition v1.0.0'"
echo ""
echo "Step 6: Create GitHub repo"
echo "  1. Go to github.com"
echo "  2. Click '+' (top right) > New repository"
echo "  3. Name: TitanBoost"
echo "  4. Description: Android Performance Optimization for Termux"
echo "  5. Choose Public or Private"
echo "  6. Click 'Create repository'"
echo ""
echo "Step 7: Connect to GitHub"
echo "  git branch -M main"
echo "  git remote add origin https://github.com/YOUR-USERNAME/TitanBoost.git"
echo "  git push -u origin main"
echo ""
echo "  (Replace YOUR-USERNAME with your GitHub username)"
echo ""
echo "Done! ✓ Your repo is now on GitHub"
echo ""
echo ""
echo "════════════════════════════════════════════════════════"
echo "PART 2: INSTALL FROM GITHUB (Anyone can do this)"
echo "════════════════════════════════════════════════════════"
echo ""
echo "On Android (Termux):"
echo ""
echo "  Method 1: Direct Clone"
echo "  $ pkg install git"
echo "  $ git clone https://github.com/YOUR-USERNAME/TitanBoost.git"
echo "  $ cd TitanBoost"
echo "  $ sh install-termux.sh"
echo "  $ titanboost"
echo ""
echo "  Method 2: Download ZIP (No git needed)"
echo "  1. Go to: https://github.com/YOUR-USERNAME/TitanBoost"
echo "  2. Click green 'Code' button"
echo "  3. Click 'Download ZIP'"
echo "  4. Extract ZIP in Termux"
echo "  5. cd TitanBoost"
echo "  6. sh install-termux.sh"
echo "  7. titanboost"
echo ""
echo ""
echo "════════════════════════════════════════════════════════"
echo "COMPLETE INSTALLATION COMMANDS (Copy-Paste Ready)"
echo "════════════════════════════════════════════════════════"
echo ""
echo "--- FOR UPLOADING (On PC/Mac) ---"
echo ""
cat << 'UPLOAD'
cd /path/to/TitanBoost
git init
git config user.name "Your Name"
git config user.email "your@email.com"
git add .
git commit -m "Initial commit: TitanBoost Termux Edition v1.0.0"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/TitanBoost.git
git push -u origin main
UPLOAD

echo ""
echo "--- FOR INSTALLING (On Termux/Android) ---"
echo ""
cat << 'INSTALL'
# Method 1: Clone with Git
pkg install git
git clone https://github.com/YOUR-USERNAME/TitanBoost.git
cd TitanBoost
sh install-termux.sh
titanboost

# Method 2: Download ZIP (no git)
# Download https://github.com/YOUR-USERNAME/TitanBoost/archive/refs/heads/main.zip
# Extract and run:
cd TitanBoost-main
sh install-termux.sh
titanboost
INSTALL

echo ""
echo "════════════════════════════════════════════════════════"
echo "SHARE YOUR REPO LINK:"
echo "════════════════════════════════════════════════════════"
echo ""
echo "After uploading, share this link:"
echo "  https://github.com/YOUR-USERNAME/TitanBoost"
echo ""
echo "Others can install with:"
echo "  git clone https://github.com/YOUR-USERNAME/TitanBoost.git"
echo "  cd TitanBoost && sh install-termux.sh"
echo ""

