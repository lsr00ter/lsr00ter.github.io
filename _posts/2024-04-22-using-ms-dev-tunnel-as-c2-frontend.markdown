---
layout: post
title: 使用 Microsoft Dev Tunnels 作为 C2 前置转发服务
slug: using-ms-dev-tunnel-as-c2-frontend
date: '2024-04-22 12:00:22'
tags:
- c2
---

> [[https://redsiege.com/blog/2024/04/using-microsoft-dev-tunnels-for-c2-redirection/](https://redsiege.com/blog/2024/04/using-microsoft-dev-tunnels-for-c2-redirection/)]

Microsoft Dev Tunnels 允许开发人员在互联网上安全地共享本地 Web 服务。它使开发人员能够将其本地开发环境与云服务连接起来，与同事共享正在进行的工作，并帮助构建 Webhook。开发隧道主要用于临时测试和开发目的，不建议用于生产工作负载。该功能目前为公共预览版，这意味着它是在没有服务级别协议的情况下提供的，并且可能具有受限的功能。`devtunnel` 可执行文件本身由 Microsoft 签名。

## 准备

使用 `dev tunnels` 需要 github/microsoft 账户，建议使用一次性 github 账户。`devtunnel` 支持 Windows、Linux 和 MacOS。完整文档在[这里](https://learn.microsoft.com/en-us/azure/developer/dev-tunnels/cli-commands)。
安装步骤：

1. 在 linux 服务器下载安装，不需要 `root` 权限
`wget -O devtunnel https://aka.ms/TunnelsCliDownload/linux-x64 && chmod +x devtunnel`
2. 使用 github 账号登录，通过命令获取登录 URL 及验证码
`./devtunnel user login -g -d`
3. 通过 Web 浏览器访问 [https://github.com/login/device](https://github.com/login/device) 并且验证 GitHub 账号，然后输入授权码（上图为 `2EFC-D183` ）并授权
4. 在本地创建到 443 端口的隧道，`-a` 设置允许匿名访问，根据需要选择 `http` 或者 `https`，如果本地只有一个隧道，该隧道为默认隧道，`host` 命令启用隧道
./devtunnel create -a
./devtunnel port create -p 443 --protocol https
./devtunnel host
5. 在 cobaltstrike 建立 HTTPS 监听器，使用 `devtunnel` 的端口和 `host`
6. 创建 beacon 并运行，即可收到上线主机信息

## 排错

在 `devtunnel` 启动时，微软提供了一个基于 web 的监控攻击：Tunnel Inspection URL
应该注意的是，开发隧道**破坏了原始 TLS**，因此 Microsoft 能够访问和检查原始流量。
首次连接到开发隧道时，Microsoft 会插入一个点击广告，警告用户这可能是网络钓鱼尝试，只有成功连接过隧道的请求才不会弹出该警告。

通过修改 malleable C2 profile 可以绕过该页面，更改 `Accept` 标头为 `*/*` ，或者将 `X-Tunnel-Skip-AntiPhishing-Page: True` 标头添加到配置文件中的客户端 `http-get` 块

## 遗留问题

1. 如果加上认证，要求在请求标头中包含 373 个字符的 JWT，这会消耗 C2 配置文件允许的客户端 `http-get` 和 `http-post` 块的 508 字节限制
2. JWT 在 24 小时后过期，限制 beacon 的存活时间。
3. 使用该方式创建的监听器出口 IP 在海外，属于微软的 CDN 范围，比如本次 `20.197.80.108` 在新加坡
