---
layout: post
title: 捡垃圾的快乐 - Aruba AP（瘦 AP）刷机变家用 IAP（胖 AP）
date: '2020-06-18 06:18:00'
tags:
- ap
- aruba
- hash-import-2023-03-22-16-36
---

由于现在无线设备越来越多，同时需要兼顾看电影、打游戏、办公、智能家居、NAS 下载等，所以感觉现有的无线路由器有点力不从心，就咸鱼 200 块淘了一个 Aruba 的 AP-203R，希望 MU-MIMO 能带来更好的体验。然后淘回来发现是个没办法单独使用的瘦 AP，查找了一番资料，发现可以刷机变成胖 AP 单独使用，这里做个记录。

## 购买一条 TTL 线

查看 aruba 官网相应版本的说明书（`AP-XXX_Install_Guide.pdf`），找到相应的 `Console Port` 说明信息，再查找推荐的 `AP-CBL-SERU cable` 信息，根据文档里的 `CONNECTOR` 去淘宝找相应的型号，根据文档提供的线序购买。

<img src="https://raw.githubusercontent.com/5cr1pt/img4markdown/master/pics/20200618174916.jpg" class="kg-image" alt="查询 Installation Guide" loading="lazy"><img src="https://raw.githubusercontent.com/5cr1pt/img4markdown/master/pics/20200618175122.jpg" class="kg-image" alt="查看 Console Port 支持的线缆" loading="lazy"><img src="https://raw.githubusercontent.com/5cr1pt/img4markdown/master/pics/20200618175155.jpg" class="kg-image" alt="查询相关线缆" loading="lazy"><img src="https://raw.githubusercontent.com/5cr1pt/img4markdown/master/pics/20200618175252.jpg" class="kg-image" alt="查看线缆线序和新片" loading="lazy"><img src="https://raw.githubusercontent.com/5cr1pt/img4markdown/master/pics/20200618175301.jpeg" class="kg-image" alt="购买 Console 线" loading="lazy">
## 准备软件和资料

