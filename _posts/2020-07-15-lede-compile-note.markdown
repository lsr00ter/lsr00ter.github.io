---
layout: post
title: LEDE 旁路由 x86 固件定制记录
date: '2020-07-15 06:20:00'
tags:
- openwrt
- lede
- hash-import-2023-03-22-16-36
---

在使用了几年 Linksys WRT1200AC 安装 OpenWrt 固件，用来正常上网后，这两年手头需要正常上网的设备越来越多（Netflix、Apple TV+、美区 iCloud 同步等），终于感觉网速有点不够用了，于是在 NAS 的虚拟机里安装了 LEDE 作为旁路由。在连续多次编译了 lean 大佬的 lede 固件，尝试做到了对于 **单网口旁路由** 来说使用最佳，然后记录了更方便进行再次编译的配置方式。

下面通过本地编译开始，然后转移到使用 Github Action 自动编译，做到完全伸手可得。

## 本地编译

这里先贴一下 Lean 大佬的 lede 源码仓库上说明的步骤：

### 注意：

1. 不要用 root 用户 git 和编译！！！
2. 国内用户编译前最好准备好梯子
3. 默认登陆 IP `192.168.1.1`, 密码 `password`

### 编译命令如下：

1. 首先装好 Ubuntu 64bit，推荐 Ubuntu 18 LTS x64

命令行输入 `sudo apt-get -y update` 更新系统软件源，然后输入命令安装依赖：

    sudo apt-get -y install build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3.5 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget swig

1. 使用 `git clone https://github.com/coolsnowwolf/lede` 命令下载源代码，然后 `cd lede` 进入目录

**进行完上面的步骤，就可以开始自定义自己需要的固件了：**

### 启用 SSR-Plus

编辑 `./feeds.conf.default` 文件，取消注释 `#src-git helloworld https://github.com/fw876/helloworld`，修改完成后该文件如下：

    src-git packages https://github.com/coolsnowwolf/packages
    src-git luci https://github.com/coolsnowwolf/luci
    src-git routing https://git.openwrt.org/feed/routing.git
    src-git telephony https://git.openwrt.org/feed/telephony.git
    src-git freifunk https://github.com/freifunk/openwrt-packages.git
    #src-git video https://github.com/openwrt/video.git
    #src-git targets https://github.com/openwrt/targets.git
    #src-git management https://github.com/openwrt-management/packages.git
    #src-git oldpackages http://git.openwrt.org/packages.git
    #src-link custom /usr/src/openwrt/custom-feed
    src-git helloworld https://github.com/fw876/helloworld

### 修改路由器固件的初始网络配置

原版固件的默认登录 IP 地址为 `192.168.1.1`，如果刷完直接使用，一般会和家里的路由器 IP 地址冲突，这里修改一下。编辑 `./package/lean/default-settings/files/zzz-default-settings` 文件，在 `exit 0` 这一行上面添加如下代码（我一般在 `uci commit system` 这一行后面添加）：

    uci set network.lan.ipaddr='192.168.1.254' # 默认 IP 地址
    uci set network.lan.proto='static' # 静态 IP
    uci set network.lan.type='bridge' # 桥接
    uci set network.lan.ifname='eth0' # 网络端口默认 eth0
    uci set network.lan.netmask='255.255.255.0' # 子网掩码
    uci set network.lan.gateway='192.168.1.1' # 默认网关
    uci set network.lan.dns='192.168.1.1' # 默认上游 DNS 地址
    uci commit network

> 可选：在 `uci commit system` 这一行上面添加 `uci set system.@system[0].hostname=LEDE` 来设置主机名为 `LEDE`

