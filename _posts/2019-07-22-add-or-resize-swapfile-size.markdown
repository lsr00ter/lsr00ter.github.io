---
layout: post
title: 在 Linux 中设置和修改 swap 空间
date: '2019-07-22 06:10:00'
tags:
- linux
- hash-import-2023-03-22-16-36
---

## 启用 swap

创建 swapfile

    dd if=/dev/zero of=/swapfile bs=1M count=2048
    mkswap /swapfile
    chmod 600 /swapfile

使用 vi 打开 fstab

    vi /etc/fstab

将以下内容添加到文件中

    /swapfile swap swap defaults 0 0

（可选）设置当系统内存较小时才使用 swapfile

    sysctl -w vm.swappiness=10
    echo vm.swappiness = 10 | tee -a /etc/sysctl.conf
    sysctl vm.vfs_cache_pressure=60
    echo vm.vfs_cache_pressure = 60 | tee -a /etc/sysctl.conf

启用 swapfile.

    mount -a
    swapon -a

检查 swapfile 状态

    swapon -s

## 修改swap大小

关闭 swap

    sudo swapoff -a

把当前的 swapfile 文件增大

    sudo dd if=/dev/zero of=/swapfile bs=1M count=1024

bs 指的是 Block Size，就是每一块的大小。这里的例子是 1M，意思就是 count 的数字，是以 1M 为单位的。  
counter 是告诉程序，新的 swapfile 要多少个 block。这里是 1024，就是说，新的 swap 文件是 1G 大小。

把增大后的文件变为swap文件。

    sudo mkswap /swapfile

重新打开 swap

    sudo swapon /swapfile

让 swap 在启动的时候，自动生效。打开 `/etc/fstab` 文件

    sudo vim /etc/fstab

(如果之前未设置) 打开 fstab `vi /etc/fstab`加上以下命令。然后保存。

    /swapfile swap swap defaults 0 0

