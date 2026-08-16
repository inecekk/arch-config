export XCURSOR_SIZE=12
export XCURSOR_THEME="default"
# >>> miyu bash hook >>>
[ -r '/home/lk/.miyu/config/shell/bash-hook.sh' ] && source '/home/lk/.miyu/config/shell/bash-hook.sh'
# <<< miyu bash hook <<<

# 用户本地可执行文件
export PATH="$HOME/.local/bin:$PATH"

# ═══════════════════════════════
# MusicFox
# ═══════════════════════════════
music() {
  # musicfox 单窗口方案：foot 终端（与主终端统一）
  # 已有窗口不重复开，幂等
  if ! pgrep -f 'foot.*musicfox' >/dev/null; then
    foot -T musicfox -e musicfox &
  fi
}
# 1. 强制所有 Qt 应用（如 OBS, VLC 等）整体缩放 2 倍
export QT_SCALE_FACTOR=2

# 2. 强制 GTK 应用整体缩放 2 倍
export GDK_SCALE=2

# 3. 强制 Electron 应用（VS Code, Discord 等）在 Wayland 下按比例缩放
export ELECTRON_FORCE_WINDOW_DSF=2.0

# 4. 确保应用强制走纯 Wayland 通道，避免模糊
export ELECTRON_OZONE_PLATFORM_HINT="wayland"
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM="wayland"
