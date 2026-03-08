#!/usr/bin/env bash

set -e

MODE=${1:-full}

echo "======================================"
echo " Installing DigimonFetch"
echo " Mode: $MODE"
echo "======================================"

BIN_DIR="$HOME/.local/bin"
DATA_DIR="$HOME/.local/share/digimonfetch"
IMAGE_DIR="$DATA_DIR/images"

API="https://digi-api.com/api/v1/digimon?pageSize=2000"

mkdir -p "$BIN_DIR"
mkdir -p "$DATA_DIR"
mkdir -p "$IMAGE_DIR"

echo
echo "Checking dependencies..."

deps=(curl jq xargs)

for cmd in "${deps[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Missing dependency: $cmd"
        echo "Install it and run install.sh again."
        exit 1
    fi
done

echo "Dependencies OK"


echo
echo "Installing executable..."

install -m 755 digimon-fetch.sh "$BIN_DIR/digimonfetch"

echo "Installed to $BIN_DIR/digimonfetch"


echo
echo "Downloading Digimon database..."

curl -L "$API" | jq '.content' > "$DATA_DIR/digimon.json"

TOTAL=$(jq length "$DATA_DIR/digimon.json")

echo "Database downloaded ($TOTAL Digimon)"


if [ "$MODE" = "lite" ]; then
    echo
    echo "Lite mode selected."
    echo "Images will be downloaded on demand."
    echo
    echo "Installation complete."
    exit 0
fi


echo
echo "Preparing image download list..."

TMP_LIST=$(mktemp)

jq -r '
.[]
| select(.image != null)
| .name as $name
| .image as $img
| ($name
   | ascii_downcase
   | gsub("[^a-z0-9]"; "_")
 ) as $safe
| "\($img)|'"$IMAGE_DIR"'/\($safe).png"
' "$DATA_DIR/digimon.json" > "$TMP_LIST"


echo
echo "Downloading images in parallel..."
echo "This may take a minute."
echo


download_image() {

    URL="$1"
    FILE="$2"

    if [ -f "$FILE" ]; then
        exit 0
    fi

    curl \
        --location \
        --retry 3 \
        --fail \
        --progress-bar \
        "$URL" \
        -o "$FILE.tmp"

    mv "$FILE.tmp" "$FILE"
}

export -f download_image

cat "$TMP_LIST" | while IFS="|" read -r url file; do
    download_image "$url" "$file" &
    
    while [ "$(jobs -r | wc -l)" -ge 8 ]; do
        sleep 0.1
    done
done

wait

rm "$TMP_LIST"


echo
echo "Images cached in:"
echo "$IMAGE_DIR"


if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo
    echo "WARNING:"
    echo "$BIN_DIR is not in your PATH."
    echo
    echo "Add this to your shell config:"
    echo
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
fi


echo
echo "======================================"
echo " DigimonFetch installed successfully"
echo "======================================"

echo
echo "Run:"
echo
echo "  digimonfetch"
echo

echo "Optional:"
echo "Add 'digimonfetch' to your ~/.bashrc or ~/.zshrc"