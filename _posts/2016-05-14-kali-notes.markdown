---
layout: post
title: Kali linux 使用记录
date: '2016-05-14 05:57:00'
tags:
- pentest
- kali
- hash-import-2023-03-22-16-36
---

<figure class="kg-card kg-image-card"><img src="http://image.3001.net/images/20160130/14540858194014.png" class="kg-image" alt loading="lazy"></figure>
## 安装完Kali linux 之后的配置 常用软件 记录

- [Kali linux 使用记录](#toc_0)
- [安装完Kali linux 之后的配置 常用软件 记录](#toc_1)
- [0x01 更换源并更新](#toc_2)
- [0x02 安装内核头](#toc_3)
- [0x03 安装字体](#toc_4)
- [0x04 安装浏览器](#toc_5)
- [0x05 拼音输入法（需要注销重新登录）](#toc_6)
- [0x06 科学上网](#toc_7)
- [0x07 定制终端](#toc_8)
- [0x08 配置Python及Java环境](#toc_9)
- [0x09 安装代码编辑器](#toc_10)
- [0x10 安装 git](#toc_11)
- [0x11 一些工具](#toc_12)
- [0x12 娱乐](#toc_13)
- [0x13 wps等一系列软件](#toc_14)
- [参考网站](#toc_15)

### 0x01 更换源并更新

`root@kali:~# leafpad /etc/apt/sources.list`

    #kali官方源
    deb cdrom:[Debian GNU/Linux 2.0 _Sana_ - Official Snapshot i386 LIVE/INSTALL Binary 20150811-09:06]/ sana contrib main non-free
    deb cdrom:[Debian GNU/Linux 2.0 _Sana_ - Official Snapshot i386 LIVE/INSTALL Binary 20150811-09:06]/ sana contrib main non-free
    deb http://http.kali.org/kali sana main non-free contrib
    deb-src http://http.kali.org/kali sana main non-free contrib
    deb http://security.kali.org/kali-security/ sana/updates main contrib non-free
    deb-src http://security.kali.org/kali-security/ sana/updates main contrib non-free
    deb http://http.kali.org/kali kali main non-free contrib
    deb-src http://http.kali.org/kali kali main non-free contrib
    deb http://security.kali.org/kali-security kali/updates main contrib non-free
    
    #阿里云Kali源
    deb http://mirrors.aliyun.com/kali kali main non-free contrib
    deb-src http://mirrors.aliyun.com/kali kali main non-free contrib
    deb http://mirrors.aliyun.com/kali-security kali/updates main contrib non-free
    
    #kali新加坡源的地址
    deb http://mirror.nus.edu.sg/kali/kali/ kali main non-free contrib
    deb-src http://mirror.nus.edu.sg/kali/kali/ kali main non-free contrib
    deb http://security.kali.org/kali-security kali/updates main contrib non-free
    deb http://mirror.nus.edu.sg/kali/kali-security kali/updates main contrib non-free
    deb-src http://mirror.nus.edu.sg/kali/kali-security kali/updates main contrib non-free
    
    #debian_wheezy国内源的地址
    deb http://ftp.sjtu.edu.cn/debian wheezy main non-free contrib
    deb-src http://ftp.sjtu.edu.cn/debian wheezy main non-free contrib
    deb http://ftp.sjtu.edu.cn/debian wheezy-proposed-updates main non-free contrib
    deb-src http://ftp.sjtu.edu.cn/debian wheezy-proposed-updates main non-free contrib
    deb http://ftp.sjtu.edu.cn/debian-security wheezy/updates main non-free contrib
    deb-src http://ftp.sjtu.edu.cn/debian-security wheezy/updates main non-free contrib
    deb http://mirrors.163.com/debian wheezy main non-free contrib
    deb-src http://mirrors.163.com/debian wheezy main non-free contrib
    deb http://mirrors.163.com/debian wheezy-proposed-updates main non-free contrib
    deb-src http://mirrors.163.com/debian wheezy-proposed-updates main non-free contrib
    deb-src http://mirrors.163.com/debian-security wheezy/updates main non-free contrib
    deb http://mirrors.163.com/debian-security wheezy/updates main non-free contrib
    
    #中科大kali源
    deb http://mirrors.ustc.edu.cn/kali kali main non-free contrib
    deb-src http://mirrors.ustc.edu.cn/kali kali main non-free contrib
    deb http://mirrors.ustc.edu.cn/kali-security kali/updates main contrib non-free

然后更新并安装

`root@kali:~# apt-get update && apt-get dist-upgrade`

## 0x02 安装内核头

`root@kali:apt-get install linux-headers-$(uname -r)`

或者

`aptitude -r install linux-headers-$(uname -r`

## 0x03 安装字体

    apt-get install ttf-arphic-uming ttf-wqy-zenhei ttf-wqy-microhei ttf-arphic-ukai

或者 ，自己下载字体包  
把雅黑的ttf文件拷到/usr/share/fonts/的任意目录下，假设雅黑ttf叫做Yahei.ttf：

    sudo mkdir -p /usr/share/fonts/vista
    sudo cp Yahei.ttf /usr/share/fonts/vista/

然后，改变权限：

`sudo chmod 644 /usr/share/fonts/vista/*.ttf`

安装：

    cd /usr/share/fonts/vista/
    sudo mkfontscale
    sudo mkfontdir
    sudo fc-cache -fv

最后，去系统－首选项－高级设置 里修改 debain字体

## 0x04 安装浏览器

自带浏览器汉化方法：

`root@kali:apt-get install iceweasel-l10n-zh-cn`

如果有强迫症删了系统自带浏览器，然后重新安装了一个新的火狐可能遇到的问题：

可能会出现 gnome 桌面被误删，从而导致系统进不去，并且即使你安装了一个新的火狐然后你就卸载不了了，会一直提示报错，并且此时如果你还想安装其他浏览器的话也会报错，如果真遇到的话你又不想重装系统有个治标不治本的方法（`root@kali:sudo apt-get install –reinstall firefox-mozilla-build`），还有说道如果桌面崩溃处理方法就是ctrl+alt+Fn(数字)进入非图形化界面然后重新安装下桌面环境。

安装谷歌浏览器

官网上下载谷歌浏览器（可能你访问不了，有时候等等还是可以出现下载链接的，如果访问不了去百度上搜索下然后下载个deb包），然后到下载目录安装下：`root@kali:dpkg -i google-chrome-stable`（具体以实际包的名称为准）。安装完之后，如果你是 root 运行，会提示你不给 root 执行的。解决方法：`root@kali:gedit /usr/bin/google-chrome`，然后在最后一行尾加入`–user-data-dir`（注意空格）。

安装Flash

首先`root@kali:apt-get install flashplugin-nonfree`

其次`root@kali:update-flashplugin-nonfree –install`

安装Tor Browser

    root@kali:apt-get install tor
    root@kali:service tor start
    root@kali:proxychains iceweasel

## 0x05 拼音输入法（需要注销重新登录）

    apt-get install ibus ibus-pinyin #经典的ibus
    apt-get install fcitx fcitx-pinyin fcitx-module-cloudpinyin fcitx-googlepinyin #fcitx拼音

## 0x06 科学上网

默认安装，是没有激活VPN的，能看到VPN选项，但是不能点击VPN连接

    apt-get install -y pptpd network-manager-openvpn network-manager-openvpn-gnome network-manager-pptp network-manager-pptp-gnome network-manager-strongswan network-manager-vpnc network-manager-vpnc-gnome

[lantern](https://github.com/getlantern/lantern-binaries)

方法就是下载对应的版本，然后dpkg安装下，然后打开lantern自动跳转到浏览器，然后就没有然后了。。。

Shadowsocks

首先搭建shadowsocks客户端

git 下 [https://github.com/shadowsocks/shadowsocks-qt5](https://github.com/shadowsocks/shadowsocks-qt5) 以及其安装指南 [https://github.com/shadowsocks/shadowsocks-qt5/wiki/%E5%AE%89%E8%A3%85%E6%8C%87%E5%8D%97](https://github.com/shadowsocks/shadowsocks-qt5/wiki/%E5%AE%89%E8%A3%85%E6%8C%87%E5%8D%97)

或者直接用pip安装

`pip install shadowsocks`

`/usr/local/python/bin/sslocal   //ss位置`

建立一个为ss.conf的配置文件

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

其次安装privoxy实现socks5转换成http

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

然后打开shadowsocks privoxy

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

然后设置 快捷启动终端的键（例如ctrl+alt+T）

多命令终端

byobu 介绍 [http://blog.csdn.net/lqhbupt/article/details/7786153](http://blog.csdn.net/lqhbupt/article/details/7786153)

## 0x08 配置Python及Java环境

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

将系统默认的jdk修改过来，也就是java 和javac 命令有系统自带到换成你自己安装的

    update-alternatives --install /usr/bin/java java /usr/lib/jdk/jdk1.7.0_03/bin/java 300
    update-alternatives --install /usr/bin/javac javac /usr/lib/jdk/jdk1.7.0_03/bin/javac 300
    update-alternatives --config java
    update-alternatives --config javac

<figure class="kg-card kg-image-card"><img src="http://static.oschina.net/uploads/img/201403/06002415_wAFS.png" class="kg-image" alt loading="lazy"></figure>

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

解决界面汉化：网上搜索下载 Sublime\_Text\_CN\_3059.zip，解压之后得到`Default.sublime-package`文件，其实就是个 package，在菜单中选择`preferences——Browse packages`进入到`/home/siat/.config/sublime-text-3/Packages`然后向上一级进入到`/home/siat/.config/sublime-text-3/Installed Packages`，把`Default.sublime-package`包复制到`Installed    Packages`文件夹下，这时 sublime text3 立刻变成中文了。

## 0x10 安装 git

安装：

    aptitude install git-core
    aptitude install git-doc git-svn git-email git-gui gitk

配置：

    ssh-keygen -t rsa -C "xxxx@email.com"

进入 github 设置 &nbsp;SSH Keys：

<figure class="kg-card kg-image-card"><img src="http://static.oschina.net/uploads/space/2014/0304/231551_SyDR_615783.png" class="kg-image" alt loading="lazy"></figure>

`ssh -T git@github.com`

看其是否返回：

`Hi xxx! You've successfully authenticated, but GitHub does not provide shell access .`

**设置git 全局变量 ，name 和 email**

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

安装dota2和steam平台

**（64位适合）**

首选官网下载steam并且dpkg安装下，然后如果你是root运行会有提示。解决方法终端执行：

    /usr/bin
    gedit steam

然后找到如下位置，并且把双引号中的0改成1即可

    # Don’t allow running as root
    if ["$(id -u)" == "0"]; then
    show_message –error $”Cannot run as root user”
    exit 1
    Fi

然后登陆账号，下载dota2。

网易云音乐

首先git下 [https://github.com/cosven/FeelUOwn](https://github.com/cosven/FeelUOwn)

然后下载后依次输入

    root@kali:git clone https://github.com/cosven/FeelUOwn.git
    root@kali:cd FeelUOwn
    root@kali:./install.sh

## 0x13 wps等一系列软件

    链接: http://pan.baidu.com/s/1c0b2qiO 密码: l3bj

## 参考网站

    http://www.cnblogs.com/Kali-BT/p/4199533.html
    http://www.th7.cn/system/lin/201508/127806.shtml //sublime text3
    http://www.blackmoreops.com/
    http://www.blackmoreops.com/2014/02/27/change-install-theme-kali-linux-gtk-3-themes/

