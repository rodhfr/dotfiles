#!/usr/bin/env bash

COMMIT_MSG="auto committed"

# Colors
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RED="\033[1;31m"
RESET="\033[0m"

# Symbols
CHECK="✅"
INFO="ℹ️"
WARN="⚠️"
PUSH="📤"

# Function to apply stow
apply_stow() {
  local repo_path=$1
  local description=$2

  echo -e "${BLUE}==============================${RESET}"
  echo -e "${INFO} Applying stow for $description in $repo_path"
  echo -e "${BLUE}==============================${RESET}"

  cd "$repo_path" || {
    echo -e "${RED}${WARN} Failed to enter $repo_path${RESET}"
    exit 1
  }

  stow --adopt .
  echo -e "${GREEN}${CHECK} Stow applied for $description${RESET}"
}

# Function to commit and push changes in a git repository
git_update() {
  local repo_path=$1
  local description=$2

  echo -e "${BLUE}==============================${RESET}"
  echo -e "${INFO} Updating $description in $repo_path"
  echo -e "${BLUE}==============================${RESET}"

  cd "$repo_path" || {
    echo -e "${RED}${WARN} Failed to enter $repo_path${RESET}"
    exit 1
  }

  echo -e "${YELLOW}${INFO} Staging changes...${RESET}"
  git add .

  if git diff --cached --quiet; then
    echo -e "${YELLOW}${WARN} No changes detected for $description. Nothing to commit or push.${RESET}"
  else
    echo -e "${GREEN}${INFO} Committing changes...${RESET}"
    git commit -m "$COMMIT_MSG"

    echo -e "${GREEN}${PUSH} Pushing $description to remote repository...${RESET}"
    git push

    echo -e "${GREEN}${CHECK} $description synced, committed, and pushed successfully.${RESET}"
  fi
  echo ""
}

# Update dotfiles and dotfiles_secret (stow + git)
apply_stow "$HOME/dotfiles" "dotfiles"
git_update "$HOME/dotfiles" "dotfiles"

apply_stow "$HOME/dotfiles_secret" "dotfiles secrets"
git_update "$HOME/dotfiles_secret" "dotfiles secrets"

# Update journal (git only)
git_update "$HOME/jour" "journal"
