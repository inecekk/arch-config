```markdown
# Arch Linux 手动安装指南 (Btrfs + 子卷方案)

> 适用：UEFI + systemd-boot + Btrfs (含子卷) + LUKS 加密 (可选) + niri Wayland 桌面
>
> 目标磁盘：`/dev/nvme0n1` (NVMe) 或 `/dev/sda` (SATA)
>
> ⚠️ **警告**：以下命令需在 root 权限下执行，会清空目标磁盘数据，请务必确认磁盘设备名无误后再操作。

---

## 1. 准备工作

- 下载 ISO 并校验（`sha256sum` 或 GPG 签名）
- 使用 `dd` 或 Rufus / Etcher 写入 U 盘
- BIOS 设置：
  - UEFI Only（关闭 Legacy/CSM）
  - Secure Boot：Disabled
  - Fast Boot：Disabled

## 2. 启动与网络

```bash
# 确认处于 UEFI 模式（有输出即为 UEFI）
ls /sys/firmware/efi/efivars

# 有线网络：一般自动 DHCP，可用以下命令验证
ping -c3 archlinux.org

# 无线网络
iwctl
# station wlan0 connect <SSID>
```

同步系统时间：

```bash
timedatectl set-ntp true
```

## 3. 磁盘分区与 Btrfs 子卷（核心）

目标磁盘：`/dev/nvme0n1`

> 💡 子卷布局说明：`@` 根目录、`@home` 用户目录、`@snapshots` 快照专用、`@cache`/`@log` 隔离高写入目录以减少快照体积。建议后续用 `snapper` 管理 `@` 与 `@home` 的快照。

### 方案 A：标准 UEFI（无加密）

```bash
cfdisk /dev/nvme0n1
# p1: 512M  EFI System         -> /boot
# p2: 剩余  Linux filesystem   -> 用于 Btrfs

# 格式化 Btrfs 并创建子卷
mkfs.btrfs -f /dev/nvme0n1p2
mount /dev/nvme0n1p2 /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@log
umount /mnt

# 挂载子卷（compress=zstd 压缩 + noatime 减少写入）
mount -o noatime,compress=zstd,subvol=@ /dev/nvme0n1p2 /mnt
mkdir -p /mnt/{boot,home,.snapshots,var/cache,var/log}
mount -o noatime,compress=zstd,subvol=@home      /dev/nvme0n1p2 /mnt/home
mount -o noatime,compress=zstd,subvol=@snapshots /dev/nvme0n1p2 /mnt/.snapshots
mount -o noatime,compress=zstd,subvol=@cache     /dev/nvme0n1p2 /mnt/var/cache
mount -o noatime,compress=zstd,subvol=@log       /dev/nvme0n1p2 /mnt/var/log

# 挂载 EFI 分区
mount /dev/nvme0n1p1 /mnt/boot
```

### 方案 B：LUKS2 全盘加密 + Btrfs

```bash
cfdisk /dev/nvme0n1
# p1: 512M  EFI (ef00)
# p2: 剩余  Linux filesystem (8300)

# 创建加密容器
cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup open /dev/nvme0n1p2 cryptroot

# 格式化 Btrfs 并创建子卷
mkfs.btrfs -f /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@log
umount /mnt

# 挂载子卷
mount -o noatime,compress=zstd,subvol=@ /dev/mapper/cryptroot /mnt
mkdir -p /mnt/{boot,home,.snapshots,var/cache,var/log}
mount -o noatime,compress=zstd,subvol=@home      /dev/mapper/cryptroot /mnt/home
mount -o noatime,compress=zstd,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots
mount -o noatime,compress=zstd,subvol=@cache     /dev/mapper/cryptroot /mnt/var/cache
mount -o noatime,compress=zstd,subvol=@log       /dev/mapper/cryptroot /mnt/var/log

# 挂载 EFI 分区
mount /dev/nvme0n1p1 /mnt/boot
```

### （可选）交换空间 / 休眠支持

若需要支持休眠（hibernate），建议在 `@` 子卷下创建 Btrfs swapfile：

```bash
btrfs filesystem mkswapfile --size 16g --uuid clear /mnt/swap/swapfile
swapon /mnt/swap/swapfile
```

> 注意：swapfile 所在子卷需禁用 CoW（`chattr +C`），且需记录 `resume_offset` 用于 systemd-boot 引导参数。

## 4. 镜像源优化

编辑 `/etc/pacman.d/mirrorlist`，将国内镜像源（如中科大、清华、阿里云）置顶，或使用 `reflector` 自动生成：

```bash
reflector --country China --age 12 --protocol https --sort rate \
  --save /etc/pacman.d/mirrorlist
