# 如果当前在 TTY1 登录且没有 Wayland 会话，则自动拉起 Niri
#: <<'EOF'
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    # 显式声明 Wayland 会话类型，避免应用误判
    export XDG_SESSION_TYPE="wayland"
    export XDG_CURRENT_DESKTOP="niri"
    exec niri-session -l
fi
#EOF
