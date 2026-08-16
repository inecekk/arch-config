# arch-config — My Arch Linux Dotfiles

> **Bare repository dotfiles** — 直接以 `$HOME` 为工作树，无需符号链接，干净、极简。

---

## 📦 仓库结构

```
~/.dotfiles/          ← 裸仓库（仅存 .git 数据库）
~/                    ← 工作树（你的整个 $HOME）
~/.local/bin/dotfiles ← 管理别名脚本
```

---

## 🚀 快速开始（新机器）

```bash
# 一键克隆并恢复配置（推荐：SSH）
curl -fsSL https://raw.githubusercontent.com/inecekk/arch-config/main/.local/bin/install-dotfiles.sh | bash

# 或者手动
git clone --bare git@github.com:inecekk/arch-config.git ~/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dotfiles checkout main
dotfiles config status.showUntrackedFiles no
```

### 安装脚本参数

| 参数 | 作用 |
|------|------|
| `--with-packages` | 恢复官方源 + AUR 包列表 |
| `--with-packages-full` | 恢复完整包列表（含依赖，`pkglist-all.txt`） |
| `--with-system` | 恢复 `/etc`、 `/boot` 等系统级配置 |
| `--force` | 冲突文件直接覆盖（默认备份 `.bak`） |
| `--full` | 等价于 `--with-packages --with-system` |

---

## 🛠 日常管理

```bash
dotfiles status
dotfiles add .config/niri/config.kdl
dotfiles commit -m "Update niri config"
dotfiles push origin main
```

---

## 📁 追踪内容概览

### 用户配置（`$HOME`）
```
.config/
├── niri/
├── foot/
├── fcitx5/
├── btop/
├── cava/
├── dae/
├── systemd/user/
└── ... (其他应用配置)

.local/bin/
├── dotfiles
├── install-dotfiles.sh
├── backuplk
└── ... (自定义脚本)

.bashrc, .bash_profile, .tmux.conf, .gitconfig
```

### 系统级配置 → `~/.config/system-backup/`
```
etc/
├── fstab, hostname, locale.conf, mkinitcpio.conf, vconsole.conf
├── iwd/main.conf
├── modprobe.d/watchdog.conf
├── pacman.conf, paru.conf, makepkg.conf
├── tlp.conf, locale.gen
├── systemd/network/*.network
├── systemd/system/disable-wakeup.service
├── default/*          (grub, sndiod...)
├── modprobe.d/*.conf
├── nftables.conf, arptables.conf, ebtables.conf
├── fuse.conf, ld.so.conf, gai.conf, host.conf, nsswitch.conf, xattr.conf

boot/
├── loader/loader.conf
└── loader/entries/arch(-lts).conf
```

---

## 🎨 桌面环境：niri + Noctalia

| 组件 | 包名 | 说明 |
|------|------|------|
| **合成器** | `niri` | 可滚动平铺 Wayland 合成器 |
| **终端** | `foot` | 轻量级终端模拟器 |
| **输入法** | `fcitx5` + `fcitx5-rime` | 中文输入法引擎 |

### 📦 核心依赖

```bash
# 窗口/合成器
niri foot fcitx5 fcitx5-rime

# 网络/电源/系统
iwd systemd-networkd mkinitcpio tlp

# 音频
pipewire wireplumber pipewire-pulse

# 字体 (需手动安装)
ttf-jetbrains-mono-nerd wqy-microhei

# 备份/同步
git rsync inotify-tools
```

---

## 🔐 SSH 密钥配置

```bash
ssh-keygen -t ed25519 -C "inecekk@users.noreply.github.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub  # 上传到 GitHub
```

---

## 📝 许可证
MIT License

---

> **维护者**: inecekk  
> **Host**: Arch Linux (linux-lts) · niri · foot · fcitx5-rime · Noctalia

---

## 📘 install-dotfiles.sh 使用详解

| 参数 | 说明 |
|------|------|
| `--help` `-h` | 显示帮助 |
| `--with-packages` | 安装 pkglist 包列表 |
| `--with-packages-full` | 安装完整依赖 (pkglist-all.txt) |
| `--with-system` | 恢复 `/etc` 和 `/boot` 配置 |
| `--force` | 强制覆盖 |
| `--full` | 等价于 `--with-packages --with-system` |

```bash
curl -fsSL https://raw.githubusercontent.com/inecekk/arch-config/main/.local/bin/install-dotfiles.sh | bash
```

## 📖 手动安装指南

[📄 install-arch.md](install-arch.md) — 完整手动安装 Arch Linux 步骤
