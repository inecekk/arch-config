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

```bash
# 完整恢复：配置 + 包 + 系统配置
install-dotfiles.sh --with-packages --with-system

# 完整恢复（含所有依赖包）：
install-dotfiles.sh --with-packages-full --with-system
```

---

## 🛠 日常管理

```bash
# 状态查看
dotfiles status

# 添加/修改文件
dotfiles add .config/niri/config.kdl
dotfiles add /etc/modprobe.d/watchdog.conf    # 需 sudo，或先复制到 ~/.config/system-backup/

# 提交
dotfiles commit -m "Update niri config"

# 推送 / 拉取
dotfiles push origin main
dotfiles pull origin main

# 查看差异
dotfiles diff
dotfiles diff --staged

# 恢复单个文件
dotfiles restore .config/foot/foot.ini

# 查看日志
dotfiles log --oneline -10
```

> ⚡ **提示**：把 `alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'` 加入 `.bashrc` / `.zshrc` 后可直接使用 `dotfiles` 命令。

---

## 📁 追踪内容概览

### 用户配置（`$HOME`）

```
.config/
├── niri/           # Wayland 合成器配置（核心 WM）
├── foot/           # 终端模拟器配置
├── fcitx5/         # 输入法配置（Rime、拼音、通知等）
├── btop/           # 系统监视器
├── cava/           # 音频可视化器
├── dae/            # 透明代理配置
├── fontconfig/     # 字体配置
├── systemd/user/   # 用户级 systemd 服务
└── ...

.local/bin/         # 自定义脚本
├── dotfiles                    # 管理别名
├── install-dotfiles.sh         # 一键安装脚本
├── backuplk                    # 备份工具
├── disable-wakeup.sh           # 禁用特定设备唤醒
├── bt-volume.sh                # 蓝牙音量控制
├── brightness-safe             # 安全亮度调节
└── ...

.bashrc, .bash_profile, .tmux.conf, .gitconfig, .w3m/
```

### 系统级配置（`/etc`, `/boot`）→ 存放在 `~/.config/system-backup/`

```
.config/system-backup/
├── etc/
│   ├── fstab
│   ├── mkinitcpio.conf
│   ├── locale.conf
│   ├── hostname
│   ├── vconsole.conf
│   ├── iwd/main.conf
│   ├── modprobe.d/watchdog.conf     # 看门狗黑名单（AMD/Intel/ACPI）
│   ├── systemd/
│   │   ├── system/disable-wakeup.service
│   │   └── network/*.network
├── boot/loader/
│   ├── loader.conf
│   └── entries/arch(-lts).conf
```

> 💡 恢复系统配置需 `install-dotfiles.sh --with-system`（需 sudo 权限）

---

## 🎨 桌面环境：niri + Noctalia

本配置专为 **niri**（可滚动平铺 Wayland 合成器）设计，配合 **Noctalia** 主题风格。

### 核心组件

| 组件 | 包名 | 说明 |
|------|------|------|
| **合成器** | `niri` | 可滚动平铺，动画流畅 |
| **终端** | `foot` | 轻量、GPU 加速 |
| **状态栏** | `yambar-wayland` (AUR) | 模块化，支持 niri 工作区 |
| **启动器** | `fuzzel` | dmenu 替代，Wayland 原生 |
| **通知** | `swaync` | 通知中心 + 控制面板 |
| **壁纸** | `swaybg` | Wayland 壁纸设置 |
| **锁屏** | `swaylock` | 配合 swayidle 自动锁屏 |
| **输入法** | `fcitx5` + `fcitx5-rime` | Rime 引擎，中英混输 |
| **文件管理** | `thunar` + `gvfs` | GTK 文件管理器 |

### Noctalia 主题

统一配色方案应用于：
- `foot` 终端配色
- `niri` 边框/活跃窗口色
- `yambar` 状态栏配色
- `fuzzel` 启动器配色
- `swaylock` 锁屏界面
- `btop` / `cava` 监控配色

---

## 📦 包列表备份/恢复

```bash
# 备份当前安装的包（官方源 + AUR）
backuplk pkglist

# 恢复（需在新机器上先安装 base-devel、git、paru）
install-dotfiles.sh --with-packages
```

包列表存放位置：`~/.config/pkglist/pkglist-official.txt` / `pkglist-aur.txt`

完整依赖列表：`pkglist-all.txt`（含所有依赖，用于完整复现）

---

## 🔄 自动备份（systemd timers）

