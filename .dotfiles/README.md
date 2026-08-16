# arch-config — My Arch Linux Dotfiles

> **Bare repository dotfiles** — 直接以 `$HOME` 为工作树，无需符号链接，干净、极简。

## 📦 仓库结构

```
~/.dotfiles/          ← 裸仓库（仅存 .git 数据库）
~/                    ← 工作树（你的整个 $HOME）
~/.local/bin/dotfiles ← 管理别名脚本
```

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
| `--with-system`   | 恢复 `/etc`、 `/boot` 等系统级配置 |
| `--force`         | 冲突文件直接覆盖（默认备份 `.bak`） |

```bash
# 完整恢复：配置 + 包 + 系统配置
install-dotfiles.sh --with-packages --with-system
```

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

## 📁 追踪内容概览

### 用户配置（`$HOME`）
```
.config/
├── niri/           # Wayland 合成器配置
├── foot/           # 终端模拟器配置
├── fcitx5/         # 输入法配置（Rime、拼音、通知等）
├── btop/           # 系统监视器
├── cava/           # 音频可视化器
├── dae/            # 透明代理配置
├── dwl/            # Wayland 窗口管理器（备选）
├── denial/         # 网络配置
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

## 📦 包列表备份/恢复

```bash
# 备份当前安装的包（官方源 + AUR）
backuplk pkglist

# 恢复（需在新机器上先安装 base-devel、git、paru）
install-dotfiles.sh --with-packages
```

包列表存放位置：`~/.config/pkglist/pkglist-official.txt` / `pkglist-aur.txt`

## 🔄 自动备份（systemd timers）

```bash
# 启用定时备份（配置文件 + 壁纸仓库）
systemctl --user enable --now dotfiles-backup.timer wallpapers-backup.timer

# 查看状态
systemctl --user status dotfiles-backup.timer
journalctl --user -u dotfiles-backup -f
```

## 🌐 相关仓库

| 仓库 | 用途 | 地址 |
|------|------|------|
| **arch-config** (本仓库) | 系统/用户配置、脚本、包列表 | `git@github.com:inecekk/arch-config.git` |
| **wallpapers** | 壁纸收集，定时自动备份 | `git@github.com:inecekk/wallpapers.git` |

## 📋 依赖核心软件包

```bash
# 窗口/合成器
niri foot fcitx5 fcitx5-rime

# 状态栏/启动器
yambar-wayland (AUR)  # 依赖 wayland, gtk4, libsoup3 等

# 系统工具
btop cava btop iwd systemd-networkd mkinitcpio

# 备份/同步
git rsync inotify-tools (for auto-backup)
```

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

## 📝 许可证

MIT License — 随意 fork、修改、使用。

---

> **维护者**: inecekk  
> **最后更新**: 2025-08-16  
> **Host**: Arch Linux (linux-lts) · niri · foot · fcitx5-rime
