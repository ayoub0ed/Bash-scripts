#!/bin/bash

set -euo pipefail

# Validate arguments
if [ $# -ne 2 ]; then
  echo "Usage: $0 <path_to_commit> <commit_message>"
  exit 1
fi

path_to_commit="$1"
commit_message="Update $1"

# Check if the path exists
if [ ! -e "$path_to_commit" ]; then
  echo "Path $path_to_commit does not exist"
  exit 1
fi

# Check if the path is already committed
if git log --pretty=format: --full-history --name-only | grep "$path_to_commit" > /dev/null; then
  # If the path is already committed, use git commit --amend to update the commit
  git add -A "$path_to_commit"
  CURRENT_MESSAGE="$(git log -1 --pretty=%B)"

  ${EDITOR:-Vim} "$(git rev-parse --git-dir)/COMMIT_EDITMSG"
  NEW_MESSAGE="$(cat "$(git rev-parse --git-dir)/COMMIT_EDITMSG")"

  git commit --amend --message="$NEW_MESSAGE"
  git pull --rebase
  git push --force
else
  # If the path is not already committed, add the path to the staging area
  git add -A "$path_to_commit"
  git commit -m "$commit_message"
  git pull --rebase
  git push -u origin main
fi

# Exit with success status code
exit 0
