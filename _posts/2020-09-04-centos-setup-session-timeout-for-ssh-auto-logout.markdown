---
layout: post
title: CentOS 配置登录会话超时，防止 SSH 自动退出
date: '2020-09-04 05:39:00'
tags:
- centos
- ssh
- hash-import-2023-03-22-16-36
---

在远程管理 VPS 的时候经常会遇到登录会话无活动，导致会话超时 SSH 自动退出的问题，可以通过两个方式在服务端修改配置解决。

`/etc/ssh/sshd_config` 文件中的两个参数，和 SSH 无活动会话超时自动退出有关：

    ClientAliveInterval
    ClientAliveCountMax

在 `sshd_config` 的 `man` 帮助页面有对于这两个参数的解释：

    $ man sshd_config
         ClientAliveCountMax
                 Sets the number of client alive messages (see below) which may be sent without sshd(8) receiving any messages back from the client. If this threshold is reached while client alive messages are being sent, sshd will disconnect the client, terminating the session. It is important to note that the use of client alive messages is very different from TCPKeepAlive (below). The client alive messages are sent through the encrypted channel and therefore will not be spoofable. The TCP keepalive option enabled by TCPKeepAlive is spoofable. The client alive mechanism is valuable when the client or server depend on knowing when a connection has become inactive. The default value is 3. If ClientAliveInterval (see below) is set to 15, and ClientAliveCountMax is left at the default, unresponsive SSH clients will be disconnected after approximately 45 seconds. This option applies to protocol version 2 only.
    
         ClientAliveInterval
                 Sets a timeout interval in seconds after which if no data has been received from the client, sshd(8) will send a message through the encrypted channel to request a response from the client. The default is 0, indicating that these messages will not be sent to the client. This option applies to protocol version 2 only.

所以有两种方法来配置无活动会话超时。

## Method 1

- 在 `/etc/ssh/sshd_config` 文件中配置超时参数

    $ vi /etc/ssh/sshd_config
    ClientAliveInterval 5m # 5 分钟
    ClientAliveCountMax 2 # 2 次

- 重启 `sshd` 服务

    $ service sshd restart

这样就将超时时间设置成了 10 分钟（5分钟检测一次客户端活动，共检测两次）。

## Method 2

- 通过设置 `ClientAliveCountMax` 为 0，`ClientAliveInterval` 为 10m 来达到同样的效果

    $ vi /etc/ssh/sshd_config
    ClientAliveInterval 10m # 10 minutes
    ClientAliveCountMax 0 # 0 times

- 重启 `sshd` 服务

    $ service sshd restart

## Method 1 和 Method 2 的不同

Method 1 ：如果客户端 5 分钟没有活动，`sshd` 会向客户端发送保持连接信息，最多发送两次，如果达到两次则断开客户端连接。

Method 2 ：`sshd` 不会向客户端发送信息，如果客户端 10 分钟没有活动（服务端 10 分钟没有收到客户端消息），服务端会直接断开连接。

