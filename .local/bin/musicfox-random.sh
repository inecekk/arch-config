#!/bin/bash
# musicfox 随机启动动画脚本
# 每次启动随机选一种动画写入配置，再启动 musicfox

# 可选动画列表（与 musicfox 支持的动画一致）
ANIMS=("sequence" "fade-in" "rainbow-wave" "typewriter" "spinner" "slide-in" "glitch" "matrix-rain" "particle-burst")

# 随机选一个
RANDOM_ANIM="${ANIMS[$RANDOM % ${#ANIMS[@]}]}"

# 写入配置（只改 animation 行，不碰其他内容）
sed -i "s/^animation = .*/animation = \"$RANDOM_ANIM\"/" ~/.config/go-musicfox/config.toml

# 在 foot 终端里启动 musicfox（与原快捷键一致）
exec foot -e musicfox
