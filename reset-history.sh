#!/usr/bin/env bash
set -e

echo "== Restore point =="
git tag backup-before-reset-$(date +%Y%m%d-%H%M%S)

CURRENT_BRANCH=$(git branch --show-current)

echo "Current branch: $CURRENT_BRANCH"

echo "== Create orphan branch =="

git checkout --orphan clean-history

git add -A

git commit -m "Initial clean import"

git branch -D "$CURRENT_BRANCH"

git branch -m "$CURRENT_BRANCH"

echo
echo "History after reset:"
git log --oneline

echo
echo "Verify secrets..."

FOUND=0
for c in $(git rev-list --all); do
    if git show "$c:.env.example" >/dev/null 2>&1; then
        if git show "$c:.env.example" | grep -Eq 'sk-or-v1-|OPENROUTER_API_KEY=.*sk-'; then
            echo "Secret still found in $c"
            FOUND=1
        fi
    fi
done

if [ "$FOUND" = "1" ]; then
    echo
    echo "FAILED"
    exit 1
fi

echo
echo "SUCCESS"

echo
echo "Force push with:"
echo "git push --force origin $CURRENT_BRANCH"
