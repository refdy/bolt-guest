#!/usr/bin/env bash
set -e

echo "===== Branch ====="
git branch -vv

echo
echo "===== Tags ====="
git tag | tail

echo
echo "===== Secret scan on ALL commits ====="

FOUND=0

for c in $(git rev-list --all); do
    if git show "$c:.env.example" >/dev/null 2>&1; then
        if git show "$c:.env.example" | grep -Eq 'sk-or-v1-|OPENROUTER_API_KEY=.*sk-'; then
            echo
            echo "SECRET FOUND"
            echo "Commit : $c"
            git log --oneline -1 "$c"
            FOUND=1
        fi
    fi
done

echo
echo "===== refs/original ====="
find .git/refs/original -type f 2>/dev/null || true

echo
echo "===== replace refs ====="
find .git/refs/replace -type f 2>/dev/null || true

echo
if [ "$FOUND" -eq 0 ]; then
    echo "OK - No OpenRouter key found in reachable history."
else
    echo "FAILED - Secret still exists."
fi
