---
layout: post
title: 在 QNAP NAS 中安装 Flexget 并配置 RSS 订阅下载
date: '2020-03-06 06:15:00'
tags:
- qnap
- nas
- rss-tag
- flexget
- hash-import-2023-03-22-16-36
---

Flexget 配合种子下载软件（Transmission/Deluge 等），可以根据 RSS 链接和配置文件，自动下载订阅的种子，或进行相应的过滤，不必总是去种子站守资源或者搜索。一般的 PT 站都提供 RSS 订阅下载功能，订阅下载资源非常方便。

## 0x00 下载安装 Flexget

> 参考官网：[https://flexget.com/InstallWizard/QNAP](https://flexget.com/InstallWizard/QNAP)

SSH 连接到 NAS 并输入下面的命令：

    apt-get update && apt-get install -y python-pip
    pip install --upgrade setuptools
    pip install flexget
    mkdir /root/.flexget
    cd /root/.flexget

## 0x01 配置 RSS 订阅下载

    # 创建 flexget.yml 文件
    vim flexget.yml
    # 修改下面的配置信息并粘贴
    tasks:
      my_feed:
        rss: https://somerssfeed.com/feed.xml # rss 订阅链接
        accept_all: yes
        transmission:
          host: *transmission-host* # transmission 地址
          port: *transmission-port* # transmission 端口号
          username: *transmission-username* # transmission 用户名
          password: *transmission-password* # transmission 密码
          path: /path/to/download # 订阅下载的目录

## 0x02 配置自动刷新脚本

    # 创建脚本
    vim flexget.sh
    # 将下面的配置粘贴到脚本中
    export LANG=en_US.UTF-8
    FLEXGETLOGFILE='/root/.flexget/flexget.log' # 配置日志文件
    flexget --cron --logfile $FLEXGETLOGFILE -c '/root/.flexget/flexget.yml' execute # 执行首次 RSS 订阅下载更新
    # 记录错误信息到日志文件
    sed -i '/ CRITICAL \s*rss .* HTTP error 502 received from /d' "$FLEXGETLOGFILE"
    sed -i '/ CRITICAL \s*rss .* Internal server exception on task /d' "$FLEXGETLOGFILE"
    sed -i '/ WARNING \s*task .* Aborting task /d' "$FLEXGETLOGFILE"
    sed -i '/ INFO \s*manager .* Running database cleanup\./d' "$FLEXGETLOGFILE"
    sed -i '/ INFO \s*db_analyze .* Running ANALYZE on database to improve performance\./d' "$FLEXGETLOGFILE"

给脚本分配执行的权限：

    chmod +x flexget.sh

执行下面的命令，设置自动刷新（默认是每天刷新一次）：

    printf "0 * * * * '/root/.flexget/flexget.sh'\n" >> '/etc/config/crontab'

如果想要手动刷新 RSS 订阅下载信息的话，可以执行下面的命令：

    flexget --cron --logfile /root/.flexget/flexget.log -c '/root/.flexget/flexget.yml' execute

或者直接运行创建好的 flexget.sh 脚本：

    cd /root/.flexget/
    ./flexget.sh

> 每次重启 NAS 之后，所有配置信息都会丢失，需要重新填写。所以请备份第一次的配置信息方便恢复。

