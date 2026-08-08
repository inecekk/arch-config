/* Taken from https://github.com/djpohly/dwl/issues/466 */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }

/* --- 1. 外观与透明度基础配置 --- */
static const int sloppyfocus              = 1;    /* 鼠标跟随焦点 (1=开启, 0=关闭) */
static const int bypass_surface_visibility = 0;   /* 优化遮挡表面的可见性传递 */
static const unsigned int borderpx         = 2;    /* 窗口边框像素宽度 */
static const float rootcolor[]             = COLOR(0x1e1e2eff); /* 桌面背景色 (Catppuccin 深色) */
static const float bordercolor[]           = COLOR(0x45475aee); /* 非活动窗口边框颜色 */
static const float focuscolor[]            = COLOR(0x89b4faff); /* 活动/聚焦窗口边框颜色 */
static const float urgentcolor[]           = COLOR(0xf38ba8ff); /* 紧急状态窗口边框颜色 */
static const float fullscreen_bg[]         = {0.0f, 0.0f, 0.0f, 1.0f}; /* 全屏时的背景纯色 */

/* --- 2. 标签页 (Workspaces) 配置 --- */
#define TAGCOUNT (9)                             /* 工作区/标签页总数设为 9 */

/* --- 3. 日志级别 --- */
static int log_level = WLR_ERROR;                /* Wayland 核心日志过滤级别 */

/* --- 4. 窗口行为规则 (Rules) --- */
static const Rule rules[] = {
    /* app_id             title    tags mask    isfloating    monitor */
    { "Gimp_EXAMPLE",     NULL,    0,           1,            -1 }, 
    { "firefox_EXAMPLE",  NULL,    1 << 8,      0,            -1 }, 
};

/* --- 5. 布局 (Layouts) 配置 --- */
static const Layout layouts[] = {
    /* symbol     arrange function */
    { "[]=",      tile },    /* 主从平铺布局 */
    { "><>",      NULL },    /* 浮动布局 */
    { "[M]",      monocle }, /* 极大化单窗口平铺模式 */
};

/* --- 6. 显示器与默认缩放 (Scale: 2.0) --- */
static const MonitorRule monrules[] = {
    /* name       mfact  nmaster scale layout               transform             x    y */
    { NULL,       0.55f, 1,      2,    &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL,    -1,  -1 }, 
};

/* --- 7. 键盘与输入设备配置 --- */
static const struct xkb_rule_names xkb_rules = {
    .options = NULL,
};

static const int repeat_rate = 25;               
static const int repeat_delay = 600;             

/* --- 8. 触控板 (Trackpad) 配置 --- */
static const int tap_to_click = 1;               
static const int tap_and_drag = 1;               
static const int drag_lock = 1;                  
static const int natural_scrolling = 0;          
static const int disable_while_typing = 1;       
static const int left_handed = 0;                
static const int middle_button_emulation = 0;    
static const enum libinput_config_scroll_method scroll_method = LIBINPUT_CONFIG_SCROLL_2FG;
static const enum libinput_config_click_method click_method = LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS;
static const uint32_t send_events_mode = LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;
static const enum libinput_config_accel_profile accel_profile = LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
static const double accel_speed = 0.0;           
static const enum libinput_config_tap_button_map button_map = LIBINPUT_CONFIG_TAP_MAP_LRM;

/* --- 9. 快捷键与修饰键绑定 --- */
#define MODKEY WLR_MODIFIER_LOGO                 /* 将主修饰键 (Mod) 定义为 Super 键 */

#define TAGKEYS(KEY,SKEY,TAG) \
    { MODKEY,                       KEY,        view,         {.ui = 1 << TAG} }, \
    { MODKEY|WLR_MODIFIER_CTRL,     KEY,        toggleview,   {.ui = 1 << TAG} }, \
    { MODKEY|WLR_MODIFIER_SHIFT,    SKEY,       tag,          {.ui = 1 << TAG} }, \
    { MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT,SKEY,toggletag, {.ui = 1 << TAG} }

#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

static const char *termcmd[] = { "foot", NULL };   
static const char *menucmd[] = { "fuzzel", NULL }; 

