# 显式安装软件包清单 (54 个)

> 来源: `pacman -Qqe` + AUR 包  
> 更新时间: 2025-08-16  
> 官方源: 45 个 | AUR: 9 个

---

## 📦 官方源包 (45)

### 基础系统 (8)
```
base base-devel bash-completion sudo vim git
```

### 内核与硬件 (9)
```
linux-lts linux-firmware-amdgpu linux-firmware-realtek
amd-ucode btrfs-progs efibootmgr wireless-regdb
alsa-utils upower
```

### 网络与安全 (5)
```
iwd avahi openssh wireless-regdb tlp
```

### 桌面环境 (12)
```
niri foot fcitx5 fcitx5-gtk fcitx5-qt fcitx5-rime
noctalia swaybg swayidle swaylock swaync waybar
```

### 字体 (3)
```
ttf-jetbrains-mono wqy-microhei noto-fonts
```

### 音频 (4)
```
pipewire pipewire-alsa pipewire-pulse wireplumber
```

### 工具与实用程序 (7)
```
btop dust tree jq neofetch-git impala mpv
```

### 截图录屏 (3)
```
wf-recorder grim slurp
```

### 电源与外设 (3)
```
tlp brightnessctl bluez-utils
```

### 代理与输入法 (2)
```
dae qt6-websockets
```

### 文件管理 (2)
```
spacefm-bin w3m
```

### 备份与 AUR (3)
```
paru rsync inotify-tools
```

---

## 📦 AUR 包 (9)

### 通信/社交
```
linuxqq materialgram-bin
```

### 开发/工具
```
go-musicfox-git miyu visual-studio-code-bin
```

### 游戏/娱乐
```
osu-lazer-bin zen-browser-bin
```

### 文件管理/其他
```
spacefm-bin neofetch-git
```

---

## 🔧 安装方法

### 一键安装 (推荐)
```bash
# 安装官方源包
sudo pacman -S --needed - < ~/.dotfiles/pkglist-official.txt

# 安装 AUR 包 (需 paru)
paru -S --needed - < ~/.dotfiles/pkglist-aur.txt

# 或完整安装
paru -S --needed - < ~/.dotfiles/pkglist-all.txt
```

### 通过 dotfiles 恢复
```bash
# 克隆后自动恢复包
install-dotfiles.sh --with-packages
```

---

## 📋 总计

| 类型 | 数量 |
|------|------|
| 官方源 | 45 |
| AUR | 9 |
| **总计** | **54** |

> 完整依赖列表: `pacman -Qq` (含依赖, 通常 500+ 个)
