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

