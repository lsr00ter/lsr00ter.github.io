---
layout: post
title: Android App 抓包排查思路
date: '2021-09-28 09:51:46'
tags:
- android
- capture
- ssl
- hash-import-2023-03-22-16-36
---

### 前提条件

- Burpsuite
- 代理地址 192.168.1.100:8080

### 0x00 设备上设置代理
<figure class="kg-card kg-image-card"><img src="assets/img/blog/imported/android-app-traffic-capture-skill-merge.png" class="kg-image" alt loading="lazy"></figure>
### 0x01 配置 Proxy Listener

在 Burpsuite 上依次点击 `Proxy -> Options -> Edit (Proxy Listeners)` 然后设置监听接口和监听端口：

    Bind to port: 8080
    Bind to address: All interfaces

<figure class="kg-card kg-image-card"><img src="assets/img/blog/imported/android-app-traffic-capture-skill-DraggedImage.png" class="kg-image" alt loading="lazy"></figure>
### 0x02 检查设备是否成功连接代理

在设备上用浏览器打开 [http://burp](http://burp) 应该会看到 Burpsuite 的欢迎页面：

<figure class="kg-card kg-image-card"><img src="assets/img/blog/imported/android-app-traffic-capture-skill-image.png" class="kg-image" alt loading="lazy" ></figure>

如果加载失败，下面是几种解决的思路：

- 设置一个新的 Wi-Fi 热点并连接
- 使用 adb 通过 USB 进行代理  
  – 将设备代理设置为 `127.0.0.1:8080`– 设备使用 USB 连接电脑– 执行 `adb reverse tcp:8080 tcp:8080` 将设备 `8080` 端口的流量转发到电脑的 `8080` 端口– 再次打开 `http://burp` 或者 `http://127.0.0.1:8080` 应该可以看到 Burpsuite 的欢迎页

### 0x03 验证是否可以代理抓包 HTTP 流量

访问 [http://neverssl.com/](http://neverssl.com/) 应该可以在 Burpsuite 的 `Proxy -> HTTP history` 中看到 HTTP 流量，该网站不使用 SSL 或者 HSTS。

如果没有看到流量，Burpsuite 中的 `Proxy -> Intercept` 应该是 `Intercept is on` 状态，切换为 `off` 或者点击 `Forward` 将单次请求放行。

### 0x04 在设备上安装 Burpsuite 证书

- 访问 [http://burp](http://burp) 点击右上角 `CA Certificate` 下载 Burpsuite 的证书
- 将证书 `.der` 重命名为 `.crt` 文件  
  – 在文件管理器中找到下载的文件并修改后缀– 使用命令 `adb shell mv /sdcard/Download/cacert.der /sdcard/Download/cacert.crt` 修改后缀
- 在设备上打开证书文件进行安装

### 0x05 将 Burpsuite 证书安装为系统根证书

- 把证书文件移动到系统证书位置：`/system/etc/security/cacerts`
- 使用 Magisk  
  1. 安装 Magisk 模块 [https://github.com/NVISOsecurity/MagiskTrustUserCerts](https://github.com/NVISOsecurity/MagiskTrustUserCerts)2. 重启设备让 Magisk 模块生效 3. 正常安装证书 4. 重启设备 5. 完成后可以在系统根证书部分看到该证书

### 0x06 正确设置证书有效期

新版 Android 中，如果证书有效期超过一年，系统有可能会忽略该证书，需要创建一个新的证书；或使用新版 Burpsuite 生成新的证书。

### 0x07 App 相关的代理设置

系统代理设置完成之后，可以针对 App 进行代理设置。

#### App 忽略系统代理

在之前的设置之后，如果没有在 Burpsuite 的 `Proxy Tab` 中看到 HTTPS 请求数据，或者在 `Dashboard -> Event log` 中看到请求错误的信息，App 有可能使用了第三方框架如 Flutter/Xamarin/Unity，可以反编译之后检查 App 源码的如下位置：

- Flutter: `app/lib/arm64-v8a/libflutter.so`
- Xamarin: `app/unknown/assemblies/Mono.Android.dll`
- Unity: `app/lib/arm64-v8a/libunity.so`

如果 App 使用了第三方框架：

- 使用 [ProxyDroid](https://play.google.com/store/apps/details?id=org.proxydroid&hl=en&gl=US) 对流量进行代理，ProxyDroid 使用 iptables 强制重定向流量到代理服务器

使用条件：

- 关掉系统 Wi-Fi 的代理设置
- 在 Burpsuite 中设置 `Proxy > Options > active proxy > edit > Request Handling > Support invisible proxying`

#### App 服务端使用自定义端口

ProxyDroid 只重定向 HTTP（80）和 HTTPS（443）端口。如果 App 连接的是服务端的其他端口，ProxyDroid 将不会重定向相关流量。

- 使用 tcpdump 抓取 App 连接信息  
  `tcpdump -i wlan0 -n -s0 -w /sdcard/output.pcap `
- 用 WireShark 打开 output.pcap 进行分析

使用 iptables 重定向特定端口的流量：

- 电脑端：`adb reverse tcp:8080 tcp:8080`
- 设备上：`iptables -t nat -A OUTPUT -p tcp -m tcp --dport 8088 -j REDIRECT --to-ports 8080`

#### 使用 Xpose 的 ssl-unpining 模块绕过 SSL Pinning

模块下载地址：[SSLUnpinning](https://github.com/ac-pm/SSLUnpinning_Xposed)

直接安装后 **重启** 配置代理抓包。

#### App 使用 SSL Pinning（SSL 绑定）

Android 允许 App 针对特定 SSL 证书进行信任（SSL Pinning）。检查下面文件查看 App 是否设置了 SSL Pinning：

    $ cat AndroidManifest.xml | grep -i networksecurity	# 查看 App 是否设置了 SSL Pinning
    $ cat res/xml/network_security_config.xml | grep digest -B 3 -A 2	# 查看 SSL Pinning 的 SSL 证书 SHA-256 信息

绕过 SSL Pinning：

- 使用 Objection： `android sslpinning disable`
- 使用 Frida：`frida -U --codeshare akabe1/frida-multiple-unpinning -f example.app`
- 使用 `apktool d/apktool b` 反编译重新打包 App，移除 SSL Pinning 相关设置

或者尝试下面几个 Frida 绕过 SSL Pinning 脚本：

    https://codeshare.frida.re/@akabe1/frida-multiple-unpinning/
    https://codeshare.frida.re/@pcipolloni/universal-android-ssl-pinning-bypass-with-frida/
    https://codeshare.frida.re/@sowdust/universal-android-ssl-pinning-bypass-2/
    https://codeshare.frida.re/@masbog/frida-android-unpinning-ssl/
    https://codeshare.frida.re/@segura2010/android-certificate-pinning-bypass/
    https://codeshare.frida.re/@akabe1/frida-universal-pinning-bypasser/

