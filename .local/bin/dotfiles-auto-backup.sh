#!/bin/bash
# 自动备份 dotfiles 到 GitHub（systemd 定时器调用）
DOTFILES="/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] dotfiles 备份开始"

# 添加已跟踪文件的改动（不自动加新文件，防止误提交敏感内容）
$DOTFILES add -u

# 没有改动就退出
if $DOTFILES diff --cached --quiet; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 无改动，跳过"
    exit 0
fi

# 提交（带日期）
$DOTFILES commit -m "auto-backup $(date '+%Y-%m-%d %H:%M')"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 已提交"

# 推送（失败不影响，下次再推）
if $DOTFILES push; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 推送成功"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 推送失败，下次再试"
fi
