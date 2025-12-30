#!/usr/bin/env bash

grim - | tee $HOME/Pictures/Screenshots/$(date +%Y%m%d-%H%M%S).png | wl-copy
