---
layout: post
title: 使用 Frida 绕过部分 ROOT 检测
date: '2021-08-25 06:59:16'
tags:
- android
- frida
- bypass
- hash-import-2023-03-22-16-36
---

### 先使用 Frida 对 app 进行 hook

    $ frida -U -f "app.example"
    # -U 使用 USB
    # -f 目标应用
    # 需要暂时关闭 Magisk Hide
    Spawning `app.example`...
    Spawned `app.example`. Use %resume to let the main thread start executing!
    # 成功 hook

### 继续运行 app 触发 root 检测 crash

    [Pixel::app.example]-> %resume
    # 出现 Exception:
    [Pixel::app.example]-> Process crashed: java.lang.RuntimeException: 该手机已被root，存在安全隐患
    ***
    FATAL EXCEPTION: main
    Process: app.example, PID: 13079
    java.lang.RuntimeException: Unable to create application com.esunny.estar.EsApplication: java.lang.RuntimeException: 该手机已被root，存在安全隐患
    Caused by: java.lang.RuntimeException: 该手机已被root，存在安全隐患
    	... 9 more
    ***
    [Pixel::app.example]->

### 通过 crash 信息定位问题点

crash 信息中有用的部分：

    Caused by: java.lang.RuntimeException: 该手机已被root，存在安全隐患
    	at com.example.EsApplication.appSecurityCheck(EsApplication.java:24)

代码中找到该模块：

<img src="assets/img/blog/imported/bypass-android-root-detect-using-frida-DraggedImage.png" class="kg-image" alt loading="lazy">

    public class EsApplication extends Application {
        private void appSecurityCheck(String arg3) {
            if(!EsRomUtil.isRoot()) {
                Signature[] v3 = AppInfoUtils.getSignatures(this, arg3);
                String v0 = "";
                if(v3 != null && v3.length > 0) {
                    v0 = AppInfoUtils.getSignatureString(v3[0], "MD5");
                }
    
                if(AppInfoUtils.checkSignature(v0)) {
                    return;
                }
    
                throw new RuntimeException("应用签名不匹配，存在篡改风险");
            }
    
            throw new RuntimeException("该手机已被root，存在安全隐患");
        }
    
        @Override // android.app.Application
        public void onCreate() {
            super.onCreate();
            this.appSecurityCheck(this.getPackageName());
            CrashReport.initCrashReport(this);
        }
    }

### 反编译修改代码

使用 apktool 反编译

    $ apktool d app-example.apk
    # 源代码将解压到 `app-example` 文件夹中

打开源码文件 `EsApplication.smali`，修改

    throw new RuntimeException("该手机已被root，存在安全隐患"); `：

对应的 smali 代码：

    00000052 new-instance p1, RuntimeException
    00000056 const-string v0, "该手机已被root，存在安全隐患"
    0000005A invoke-direct RuntimeException-><init>(String)V, p1, v0
    00000060 throw p1

将 `throw p1` 修改为 `return-void`，重新打包签名安装。

### apk 重签名

- 生成签名证书（v1 证书，通用）

    $ keytool -genkey -v -keystore your.keystore -alias qax -sigalg MD5withRSA -keyalg RSA -keysize 2048 -validity 7300
    # your.keystore	证书名称
    # qax	证书 alias，后面药用到
    # 一路回车，等到提示 Is *** correct? 的时候输入 yes:
    Is CN=Unknown, OU=Unknown, O=Unknown, L=Unknown, ST=Unknown, C=Unknown correct?
      [no]: yes
    Generating 2,048 bit RSA key pair and self-signed certificate (MD5withRSA) with a validity of 7,300 days
    	for: CN=Unknown, OU=Unknown, O=Unknown, L=Unknown, ST=Unknown, C=Unknown

- 删除 apk 原来的签名信息

找到 `META-INF` 文件夹中的三个文件并删掉：

    CERT.RSA
    CERT.SF
    MANIFEST.MF

- 使用 apktool 重打包

    $ apktool b app-example -o origin.apk`

- 使用 jarsigner 重签名

    jarsigner -keystore your.keystore -signedjar new-signed.apk origin.apk qax`

- 安装

    $ adb install new-signed.apk
    # 安装前需要卸载原来的 app

