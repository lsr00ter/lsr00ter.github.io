---
layout: post
title: CentOS VPS 安全加固
date: '2020-06-09 06:17:00'
tags:
- centos
- vps
- hash-import-2023-03-22-16-36
---

由于正常上网和经常产生新的 idea 需要，手上的 VPS 越来越多，每次都要对新 VPS 进行安全加固，防止被黑。顺便记录常用加固项。

## 添加 alias 信息

编辑本地 `~/.ssh/config` 文件，添加 VPS 的 alias 信息，方便以后通过 `ssh alias-name` 连接 VPS。

以 masOS 为例，首先打开 `~/.ssh/config` 文件：

    $ vi ~/.ssh/config

然后将自己的 VPS 信息填写进去，格式如下：

    Host alias-name # 自定义的主机昵称
       HostName ip_address # VPS 主机地址
       Port port_number # 端口号
       User user # 登陆用户名

如果记不住那么多机器的 alias ，可以写个脚本命令列出已经添加的配置，例如 `sshl` ，每次需要的显示一下敲一下就 OK 了。

    $ alias sshl='cat ~/.ssh/config | grep "Host "'

## 安装 NTP 服务

    $ sudo yum install ntp ntpdate # 安装 ntp 服务
    $ chkconfig ntpd on # 开机自动启动
    $ ntpdate pool.ntp.org # 添加 ntp 服务器
    $ systemctl start ntpd # 启动 ntp 服务

### CentOS 8 使用 chrony

    $ yum install chrony
    $ systemctl start chronyd

## 在登陆时提示上次登录失败的信息

    $ vim /etc/pam.d/systemd-user
    # 将下面这一行复制进去
    session required pam_lastlog.so showfailed

## 设置每个会话最大密码尝试次数

    $ vim /etc/pam.d/systemd-user
    # 将下面这一行复制进去
    auth pam_pwquality.so retry=3

## 阻止错误密码尝试

编辑 `/etc/pam.d/system-auth` 和 `/etc/pam.d/password-auth` 两个 PAM 配置文件（尝试3次错误锁定20分钟），添加下面两行进去

    auth [default=die] pam_faillock.so authfail deny=3 unlock_time=1200 fail_interval=900
    auth required pam_faillock.so authsucc deny=3 unlock_time=1200 fail_interval=900

## 限制密码重用

使用 PAM 模块配置，在 `/etc/pam.d/system-auth` 这个 PAM 配置文件里面，在 `pam_unix.so` 所在的行添加 `remember=24` 。这样服务器就会记录历史上的前 24 个旧密码，为啥为 24？因为这是美国国防部的标准。

    password sufficient pam_unix.so existing_options remember=24

## 设置 /boot/grub2/grub.cfg 权限

设置 `/boot/grub2/grub.cfg` 的权限为 600

    sudo chmod 600 /boot/grub2/grub.cfg

## 创建具有 sudo 权限的普通用户

### 创建一个新用户

    adduser demo
    passwd demo

### 查看当前活跃用户

    w

### 查看用户列表

    cat /etc/passwd|grep -v nologin|grep -v halt|grep -v shutdown|awk -F":" '{ print $1"|"$3"|"$4 }'|more

### 给新用户 sudo 权限

现在，我们有了普通用户，进行普通的操作，但是有时，我们需要更大的权限进行操作，如 `yum update`，进行这样的操作，我们一般不会使用 root 登进登录，一般使用 `sudo` （Super User do）命令。

为了将 `sudo` 权限给普通用户，我们需要将新用户加入 wheel 组中，CentOS 默认的 wheel 组有运行 `sudo` 的权限。

我们使用 root 用户，将 demo 用户加入到 wheel 组中。

    gpasswd -a demo wheel

## 配置 SSH 服务

我们添加了普通用户，也可以执行 `sudo` 命令，需要配置 ssh 服务，去掉 root 用户的远程登录，这样更加安全。

### 登录到服务器

    $ ssh demo@SERVER_IP_ADDRESS

### 进行配置

    $ sudo vi /etc/ssh/sshd_config

将

    #PermitRootLogin yes

改为

    PermitRootLogin no

`:wq` 保存并退出。

### 重启 ssh 服务

    $ sudo systemctl reload sshd

这样，服务器的 root 用户就被禁止了远程登录。

### 修改端口

    $ sudo vi /etc/ssh/sshd_config
    Port *

### 禁止空密码登录

    vim /etc/ssh/sshd_config:
    
    PermitEmptyPasswords no

### 只允许 ssh proto 2

    vim /etc/ssh/sshd_config
    
    Protocol 2

