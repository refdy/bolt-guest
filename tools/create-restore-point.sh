#!/usr/bin/env bash
set -e

echo "== Current repository =="

git status --short
git branch -vv

STAMP=$(date +%Y%m%d-%H%M%S)
TAG="restore-$STAMP"

git tag "$TAG"

echo
echo "Restore tag created:"
echo "  $TAG"

echo
echo "Pushing tag..."
git push origin "$TAG"

echo
echo "Done."
