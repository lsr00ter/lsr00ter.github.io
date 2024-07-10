---
layout: post
title: Apple News 国内极简使用指南
date: '2019-05-30 06:09:00'
tags:
- apple
- hash-import-2023-03-22-16-36
---

<img src="https://raw.githubusercontent.com/5cr1pt/img4markdown/master/15591142960108/15591143208187.jpg" class="kg-image" alt loading="lazy">

Apple News 是苹果在 iOS 和 macOS （10.14及之后的版本）设备上自带的新闻软件。目前仅在美国、英国和澳大利亚运营。它不生产内容，只搭建平台，方便各大媒体和内容创作者在上面提供内容。可以将其理解为更加开放些的微信公众平台或者今日头条。但是就目前来看，美区基本都是传统媒体和影响力较大的媒体接入。Apple News 的优势在于因为内容发布在同一平台，内容格式相对一致，用户体验极好。

<img src="https://raw.githubusercontent.com/5cr1pt/img4markdown/master/15591142960108/IMG_1465.jpg" class="kg-image" alt="IMG_1465" loading="lazy">

上图是 Apple News iPhone 版本的展示。  
一共有三栏：

- **Today** 一栏，是编辑精选内容以及头条新闻，热门，个性化推荐，视频专区等等。也即是智能推荐和热门内容的合集。
- **News+** 是 2019年3月25日 发布的全新订阅服务，整合了《洛杉矶时报》、《华尔街日报》在内超过300多家杂志和新闻内容。这里有一份完整的杂志列表：[A Complete List of All the Magazines Available for Apple News+ in the U.S. (So Far)](https://www.macstories.net/news/a-complete-list-of-all-the-magazines-available-for-apple-news-in-the-u-s-so-far/)
- **Following** 是个人关注，可以关注包括话题、频道等。

## 准备工作

- 美区代理
- 美区 ID

## 开始使用

Apple News 针对中国地区做了特殊的限制，iOS 设备会检测是不是在使用中国运营商网络，macOS 会检测地理位置缓存，这是已知的苹果对自己服务作出的最严格的地域限制。

在iOS 设备使用 Apple News，需要：

1. iTunes 中使用美区 Apple ID
2. 设置中地区切换为美国
3. IP 地址为美国/英国/澳大利亚等运营区域
4. 使用非中国运营商网络/开启飞行模式

在 macOS 设备上使用 Apple News 需要：

1. 设置中地区切换为美国
2. 网络 IP 地址是美国/英国/澳大利亚等运营区域
3. 清除地理位置缓存

### iPhone/iPad 设备上使用 Apple News

启用 Apple News

- iTunes & App Store 账号更换为美区
- `设置 - 通用 - 语言/地区` 中，切换地区为美国在 iOS 的设置中将 iTunes & App Store 换成美区 Apple ID，切换区域完成，Apple News, Apple TV 等软件就会出现在设备上了。

正常使用 Apple News

在 iPhone 上开启飞行模式，打开 Wi-Fi，使用 VPN 或者 SS 类软件的全局代理。iOS 上，Apple News 对代理的 IP 没有特别限制，但建议使用主运营区域的。必须开启飞行模式这一点，等于屏蔽移动运营商网络，代价很大且不方便。

若在没有插 SIM 卡的 iPad 上，使用 VPN 或者 SS 类软件的全局代理即可。常在 Wi-Fi 网络下扔着的 iPad 更适合用 Apple News 来阅读新闻。

排查错误

如果按照上述步骤一步一步操作仍不可用，或者本来可用，突然不可用。可以尝试在 设置 中搜索 `Location` 选择 `Reset location and privacy`，这样可以重置对所有 APP 及服务的授权，重新打开 News 时关闭地理位置授权即可。

如果是购买国内常用的 SS 代理服务，部分美区节点可能没有被苹果识别为美国，多切换几个节点尝试。

### Mac 设备上使用 Apple News

启用 Apple News

<img src="https://raw.githubusercontent.com/5cr1pt/img4markdown/master/15591142960108/15591398086835.jpg" class="kg-image" alt loading="lazy">

macOS 需升级到10.14 macOS Mojave。MacOS 上仅需要在 `系统设置-语言与地区` 中将地区更改为 `美国`，Apple News 就会出现在应用页面。若仍未出现，可以在 `应用程序` 文件夹中查看到，按住拖到 Dock 栏方便使用。

正确设置代理

使用 VPN 或者 SS 类软件的全局代理。若经常使用全局代理不方便，也可以考虑使用 Proxifier 针对电脑上的每个软件分别设置代理策略。

如果是 Surge 用户，开启增强模式后，增加针对 Apple News 的进程代理美国IP地址即可。如果是其他代理软件，觉得全局代理的体验较差，可以新增规则，将 `apple.news` 域名设置为 Proxy，将 `apple.comscoreresearch.com` 设置为 Deny。

**与iOS不同，macOS 上对 IP 地址还是有要求的，若使用加拿大或者其他非 Apple News 运营地区的 IP 地址，仍会显示为该地区不支持。**

清除地理位置缓存  
点开 Apple News，很可能还会提示该地区不支持。这是需要在设置中将保存的地理位置信息清除。具体位置在`System Preference -> Security & Privacy -> Location Service -> System Services -> Details -> Significant Locations -> Details`，点击 `Clear History` 即可清除。 **这个步骤需要将左下角的锁打开** 。关闭并重新打开 Apple News 即可。

<img src="https://raw.githubusercontent.com/5cr1pt/img4markdown/master/15591142960108/15591396528920.jpg" class="kg-image" alt loading="lazy"><img src="https://raw.githubusercontent.com/5cr1pt/img4markdown/master/15591142960108/15591396704093.jpg" class="kg-image" alt loading="lazy">

Trouble Shooting

- 如果是购买国内常用的 SS 代理服务，部分美区节点可能没有被苹果识别为美国，多切换几个节点尝试。
- 如果某次打开还提示该地区不支持，可能是又存在了地理位置缓存，重复上一步骤清除缓存即可。

## 写在最后

Apple News 的繁琐步骤能劝退很多人。  
如果在国内对杂志数量有很高要求，可以使用如 Scribd、Kindle Unlimited 这些代替服务，或者 Calibre 的新闻下载功能；如果你只是固定关注特定几种刊物，有很大概率可以直接在官网免费读到多数纸刊文章，或者通过比较低廉的价格在亚马逊等平台上订阅。另外，图书馆往往会提供非常丰富的数字资源。

<img src="https://raw.githubusercontent.com/5cr1pt/img4markdown/master/15591142960108/15591422876001.png" class="kg-image" alt loading="lazy">

> 在发布会上，库克提到「站在书报亭前的满足感」，并以此为喻引出对 Apple News+ 的介绍。这是一个恰如其分的比喻——Apple News+ 的功用确实是，但同时也只是把书报亭搬到了用户面前。但究竟是能从中获取更广博的视野、更高质量的阅读材料，抑或是止步于视觉上的饱足和坐拥无限资源的富余感，就是我们身为读者只能自负其责的问题了。  
> -- via: Neverland