修改完成后 `./package/lean/default-settings/files/zzz-default-settings` 文件部分如下：

    #!/bin/sh
    uci set luci.main.lang=zh_cn
    uci commit luci
    uci set system.@system[0].timezone=CST-8
    uci set system.@system[0].zonename=Asia/Shanghai
    uci set system.@system[0].hostname=LEDE
    uci commit system
    
    uci set network.lan.ipaddr='192.168.1.254'
    uci set network.lan.proto='static'
    uci set network.lan.type='bridge'
    uci set network.lan.ifname='eth0'
    uci set network.lan.netmask='255.255.255.0'
    uci set network.lan.gateway='192.168.1.1'
    uci set network.lan.dns='192.168.1.1'
    uci commit network
    
    ...

### 接着输入编译命令

更新编译源，并进入配置界面：

    $ ./scripts/feeds update -a
    $ ./scripts/feeds install -a
    $ make menuconfig # 进入配置界面

### 定制固件

这一步选择需要的插件：

> 如不需要 `automount/autosamba` 功能（自动挂载 USB/samba 共享），需要在 `Extra-packages` 菜单中取消选择 `automount` 和 `autosamba`。

进入 `Luci - Applications` 选择需要的插件：

    # 我常用的几个，只做旁路由使用
    luci-app-firewall # 防火墙和端口转发,必备
    luci-app-adbyby-plus # 广告屏蔽大师 Plus+
    luci-app-sfe # Turbo ACC 网络加速(开启 Fast Path 转发加速)
    luci-app-unblockNeteaseMusic # 解锁网易云
    luci-app-ssr-plus
    
    # 附加应用，按需选择
    luci-app-wol # 网络唤醒
    luci-app-accesscontrol # 上网时间控制
    luci-app-arpbind # IP/MAC 绑定
    luci-app-autoreboot # 计划重启
    luci-app-ddns # 动态域名解析
    luci-app-filetransfer # 上传 ipk 文件功能
    luci-app-frpc # 内网穿透 Frp
    luci-app-ipsec-vpnd # IPSec 服务端
    luci-app-nlbwmon # 网络带宽监视器
    luci-app-ramfree # 释放内存
    luci-app-rclone # rclone
    luci-app-samba # 网络共享（samba）
    luci-app-upnp # 通用即插即用 UPnP(端口自动转发)
    luci-app-vlmcsd # KMS 服务器（WIN 激活工具）
    luci-app-vsftpd # FTP 服务器
    luci-app-webadmin # Web 管理页面设置
    luci-app-xlnetacc # 迅雷下载
    luci-app-zerotier # 虚拟局域网
    luci-app-aria2 # Aria2 下载
    luci-app-hd-idle # 硬盘休眠
    luci-app-mwan3 # MWAN 负载均衡
    luci-app-openvpn # OpenVPN 客户端
    luci-app-openvpn-server # OpenVPN 服务端
    luci-app-pptp-server # PPTP 服务端
    luci-app-sqm # 流量智能队列管理(QOS)
    luci-app-transmission # BT 下载
    luci-app-usb-printer # USB 打印服务器
    luci-app-wireguard # VPN 服务器 WireGuard 状态
    luci-app-wrtbwmon # 实时流量监测

选择完成后 `Save` 保存。

### 继续编译命令

1. `make -j8 download V=s` 下载dl库（国内请尽量全局科学上网）
2. 输入 `make -j1 V=s` （`-j1` 后面数字`1`是线程数。第一次编译推荐用单线程）进行编译你要的固件。

**编译完成后固件在 `./bin/targets/` 文件夹内。**

## 使用 Github 的 Action 功能自动编译

