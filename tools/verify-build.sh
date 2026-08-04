#!/usr/bin/env bash
set -e

export NODE_OPTIONS="--max-old-space-size=4096"

echo "========== BUILD VERIFICATION =========="
echo

echo "[1] Typecheck"
pnpm typecheck

echo
echo "[2] Lint"
pnpm lint

echo
echo "[3] Tests"
if pnpm run | grep -qE '^ *test'; then
    pnpm test
else
    echo "No test script defined."
fi

echo
echo "[4] Build"
if pnpm run | grep -qE '^ *build'; then
    pnpm build
else
    echo "No build script defined."
fi

echo
echo "========== BUILD VERIFIED =========="
