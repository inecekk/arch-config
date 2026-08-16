# Arch Linux 手动安装完整指南

> **适用场景**：全新机器、重装系统、迁移到新硬盘  
> **目标架构**：x86_64 UEFI + systemd-boot + (可选 LUKS 加密)  
> **预计耗时**：30–60 分钟（视网络/经验而定）

---

## 📋 准备工作

### 1. 下载 ISO 并制作启动盘
```bash
# 官方镜像下载
https://archlinux.org/download/
```

### 2. BIOS/UEFI 设置
| 设置项 | 推荐值 | 说明 |
|--------|--------|------|
| **启动模式** | **UEFI Only** | 禁用 Legacy |
| **Secure Boot** | **Disabled** | 官方内核未签名 |
| **快速启动** | **Disabled** | 避免分区表损坏 |

---

## 💾 磁盘分区方案

### 方案 A：标准 UEFI (无加密)
```bash
# 查看磁盘
lsblk -f
cfdisk /dev/nvme0n1
```

| 分区 | 大小 | 类型 | 挂载点 |
|------|------|------|--------|
| EFI | 512M–1G | ESP | `/boot` |
| Root | 剩余空间 | ext4 | `/` |

### 方案 B：LUKS 加密
```bash
# 1. 打开 cfdisk 创建分区
cfdisk /dev/nvme0n1
# EFI: 512M | LUKS: 剩余

# 2. 格式化 EFI 分区
mkfs -t vfat -F32 /dev/nvme0n1p1

# 3. 创建 LUKS 容器
cryptsetup luksFormat --type luks2 /dev/nvme0n1p2
cryptsetup open /dev/nvme0n1p2 cryptroot

# 4. 在解密设备上创建 ext4 文件系统
mkfs -t ext4 /dev/mapper/cryptroot

# 5. 挂载
mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
```

> ⚠️ **警告**：LUKS 密码丢失 = 数据永久丢失，务必备份 header。

---

## 🏗️ 基础系统安装

### 1. 镜像源优化
```bash
# 编辑镜像列表
vim /etc/pacman.d/mirrorlist
# 推荐国内源:
# Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
# Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch
```

### 2. 安装基础包
```bash
# 标准安装
pacstrap -K /mnt base base-devel linux linux-firmware \
    sudo vim git networkmanager iwd \
    intel-ucode amd-ucode

# 生成 fstab
genfstab -U /mnt >> /mnt/etc/filesystem
cat /mnt/etc/filesystem  # 核对 UUID
```

---

## ⚙️ 系统配置 (arch-chroot)

```bash
arch-chroot /mnt
```

### 时区与本地化
```bash
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc

# 编辑 locale.gen，取消注释 en_US.UTF-8 和 zh_CN.UTF-8
vim /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/localtime.conf
```

### 主机名
```bash
echo "archlinux" > /etc/hostname
cat > /etc/hosts << 'EOF'
127.0.0.1   localhost
::1         localhost
127.0.1.1   archlinux.localdomain archlinux
EOF
```

### 用户管理
```bash
passwd  # 设置 root 密码
useradd -m -G wheel -s /bin/bash lk
passwd lk  # 设置用户密码

# 赋予 sudo 权限
EDITOR=vim visudo
# 取消注释: %wheel ALL=(ALL:ALL) ALL
```

### 引导加载器 (systemd-boot)
```bash
bootctl install

# 创建启动项
cat > /boot/loader/entries/arch.conf << 'EOF'
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options root=/dev/nvme0n1p2 rw
EOF

cat > /boot/loader/loader.conf << 'EOF'
default arch
timeout 3
console-mode max
editor no
EOF
```

### 启用服务
```bash
systemctl enable NetworkManager
systemctl enable iwd
systemctl enable fstrim.timer
```

---

## 🔧 硬件优化

### 看门狗黑名单 (防止关机卡死)
```bash
mkdir -p /etc/modprobe.d
cat > /etc/modprobe.d/watchdog.conf << 'EOF'
# AMD 看门狗
blacklist sp5100_tco
# Intel 看门狗
blacklist iTCO_wdt
# ACPI 看门狗
blacklist wdat_wdt
EOF
```

---

## 🖥️ 桌面环境安装 (niri)

```bash
pacman -S --needed \
    niri foot fcitx5 fcitx5-rime \
    waybar swaybg swaylock swayidle \
    xdg-desktop-portal-wlr \
    polkit-gnome gnome-keyring \
    noto-fonts noto-fonts-cjk \
    pipewire wireplumber \
    bluez bluez-utils

systemctl enable bluetooth
```

---

## 📦 恢复个人配置

```bash
# 克隆裸仓库
git clone --bare git@github.com:inecekk/arch-config.git ~/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dotfiles checkout main
dotfiles config status.showUntrackedFiles no

# 恢复包列表
pacman -S $(cat ~/.config/pkglist/pkglist-official.txt)
paru -S $(cat ~/.config/pkglist/pkglist-aur.txt)

# 恢复系统配置
install-dotfiles.sh --full --force
```

---

## ✅ 安装后检查

| 项目 | 命令 | 预期 |
|------|------|------|
| 启动模式 | `bootctl status` | systemd-boot 正常 |
| 时间同步 | `timedatectl status` | NTP: yes |
| 网络 | `nmcli device` | 已连接 |
| 音频 | `wpctl status` | PipeWire 运行 |

---

## ⚠️ 常见问题

| 问题 | 原因 | 解决 |
|------|------|------|
| **emergency shell** | fstab UUID 错误 | 重新 `arch-chroot` 核对 |
| **LUKS 解密失败** | 密码错误 | 确认密码或从 header 恢复 |
| **输入法不跟随** | fcitx5 环境变量缺失 | 设置 `GTK_IM_MODULE=fcitx5` |
| **字体发虚** | 中文字体缺失 | 安装 `noto-fonts-cjk` |
