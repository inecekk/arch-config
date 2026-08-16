# arch-config — Arch Linux Dotfiles

> **Bare repository dotfiles** — 裸仓库管理, 无需符号链接.  
> **目标**: 快速恢复整个 Arch Linux + niri 环境.

---

## 🖥️ 主机配置

| 组件 | 软件包 | 说明 |
|------|--------|------|
| **系统** | `linux-lts` | Arch Linux (LTS 内核) |
| **桌面** | `niri` | Wayland 合成器 (可滚动平铺) |
| **终端** | `foot` | 轻量终端模拟器 |
| **输入法** | `fcitx5` + `fcitx5-rime` | 中文输入法 |
| **通知** | `mako` | Wayland 通知守护进程 |
| **壁纸** | `swaybg` | Wayland 桌面背景 |
| **锁屏** | `swaylock` | 屏幕锁定 |
| **主题** | `Noctalia` | 配色主题 |
| **字体** | `JetBrainsMono Nerd`, `WenQuanYi Micro Hei` | 编程 + 中文字体 |

---

## 📦 软件包列表

| 文件 | 描述 | 链接 |
|------|------|------|
| `pkglist-official.md` | 官方源包 (45 个) | [📄 .dotfiles/pkglist-official.md](.dotfiles/pkglist-official.md) |
| `pkglist-aur.md` | AUR 包 (12 个) | [📄 .dotfiles/pkglist-aur.md](.dotfiles/pkglist-aur.md) |
| `pkglist-all.md` | 合并列表 (57 个) | [📄 .dotfiles/pkglist-all.md](.dotfiles/pkglist-all.md) |
| `pkglist-full.md` | 完整依赖 (545 个) | [📄 .dotfiles/pkglist-full.md](.dotfiles/pkglist-full.md) |

---

## 🚀 快速开始

### 一键安装
```bash
curl -fsSL https://raw.githubusercontent.com/inecekk/arch-config/main/.local/bin/install-dotfiles.sh | bash
```

### 手动安装
```bash
git clone --bare git@github.com:inecekk/arch-config.git ~/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dotfiles checkout main
dotfiles config status.showUntrackedFiles no
install-dotfiles.sh --full --force
```

---

## 🛠 管理工具

| 脚本 | 用途 |
|------|------|
| **`dotfiles`** | Git 别名管理脚本 |
| **`install-dotfiles.sh`** | 一键恢复 (参数: `--with-packages`, `--with-system`, `--full`, `--force`) |
| **`backuplk`** | 自动备份工具 (`pkglist`, `pkglist-full`, `system`, `dae`, `all`) |

---

## 🔄 自动备份

通过 `systemd --user` 定时器实现，每日 13:00 自动执行。

```bash
# 查看状态
systemctl --user status dotfiles-backup.timer
backuplk status

# 手动触发
backuplk all
```

---

## 📁 仓库结构

```
~/.dotfiles/          ← 裸仓库 (Git 数据库)
~/.config/           ← 用户配置 (niri/foot/fcitx5/...)
   ├── system-backup/ ← /etc 与 /boot 备份
├── pkglist/         ← 包列表备份
└── dae/             ← 代理配置 (脱敏)
~/.local/bin/        ← 自定义脚本 (dotfiles/install-dotfiles.sh/backuplk)
```

---

## 🛡️ 安全说明

- `.ssh/`, `.gnupg/`, `.pki/`, `.netrc`, `.wget-hsts` 已排除
- `iwd` WiFi 密码保存在 `/var/lib/iwd` (PSK 不入库)
- `dae` 配置自动脱敏处理
- 看门狗黑名单: `/etc/modprobe.d/watchdog.conf`

---

> **维护者**: inecekk  
> **最后更新**: 2025-08-16
> **GitHub**: [inecekk/arch-config](https://github.com/inecekk/arch-config) · [wallpapers](https://github.com/inecekk/wallpapers)
