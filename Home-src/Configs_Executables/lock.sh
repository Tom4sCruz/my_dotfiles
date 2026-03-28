#!/usr/bin/env bash

swaylock -f --color 151515 \
  --indicator-idle-visible -l \
  --indicator-radius 100 --inside-color 151515 \
  --indicator-thickness 7 \
  --ring-color 101010 \
  --inside-ver-color 98f329 \
  --ring-ver-color 151515 \
  --inside-wrong-color d91e58 \
  --ring-wrong-color 151515 \
  --inside-clear-color f2f2f2 \
  --ring-clear-color 151515 \
  --key-hl-color 98f329 \
  --separator-color 101010 \
  --bs-hl-color d91e58 \
  --line-color 151515 \
  --clock \
  --timestr %H:%M \
  --datestr %x \
  --text-color f2f2f2
