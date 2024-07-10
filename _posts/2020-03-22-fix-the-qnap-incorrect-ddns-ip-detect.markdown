---
layout: post
title: 修复 QNAP NAS 特殊情况下 DDNS 服务识别外部 IP 错误的问题
date: '2020-03-22 06:16:00'
tags:
- nas
- qnap
- hash-import-2023-03-22-16-36
---

> 当 QNAP NAS 设备接入的网络配置了自动翻墙的话，在 QNAP NAS 的 **myQNAPcloud** 应用中， **My DDNS** 功能就有可能将 IPv4 地址识别为翻墙的代理 IP 地址，从而无法通过系统设置的 DDNS 功能从自定义的 `*.myqnapcloud.com` 域名远程访问 NAS。

## 1. 家庭网络拓扑图（家庭中的 NAS 是怎么连接到互联网的）
<figure class="kg-card kg-image-card"><img src="https://raw.githubusercontent.com/5cr1pt/img4markdown/master/pics/20200322162710.png" class="kg-image" alt loading="lazy"></figure>

其中入口路由器和无线路由器可以是同一个，即家庭中的 PPPOE 拨号上网和无线 WiFi 路由器；或者可以是多个，比如旁路翻墙的设备等。

## 2. DDNS IP 更新错误的问题（可能导致无法通过自定义的 `*.myqnapcloud.com` 域名访问 NAS）
<figure class="kg-card kg-image-card"><img src="https://raw.githubusercontent.com/5cr1pt/img4markdown/master/pics/20200322163320.png" class="kg-image" alt loading="lazy"></figure>

如图，DDNS IP 可能被识别为翻墙服务的 IP 地址，而不是实际的宽带外网地址。

## 3. 原因分析并修复

在 QNAP 系统的 `/etc/init.d/` 目录下有一个 `get_external_ip.sh` 的脚本，该脚本的内容为：

    #!/bin/bash
    # Script for getting an external WAN IP
    
    # get external IP from qcloud API
    WAN_IP=`/usr/local/bin/qcloud_cli -x 13 -e`
    [-z "$WAN_IP"] && exit 1
    echo $WAN_IP
    exit 0

可以看到获取 WAN\_IP 也就是宽带外网 IP 是通过 `/usr/local/bin/qcloud_cli -x 13 -e` 来实现的，通过追踪该可执行文件，发现该文件通过解析 `edge.api.myqnapcloud.com` 这个域名并访问，来获取外部 IP 地址的。

### 3.1 修复问题

在正常上网服务的配置里添加例外即可。

如在路由器固件为 OPENWRT/LEDE 的路由器上使用 `ShadowSocksR Plus+` 实现的，可以将 `edge.api.myqnapcloud.com` 域名添加到 `访问控制 -> 不走代理的域名` 中：

<figure class="kg-card kg-image-card"><img src="https://raw.githubusercontent.com/5cr1pt/img4markdown/master/pics/20200322164521.png" class="kg-image" alt loading="lazy"></figure>