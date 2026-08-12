#!/bin/bash                                       
# 蓝牙耳机连接后不再强制调音量6%                                
while true; do                                    
    sink=$(wpctl status | grep -i bluez | head -1)
    if [ -n "$sink" ]; then                       
        # 保留当前音量，不修改                              
        sleep 30                                  
    else                                          
        sleep 5                                   
    fi                                            
done                                              
