---
layout: post
title: 持久化 - SCM
date: '2023-04-22 07:53:23'
tags:
- persistence
---

SCM 是 Windows 操作系统中的服务控制管理器（Service Control Manager）的缩写。SCM 是 Windows 操作系统的一个重要组件，它负责启动、停止和管理 Windows 服务，这些服务可以是操作系统自带的服务，也可以是第三方应用程序的服务。SCM 还可以监控服务的运行状态，并在服务出现故障时自动重启服务。

在 Windows 操作系统中，SCM 通过服务控制管理器（Services Console）提供用户界面，用户可以通过这个控制面板管理和配置 Windows 服务。用户可以在 Services Console 中查看服务的状态、启动类型、依赖关系等信息，还可以启动、停止、暂停、继续服务的运行。

微软在 Windows 2000 及以后引入了安全描述符定义语言（SDDL），以便以更易读的格式提供安全描述符的文本表示。在 Windows 2000 之前，安全描述符以十六进制字节表示。服务控制管理器的权限和其他 Windows 对象的权限一样，由自主访问控制列表（DACL）管理，这些权限也由 SDDL 表示。

在红队行动中，如果已经获得了管理员权限，可以通过 SDDL 修改服务控制管理器的权限，以授予“Everyone”组对服务控制管理器的权限。此操作可用作一种持久性形式，因为任何用户都可以在环境中创建一个服务，每次计算机启动时都会使用 SYSTEM 级别权限执行任意命令或 payload。该技术是由 [Grzegorz Tworek](https://twitter.com/0gtweet) 发现并在 Twitter 上分享的。

执行下面的命令快速检索服务控制管理器实用程序的 SDDL 权限。

    sc sdshow scmanager

<img src="assets/img/blog/imported/persistence-scm-sc-sdshow-scmanager.png" class="kg-image" alt loading="lazy" title="服务控制管理器 - 安全描述符">

也可以用 PowerShell 枚举所有用户组的 SDDL 权限并将其转换为可读格式。

    $SD = Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Schedule\Security\
    $sddl = ([wmiclass]"Win32_SecurityDescriptorHelper").BinarySDToSDDL($SD.Security).Sddl
    $SecurityDescriptor = ConvertFrom-SddlString -Sddl $sddl
    $SecurityDescriptor.DiscretionaryAcl

<img src="assets/img/blog/imported/persistence-scm-powershell-enum-and-convert-sddl.png" class="kg-image" alt loading="lazy" title="通过 PowerShell 枚举权限">

下面的命令将枚举“scmanager”实用程序的权限，并显示相关的 SDDL 权限。

    sc sdshow scmanager showrights

<img src="assets/img/blog/imported/persistence-scm-sc-sdshow-scmanager-showrights.png" class="kg-image" alt loading="lazy" title="服务控制管理器 - 枚举权限">

普通用户无法在 Windows 环境中创建服务。这个权限仅属于高权限用户，如本地管理员。但是，修改服务控制管理器的安全描述符权限可以允许任何用户创建一个在 SYSTEM 权限运行的服务。使用安全描述符定义语言，可以通过执行以下命令来修改这些权限：

    sc.exe sdset scmanager D:(A;;KA;;;WD)

<img src="assets/img/blog/imported/persistence-scm-sc-sdset.png" class="kg-image" alt loading="lazy" title="修改安全描述符权限">

下表显示了上述命令中 SDDL 缩写的含义。

<!--kg-card-begin: html-->

| D | `Discretionary Access Control List`  
自主访问控制列表 |
| A | `Access Control Entry – Access Allowed`  
访问控制条目 - 允许访问 |
| KA | 

`KEY_ALL_ACCESS – Rights`

`KEY_ALL_ACCESS - 权限`

 |
| WD | `Security Principal of Everyone Group`  
Everyone 组的安全策略 |

<!--kg-card-end: html-->

`sc.exe` 程序可用于创建新服务。 “binPath”参数可以存储任意有效负载，该有效负载将在服务启动时执行。应注意，由于服务控制管理器的权限已更改，非特权用户也可以在 Windows 环境中创建新服务。如果蓝队删除了恶意服务，则权限仍将保留，允许标准用户继续创建新服务以维持持久性。

    sc create persistence-scm displayName="persistence-scm" binPath="C:\temp\persistence-scm.exe" start=auto

<img src="assets/img/blog/imported/persistence-scm-sc-create.png" class="kg-image" alt loading="lazy" title="服务控制管理器 - 标准用户创建新服务">

新服务将出现在 Windows 服务列表中。

<img src="assets/img/blog/imported/persistence-scm-check-sc-list.png" class="kg-image" alt loading="lazy" title="服务控制管理器 - 新服务">

当系统重新启动时，服务将自动启动，并使用系统权限执行 payload。

<img src="assets/img/blog/imported/persistence-scm-get-pwned.png" class="kg-image" alt loading="lazy" title="服务控制管理器 - Cobaltstrke">