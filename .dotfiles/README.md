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

---

## 📘 install-dotfiles.sh 安装脚本使用详解

### 基本用法

```bash
# 下载并执行（推荐 SSH 克隆）
curl -fsSL https://raw.githubusercontent.com/inecekk/arch-config/main/.local/bin/install-dotfiles.sh | bash

# 或手动克隆后执行
install-dotfiles.sh
install-dotfiles.sh --with-packages           # 恢复 + 自动安装软件包 (官方+AUR, 推荐)
install-dotfiles.sh --with-packages-full      # 恢复 + 安装完整包列表 (含依赖)
install-dotfiles.sh --with-system             # 恢复 + 同步 /etc、/boot 系统配置
install-dotfiles.sh --full              # 等同于 --with-packages --with-system
install-dotfiles.sh --force             # 覆盖已有配置文件（默认备份 .bak）
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
  • zen 浏览器用户样式 (自动合并到默认 profile)
```

### 恢复的系统级配置清单

| 分类 | 文件/目录 | 说明 |
|------|-----------|------|
| 核心系统 | `fstab`, `mkinitcpio.conf`, `locale.conf`, `hostname`, `vconsole.conf` | 文件系统挂载、初始化RAM盘、本地化 |
| 网络 | `iwd/main.conf`, `systemd/network/*.network` | Wi-Fi 认证配置、网络管理 |
| 包管理 | `pacman.conf`, `paru.conf`, `makepkg.conf` | 包源镜像、AUR 助手、编译配置 |
| 电源管理 | `tlp.conf` | Linux 电源优化 |
| 本地化 | `locale.gen` | 语系生成配置 |
| 服务默认值 | `default/*` | GRUB、sndiod 等系统服务默认参数 |
| 内核模块 | `modprobe.d/*.conf` | 看门狗黑名单、AMD GPU 调试掩码、WiFi 电源 |
| 防火墙 | `nftables.conf`, `arptables.conf`, `ebtables.conf` | 网络过滤规则 |
| 系统服务 | `systemd/system/disable-wakeup.service` | 禁止 RTL8852BE 唤醒（修复合盖秒醒） |
| 启动配置 | `boot/loader/*` | systemd-boot 引导配置 |

### 安装后手动步骤

安装完成后，请务必执行以下步骤：

1. **启用自动备份定时器**
   ```bash
   systemctl --user enable --now dotfiles-backup.timer wallpapers-backup.timer
   ```

2. **检查桌面环境**
   ```bash
   # 确认 niri 合成器正常
   niri --version
   # 检测 fcitx5 输入法状态
   fcitx5-diagnose
   # 查看 foot 终端配置
   cat ~/.config/foot/foot.ini
   ```

3. **同步系统配置（如使用 --with-system）**
   ```bash
   # 若恢复 locale.gen，请生成语系
   sudo locale-gen
   # 若恢复 nftables，请加载规则
   sudo nft -f /etc/nftables.conf
   ```

4. **验证 fstab（如恢复）**
   ```bash
   # 校验 UUID 合法性
   lsblk -f
   findmnt -D
   ```

---

### 🔄 自动备份 (Systemd Timers)

```bash
# 启用自动备份定时器
systemctl --user enable --now dotfiles-backup.timer wallpapers-backup.timer

# 查看状态
systemctl --user status dotfiles-backup.timer wallpapers-backup.timer

# 查看日志
journalctl --user -u dotfiles-backup -f
```

> - `dotfiles-backup.timer`: 每日备份 `$HOME` 配置文件到 `~/.config/system-backup/`
> - `wallpapers-backup.timer`: 定期同步壁纸仓库

### 🧰 常用管理命令

```bash
# 在任意目录管理 dotfiles
dotfiles status          # 查看变更
dotfiles add FILE        # 添加新文件
dotfiles commit -m "MSG" # 提交变更
dotfiles push            # 推送到 GitHub
dotfiles pull            # 拉取远程更新
dotfiles log --oneline -5 # 查看最近提交
```

---

## 🧰 常用管理命令

### dotfiles 管理

```bash
# 在任意目录管理 dotfiles
dotfiles status          # 查看变更
dotfiles add FILE        # 添加新文件
dotfiles commit -m "MSG" # 提交变更
dotfiles push            # 推送到 GitHub
dotfiles pull            # 拉取远程更新
dotfiles log --oneline -5 # 查看最近提交
dotfiles restore FILE    # 恢复单个文件
```

### backuplk 备份工具

```bash
backuplk help        # 显示帮助
backuplk pkglist     # 备份已安装包列表 (官方+AUR)
backuplk pkglist-full # 备份完整包列表 (含依赖 + 恢复命令)
backuplk system      # 备份 /etc 和 /boot 配置
backuplk dae         # 备份 dae 代理配置 (脱敏处理)
backuplk all         # 备份所有内容
backuplk status      # 查看定时任务状态
backuplk log         # 查看完整备份日志
```
