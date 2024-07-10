---
layout: post
title: 学习：通过寻找 MobileIron MDM 上的远程代码执行漏洞黑进 Facebook
date: '2020-09-29 06:24:00'
tags:
- pentest
- hash-import-2023-03-22-16-36
---

## 整理 MobileIron

使用 Google Search 在一个公开网站根目录找到疑似开发商测试用的 RPM 包

<figure class="kg-card kg-image-card"><img src="https://devco.re/assets/img/blog/20200912/1.png" class="kg-image" alt loading="lazy"></figure>

下载的版本是 2018 年初版。

MobileIron 使用 Java 开发，对外开放 443，8443， 9997 端口，各个端口的功能如下：

- 443 為使用者裝置註冊介面
- 8443 為設備管理介面
- 9997 為一個 MobileIron 私有的裝置同步協定 (MI Protocol)

三个端口都使用 TLS 保证安全性，网页部分则是通过 Apache Reverse Proxy 架构连接到后端，由 Tomcat 部署的网页应用处理，网页应用由 Spring MVC 开发。

<figure class="kg-card kg-image-card"><img src="https://devco.re/assets/img/blog/20200912/2.png" class="kg-image" alt loading="lazy"></figure>

由于使用的技术相对较新，传统漏洞如 SQL Injection 比较难从单一的点来发现，因此转向理解程序逻辑，并配合框架层面的攻击。

## 漏洞总结

Web Service 使用了 Hessian 格式处理资料，而产生了反序列化漏洞。

## 漏洞详解

现在已知 MobileIron 在处理 Web Service 的地方存在 Hessian 反序列化漏洞，但是无法直接接触到。

可触发 Hessian 反序列化的路径分别在：

- 一般使用界面：`https://mobileiron/mifs/services/`
- 管理界面：`https://mobileiron:8443/mifs/services/`

管理界面一般可以轻松接触到 Web Service，但一般用户界面则无法接触到 Web Service，由于一般企业不会将管理页面端口开放在外网，因此只能通过其他方式发现漏洞。

研究 MobileIron 的阻挡方式，发现是通过 Apache 上使用 Rewrite Rules 来阻挡一般用户访问 Web Service：

    RewriteRule ^/mifs/services/(.*)$ https://%{SERVER_NAME}:8443/mifs/services/$1 [R=307,L]
    RewriteRule ^/mifs/services [F]

