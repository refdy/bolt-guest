#!/usr/bin/env bash
set -e

echo "========== DEVELOPMENT REVIEW =========="
echo

echo "[1] Branch"
git branch -vv
echo

echo "[2] Repository Status"
git status --short
echo

echo "[3] Last Commit"
git log --oneline --decorate -3
echo

echo "[4] Remote"
git remote -v
echo

echo "[5] Latest Restore Tags"
git tag --sort=-creatordate | grep '^restore-' | head -5 || true
echo

echo "[6] Build"
if [ -d build ]; then
    echo "OK : build exists"
else
    echo "WARNING : build not found"
fi
echo

echo "[7] Repository State"
if [ -z "$(git status --porcelain)" ]; then
    echo "Repository clean."
else
    echo "Repository has pending changes:"
    git status --short
fi

echo
echo "========== READY FOR DEVELOPMENT =========="
