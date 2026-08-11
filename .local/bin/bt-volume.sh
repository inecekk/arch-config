#!/bin/bash
# 蓝牙耳机默认音量压到 6%，每 10 秒轮询一次
while true; do
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.06 2>/dev/null
  sleep 10
done
