---
layout: post
title: 在 CentOS 上使用 Caddy 运行 Discourse 踩坑记
date: '2019-07-25 06:12:00'
tags:
- centos
- caddy
- discourse
- hash-import-2023-03-22-16-36
---

因为想体验下论坛，所以在自己 VPS 上安装了 Discourse，这个号称论坛下一个十年的服务。

先说为什么用 Caddy 来配合使用 Discourse：

- Caddy 官方论坛是用的 Discourse
- Caddy 自动部署免费的 SSl 证书：Let’s Encrypt
- HTTP2 和 QUIC
- 配置简单

## Requirements

- 最低 1GB 内存
- CentOS 7 x64

## 设置 swapfile

Discourse 官方推荐配置最低为 2GB 内存，所以如果你的主机是 1GB 内存的话，需要创建一个 2GB 的 swapfile。

创建教程请参考我的另一篇文章[《在 Linux 中设置和修改 swap 空间》]({% post_url 2019-07-22-add-or-resize-swapfile-size %})。

## 安装 Docker

使用如下命令安装和配置 Docker

    sudo yum install docker
    vi /etc/sysconfig/docker
    # 将下面一行注释掉，效果如下
    #OPTIONS='--selinux-enabled'
    # 启用 Docker 服务，并添加开机启动
    sudo systemctl start docker
    sudo systemctl enable docker

如遇到问题，请搜索解决。

## 安装 Discourse

在 `/var` 文件夹创建一个 `discourse` 文件夹，将 Discourse 源代码克隆进去

    sudo mkdir /var/discourse
    sudo git clone https://github.com/discourse/discourse_docker.git /var/discourse

进入 `discourse` 文件夹

    cd /var/discourse

拷贝 Discourse 的配置参考文件到 containers 文件夹

    sudo cp samples/standalone.yml containers/app.yml

## 配置 Discourse

打开 `app.yml`

    sudo vi containers/app.yml

如果你使用的是 1GB 的 VPS，将配置修改为如下参数

    db_shared_buffers: "128MB"
    ## With 2GB we recommend 3-4 workers, with 1GB only 2
    UNICORN_WORKERS: 2

配置你的管理员邮箱地址

    DISCOURSE_DEVELOPER_EMAILS: 'you@youremail.com'

设置你的 Discourse 论坛域名，如 `discourse.example.com` 则将配置改为

    ## TODO: The domain name this Discourse instance will respond to
    DISCOURSE_HOSTNAME: 'discourse.example.com'

配置邮件服务

推荐使用官方教程 [INSTALL-email.md](https://github.com/discourse/discourse/blob/master/docs/INSTALL-email.md)

我尝试使用 Yandex 的免费自定义域名邮箱服务，但是配置完成后一直无法发送邮件，最后还是用了官方推荐的 Mailjet 服务。

修改配置使 Discourse 可以运行在 Caddy Server

    ## 将下面两行注释掉
    # - "templates/web.ssl.template.yml"
    # - "templates/web.letsencrypt.ssl.template.yml"
    ## 修改下面两行，注释掉 https，修改 http 端口，避免冲突（系统 apache/nginx 服务已经占用了 80 端口）
    expose:
      - "8080:80" # http，表示将容器外的 8080 端口映射到容器内的 80 端口
    # - "443:443" # https
    env:
      ## 将下面一行注释掉
      #LETSENCRYPT_ACCOUNT_EMAIL: you@youremail.com

1. 保存并关闭 `app.yml` 文件

修改 Caddy 配置文件 `Caddyfile`，添加如下配置

    discourse.example.com # 你的论坛域名
    proxy / localhost:8080 { # 8080 为之前在 app.yml 中配置的 http 端口
        transparent
    }

构建并启动 Discourse

    sudo ./launcher bootstrap app
    sudo ./launcher start app

如果构建之后修改了 `app.yml` 配置文件，则需要使用下面命令来重新构建 app 并启动

    ./launcher stop app
    ./launcher rebuild app
    ./launcher start app

1. 在浏览器输入你在 `DISCOURSE_HOSTNAME` 配置的论坛域名，如`discourse.example.com`，就可以看到部署完成的论坛了！

手动激活管理员账户

如果你的邮件服务器配置存在问题，或者始终无法收到激活邮件，则使用下面命令手动激活管理员账户

    sudo ./launcher enter app
    rake admin:create

## 使用感受

Discourse 给人的感觉就是很新，很简洁：

- 弱化分类。Discourse 首页 **默认展示全站热帖** （可配置），而不是分类目录
- 简化发布。编辑器默认 **Markdown** 格式，纯文本，方便后期格式化展示；默认附件只能上传图片
- 帖子以对话气泡的形式展示
- 类似 Bootstrap 风格的标准交互控件，大量 Ajax 加载使用，话题跟踪与通知系统
- 固定 **论坛分类的顺序** 需要在设置中将 `fixed category positions` 选中
- 论坛分类 **最多两个层级**

_部分摘自`知乎：黎欣健`_

> 参考
> [https://meta.discourse.org/t/running-discourse-with-caddy-server/54716](https://meta.discourse.org/t/running-discourse-with-caddy-server/54716)
> [https://www.vultr.com/docs/install-discourse-on-centos-7](https://www.vultr.com/docs/install-discourse-on-centos-7)
> [https://github.com/discourse/discourse/blob/master/docs/INSTALL-email.md](https://github.com/discourse/discourse/blob/master/docs/INSTALL-email.md)

