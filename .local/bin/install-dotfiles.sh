#!/bin/bash
# install-dotfiles.sh - 新机器一键恢复 Arch 配置（niri/foot/fcitx5/dae/noctalia 等）
# 用法:
#   curl -fsSL https://raw.githubusercontent.com/inecekk/arch-config/main/.local/bin/install-dotfiles.sh | bash
#   install-dotfiles.sh --with-packages   # 恢复配置后顺便恢复包列表
#   install-dotfiles.sh --force           # 已存在文件直接覆盖（默认备份 .bak）

set -euo pipefail

REPO_SSH="git@github.com:inecekk/arch-config.git"
REPO_HTTPS="https://github.com/inecekk/arch-config.git"
DOTFILES_DIR="$HOME/.dotfiles"
WITH_PACKAGES=0
FORCE=0

for arg in "$@"; do
    case "$arg" in
        --with-packages) WITH_PACKAGES=1 ;;
        --force) FORCE=1 ;;
    esac
done

GIT="git --git-dir=$DOTFILES_DIR --work-tree=$HOME"

echo "==> [1/4] 准备 bare 仓库"
if [ ! -d "$DOTFILES_DIR" ]; then
    if git clone --bare "$REPO_SSH" "$DOTFILES_DIR" 2>/dev/null; then
        echo "    已通过 SSH 克隆"
    else
        git clone --bare "$REPO_HTTPS" "$DOTFILES_DIR"
        echo "    已通过 HTTPS 克隆（如需 push 请配置 SSH key）"
    fi
else
    echo "    仓库已存在，跳过克隆"
fi

echo "==> [2/4] 恢复配置文件到 home"
if $GIT checkout main 2>/dev/null; then
    echo "    配置恢复完成"
elif [ "$FORCE" = "1" ]; then
    echo "    使用 --force，冲突文件直接覆盖"
    $GIT checkout -f main
else
    echo "    检测到已有文件冲突，逐个备份后重试..."
    # 从 git 错误输出里提取冲突文件名（格式：'path/to/file'）
    $GIT checkout main 2>&1 | grep -oE "'[^']+'" | tr -d "'" | sort -u | while read -r f; do
        [ -e "$HOME/$f" ] || continue
        bak="$HOME/$f.bak-$(date +%Y%m%d-%H%M%S)"
        mv "$HOME/$f" "$bak"
        echo "    已备份 $f -> $bak"
    done
    $GIT checkout main
fi

# 不显示 home 下所有未跟踪文件，保持 status 干净
$GIT config status.showUntrackedFiles no
echo "    status.showUntrackedFiles 已设为 no"

echo "==> [3/4] 恢复包列表"
if [ "$WITH_PACKAGES" = "1" ]; then
    OFFICIAL="$HOME/.config/pkglist/pkglist-official.txt"
    AUR="$HOME/.config/pkglist/pkglist-aur.txt"
    if [ -f "$OFFICIAL" ]; then
        echo "    恢复官方源包（$(wc -l < "$OFFICIAL") 个）..."
        sudo pacman -S --needed - < "$OFFICIAL"
    fi
    if [ -f "$AUR" ]; then
        echo "    恢复 AUR 包（$(wc -l < "$AUR") 个）..."
        paru -S --needed - < "$AUR" || echo "    AUR 恢复失败，请确认 paru 已安装"
    fi
else
    echo "    跳过（加 --with-packages 可恢复包列表）"
fi

echo "==> [4/4] 完成"
cat << 'DONE'

后续手动步骤：
  1. systemctl --user enable --now dotfiles-backup.timer wallpapers-backup.timer
  2. 确认 niri / fcitx5 / foot / dae 配置是否正常
  3. /etc 和 /boot 的系统级配置需手动确认（fstab、loader、mkinitcpio）
DONE
