#!/usr/bin/env bash
set -e

echo
echo "========== DEVELOPMENT SESSION =========="
echo

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for script in \
    review-session.sh \
    create-restore-point.sh \
    verify-build.sh
do
    if [ ! -x "$SCRIPT_DIR/$script" ]; then
        echo "ERROR: missing executable: $SCRIPT_DIR/$script"
        exit 1
    fi
done

echo "[1/3] Repository Review"
"$SCRIPT_DIR/review-session.sh"

echo
echo "[2/3] Create Restore Point"
"$SCRIPT_DIR/create-restore-point.sh"

echo
echo "[3/3] Build Verification"
"$SCRIPT_DIR/verify-build.sh"

echo
echo "========================================="
echo "Repository is ready."
echo "You may start development."
echo "========================================="
