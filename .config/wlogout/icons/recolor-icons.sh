#!/usr/bin/env bash

# Set your desired color (hex format)
COLOR="#9ba6aa"  # Change to your preference
OUTPUT_DIR="$HOME/.config/wlogout/icons"

mkdir -p "$OUTPUT_DIR"

# Convert all SVGs to colored PNGs (64x64 matches wlogout default)
for svg in /usr/share/wlogout/assets/*.svg; do
    filename=$(basename "$svg" .svg)
    magick "$svg" \
        -background none \
        -fill "$COLOR" \
        -colorize 100% \
        -resize 64x64 \
        "$OUTPUT_DIR/${filename}.png"
done

