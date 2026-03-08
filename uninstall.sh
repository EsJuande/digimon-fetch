#!/usr/bin/env bash

set -e

echo "======================================"
echo " Removing DigimonFetch"
echo "======================================"

BIN="$HOME/.local/bin/digimonfetch"
DATA_DIR="$HOME/.local/share/digimonfetch"
CACHE_DIR="$HOME/.cache/digimonfetch"


if [ -f "$BIN" ]; then
    rm -f "$BIN"
    echo "Removed executable"
else
    echo "Executable not found"
fi


if [ -d "$DATA_DIR" ]; then
    rm -rf "$DATA_DIR"
    echo "Removed data directory"
else
    echo "Data directory not found"
fi


if [ -d "$CACHE_DIR" ]; then
    rm -rf "$CACHE_DIR"
    echo "Removed cache"
else
    echo "Cache not found"
fi


echo
echo "DigimonFetch successfully uninstalled."