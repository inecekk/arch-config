#!/bin/bash
# install-dotfiles.sh - 新机器一键恢复 Arch 配置（niri/foot/fcitx5/dae/noctalia 等）
# 用法:
#   curl -fsSL https://raw.githubusercontent.com/inecekk/arch-config/main/.local/bin/install-dotfiles.sh | bash
#   install-dotfiles.sh --with-packages   # 恢复配置后顺便恢复包列表
#   install-dotfiles.sh --with-system        # 顺便恢复 /etc 和 /boot 系统配置
#   install-dotfiles.sh --force              # 已存在文件直接覆盖（默认备份 .bak）

set -euo pipefail

REPO_SSH="git@github.com:inecekk/arch-config.git"
REPO_HTTPS="https://github.com/inecekk/arch-config.git"
DOTFILES_DIR="$HOME/.dotfiles"
WITH_PACKAGES=0
WITH_SYSTEM=0
FORCE=0

for arg in "$@"; do
    case "$arg" in
        --with-packages) WITH_PACKAGES=1 ;;
        --with-system) WITH_SYSTEM=1 ;;
        --force) FORCE=1 ;;
    esac
done

GIT="git --git-dir=$DOTFILES_DIR --work-tree=$HOME"

restore_zen() {
    echo "    恢复 zen 浏览器自定义样式..."
    ZEN_DIR="$HOME/.config/zen"
    [ -d "$ZEN_DIR" ] || { echo "    未找到 zen 配置目录，跳过"; return 0; }

    # 找默认 profile：优先 profiles.ini 里 Install 段的 Default=，其次第一个 Path=
    DEF_PROFILE=""
    if [ -f "$ZEN_DIR/profiles.ini" ]; then
        DEF_PROFILE=$(grep -m1 '^Default=' "$ZEN_DIR/profiles.ini" | cut -d= -f2)
        [ -z "$DEF_PROFILE" ] && DEF_PROFILE=$(grep -m1 '^Path=' "$ZEN_DIR/profiles.ini" | cut -d= -f2)
    fi

    TARGET=""
    if [ -n "$DEF_PROFILE" ] && [ -d "$ZEN_DIR/$DEF_PROFILE" ]; then
        TARGET="$ZEN_DIR/$DEF_PROFILE"
    else
        TARGET=$(ls -d "$ZEN_DIR"/*/chrome 2>/dev/null | head -1 | xargs dirname 2>/dev/null)
    fi
    [ -z "$TARGET" ] && { echo "    未找到可用 profile，跳过"; return 0; }

    mkdir -p "$TARGET/chrome"
    # 从 git 恢复出来的（旧 hash 路径）样式文件复制到当前默认 profile
    SRC_CSS=$(ls "$ZEN_DIR"/*/chrome/userChrome.css 2>/dev/null | grep -v "$TARGET/chrome" | head -1)
    if [ -n "$SRC_CSS" ]; then
        cp "$SRC_CSS" "$TARGET/chrome/userChrome.css"
        echo "      userChrome.css -> $TARGET/chrome/"
    fi
    SRC_CONTENT=$(ls "$ZEN_DIR"/*/chrome/userContent.css 2>/dev/null | grep -v "$TARGET/chrome" | head -1)
    if [ -n "$SRC_CONTENT" ]; then
        cp "$SRC_CONTENT" "$TARGET/chrome/userContent.css"
        echo "      userContent.css -> $TARGET/chrome/"
    fi
    SRC_JS=$(ls "$ZEN_DIR"/*/user.js 2>/dev/null | grep -v "$TARGET/" | head -1)
    if [ -n "$SRC_JS" ]; then
        cp "$SRC_JS" "$TARGET/user.js"
        echo "      user.js -> $TARGET/"
    fi
    echo "    zen 样式恢复完成（重启 zen 生效）"
}

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

restore_zen

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

echo "==> [4/4] 恢复系统级配置"
if [ "$WITH_SYSTEM" = "1" ]; then
    SYSBK="$HOME/.config/system-backup"
    if [ -d "$SYSBK" ]; then
        echo "    恢复 /etc 配置..."
        for f in fstab mkinitcpio.conf locale.conf hostname vconsole.conf; do
            if [ -f "$SYSBK/etc/$f" ]; then
                sudo cp "$SYSBK/etc/$f" "/etc/$f"
                echo "      /etc/$f"
            fi
        done
        if [ -f "$SYSBK/etc/iwd/main.conf" ]; then
            sudo mkdir -p /etc/iwd
            sudo cp "$SYSBK/etc/iwd/main.conf" /etc/iwd/main.conf
            echo "      /etc/iwd/main.conf"
        fi
        # disable-wakeup 服务：禁用 GPP6（RTL8852BE 网卡）的 S4 唤醒，修复合盖休眠秒醒
        if [ -f "$SYSBK/etc/systemd/system/disable-wakeup.service" ]; then
            sudo mkdir -p /etc/systemd/system
            sudo cp "$SYSBK/etc/systemd/system/disable-wakeup.service" /etc/systemd/system/disable-wakeup.service
            echo "      /etc/systemd/system/disable-wakeup.service"
            if [ -f "$HOME/.local/bin/disable-wakeup.sh" ]; then
                sudo install -m 755 "$HOME/.local/bin/disable-wakeup.sh" /usr/local/bin/disable-wakeup.sh
                echo "      /usr/local/bin/disable-wakeup.sh"
            fi
            sudo systemctl daemon-reload || true
            sudo systemctl enable disable-wakeup.service 2>/dev/null || true
            sudo systemctl start disable-wakeup.service 2>/dev/null || true
            echo "      disable-wakeup.service 已启用"
        fi
        if [ -d "$SYSBK/etc/systemd/network" ]; then
            sudo mkdir -p /etc/systemd/network
            sudo cp "$SYSBK/etc/systemd/network/"*.network /etc/systemd/network/ 2>/dev/null
            echo "      /etc/systemd/network/*.network"
        fi
        if [ -f "$SYSBK/etc/fstab" ]; then
            echo "    fstab 已恢复，注意核对 UUID 是否与当前分区一致"
        fi
        if [ -d "$SYSBK/boot/loader" ]; then
            echo "    恢复 systemd-boot 配置..."
            sudo cp -r "$SYSBK/boot/loader/." /boot/loader/
            echo "      /boot/loader/"
        fi
        echo "    提示: iwd WiFi 密码不在此备份中，需手动 iwctl station wlan0 connect"
    else
        echo "    未找到 $SYSBK，先跑 backuplk system 备份"
    fi
else
    echo "    跳过（加 --with-system 可恢复 /etc 和 /boot 配置）"
fi

echo "==> [4/4] 完成"
cat << 'DONE'

后续手动步骤：
  1. systemctl --user enable --now dotfiles-backup.timer wallpapers-backup.timer
  2. 确认 niri / fcitx5 / foot / dae 配置是否正常
  3. 若恢复了 fstab，重启前确认 UUID 无误
DONE
