---
layout: post
title: 书签应用 Shaarli 迁移记录
date: '2023-04-11 06:40:00'
tags:
- selfhost
---


## 备份

在原始实例中 `工具 -> 导出数据库` 导出所有书签

## 创建新实例

新建 docker 容器

    docker run --detach \
               --name myshaarli \
               --publish 8080:80 \	# 映射 80 端口到外部 8080 端口
               -d \	# 后台运行
               --rm \	# 停止时删除容器
               --volume shaarli-data:/var/www/shaarli/data \	# 通过挂载 volume 持久化
               --volume shaarli-cache:/var/www/shaarli/cache \
               ghcr.io/shaarli/shaarli::release	# 新版修改了镜像地址到 ghcr.io


## 导入原始数据

初始化之后，使用 `工具 -> 导入链接` 功能，导入原实例的所有书签

## 配置 Shaarli

- `工具 -> 配置 Shaarli -> 隐藏公开链接`

## 插件管理

- default colors

    # 修改默认配色
    DEFAULT_COLORS_MAIN: #545454
    DEFAULT_COLORS_BACKGROUND: #D0D0D0
    DEFAULT_COLORS_DARK_MAIN: #6028A2


- [urlextern](https://github.com/trailjeep/shaarli-urlextern)
		– 默认在新窗口打开链接
- iOS: [Save in Shaarli Shortcut](https://initialcharge.net/2021/02/shaarli-shortcut/)
