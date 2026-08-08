#!/bin/bash
# 自动备份壁纸到 GitHub（systemd 定时器调用）
cd /home/lk/Pictures/wallpapers || exit 0
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 壁纸备份开始"

# 添加所有改动（包括新文件）
/usr/bin/git add -A

# 没有改动就退出
if /usr/bin/git diff --cached --quiet; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 无改动，跳过"
    exit 0
fi

# 提交（带日期）
/usr/bin/git commit -m "auto-backup wallpapers $(date '+%Y-%m-%d %H:%M')"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 已提交"

# 推送（失败不影响，下次再推）
if /usr/bin/git push origin main; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 推送成功"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 推送失败，下次再试"
fi
