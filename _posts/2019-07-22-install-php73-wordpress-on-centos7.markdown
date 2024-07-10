---
layout: post
title: 在 CentOS 7 上使用 PHP73/Caddy 安装 WordPress
date: '2019-07-22 06:11:00'
tags:
- centos
- caddy
- wordpress
- php
- hash-import-2023-03-22-16-36
---

虽然 PHP 已经更新到 7，但是网上相关资源还是不多，大部分停留在 PHP5.6 之前。自己折腾了使用 PHP73 来安装 wordpress，并且使用 Caddy 作为中间件。以下是记录。

## 添加 PHP73 使用的源

使用 remi 的源来安装，首先更新：

    sudo yum update

然后添加源：

    sudo yum install epel-release
    sudo rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

然后安装 PHP 和 WordPress 所依赖的PHP扩展：

    sudo yum --enablerepo=remi install php73-php php73-php-pear php73-php-bcmath php73-php-pecl-jsond-devel php73-php-mysqlnd php73-php-gd php73-php-common php73-php-fpm php73-php-intl php73-php-cli php73-php php73-php-xml php73-php-opcache php73-php-pecl-apcu php73-php-pdo php73-php-gmp php73-php-process php73-php-pecl-imagick php73-php-devel php73-php-mbstring php73-php-zip php73-php-ldap php73-php-imap php73-php-pecl-mcrypt php73-php-mysql

_下面是一些推荐配置：_

    # The current PHP memory limit is below the recommended value of 512MB.
    sudo vi /etc/opt/remi/php73/php.ini
    memory_limit = 512M
    
    # 查看 caddy 是以哪个用户来运行的，这里以 caddy 为例：
    sudo vi /etc/opt/remi/php73/php-fpm.d/www.conf
    user = apache
    group = apache
    
    # 改为运行 caddy 服务的用户：caddy
    user = caddy
    group = caddy

运行并查看版本， 重启命令， 添加自动启动，链接php文件

    php73 -v
    sudo systemctl restart php73-php-fpm
    sudo systemctl enable php73-php-fpm
    sudo ln -s /opt/remi/php73/root/usr/bin/php /usr/bin/php

## 安装 Caddy