- Serial（串口）连接软件（Windows: [Putty](https://www.chiark.greenend.org.uk/%7Esgtatham/putty/latest.html); macOS: [Serial.app](https://www.decisivetactics.com/products/serial/)）
- TFTP Server 软件（Windows: [SolarWinds TFTP Server](https://www.solarwinds.com/free-tools/free-tftp-server); macOS: 自带 TFTP Server）
- 需要刷入 AP 的系统固件（如 `ArubaInstant_Vela_8.5.0.3_72498`，以及[其他固件](https://support.arubanetworks.com/Documentation/tabid/77/DMXModule/512/Default.aspx?EntryId=8868)）
- 将固件移动到 TFTP Server 的根目录下，如 SolarWinds TFTP Server 的 `C:\TFTP-Root`
- **重要** ：关闭电脑防火墙
- 启动 SolarWinds TFTP Server，显示如下：
<img src="https://raw.githubusercontent.com/5cr1pt/img4markdown/master/pics/20200618175437.jpg" class="kg-image" alt="SolarWinds TFTP Server" loading="lazy">
## 启动 AP

（使用的软件以 Windows 平台为例）首先断开 AP 的电源，把 AP 通过串口连接到电脑上，等待提示驱动安装成功后，打开 Putty，选择连接方式为 `Serial`，按照`开始菜单（右键） - 设备管理器`中显示的串口号，选择连接的串口，如 `COM1`，点击 `Open` 打开：

<img src="https://raw.githubusercontent.com/5cr1pt/img4markdown/master/2020/06/DeviceMgr.jpg" class="kg-image" alt="查看设备的串口号" loading="lazy"><img src="https://raw.githubusercontent.com/5cr1pt/img4markdown/master/pics/20200618175335.jpg" class="kg-image" alt="Putty 配置" loading="lazy">

然后把 AP 接上电源，等待窗口中出现如下字符：

    Hit <Enter> to stop autoboot: 5

立即按回车，进入 `apboot` 模式：

    apboot>

## 配置网络

将 AP 通过网线连接到电脑，在电脑上设置相关接口为固定 IP 地址，如 `192.168.2.10`：

<img src="https://raw.githubusercontent.com/5cr1pt/img4markdown/master/pics/20200618175402.jpg" class="kg-image" alt="和 AP 连接的网卡 IP 配置" loading="lazy">

然后开始设置 AP 的地址和 TFTP 服务器

    apboot> setenv ipaddr 192.168.2.20 # 配置 AP 的 IP 地址
    apboot> setenv netmask 255.255.255.0 # 配置 AP 的子网掩码
    apboot> setenv serverip 192.168.2.10 # 配置 TFTP 服务器地址，即电脑的 IP 地址

## 开始给 AP 刷入新固件

    apboot> osinfo # 显示系统中的固件
    Partition 0:
        image type: 0
      machine type: 46
              size: 13864872
           version: 6.5.2.0-6.5.2.0
      build string: ArubaOS version 6.5.2.0-6.5.2.0 for Vela (p4build@pr-hpn-build01) (gcc version 4.7.2) #59123 Fri Apr 7 09:37:25 AST 2017
             flags: Instant preserve
               oem: aruba

    Image is signed; verifying checksum... passed
    SHA2 Signature available
    Signer Cert OK
    Policy Cert OK
    RSA signature verified using SHA2.

    Partition 1:
        image type: 0
      machine type: 46
              size: 13864872
           version: 6.5.2.0-6.5.2.0
      build string: ArubaOS version 6.5.2.0-6.5.2.0 for Vela (p4build@pr-hpn-build01) (gcc version 4.7.2) #59123 Fri Apr 7 09:37:25 AST 2017
             flags: Instant preserve
               oem: aruba

    Image is signed; verifying checksum... passed
    SHA2 Signature available
    Signer Cert OK
    Policy Cert OK
    RSA signature verified using SHA2.

    apboot> clear os 0 # 清除分区 0 的系统
    apboot> upgrade os 0 ArubaInstant_Vela_8.5.0.3_72498 # os 0 分区刷入 TFTP Server 中的 ArubaInstant_Vela_8.5.0.3_72498 固件

    # 当看到 Upgrade successful 表示刷入成功

    apboot> factory_reset # ！重要：清除原来的配置

> 建议将两个分区刷入同样的固件。

## 配置 IAP

等待 5 分钟左右，会出现一个 `SetMeUp-XX:XX:XX` 类似的名字的 Wi-Fi 信号，就是刷新后的 Aruba IAP 的初始网络。

连接上去后，打开浏览器，输入网址 `https://setmeup.arubanetworks.com:4343/` （有可能浏览器会提示此网站证书不受信任，直接点仍然继续访问）进入 web 设置界面，使用账号 `admin` 和密码 `机器的 SN 号` 登陆（8.5 以下系统是 `admin/admin`，开始和普通无线路由器一样设置网络。

需要配置的地方为：

- 配置 - 接入点：设置 AP 的接入方式，如连接主路由，只需要在 `常规`选项中选择 DHCP 即可
- 配置 - 网络：设置 Wi-Fi，新建即可，在高级选项中可以选择 2.4G 或 5G 网络，是否隐藏 SSID，加密方式等

设置完毕，将 AP 连接到路由器上就可以正常使用了。

<img src="https://raw.githubusercontent.com/5cr1pt/img4markdown/master/pics/20200618175509.jpg" class="kg-image" alt="Overview" loading="lazy">
安装 Flash

首先`root@kali:apt-get install flashplugin-nonfree`

其次`root@kali:update-flashplugin-nonfree –install`

安装 Tor Browser

    root@kali:apt-get install tor
    root@kali:service tor start
    root@kali:proxychains iceweasel

## 0x05 拼音输入法（需要注销重新登录）

    apt-get install ibus ibus-pinyin #经典的ibus
    apt-get install fcitx fcitx-pinyin fcitx-module-cloudpinyin fcitx-googlepinyin #fcitx拼音

## 0x06 科学上网

默认安装，是没有激活 VPN 的，能看到 VPN 选项，但是不能点击 VPN 连接

    apt-get install -y pptpd network-manager-openvpn network-manager-openvpn-gnome network-manager-pptp network-manager-pptp-gnome network-manager-strongswan network-manager-vpnc network-manager-vpnc-gnome

[lantern](https://github.com/getlantern/lantern-binaries)

方法就是下载对应的版本，然后 dpkg 安装下，然后打开 lantern 自动跳转到浏览器，然后就没有然后了。。。

Shadowsocks

首先搭建 shadowsocks 客户端

git 下 [https://github.com/shadowsocks/shadowsocks-qt5](https://github.com/shadowsocks/shadowsocks-qt5) 以及其安装指南 [https://github.com/shadowsocks/shadowsocks-qt5/wiki/%E5%AE%89%E8%A3%85%E6%8C%87%E5%8D%97](https://github.com/shadowsocks/shadowsocks-qt5/wiki/%E5%AE%89%E8%A3%85%E6%8C%87%E5%8D%97)

或者直接用 pip 安装

`pip install shadowsocks`

`/usr/local/python/bin/sslocal   //ss位置`

建立一个为 ss.conf 的配置文件

    {
    "server" : "100.100.100.100",
    "server_port" : 8888,
    "local_port" : 1080,
    "password" : "123456",
    "timeout" : 600,
    "method" : "aes-256-cfb"
    }

然后运行

`sslocal -c /filepath/ss.conf`

其次安装 privoxy 实现 socks5 转换成 http

privoxy-3.0.23-stable-src.tar.gz &nbsp; // [http://www.privoxy.org/](http://www.privoxy.org/) 官网下载源码

    tar xf privoxy-3.0.23-stable-src.tar.gz //解压缩
    cd privoxy-3.0.23-stable
    useradd privoxy //进入目录后创建privoxy用户，然后安装
     autoheader && autoconf
    ./configure
     make && make install
    Vim /usr/local/etc/privoxy/config 修改配置文件
    listen-address 127.0.0.1:8118 //找到783行，去掉注释即可
    forward-socks5t / 127.0.0.1:1080. //找到1336行，去掉注释即可，保证1080端口和ss配置中一致，注意1080后面与个小数点。

最后让终端走代理

`vim /ect/profile`

添加两行

    export http_proxy=http://127.0.0.1:8118
    export ftp_proxy=http://127.0.0.1:8118

然后打开 shadowsocks privoxy

    sslocal -c /filepath/ss.conf
    service privoxy start

测试
`curl www.google.com`
访问谷歌即可，如果不行查看配置或者重启下。

## 0x07 定制终端

设置启动终端快捷键

系统》设置》快捷键
添加如下命令：

    gnome-terminal

然后设置 快捷启动终端的键（例如 ctrl+alt+T）

多命令终端

byobu 介绍 [http://blog.csdn.net/lqhbupt/article/details/7786153](http://blog.csdn.net/lqhbupt/article/details/7786153)

## 0x08 配置 Python 及 Java 环境

python IDE 安装

下载最新的 tar 包，解压出来，进入 bin &nbsp;, `./pycharm.sh` 即可启动

3.1 pycharm 注册码

    EMBRACE
    ========= Sjolzy.cn =========
    14203-12042010
    0000107Iq75C621P7X1SFnpJDivKnX
    6zcwYOYaGK3euO3ehd1MiTT"2!Jny8
    bff9VcTSJk7sRDLqKRVz1XGKbMqw3G
    =========== Sjolzy.cn =============

安装 add-apt-repository 和 pip

    add-apt-repository
    apt-get install python-software-properties
    nano app-apt-repository.sh
    #!/bin/bash // 添加如下代码
    if [$# -eq 1]
    NM=`uname -a && date`
    NAME=`echo $NM | md5sum | cut -f1 -d" "`

或者其他方法：[http://www.blackmoreops.com/2014/02/21/kali-linux-add-ppa-repository-add-apt-repository/](http://www.blackmoreops.com/2014/02/21/kali-linux-add-ppa-repository-add-apt-repository/) &nbsp;Pip

    apt-get python-setuptools
    easy_install pip
    pip gevent --upgrade

注：如果最后一步出错，执行`root@kali:pip install setuptools --no-use-wheel --upgrade`

Java 环境安装

`mkdir /usr/lib/jdk`

压缩包 cp 到 `/usr/lib/jdk`
解压之后配置环境变量

`gedit /etc/profile` &nbsp;# 最末尾添加

    export JAVA_HOME=/usr/lib/jdk/jdk1.7.0_03
    export JRE_HOME=/usr/lib/jdk/jdk1.7.0_03/jre
    export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH
    export CLASSPATH=$CLASSPATH:.:$JAVA_HOME/lib:$JAVA_HOME/jre/lib

将系统默认的 jdk 修改过来，也就是 java 和 javac 命令有系统自带到换成你自己安装的

    update-alternatives --install /usr/bin/java java /usr/lib/jdk/jdk1.7.0_03/bin/java 300
    update-alternatives --install /usr/bin/javac javac /usr/lib/jdk/jdk1.7.0_03/bin/javac 300
    update-alternatives --config java
    update-alternatives --config javac

<img src="http://static.oschina.net/uploads/img/201403/06002415_wAFS.png" class="kg-image" alt loading="lazy">

IDEA 13 下载及安装

下载最新的 tar 包，解压出来，进入 bin &nbsp; &nbsp;./idea.sh 即可 启动

注册码：

    用户名：qianbi
    注册码：00667-3LLZU-A174Q-GQ9WU-QCR2R-8RXG3
    注册码：00701-AWVMK-JG2K1-OPKFI-099ZF-LJNS4
    注册码：00122-PHU9A-1C01F-1QOID-GYCT8-B3NM3
    注册码：00979-DV75L-VEUEI-3ZNBS-GKD3C-ZKNX2
    注册码：00127-DDFPG-E91IA-DP5U3-4WYJE-8HF34
    注册码：00310-I608W-EA5YT-Z6IJ2-M2KU2-STY95
    注册码：00965-VFZO8-8190O-8T2MR-XR8VQ-GUBA3
    注册码：00422-4SO2M-1VXOY-LB4K1-XW05P-XT3E3

## 0x09 安装代码编辑器

sublime 解决不能输入中文方法：

新建并保存下面的代码为 sublime\_imfix.c

    /*
    sublime-imfix.c
    Use LD_PRELOAD to interpose some function to fix sublime input method support for linux.
    By Cjacker Huang
    gcc -shared -o libsublime-imfix.so sublime_imfix.c `pkg-config --libs --cflags gtk+-2.0` -fPIC
    LD_PRELOAD=./libsublime-imfix.so sublime_text
    */
    #include
    #include
    typedef GdkSegment GdkRegionBox;
    struct _GdkRegion
    {
      long size;
      long numRects;
      GdkRegionBox *rects;
      GdkRegionBox extents;
    };
    GtkIMContext *local_context;
    void
    gdk_region_get_clipbox (const GdkRegion *region,
                GdkRectangle *rectangle)
    {
      g_return_if_fail (region != NULL);
      g_return_if_fail (rectangle != NULL);
      rectangle->x = region->extents.x1;
      rectangle->y = region->extents.y1;
      rectangle->width = region->extents.x2 - region->extents.x1;
      rectangle->height = region->extents.y2 - region->extents.y1;
      GdkRectangle rect;
      rect.x = rectangle->x;
      rect.y = rectangle->y;
      rect.width = 0;
      rect.height = rectangle->height;
      //The caret width is 2;
      //Maybe sometimes we will make a mistake, but for most of the time, it should be the caret.
      if(rectangle->width == 2 && GTK_IS_IM_CONTEXT(local_context)) {
            gtk_im_context_set_cursor_location(local_context, rectangle);
      }
    }
    //this is needed, for example, if you input something in file dialog and return back the edit area
    //context will lost, so here we set it again.
    static GdkFilterReturn event_filter (GdkXEvent *xevent, GdkEvent *event, gpointer im_context)
    {
        XEvent *xev = (XEvent *)xevent;
        if(xev->type == KeyRelease && GTK_IS_IM_CONTEXT(im_context)) {
           GdkWindow * win = g_object_get_data(G_OBJECT(im_context),"window");
           if(GDK_IS_WINDOW(win))
             gtk_im_context_set_client_window(im_context, win);
        }
        return GDK_FILTER_CONTINUE;
    }
    void gtk_im_context_set_client_window (GtkIMContext *context,
              GdkWindow *window)
    {
      GtkIMContextClass *klass;
      g_return_if_fail (GTK_IS_IM_CONTEXT (context));
      klass = GTK_IM_CONTEXT_GET_CLASS (context);
      if (klass->set_client_window)
        klass->set_client_window (context, window);
      if(!GDK_IS_WINDOW (window))
        return;
      g_object_set_data(G_OBJECT(context),"window",window);
      int width = gdk_window_get_width(window);
      int height = gdk_window_get_height(window);
      if(width != 0 && height !=0) {
        gtk_im_context_focus_in(context);
        local_context = context;
      }
      gdk_window_add_filter (window, event_filter, context);
    }

编译动态库

    gcc -shared -o libsublime-imfix.so sublime_imfix.c `pkg-config --libs --cflags gtk+-2.0` -fPIC

设置 LD\_PRELOAD 并启动 Sublime Text：

     LD_PRELOAD=./libsublime-imfix.so sublime_text

解决界面汉化：网上搜索下载 Sublime\_Text\_CN\_3059.zip，解压之后得到`Default.sublime-package`文件，其实就是个 package，在菜单中选择`preferences——Browse packages`进入到`/home/siat/.config/sublime-text-3/Packages`然后向上一级进入到`/home/siat/.config/sublime-text-3/Installed Packages`，把`Default.sublime-package`包复制到`Installed    Packages`文件夹下，这时 sublime text3 立刻变成中文了。

## 0x10 安装 git

安装：

    aptitude install git-core
    aptitude install git-doc git-svn git-email git-gui gitk

配置：

    ssh-keygen -t rsa -C "xxxx@email.com"

进入 github 设置 &nbsp;SSH Keys：

<img src="http://static.oschina.net/uploads/space/2014/0304/231551_SyDR_615783.png" class="kg-image" alt loading="lazy">

`ssh -T git@github.com`

看其是否返回：

`Hi xxx! You've successfully authenticated, but GitHub does not provide shell access .`

**设置 git 全局变量，name 和 email**

    git config --global user.name "yourusername"
    git config --global user.email "youremailaddress"

## 0x11 一些工具

     apt-get install gnome-tweak-tool #安装gnome管理软件
     apt-get install synaptic #安装新立德
     apt-get install software-center #安装ubuntu软件中心
     apt-get install file-roller #安装解压缩软件
     apt-get install gedit #安装gedit编辑软件
     apt-get install audacious #audacious音乐播放器
     apt-get install smplayer #安装smplayer视频播放器

## 0x12 娱乐

安装 dota2 和 steam 平台

**（64 位适合）**

首选官网下载 steam 并且 dpkg 安装下，然后如果你是 root 运行会有提示。解决方法终端执行：

    /usr/bin
    gedit steam

然后找到如下位置，并且把双引号中的 0 改成 1 即可

    # Don’t allow running as root
    if ["$(id -u)" == "0"]; then
    show_message –error $”Cannot run as root user”
    exit 1
    Fi

然后登陆账号，下载 dota2。

网易云音乐

首先 git 下 [https://github.com/cosven/FeelUOwn](https://github.com/cosven/FeelUOwn)

然后下载后依次输入

    root@kali:git clone https://github.com/cosven/FeelUOwn.git
    root@kali:cd FeelUOwn
    root@kali:./install.sh

## 0x13 wps 等一系列软件

    链接: http://pan.baidu.com/s/1c0b2qiO 密码: l3bj

## 参考网站

    http://www.cnblogs.com/Kali-BT/p/4199533.html
    http://www.th7.cn/system/lin/201508/127806.shtml //sublime text3
    http://www.blackmoreops.com/
    http://www.blackmoreops.com/2014/02/27/change-install-theme-kali-linux-gtk-3-themes/