static const Key keys[] = {
    /* modifier                     key                     function            argument */
    
    /* --- A. 核心应用与效率启动 --- */
    { MODKEY,                       XKB_KEY_Return,         spawn,              {.v = termcmd} }, 
    { MODKEY,                       XKB_KEY_d,              spawn,              {.v = menucmd} }, 
    { MODKEY,                       XKB_KEY_e,              spawn,              SHCMD("pcmanfm") }, 
    { MODKEY,                       XKB_KEY_g,              spawn,              SHCMD("google-chrome-stable") }, 
    { MODKEY,                       XKB_KEY_z,              spawn,              SHCMD("zen-browser") }, 
    { MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_C,              spawn,              SHCMD("code") }, 
    { MODKEY,                       XKB_KEY_t,              spawn,              SHCMD("materialgram") }, 
    { MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_Q,              spawn,              SHCMD("qq --enable-features=UseOzonePlatform --ozone-platform=wayland") }, 
    { MODKEY,                       XKB_KEY_m,              spawn,              SHCMD("musicfox-random.sh") }, 
    { MODKEY,                       XKB_KEY_n,              spawn,              SHCMD("foot -e nnn") }, 

    /* --- B. 系统实用工具与壁纸 (awww 动态壁纸集成) --- */
    { MODKEY,                       XKB_KEY_s,              spawn,              SHCMD("grim -g \"$(slurp)\" - | swappy -f -") }, 
    { MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_Return,         spawn,              SHCMD("awww img /home/lk/Pictures/wallpapers/360/134298742771617433.jpg") }, 

    /* --- C. 窗口生命周期与平铺布局微调 --- */
    { MODKEY,                       XKB_KEY_q,              killclient,         {0} }, 
    { MODKEY,                       XKB_KEY_f,              togglefullscreen,   {0} }, 
    { MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_V,              togglefloating,     {0} }, 
    { MODKEY,                       XKB_KEY_Tab,            view,               {0} }, 

    /* --- D. 焦点切换与平铺移动 --- */
    { MODKEY,                       XKB_KEY_Left,           focusmon,           {.i = WLR_DIRECTION_LEFT} },  
    { MODKEY,                       XKB_KEY_Right,          focusmon,           {.i = WLR_DIRECTION_RIGHT} }, 
    { MODKEY,                       XKB_KEY_Up,             focusstack,         {.i = -1} },                 
    { MODKEY,                       XKB_KEY_Down,           focusstack,         {.i = +1} },                 
    { MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_Left,           tagmon,             {.i = WLR_DIRECTION_LEFT} },  
    { MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_Right,          tagmon,             {.i = WLR_DIRECTION_RIGHT} }, 

    { MODKEY,                       XKB_KEY_j,              focusstack,         {.i = +1} },
    { MODKEY,                       XKB_KEY_k,              focusstack,         {.i = -1} },

    { MODKEY|WLR_MODIFIER_SHIFT,    XKB_KEY_E,              quit,               {0} },

    /* --- E. 全局多媒体硬件控制健 --- */
    { 0, XKB_KEY_XF86AudioRaiseVolume,    spawn, SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+ -l 1.0") }, 
    { 0, XKB_KEY_XF86AudioLowerVolume,    spawn, SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05-") },        
    { 0, XKB_KEY_XF86AudioMute,           spawn, SHCMD("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") },         
    { 0, XKB_KEY_XF86AudioPlay,           spawn, SHCMD("playerctl play-pause") },                                   
    { 0, XKB_KEY_XF86AudioNext,           spawn, SHCMD("playerctl next") },                                         
    { 0, XKB_KEY_XF86AudioPrev,           spawn, SHCMD("playerctl previous") },                                     
    { 0, XKB_KEY_XF86MonBrightnessUp,     spawn, SHCMD("brightnessctl --class=backlight set +10%") },             
    { 0, XKB_KEY_XF86MonBrightnessDown,   spawn, SHCMD("brightnessctl --class=backlight set 10%-") },             

    /* --- F. 工作区数字快捷键映射 (1-9) --- */
    TAGKEYS(                XKB_KEY_1, XKB_KEY_exclam,                     0),
    TAGKEYS(                XKB_KEY_2, XKB_KEY_at,                         1),
    TAGKEYS(                XKB_KEY_3, XKB_KEY_numbersign,                 2),
    TAGKEYS(                XKB_KEY_4, XKB_KEY_dollar,                     3),
    TAGKEYS(                XKB_KEY_5, XKB_KEY_percent,                    4),
    TAGKEYS(                XKB_KEY_6, XKB_KEY_asciicircum,                5),
    TAGKEYS(                XKB_KEY_7, XKB_KEY_ampersand,                  6),
    TAGKEYS(                XKB_KEY_8, XKB_KEY_asterisk,                   7),
    TAGKEYS(                XKB_KEY_9, XKB_KEY_parenleft,                  8),

    { WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_Terminate_Server, quit, {0} },
#define CHVT(n) { WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_XF86Switch_VT_##n, chvt, {.ui = (n)} }
    CHVT(1), CHVT(2), CHVT(3), CHVT(4), CHVT(5), CHVT(6),
    CHVT(7), CHVT(8), CHVT(9), CHVT(10), CHVT(11), CHVT(12),
};

/* --- 10. 鼠标行为绑定 --- */
static const Button buttons[] = {
    { MODKEY, BTN_LEFT,     moveresize,     {.ui = CurMove} },   
    { MODKEY, BTN_MIDDLE,   togglefloating, {0} },               
    { MODKEY, BTN_RIGHT,    moveresize,     {.ui = CurResize} }, 
};

/* --- 自启动程序列表 --- */
static const char *const autostart[] = {
    "sh", "-c", "export GTK_IM_MODULE=fcitx QT_IM_MODULE=fcitx XMODIFIERS=@im=fcitx SDL_IM_MODULE=fcitx GLFW_IM_MODULE=fcitx; fcitx5 -d", NULL,
    "sh", "-c", "awww init && sleep 0.5 && awww img /home/lk/Pictures/wallpapers/360/134298742771617433.jpg", NULL,
    "sh", "-c", "sudo dae run", NULL, 
    NULL 
};
