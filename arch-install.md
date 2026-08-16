# Arch Linux 手动安装指南

> 适用：UEFI + systemd-boot + LUKS加密(可选) + niri Wayland 桌面  
> 目标分区：/dev/nvme0n1 (NVMe) 或 /dev/sda (SATA)  
> 所有命令需在 root 权限下执行，会清空目标磁盘数据

---

## 1. 准备工作

- 下载 ISO 并校验
- 写入 U 盘
- BIOS 设置：UEFI Only、Secure Boot Disabled、快速启动 Disabled

---

## 2. 启动与网络

确认 UEFI 模式：`ls /sys/firmware/efi/efivars`  
网络配置：有线自动 DHCP，无线用 iwctl

---

## 3. 磁盘分区 (核心)

目标磁盘：/dev/nvme0n1

### 方案 A：标准 UEFI (无加密)

```bash
cfdisk /dev/nvme0n1
# p1: 512M EFI -> /boot
# p2: 剩余 ext4 -> /

# 格式化与挂载
# 使用对应工具格式化分区
# mount /dev/nvme0n1p2 /mnt
# mkdir -p /mnt/boot
# mount /dev/nvme0n1p1 /mnt/boot
```

### 方案 B：LUKS2 全盘加密

```bash
cfdisk /dev/nvme0n1
# p1: 512M EFI (ef00)
# p2: 剩余 Linux filesystem (8300)

# 加密容器
# cryptsetup luksFormat /dev/nvme0n1p2
# cryptsetup open /dev/nvme0n1p2 cryptroot
# 格式化并挂载
# mount /dev/mapper/cryptroot /mnt
```

---

## 4. 镜像源优化

编辑 /etc/pacman.d/mirrorlist，置顶国内源

---

## 5. 基础系统安装

```bash
pacstrap -K /mnt base base-devel linux linux-firmware \
    sudo vim git networkmanager iwd intel-ucode amd-ucode
```

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

---

## 6. 系统配置

```bash
arch-chroot /mnt
```

### 时区 本地化
- 时区 Asia/Shanghai
- locale.gen 取消注释 en_US.UTF-8 zh_CN.UTF-8
- locale-gen
- /etc/locale.conf 设置 LANG=en_US.UTF-8

### 主机名 网络 用户
- /etc/hostname, /etc/hosts
- useradd -m -G wheel -s /bin/bash lk
- visudo 启用 wheel 组 sudo

### Mkinitcpio
```bash
# /etc/mkinitcpio.conf HOOKS
# LUKS: (base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck)
# Btrfs: 添加 btrfs
# mkinitcpio -P
```

### 引导
```bash
bootctl install
# /boot/loader/entries/arch.conf
# title Arch Linux
# linux /vmlinuz-linux
# initrd /intel-ucode.img
# initrd /initramfs-linux.img
# options root=UUID=... rw
```

### 服务
```bash
systemctl enable NetworkManager iwd bluetooth fstrim.timer
```

---

## 7. 桌面环境

```bash
pacman -S niri foot fcitx5 fcitx5-rime swaybg swaylock swayidle mako
pacman -S noto-fonts noto-fonts-cjk ttf-jetbrains-mono-nerd
pacman -S pipewire wireplumber pipewire-pulse btop cava
```

---

## 10. 恢复个人配置

```bash
git clone --bare git@github.com:inecekk/arch-config.git ~/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dotfiles checkout main
dotfiles config status.showUntrackedFiles no
```

---

## 维护

```bash
paru -Syu
paccache -rk3
```

---

> 维护者: inecekk  
> Host: Arch Linux (linux-lts) niri foot fcitx5-rime Noctalia
