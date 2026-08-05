#!/usr/bin/env bash
set -e

cd ~/bolt-guest

# Gunakan display X11 yang sedang aktif
export DISPLAY=${DISPLAY:-:0}
export XAUTHORITY=${XAUTHORITY:-$HOME/.Xauthority}
export NODE_ENV=development

echo "=================================="
echo " Bolt DIY Electron Development"
echo "=================================="
echo "DISPLAY=$DISPLAY"
echo "XAUTHORITY=$XAUTHORITY"
echo

# Matikan proses lama jika ada
pkill -f "remix vite:dev" 2>/dev/null || true
pkill -f "electron.*build/electron/main/index.mjs" 2>/dev/null || true

sleep 1

# Jalankan Electron Dev
node scripts/electron-dev.mjs
