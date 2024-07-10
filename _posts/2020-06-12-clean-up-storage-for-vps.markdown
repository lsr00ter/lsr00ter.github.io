---
layout: post
title: 查找并清理 Linux 的存储空间
date: '2020-06-12 06:18:00'
tags:
- centos
- vps
- linux
- hash-import-2023-03-22-16-36
---

最近 VPS 磁盘空间一直警告不够用，就想看一下哪个文件占用空间比较大，删掉一些不用的大文件，腾出可用空间来。

以下是记录。

## 查看磁盘空间使用量

    $ df -h
    Filesystem Size Used Avail Use% Mounted on
    devtmpfs 394M 0 394M 0% /dev
    tmpfs 411M 0 411M 0% /dev/shm
    tmpfs 411M 42M 369M 11% /run
    tmpfs 411M 0 411M 0% /sys/fs/cgroup
    /dev/mapper/cl-root 50G 2.3G 48G 5% /
    /dev/mapper/cl-home 47G 367M 47G 1% /home
    /dev/vda1 976M 175M 735M 20% /boot
    tmpfs 83M 0 83M 0% /run/user/0
    tmpfs 83M 0 83M 0% /run/user/1000

## 排查大文件所在目录

    $ du -sh .[!.]* # 查看当前目录下子目录大小（du: disk usage）;-s: 显示总和；-h: 易读模式
    4.0K .bash_history
    4.0K .bash_logout
    4.0K .bash_profile
    4.0K .bashrc
    4.0K .ssh
    4.0K .wget-hsts
    
    $ du -sh /usr/[!.]* # 查看 /usr/ 目录下各个子目录大小
    202M /usr/bin
    0 /usr/games
    84K /usr/include
    614M /usr/lib
    270M /usr/lib64
    84M /usr/libexec
    4.0K /usr/local
    64M /usr/sbin
    374M /usr/share
    0 /usr/src
    0 /usr/tmp

## 查看大文件

    $ ls -laShs
    total 20K
    4.0K -rw-------. 1 groot groot 2.8K Jun 11 17:10 .bash_history
    4.0K -rw-r--r--. 1 groot groot 312 Nov 9 2019 .bashrc
    4.0K -rw-rw-r--. 1 groot groot 204 Jun 12 13:32 .wget-hsts
    4.0K -rw-r--r--. 1 groot groot 141 Nov 9 2019 .bash_profile
    4.0K -rw-r--r--. 1 groot groot 18 Nov 9 2019 .bash_logout

## 查看已标记为删除的文件占用的空间

    $ lsof -n | grep deleted
    systemd-j 619 root txt REG 253,0 234488 650779 /usr/lib/systemd/systemd-journald (deleted)
    qemu-ga 843 root txt REG 253,0 449064 1079814 /usr/bin/qemu-ga (deleted)
    systemd-l 873 root txt REG 253,0 481696 650781 /usr/lib/systemd/systemd-logind (deleted)
    NetworkMa 891 root txt REG 253,0 7350304 34213286 /usr/sbin/NetworkManager (deleted)
    NetworkMa 891 902 gmain root txt REG 253,0 7350304 34213286 /usr/sbin/NetworkManager (deleted)
    NetworkMa 891 903 gdbus root txt REG 253,0 7350304 34213286 /usr/sbin/NetworkManager (deleted)

## 释放空间已删除文件所占空间

    $ kill -9 %PID% # 结束相应的进程

## 清除 apt cache

    # 查看
    du -sh /var/cache/apt/archives
    # 删除
    sudo apt-get clean

## 清除不需要的包

    sudo apt-get autoremove

## 删除旧的 kernels

    sudo apt-get autoremove --purge

## Mysql 日志自动清理

    # vim /etc/my.cnf
    
    #日志超过3天自动过期
    expire_logs_days = 3
    
    # sudo systemctl restart mysqld

> [https://blog.csdn.net/lk\_db/article/details/78341698](https://blog.csdn.net/lk_db/article/details/78341698)

> [https://jaminzhang.github.io/os/File-Deleted-And-Still-Use-The-Filesystem-Space-Problem-In-Linux/](https://jaminzhang.github.io/os/File-Deleted-And-Still-Use-The-Filesystem-Space-Problem-In-Linux/)

> [http://blog.kankanan.com/article/63a75236-pm2-768465e55fd765874ef659275c0f.html](http://blog.kankanan.com/article/63a75236-pm2-768465e55fd765874ef659275c0f.html)

> [http://einverne.github.io/post/2018/03/du-find-out-which-fold-take-space.html](http://einverne.github.io/post/2018/03/du-find-out-which-fold-take-space.html)

