#!/bin/bash
# 随机设置壁纸并锁屏
# 从 16X10 壁纸库随机选一张作为当前壁纸，再触发 noctalia 锁屏
DIR="/home/lk/Pictures/wallpapers/16X10"
WALLPAPER=$(find "$DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null | shuf -n1)
if [ -n "$WALLPAPER" ]; then
    noctalia msg wallpaper-set eDP-1 "$WALLPAPER" >/dev/null 2>&1
fi
noctalia msg session lock
