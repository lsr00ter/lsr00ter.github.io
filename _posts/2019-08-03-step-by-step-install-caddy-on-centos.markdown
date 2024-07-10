---
layout: post
title: 在 CentOS 上安装 Caddy 服务
date: '2019-08-03 06:14:00'
tags:
- centos
- caddy
- webserver
- hash-import-2023-03-22-16-36
---

## 安装

CentOS 据说可以通过 `yum install caddy` 来安装，不过前提是要安装 epel 安装源，不过我习惯从 Caddy 官方网站下载安装。

ssh 登录到 CentOS 系统里，运行

    # 选择自己需要的模块一并安装
    curl https://getcaddy.com | bash -s personal http.cache,http.geoip,http.git,http.grpc

因为 Caddy 就是一个可执行文件，所以下载就完了。

## 配置

要启动 Caddy，需要建立一个 root 用户以外的账户，我新建的账户叫做 caddy，以下为 caddy 的配置过程：

建立一个用于存放网页文件的目录，如 `/var/www`,命令如下：

    sudo mkdir /var/www

建立 caddy 用户

    sudo adduser -r -d /var/www -s /sbin/nologin caddy

建立 Caddy 配置文件的路径

    mkdir /etc/caddy

建立一个空的 Caddy 工作配置参数文件

    sudo touch /etc/caddy/Caddyfile

设置路径的访问权限

    sudo chown -R root:caddy /etc/caddy

创建用于存放 ssl 证书的路径，并给予正确的权限

    sudo mkdir /etc/ssl/caddy
    sudo chown -R caddy:root /etc/ssl/caddy
    sudo chmod 0770 /etc/ssl/caddy

创建用于存放日志的路径

    sudo mkdir /var/log/caddy
    sudo chown -R caddy:root /var/log/caddy

修改存放网页的路径权限 `/var/www`

    sudo chown caddy:caddy /var/www

把 Caddy 安装为开机自动启动的服务

    sudo curl -s https://raw.githubusercontent.com/mholt/caddy/master/dist/init/linux-systemd/caddy.service -o /etc/systemd/system/caddy.service

修改配置文件里面的用户信息

    # 打开自动启动服务配置文件
    sudo vi /etc/systemd/system/caddy.service
    # 查找并修改：
    ; User and group the process will run as.
    User=caddy
    Group=caddy

设置服务

    sudo systemctl daemon-reload
    sudo systemctl enable caddy.service

_现在还不能正常成功启动 Caddy，因为还没有配置网站参数信息。_

配置网站信息

网站配置参数信息文件是 `/etc/caddy/Caddyfile`

    # 打开配置文件
    sudo vi /etc/caddy/Caddyfile
    # 添加如下信息
    www.example.com   # 把这里修改为实际网站的域名
    {
      log /var/log/caddy/caddy.log # 日志文件
      tls example@example.com # 修改为个人邮箱帐号，用于自动申请 ssl 证书
      root /var/www # 网站根目录
      gzip
    }

## 启动 Caddy 服务

    # 重启 Caddy 服务
    sudo systemctl restart caddy
    # 查看运行状态
    sudo systemctl status caddy -l

如果提示自动加载证书失败,可以使用 [CertBot](https://certbot.eff.org/) 手动申请证书。

