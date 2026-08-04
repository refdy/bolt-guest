#!/usr/bin/env bash
set -euo pipefail

echo "=== Restore Point ==="
git tag -f restore-before-secret-cleanup-$(date +%Y%m%d-%H%M%S)

echo "=== Backup Branch ==="
git branch backup-before-secret-cleanup-$(date +%Y%m%d-%H%M%S)

echo "=== Rewriting History ==="

git filter-branch --force \
--tree-filter '
if [ -f .env.example ]; then
    sed -Ei \
      "s#(OPENROUTER_API_KEY=).*#\1your_openrouter_api_key_here#g" \
      .env.example
fi
' \
--tag-name-filter cat \
-- --all

echo "=== Cleanup ==="

rm -rf .git/refs/original
git reflog expire --expire=now --all
git gc --prune=now --aggressive

echo
echo "=== Verification ==="

git log --all -- .env.example --oneline

echo
echo "Searching for possible OpenRouter secrets..."

if git grep -nE "sk-or-v1-|OPENROUTER_API_KEY=.*sk-" $(git rev-list --all); then
    echo
    echo "WARNING: Secret pattern still exists."
    exit 1
fi

echo
echo "History cleaned."

echo
echo "Force push:"
echo "git push --force --all origin"
echo "git push --force --tags origin"