```

## 5. 基础系统安装

```bash
pacstrap -K /mnt base base-devel linux linux-firmware \
    sudo vim git networkmanager iwd intel-ucode amd-ucode btrfs-progs
```

> 根据 CPU 厂商，`intel-ucode` 与 `amd-ucode` 只需保留对应一项，另一项可省略以节省空间（保留两者也不影响正常使用）。

生成 fstab：

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

生成后建议检查一遍，确认各子卷挂载选项（`subvol=`、`compress=zstd` 等）无误。

## 6. 系统配置

```bash
arch-chroot /mnt
```

### 时区与本地化

```bash
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc
```

编辑 `/etc/locale.gen`，取消注释：

```
en_US.UTF-8 UTF-8
zh_CN.UTF-8 UTF-8
```

```bash
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

### 主机名、网络与用户

```bash
echo "arch" > /etc/hostname

cat >> /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   arch.localdomain arch
EOF

useradd -m -G wheel -s /bin/bash lk
passwd lk
passwd root

visudo
# 取消注释：%wheel ALL=(ALL:ALL) ALL
```

### Mkinitcpio（Btrfs / LUKS）

编辑 `/etc/mkinitcpio.conf` 中的 `HOOKS`：

```bash
# 无加密 Btrfs 方案（Btrfs 由 filesystems 钩子自动处理，无需单独加 btrfs）：
HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block filesystems fsck)

# LUKS + Btrfs 方案（需在 block 之后、filesystems 之前加入 encrypt）：
HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck)
```

重新生成 initramfs：

```bash
mkinitcpio -P
```

### 引导（systemd-boot）

```bash
bootctl install
```

创建 `/boot/loader/loader.conf`：

```ini
default arch.conf
timeout 3
console-mode max
editor no
```

创建 `/boot/loader/entries/arch.conf`：

```ini
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img

# 无加密方案 options：
# options root=UUID=<btrfs-uuid> rootflags=subvol=@ rw

# LUKS 加密方案 options：
# options cryptdevice=UUID=<luks-uuid>:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw
```

> 提示：使用 `blkid` 查看对应分区的 UUID（无加密方案取 `p2` 的 UUID，LUKS 方案取加密分区本身的 UUID）。

### 启用服务

```bash
systemctl enable NetworkManager iwd bluetooth fstrim.timer
```

> Btrfs 已内置压缩与 CoW 特性，`fstrim.timer` 对 SSD/NVMe 定期 TRIM 有助于维持性能。

---

## 7. 桌面环境（niri + 相关组件）

```bash
pacman -S niri foot fcitx5 fcitx5-rime swaybg swaylock swayidle mako
pacman -S noto-fonts noto-fonts-cjk ttf-jetbrains-mono-nerd
pacman -S pipewire wireplumber pipewire-pulse btop cava
```

配置 fcitx5 环境变量（`/etc/environment` 或 `~/.pam_environment`）：

```
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
```

---

## 8. 重启进入系统

```bash
exit
umount -R /mnt
reboot
```

---

## 9. 恢复个人配置（dotfiles）

```bash
git clone --bare git@github.com:inecekk/arch-config.git ~/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dotfiles checkout main
dotfiles config status.showUntrackedFiles no
```

> 若 `checkout` 报错提示文件已存在，可先备份冲突文件（如 `.bashrc`）再重试。

---

## 10. 日常维护

```bash
# 系统更新（含 AUR）
paru -Syu

# 清理 pacman 缓存，仅保留最近 3 个版本
paccache -rk3

# 检查 Btrfs 文件系统状态
btrfs filesystem usage /
btrfs scrub start /
```

建议配合 `snapper` 定期清理快照，避免子卷体积膨胀：

```bash
snapper -c root list
snapper -c root cleanup number
```

---

**维护者**：inecekk
**Host**：Arch Linux (linux-lts) · niri · foot · fcitx5-rime · Noctalia
```
