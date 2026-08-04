#!/usr/bin/env bash
set -e

echo "========== START DEVELOPMENT SESSION =========="
echo

echo "[1/3] Review repository..."
./tools/review-session.sh

echo
echo "[2/3] Create restore point..."
./tools/create-restore-point.sh

echo
echo "[3/3] Repository status..."
git status

echo
echo "Development session ready."
echo "Next step:"
echo "  - Review request"
echo "  - Implement"
echo "  - Test"
echo "  - Commit"
echo "  - Push"

echo
echo "========== READY =========="