```bash
# 启用定时备份（配置文件 + 壁纸仓库）
systemctl --user enable --now dotfiles-backup.timer wallpapers-backup.timer

# 查看状态
systemctl --user status dotfiles-backup.timer
journalctl --user -u dotfiles-backup -f
```

---

## 🌐 相关仓库

| 仓库 | 用途 | 地址 |
|------|------|------|
| **arch-config** (本仓库) | 系统/用户配置、脚本、包列表 | `git@github.com:inecekk/arch-config.git` |
| **wallpapers** | 壁纸收集，定时自动备份 | `git@github.com:inecekk/wallpapers.git` |

---

## 📋 依赖核心软件包

```bash
# 窗口/合成器
niri foot fcitx5 fcitx5-rime

# 状态栏/启动器/通知
yambar-wayland fuzzel swaync swaybg swaylock swayidle

# 系统工具
btop cava iwd systemd-networkd mkinitcpio tlp

# 字体
noto-fonts noto-fonts-cjk ttf-jetbrains-mono-nerd

# 音频
pipewire wireplumber pipewire-pulse

# 备份/同步
git rsync inotify-tools
```

---

## 🔐 SSH 密钥配置（推送权限）

```bash
# 生成 Ed25519 密钥（如未有）
ssh-keygen -t ed25519 -C "inecekk@users.noreply.github.com"

# 添加到 ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# 公钥上传到 GitHub Settings → SSH and GPG keys
cat ~/.ssh/id_ed25519.pub
```

---

## 📝 许可证

MIT License — 随意 fork、修改、使用。

---

## 📘 install-dotfiles.sh 安装脚本使用详解

### 基本用法

```bash
# 下载并执行（推荐：SSH）
curl -fsSL https://raw.githubusercontent.com/inecekk/arch-config/main/.local/bin/install-dotfiles.sh | bash

# 或手动克隆后执行
install-dotfiles.sh
install-dotfiles.sh --with-packages           # 恢复 + 自动安装软件包 (官方+AUR, 推荐)
install-dotfiles.sh --with-packages-full      # 恢复 + 安装完整包列表 (含依赖)
install-dotfiles.sh --with-system             # 恢复 + 同步 /etc、/boot 系统配置
install-dotfiles.sh --full                    # 等同于 --with-packages --with-system
install-dotfiles.sh --force                   # 覆盖已有配置文件（默认备份 .bak）
```

### 参数说明

| 参数 | 说明 |
|------|------|
| `--help`, `-h` | 显示完整帮助信息 |
| `--with-packages` | 自动安装官方源 + AUR 包列表（来自 `.config/pkglist/`，**推荐**） |
| `--with-packages-full` | 自动安装完整包列表（含所有依赖，来自 `pkglist-all.txt`） |
| `--with-system` | 恢复 `/etc`、`/boot` 等系统级配置（需要 `sudo`，从 `~/.config/system-backup/` 同步） |
| `--force` | 强制覆盖已有文件，跳过 `.bak` 备份流程 |
| `--full` | 复合参数，等同于 `--with-packages --with-system` |

### 帮助信息示例

```bash
$ install-dotfiles.sh --help
┌─────────────────────────────────────────────────────────┐
│ install-dotfiles.sh — Arch Linux dotfiles 一键安装脚本  │
├─────────────────────── 用法 ────────────────────────────┤
│  install-dotfiles.sh [选项]                             │
│                                                         │
│  --help, -h            显示本帮助信息                   │
│  --with-packages       恢复配置 + 安装包列表 (推荐)     │
│  --with-packages-full  恢复完整包列表 (含依赖)          │
│  --with-system         恢复 /etc、/boot 系统配置        │
│  --force               强制覆盖已有文件                 │
│  --full                等价于 --with-packages --with-system│
└─────────────────────────────────────────────────────────┘

恢复内容:
  • $HOME 下所有 dotfiles (niri/foot/fcitx5/dae/...)
  • ~/.config/system-backup/ 下的 /etc、/boot 配置
  • ~/.config/pkglist/ 下的官方源 + AUR 包列表
```

---

## 📖 完整安装指南

详细的 **手动安装 Arch Linux 步骤** 请参考单独文档：

[📄 install-arch.md](install-arch.md) —— 含分区、加密、systemd-boot、LUKS、niri 桌面、Dotfiles 恢复、常见问题等完整流程

---

> **维护者**: inecekk  
> **最后更新**: 2025-08-16  
> **Host**: Arch Linux (linux-lts) · niri · foot · fcitx5-rime · yambar-wayland · Noctalia