Caddy 项目提供了一个安装脚本，用于安装 Caddy 服务器文件。要执行请输入：  
`curl -s https://getcaddy.com | bash`  
您可以通过访问 [https://getcaddy.com](https://getcaddy.com) 使用 wget 或 curl 下载文件来查看脚本。

在安装过程中，脚本将用于 sudo 获取管理权限，以便将 Caddy 文件放在系统范围的目录中，因此它可能会提示您输入密码。

命令输出如下所示：

    Downloading Caddy for linux/amd64...
    https://caddyserver.com/download/linux/amd64?plugins=
    Extracting...
    Putting caddy in /usr/local/bin (may require password)
    [sudo] password for sammy:
    Caddy 0.10.2
    Successfully installed

脚本完成后，Caddy 文件将安装在服务器上并准备使用。您可以使用 which 检查其位置来验证 Caddy 二进制文件是否已到位。

    which caddy

命令输出将说明可以找到 Caddy 二进制文件

    /usr/local/bin/caddy

## 创建 MySQL 数据库和专用用户

WordPress 使用 MySQL 数据库来存储其所有信息。在默认的 MySQL 安装中，仅创建 root 管理帐户。不应使用此帐户，因为它对数据库服务器存在安全风险。在这里，我们为 WordPress 创建一个专用的 MySQL用户，以允许新用户访问的数据库。

首先，登录 MySQL root 管理帐户。

    mysql -u root -p

在安装过程中，系统将提示输入 MySQL root 帐户的密码。创建一个名为 wordpress 的新数据库，将用于 WordPress 网站。使用其他名称请确保在以后进行其他配置时记住该名称。

    CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

接下来，创建一个允许访问此数据库的新用户。在这里，我们使用用户名 `wordpressuser` 来简化，你可以选择自己的名称。请用安全的密码替换 `password` 。

    GRANT ALL ON wordpress.* TO 'wordpressuser'@'localhost' IDENTIFIED BY 'password';

注意：默认密码策略需要12个字符，至少包含一个大写字母，一个小写字母，一个数字和一个特殊字符。如果忘记遵循该策略，则上述命令不会创建用户，而是显示错误消息。  
刷新权限以通知 MySQL 服务器更改。

    FLUSH PRIVILEGES;

现在可以退出 MySQL。

    EXIT;

WordPress 有一个专用的数据库和用户帐户，因此所有系统组件都已设置完毕。下一步是安装 WordPress 本身。

## 下载 WordPress

将最新的 WordPress 下载到 Web 根目录并确保 Web 服务器可以访问它，然后通过 WordPress 的浏览器的 GUI（图形界面）完成安装。在这一步中，我们只下载该版本，因为我们需要在访问 GUI（图形界面）之前配置Web服务器。

首先，将当前目录更改为`/var/www`，即存储网站文件的Web根目录。

    cd /var/www

下载最新的 WordPress 版本。建议您使用最新版，因为软件经常使用安全补丁进行更新。

    sudo curl -O https://wordpress.org/latest.tar.gz

提取解压刚下载的压缩存档。

    sudo tar zxf latest.tar.gz

这将自动创建一个名为 wordpress 的新目录。删掉旧的压缩包 `sudo rm latest.tar.gz`

更改 WordPress 文件和目录的权限，以便所有文件都可由 Caddy 写入。允许 WordPress 自动更新到更新的版本。

    sudo chown -R caddy:caddy wordpress

注意：禁止对 WordPress 文件进行写访问可以提高安全性，通过使它无法利用可能导致 WordPress 核心文件泄露的一些错误，但同时，它会导致禁用自动安全更新以及通过 WordPress Web 界面安装和更新插件的功能。  
接下来，需要修改Web服务器的配置以访问网站。

## 配置 Caddy 为 WordPress 网站提供服务

修改 Caddyfile 配置文件，告诉 Caddy 我们的 WordPress 安装位于何处以及应该用哪个域名来执行。

    sudo vi /etc/caddy/Caddyfile

将以下配置修改为实际配置并复制粘贴到文件中。

    example.com {
        tls example@example.com
        root /var/www/wordpress
        gzip
        fastcgi / 127.0.0.1:9000 php
        rewrite {
            if {path} not_match ^\/wp-admin
            to {path} {path}/ /index.php?_url={uri}
        }
    }

重新启动 Caddy 以使新配置文件设置生效。

    sudo systemctl restart caddy

现在已经安装并配置了 Caddy 和所有必需的软件来托管 WordPress 网站。最后一步是使用其 GUI（图形界面）完成 WordPress 的配置。

## 配置 WordPress

WordPress 有一个 GUI（图形界面）安装向导来完成其设置，包括连接到数据库和设置网站。

当第一次在浏览器中访问新的 WordPress 实例时，将看到一个语言列表。选择你要使用的语言。在下一个屏幕上，它描述了它所需的有关数据库的信息。点击 `Let's go!`，下一页将询问数据库连接详细信息。填写以下表格：

数据库名称应该是`wordpress`，或者你之前自定义的名称。  
用户名应为`wordpressuser`，或者你之前自定义的用户名。  
密码应该是在之前为`wordpressuser`设置的密码。  
数据库主机应该是实际数据库的地址（和 WordPress 同一台主机安装请填写 `localhost`）  
表前缀保留其默认值。  
单击“提交”时，WordPress 将检查提供的详细信息是否正确。如果收到错误消息，请仔细检查您是否正确输入了数据库详细信息。

一旦 WordPress 成功连接到数据库，你将看到一条以 `All right, sparky! You've made it through this part of the installation. WordPress can now communicate with your database.`（你完成了这部分安装。WordPress现在可以与您的数据库进行通信。）开头的消息

单击“运行安装”以开始安装。

注意：对于管理帐户，不推荐使用 Admin 等常用用户名，因为许多安全漏洞依赖于标准用户名和密码。选择唯一的用户名和强密码，以确保网站安全。

单击安装 WordPress 完成后，将被定向到 WordPress 仪表板。

## 网站文件夹及文件权限设置

假设 Caddy 服务器运行的用户和用户组是 `caddy`，服务器用户为 `centos`，网站根目录是 `/var/www/wordpress`：

首先设定网站目录和文件的所有者和所有组为 `centos,caddy`，如下命令：

    chown -R centos:caddy /var/www/wordpress

设置网站目录权限为750，750是 centos 用户对目录拥有读写执行的权限，这样 centos 用户可以在任何目录下创建文件，用户组有有读执行权限，这样才能进入目录，其它用户没有任何权限：

    cd /var/www/wordpress
    find -type d -exec chmod 750 {} \;

设置网站文件权限为640，640指只有 centos 用户对网站文件有更改的权限，Caddy 服务只有读取文件的权限，无法更改文件，其它用户无任何权限：

    cd /var/www/wordpress
    find -not -type d -exec chmod 640 {} \;

针对个别目录设置可写权限。比如网站的一些缓存目录就需要给 Caddy 服务有写入权限。比如 wordpress 的 `wp-content/uploads/` 目录就必须要有写入权限才能上传图片：

    cd /var/www/wordpress
    find uploads -type d -exec chmod 770 {} \;

> 参考

> [https://park.mobayke.com/tools/bbpress.html](https://park.mobayke.com/tools/bbpress.html)  
> [https://cloud.tencent.com/developer/article/1169259](https://cloud.tencent.com/developer/article/1169259)  
> [https://www.itgeeker.net/php7-3-yum-install-on-centos-7/](https://www.itgeeker.net/php7-3-yum-install-on-centos-7/)  
> [https://www.cnblogs.com/sochishun/p/7413572.html](https://www.cnblogs.com/sochishun/p/7413572.html)

