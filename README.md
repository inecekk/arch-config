# arch-config

lk 的 Arch Linux dotfiles。用 bare git 仓库管理 `$HOME` 下的配置文件，配合 `backuplk` 定时自动备份，重装或换机后一条命令恢复。

## 仓库结构

- `.config/` — 日常应用配置：niri（Wayland 合成器）、foot、fcitx5 + rime 双拼、dae、noctalia 主题、gtk / qt5ct / qt6ct 配色等
- `.config/system-backup/` — 系统级配置：fstab、mkinitcpio.conf、locale.conf、hostname、vconsole.conf、systemd-boot（loader.conf + entries/arch.conf）、iwd/main.conf
- `.config/pkglist/` — 已安装包列表（官方源 / AUR 分开存）
- `.config/systemd/user/` — 自动备份的 systemd 用户服务与定时器
- `.local/bin/` — 工具脚本：`backuplk`、`install-dotfiles.sh`、`dotfiles`（git 别名）等

## 快速开始

### 新机器 / 重装后恢复

装好基础系统、配好网络和 paru 之后执行：

```bash
curl -fsSL https://raw.githubusercontent.com/inecekk/arch-config/main/.local/bin/install-dotfiles.sh | bash
```

可选参数：

| 参数 | 作用 |
| --- | --- |
| `--with-packages` | 顺便恢复包列表（官方源 + AUR） |
| `--with-system` | 顺便恢复 /etc 和 /boot 系统配置 |
| `--force` | 冲突文件直接覆盖（默认先备份成 `.bak-时间戳`） |

### 日常备份

```bash
backuplk all
```

## backuplk 用法

| 命令 | 作用 |
| --- | --- |
| `backuplk` / `backuplk backup` | 手动备份 dotfiles 并显示结果 |
| `backuplk dae` | 备份 dae 代理配置（节点 / 密码脱敏） |
| `backuplk system` | 备份系统配置（fstab / iwd / boot loader / mkinitcpio / networkd，需要 sudo） |
| `backuplk pkglist` | 备份已安装包列表（官方源 / AUR 分开） |
| `backuplk all` | 上面全部一起跑 |
| `backuplk status` | 查看定时器下次执行时间 |
| `backuplk log` | 查看完整备份日志 |
| `backuplk help` | 显示帮助 |

## 自动备份

systemd 用户定时器每天 13:00 自动执行并推送到 GitHub：

- `dotfiles-backup.timer` — 备份 dotfiles
- `wallpapers-backup.timer` — 备份壁纸

查看状态：`systemctl --user list-timers | grep backup`

## 注意事项

- iwd 的 WiFi 密码（PSK）在 `/var/lib/iwd`，含明文不入库；重装后需手动 `iwctl station wlan0 connect`
- dae 配置会脱敏：节点链接和 uuid 替换为 `[REDACTED]`
- 恢复 fstab 后重启前务必核对 UUID 是否与当前分区一致
- `backuplk system` 涉及 /etc 和 /boot，需要 sudo 权限

## 相关仓库

- 壁纸仓库：<https://github.com/inecekk/wallpapers>
