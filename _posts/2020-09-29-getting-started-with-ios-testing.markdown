---
layout: post
title: iOS App 测试笔记
date: '2020-09-29 06:23:00'
tags:
- pentest
- ios
- hash-import-2023-03-22-16-36
---

## 设备越狱

目前稳定的越狱途径是使用 [checkra1n](https://checkra.in/linux)，或者使用 [bootra1n](https://github.com/foxlet/bootra1n)，一个包含 checkra1n 的 USB Linux 启动盘。

## 安装需要测试的 app

- 注册一个不包含个人信息的测试帐号
- 登录 App Store，安装需要测试的 app（或者使用 [3uTools](http://www.3u.com/) 安装）

## Dump IPA 文件

- 在已越狱的设备上
- 打开 Cydia 商店，安装 [frida-server](https://frida.re/docs/ios/)
- 在 Kali VM 里安装 frida

    pip install frida-tools

- Kali 安装 `frida-ios-dump`

    apt-get install libusbmuxd-tools
    git clone https://github.com/AloneMonkey/frida-ios-dump.git
    cd frida-ios-dump
    pip install -r requirements.txt

- 使用 iproxy 将设备的 SSH 端口映射到本机

    iproxy 2222 44 # 将设备的 44 端口（SSH）映射为本机 2222 端口

然后运行 `dump.py` ：

    ssh -p 2222 root@localhost&
    python3 dump.py <target_app_name>

使用 `frida-ps` 来找到正确的 app 名称（target\_app\_name）

    frida-ps -Uai

app 下载后使用 `unzip target_app_name` 解压 app。

## 使用 **CrackerXI Dump IPA**

1. 添加 Cydia 源 [`http://cydia.iphonecake.com`](http://cydia.iphonecake.com/)
2. 搜索并安装 **`CrackerXI`**
3. 打开 App： **`CrackerXI`**
4. 点击右上角设置图标，开启 `Hook`
<img src="assets/img/blog/imported/getting-started-with-ios-testing-image.png" class="kg-image" alt loading="lazy" >

5. 主界面点击需要 Dump 的 App，选择 Full IPA

<img src="assets/img/blog/imported/getting-started-with-ios-testing-image-1.png" class="kg-image" alt loading="lazy" >

6. Dump 的 IPA 文件保存在 `/var/mobile/Documents/CrackerXI/` 文件夹内

## 使用 debugserver 调试

安装 [debugserver](https://github.com/wstclzy2010/iOS-debugserver) 到越狱的设备上。

运行 app，使用 `ps ax | grep **target_app_name** ` 来查找 app 的进程编号，通过下面命令开启调试：

    $ debugserver *:1234 -a **target_app_name** # 1234:远程调试端口

如果开启 `debugserver` 后，在 `lldb` 连接时提示 `error: rejection incoming connection from ***` 则修改 `*:1234` 为 `127.0.0.1:1234` 即可。

在电脑端打开 LLDB 连接设备进行调试：

    $ lldb
    (lldb) process connect connect://127.0.0.1:1234

如出现 `Segmentation fault: 11` 则程序开启了反调试。

## 使用 Cycript 注入 dylib 动态库

    $ cycript -p 5911 # 注入 5911 进程
    # 弹出 Alert
    $ var alert = [[UIAlertView alloc] initWithTitle:@"Hack You" message:@"I've hacked you" delegate:nil cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    $ [alert show];

## MobSF 静态扫描

参照[手册](https://linuxhint.com/install_docker_kali_linux/)安装 docker 版 `MobSF` 并启动：

    docker pull opensecurity/mobile-security-framework-mobsf
    docker run opensecurity/mobile-security-framework-mobsf

查找该 docker MobSF 监听的端口：

    docker ps
    docker inspect <container_id> | grep IPAddress

然后浏览器访问 [http://IPAddress:8000/](http://IPAddress:8000/)，将上一步 dump 的 ipa 文件上传并开始静态分析。

> [Getting started with iOS testing](https://cornerpirate.com/2020/09/22/getting-started-with-ios-testing/)

> [移动应用安全基础篇——绕过 iOS 越狱检测 - FreeBuf 网络安全行业门户](https://www.freebuf.com/column/201114.html)

