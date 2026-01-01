#!/usr/bin/env bash

cd ~/src/Personal/my_dotfiles

# Copy configs
for dir in hypr kitty waybar wlogout wofi; do
  cp -r ~/.config/"$dir" ./.config/
done

# Copy config-related files
for dir in Configs_Executables; do
  cp -r ~/src/Personal/Configs_Executables/ ./Home-src/
done

# Copy Wallpapers
cp -r ~/Pictures/Wallpapers/ ./

git status

read -p $'\e[1mDo you wish to commit-and-push? [y/N]\e[0m ' yn
case $yn in
[Yy]*)
  git add .
  git commit -m "Auto-sync $(date '+%Y-%m-%d %H:%M:%S')"
  git push
  echo "✅ Dotfiles synced!"
  ;;
*)
  echo "❌ No commit was done."
  exit 0
  ;;
esac
