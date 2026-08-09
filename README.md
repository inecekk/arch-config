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

## 重装系统指南

> 重装会清空整个目标磁盘，动手前先过一遍确认清单。

### 确认清单（必读）

- [ ] `backuplk all` 已跑完，`dotfiles status` 干净，最新提交已 push
- [ ] 家目录数据已单独备份：音乐库、文档、SSH key、Vaultwarden 数据等
- [ ] iwd WiFi 密码不在备份里，记好 SSID 和密码
- [ ] `lsblk -f` 记录当前分区和 UUID，后面恢复 fstab 时要核对
- [ ] 以下命令里的 `/dev/nvme0n1` 按机器实际设备名改，别照抄

### 1. 制作安装介质

```bash
# 下载 https://archlinux.org/download/ 的 ISO
sudo dd bs=4M if=archlinux-x86_64.iso of=/dev/sdX status=progress oflag=sync
```

### 2. 分区（btrfs 多子卷，保持现有结构）

布局：`nvme0n1p1` = EFI(512M)，`nvme0n1p2` = btrfs，子卷 `@` `@home` `@log` `@pkg` `@.snapshots`。

```bash
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.btrfs /dev/nvme0n1p2

mount /dev/nvme0n1p2 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@pkg
btrfs subvolume create /mnt/@.snapshots
umount /mnt

mount -o subvol=@,compress=zstd,noatime /dev/nvme0n1p2 /mnt
mkdir -p /mnt/{boot,home,var/log,var/cache/pacman/pkg,.snapshots}
mount -o subvol=@home,compress=zstd,noatime /dev/nvme0n1p2 /mnt/home
mount -o subvol=@log,compress=zstd,noatime /dev/nvme0n1p2 /mnt/var/log
mount -o subvol=@pkg,compress=zstd,noatime /dev/nvme0n1p2 /mnt/var/cache/pacman/pkg
mount -o subvol=@.snapshots,compress=zstd,noatime /dev/nvme0n1p2 /mnt/.snapshots
mount /dev/nvme0n1p1 /mnt/boot
```

### 3. 基础安装

```bash
pacstrap -K /mnt base base-devel linux linux-firmware amd-ucode \
  btrfs-progs iwd systemd-boot-shim git vim

genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```

### 4. chroot 内基础配置

```bash
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc
echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=zh_CN.UTF-8" > /etc/locale.conf

echo "arch" > /etc/hostname
passwd
useradd -m -G wheel lk
passwd lk
EDITOR=vim visudo   # 取消注释 %wheel ALL=(ALL:ALL) ALL

bootctl install
mkinitcpio -P
```

`/boot/loader/entries/arch.conf`：

```
title   Arch Linux
linux   /vmlinuz-linux
initrd  /amd-ucode.img
initrd  /initramfs-linux.img
options root=UUID=<你的UUID> rootflags=subvol=@ rw acpi_osi=! acpi_osi=Linux
```

`acpi_osi` 参数是这台机器（TM2113）挂起/唤醒 firmware bug 的修复项，别漏。

### 5. 重启进新系统

```bash
exit
umount -R /mnt
reboot
```

### 6. 网络 + AUR helper + 一键恢复

```bash
sudo systemctl enable --now iwd
iwctl station wlan0 connect <SSID>

git clone https://aur.archlinux.org/paru.git
cd paru && makepkg -si

# 一键恢复：dotfiles + 包列表 + 系统配置
curl -fsSL https://raw.githubusercontent.com/inecekk/arch-config/main/.local/bin/install-dotfiles.sh | bash -s -- --with-packages --with-system
```

### 7. 收尾

```bash
sudo systemctl enable --now greetd bluetooth dae
systemctl --user enable --now dotfiles-backup.timer wallpapers-backup.timer
```

- 重启前核对 `/etc/fstab` 的 UUID 和当前分区是否一致
- iwd 密码手动连一次会自动重新生成
- dae 配置恢复的是脱敏版，节点信息需要手动补回

## 相关仓库

- 壁纸仓库：<https://github.com/inecekk/wallpapers>
