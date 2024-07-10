---
layout: post
title: Android App 绕过 OkHttp SSL 证书校验抓包
date: '2024-02-23 10:16:34'
---

> 针对 OkHttp

## OkHttp 介绍

OkHttp 是 Square 公司开发的一个开源网络请求库，适用于 Android 和 Java 应用程序。它基于 HTTP/2 和 SPDY 协议，提供了简单易用的 API，支持同步和异步请求，并具有拦截器机制，可用于修改请求和响应数据。

## 识别 MitM 抓包中的证书错误类型

- 未安装 burpsuite 证书

打开浏览器，访问 neverssl.com 正常显示，访问 **https** 网站比如 www.baidu.com 提示不安全

- 用户模式安装 ssl 证书

浏览器访问 https 网站正常显示，无提示；App 内连接错误

- 安装 ssl 证书到系统

大部分 app 自动信任根系统证书，正常抓包；少量 App 配置了 SSL Pinning（证书绑定），只信任特定证书，不信任外部证书

## 通过工具快速绕过使用 OkHttp 库的 SSL Pinning

### 快速确认 App 是否使用 OkHttp

Apk 拖入任何反编译软件如 jd-gui 然后查看包中是否存在 okhttp3 库，如果存在大概率使用了 OkHttp 处理所有网络连接请求
![](assets/img/blog/imported/android-app-okhttp-ssl-bypass-CleanShot-2024-02-23-at-11.27.13.png)
### 绕过 SSL Pinning

手机端安装 magisk + frida-server, 电脑端安装 frida, frida-tools, objection

手机端的 frida-server 版本和电脑端的 frida 版本一定要匹配。

快速找到特定 frida 版本方法：

查看手机端 frida-server 版本的发布日期，安装该发布日期前一版的 frida

**绕过 ssl pinning**

opt 1:

    $ frida --codeshare federicodotta/okhttp3-pinning-bypass -f YOUR_BINARY
    

opt 2:

    $ objection -g xxx.xxx explore
    objection: android sslpining disable