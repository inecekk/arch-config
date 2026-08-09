#!/bin/bash
# 禁用 RTL8852BE 无线网卡（GPP6）的 S4 休眠唤醒
# 合盖休眠时网卡信号事件会把系统拉醒，需要开机时禁用它
if grep -q "GPP6.*enabled" /proc/acpi/wakeup; then
    echo GPP6 > /proc/acpi/wakeup
fi
exit 0