由于是在前端做的阻挡，联想到 2015 年的研究，针对 Reverse Proxy 架构的新攻击面 [Breaking Parser Logic](https://blog.orange.tw/2018/08/how-i-chained-4-bugs-features-into-rce-on-amazon.html)，这个技巧最近也被利用在 [CVE-2020-5902](https://support.f5.com/csp/article/K52145254)，F5 BIG-IP TMUI 的远程代码执行漏洞上。

通过 Apache 与 Tomcat 对路径的理解不一致，可以使用以下方式绕过 Rewrite Rule 攻击 Web Service：

    https://mobileiron/mifs/.;/services/someService

这样就可以直接接触到有 Hessian 反序列化存在的 Web Service 了。

## 利用漏洞

针对 Hessian 反序列化，[Moritz Bechler](https://github.com/mbechler) 在 [Java Unmarshaller Security](https://www.github.com/mbechler/marshalsec/blob/master/marshalsec.pdf) 中做了详细的研究报告，从他开源的 [marshalsec](https://github.com/mbechler/marshalsec) 源码中，能学习到 Hessian 在反序列化过程中除了通过 HashMap 触发 `equals()` 以及 `hashcode()`等，也可以通过 `XString` 到 `toString()`，而目前关于 Hessian 反序列化已存在的利用链有四条：

- Apache XBean
- Caucho Resin
- Spring AOP
- ROME EqualsBean/ToStringBean

而根据目标环境，只有 Sprint AOP 这条利用链可以用。

<!--kg-card-begin: html-->

| | Name | Effect |
| --- | --- | --- |
| x | Apache XBean | JNDI 注入 |
| x | Caucho Resin | JNDI 注入 |
| √ | Spring AOP | JNDI 注入 |
| x | ROME EqualsBean | RCE |

<!--kg-card-end: html-->

现在有了 JNDI 注入，只要通过 [Alvaro Muñoz](https://twitter.com/pwntester) 和 [Oleksandr Mirosh](https://twitter.com/olekmirosh) 在 Black Hat USA 2016 上发表的 [A Journey From JNDI/LDAP to RCE Dream Land](https://www.blackhat.com/us-16/briefings.html#a-journey-from-jndi-ldap-manipulation-to-remote-code-execution-dream-land) 就可以取得远程命令执行了。

自从 [Alvaro Muñoz](https://twitter.com/pwntester) 和 [Oleksandr Mirosh](https://twitter.com/olekmirosh) 在 Black Hat 发表了这个新的攻击向量后，帮助了不知道多少黑客，甚至有人认为“遇到反序列化用 JNDI”就对了！，但是自从 2018 年 10 月，Java 把 JNDI 注入的最后一个拼图修复了，这条修复被记录在 [CVE-2018-3149](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-3149) 中，从此以后，所有 Java 版本高于 8u181, 7u191, 6u201 的版本皆无法通过 JNDI/LDAP 的方式执行代码，因此如果要在最新版 MobileIron 上实现攻击，需要另外寻找出路。

关于 CVE-2018-3149，是通过将 `com.sun.jndi.ldap.object.trustURLCodebase` 的默认值设置为 `False` 的方式以达到禁止攻击者下载远程 Bytecode 执行代码。

但是我们依然可以通过 JNDI 的 Naming Reference 到本机已经有的 Class Factory 上。通过类似 [Return-Oriented Programming](https://en.wikipedia.org/wiki/Return-oriented_programming) 的概念，寻找本地可以利用的类别做进一步的利用，详细手法参考 [Michael Stepankin](https://twitter.com/artsploit) 在 2019 年年初发表的 [Exploiting JNDI Injections in Java](https://www.veracode.com/blog/research/exploiting-jndi-injections-java)，里面详细介绍了如何通过 Tomcat 的 `BeanFactory` 去载入 `ELProcessor` 达到任意代码执行。

但是由于 `ELProcessor` 在 Tomcat 8 以后才被引入，但是目标是 Tomcat 7.x，因此需要为 `BeanFactory` 寻找一个新的利用链。

经过搜索，发现在 [Welkin](https://github.com/welk1n) 的[文章](https://www.cnblogs.com/Welk1n/p/11066397.html)中提到：

> 除了 `javax.el.ELProcessor`，当然也还有很多其他的类符合条件可以作为 `beanClass` 注入到 `BeanFactory` 中实现利用。举个例子，如果目标机器 `classpath` 中有 `groovy` 的库，则可以结合之前 Orange 师傅发过的 [Jenkins 的漏洞实现利用](https://blog.orange.tw/2019/02/abusing-meta-programming-for-unauthenticated-rce.html)

目标的 `ClassPath` 上刚好有 `Groovy` 存在，但是版本为 `1.5.6`，是一个距今十年不支持 Meta Programming 的版本，所以最后基于 Groovy 的代码，重新寻找了一个在 `GroovyShell` 上的利用链，详细信息参考提交给 [JNDI-Injection-Bypass](https://github.com/welk1n/JNDI-Injection-Bypass) 的这个 [Pull Request](https://github.com/welk1n/JNDI-Injection-Bypass/pull/1)。

## 攻击 Facebook

有了基于 `JNDI` + `BEANFACTORY` + `GROOVYSHELL` 的完美远程代码执行漏洞，就可以攻击 Facebook 了。但是检查时发现首页变成了 403 Forbidden，索性 Web Service 还在。

联系到上次的攻击经验，由于安全考虑，Facebook 会禁止所有针对外部的连接，JNDI 注入的核心就是通过受害者连接至攻击者控制的恶意服务器，并接受回传的恶意 Naming Reference 后所导致的一系列利用，无法连接到攻击者的恶意服务器，就没有办法利用。

由此，JNDI 注入的路被全部封杀，只能回到 Hessian 反序列化利用。

为了寻在新的利用链，必须先深入理解已存在的利用链的原理及成因。在重读 [Java Unmarshaller Security](https://github.com/mbechler/marshalsec/blob/master/marshalsec.pdf) 的论文后，其中一句话：

> Cannot restore Groovy’s MethodClosure as readResolve() is called which throws an exception.

猜想：

> 作者評估過把 Groovy 當成利用鏈的可行性，雖然被限制住了，但一定覺得有機會才會寫進論文中!

从这个猜想触发，虽然 Groovy 的利用链被 `readResolve()` 限制住了，但是目标版本的 Groovy 比较旧，有可能还没进行限制。

比较 Groovy-1.5.6 和最新版本关于 `groovy/runtime/MethodClosure.java` 中 `readSolve()` 的实现：

    $ diff 1_5_6/MethodClosure.java 3_0_4/MethodClosure.java
    
    > private Object readResolve() {
    > if (ALLOW_RESOLVE) {
    > return this;
    > }
    > throw new UnsupportedOperationException();
    > }

可以看到旧版没有 `ALLOW_RESOLVE` 限制，后来经过查证发现这个限制其实是 Groovy 因为 2015 年出现的 Java 反序列化漏洞而做的缓解措施，而且还被分配了 [CVE-2015-3253](https://groovy-lang.org/security.html) 这个漏洞编号。由于 Groovy 只是一个在内部使用，不会对外的小配角，因此没有特别需求下开发者也不会特地去更新，因此这成为了攻击链中的重要一环。

最后攻击成功，取得 Facebook 服务器上的 Shell。

<figure class="kg-card kg-image-card"><img src="https://img.youtube.com/vi/hGTLIIOb14A/0.jpg" class="kg-image" alt="MobileIron MDM unauthenticated REC" loading="lazy"></figure>