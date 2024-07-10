---
layout: post
title: 在 CentOS 7 上搭建 MediaWiki/Caddy
date: '2019-08-03 06:13:00'
tags:
- centos
- caddy
- mediawiki
- hash-import-2023-03-22-16-36
---

一个标准安装的 MediaWiki 除软件自身以外，还需要安装下列环境：

- Web 服务器。用于服务客户端浏览器的请求。
- PHP 运行环境。
- 数据库服务器。用于储存网站页面与数据。  
除上述必需的环境以外，还有若干可选依赖，如果你需要使用一些高级功能则需要安装这些依赖。

## 安装 php、mariadb

安装 mariadb

    sudo yum install -y mariadb-server mariadb

安装 php 及依赖

    sudo yum --enablerepo=remi install php73-php php73-php-apcu php73-php-intl php73-php-mbstring php73-php-xml php73-php-gd mariadb-server

## 配置数据库

    sudo systemctl start mariadb.service
    
    # 执行 mysql_secure_installation 命令，配置 MariaDB 安全权限：
    mysql_secure_installation
    
    # 执行完成后登录 MariaDB，初始化 MediaWiki 数据库
    CREATE USER 'wiki'@'localhost' IDENTIFIED BY 'InputPasswordHere';
    CREATE DATABASE wiki;
    GRANT ALL PRIVILEGES ON wiki.* TO 'wiki'@'localhost';
    FLUSH PRIVILEGES;

## 安装及配置 MediaWiki

下载并解压

    wget https://releases.wikimedia.org/mediawiki/1.33/mediawiki-1.33.0.tar.gz
    tar -zxvf mediawiki-1.33.0.tar.gz
    # 移动到网站根目录
    mv mediawiki-1.29.1 /var/www/html/wiki

配置 MediaWiki

用浏览器打开 MediaWiki 页面，按照指示添加站点信息以及数据库等信息。