> 参考[【教程】会本地编译的情况下，怎么用GitHub Actions云编译？](https://github.com/coolsnowwolf/lede/issues/2288)

以 `lede` 自带的 Action 为例来修改。文件路径为 `./.github/workflows/openwrt-ci.yml`。

### 提取本地自定义插件和默认配置的差异

在上面本地编译时，当完成“选择完成后 `Save` 保存。”后，会生成一个 `.config` 文件，此时运行下面命令来提取配置差异：

    make defconfig
    ./scripts/diffconfig.sh > diff.config # 将差异保存在 diff.config 文件中

### 在 `openwrt-ci.yml` 中添加自定义配置

#### 启用 SSR-Plus

修改 `opennwrt-ci.yml` 的这一部分：

          - name: Update feeds
            run: |
              sed -i 's/\"#src-git\"/\"src-git\"/g' ./feeds.conf.default
              ./scripts/feeds update -a
              ./scripts/feeds install -a

在 `run: |` 的下一行添加： `echo 'src-git helloworld https://github.com/fw876/helloworld' >> ./feeds.conf.default`，添加完后配置为：

          - name: Update feeds
            run: |
              echo 'src-git helloworld https://github.com/fw876/helloworld' >> ./feeds.conf.default
              sed -i 's/\"#src-git\"/\"src-git\"/g' ./feeds.conf.default
              ./scripts/feeds update -a
              ./scripts/feeds install -a

#### 添加自定义的插件和默认网络配置

修改 `openwrt-ci.yml` 如下部分：

          - name: Generate configuration file
            run: make defconfig

将之前生成的配置差异文件 `diff.config` 中的内容拷贝出来，填入 `openwrt-ci.yml` ，并增加默认网络配置，配置后如下：

          - name: Generate configuration file
            run: |
              rm -f ./.config*
              touch ./.config
              cat >> .config <<EOF
              #
              # ========================固件定制部分========================
              #
              CONFIG_TARGET_x86=y
              CONFIG_TARGET_x86_64=y
              CONFIG_TARGET_x86_64_DEVICE_generic=y
              # CONFIG_PACKAGE_luci-app-accesscontrol is not set
              # CONFIG_PACKAGE_luci-app-arpbind is not set
              CONFIG_PACKAGE_luci-app-autoreboot=m
              CONFIG_PACKAGE_luci-app-ddns=m
              # CONFIG_PACKAGE_luci-app-filetransfer is not set
              CONFIG_PACKAGE_luci-app-frpc=m
              CONFIG_PACKAGE_luci-app-ipsec-vpnd=m
              CONFIG_PACKAGE_luci-app-nlbwmon=m
              CONFIG_PACKAGE_luci-app-ramfree=m
    
              ...
              # 省略一部分配置信息
              ...
    
              #
              # ========================固件定制部分结束========================
              #
              EOF
              sed -i 's/^[\t]*//g' ./.config
              make defconfig
    
              # 固件网络配置
              sed -i "10i # network config" ./package/lean/default-settings/files/zzz-default-settings
              # 默认 IP 地址，旁路由时不会和主路由的 192.168.1.1 冲突
              sed -i "11i uci set network.lan.ipaddr='192.168.1.5'" ./package/lean/default-settings/files/zzz-default-settings
              sed -i "12i uci set network.lan.proto='static'" ./package/lean/default-settings/files/zzz-default-settings
              sed -i "13i uci set network.lan.type='bridge'" ./package/lean/default-settings/files/zzz-default-settings
              sed -i "14i uci set network.lan.ifname='eth0'" ./package/lean/default-settings/files/zzz-default-settings
              sed -i "15i uci set network.lan.netmask='255.255.255.0'" ./package/lean/default-settings/files/zzz-default-settings
              # 主路由 IP 地址
              sed -i "16i uci set network.lan.gateway='192.168.1.1'" ./package/lean/default-settings/files/zzz-default-settings
              # 解析国内网站时，上游 DNS 服务器为主路由器
              sed -i "17i uci set network.lan.dns='192.168.1.1'" ./package/lean/default-settings/files/zzz-default-settings
              sed -i "18i uci commit network\n" ./package/lean/default-settings/files/zzz-default-settings

## 开机后的旁路由设置

1. 接口 IP 地址改静态，和主路由同一个网段
2. 接口的 IPv4 网关为主路由网关
3. 接口的 DNS 地址为主路由地址，也可以为自定义 DNS 地址
4. 接口的 DHCP 设置为 **忽略此接口** （DHCP 由主路由来分配）
5. 设置相关插件（SSR Plus，广告屏蔽大师 Plus 等）
