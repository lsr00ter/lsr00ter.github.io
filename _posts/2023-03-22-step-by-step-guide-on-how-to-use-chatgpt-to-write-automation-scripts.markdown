---
layout: post
title: 手把手教你用 ChatGPT 写自动化脚本
date: '2023-03-22 14:40:10'
tags:
- recon
- code
- hash-import-2023-03-22-16-36
---

## 什么是 ChatGPT？

ChatGPT 是由 OpenAI 开发的一个大型语言模型。它是一种使用自然语言处理技术的 AI 对话代理，能够理解和生成类似于真人对话的文本响应。

## 使用自动化脚本的好处

自动化脚本可以提供以下好处：

1. 提高效率：自动化脚本可以大大减少人工操作的时间和精力，从而提高信息收集和分析的效率。
2. 减少错误：自动化脚本可以减少人为的错误，因为它们可以自动执行重复性任务，而无需人类干预。
3. 可重复性：自动化脚本可以重复使用，因此您可以在不同的场景中使用相同的脚本，从而减少工作量。
4. 大规模数据处理：自动化脚本可以处理大规模的数据，因为它们可以在很短的时间内处理大量的信息。
5. 实时反馈：自动化脚本可以提供实时反馈，因为它们可以在任何时间点执行，并在执行完毕后立即提供结果。

总之，使用自动化脚本可以大大提高信息收集的效率和准确性，尤其是在大规模数据处理和重复性任务方面。

## 让我们请求 ChatGPT 创建一个高级的信息收集程序

> 编写一个 bash 脚本，安装和使用以下工具来自动化我的信息收集过程——subfinder、dirsearch、nmap、vulners、GetJS、GoLinkFinder、getallurls、WayBackUrls、WayBackRobots、MassDNS、Sublist3r、FFuF、XSSHunter、SQLMap、XXEInjector、SSRFDetector、GitTools、gitallsecrets、CORStest、EyeWitness

### 回复：

> 以下是一个 bash 脚本，可以安装和使用上述工具来自动化信息收集过程。在运行此脚本之前，请确保您的系统上已经安装了 git 和 python3。

    #!/bin/bash
    
    # 安装subfinder
    go get github.com/projectdiscovery/subfinder/cmd/subfinder
    
    # 安装dirsearch
    git clone https://github.com/maurosoria/dirsearch.git
    cd dirsearch
    pip3 install -r requirements.txt
    
    # 安装nmap
    sudo apt-get install nmap
    
    # 安装vulners
    git clone https://github.com/vulnersCom/nmap-vulners.git
    cd nmap-vulners
    sudo cp *.nse /usr/share/nmap/scripts/
    sudo nmap --script-updatedb
    
    # 安装GetJS
    git clone https://github.com/003random/getJS.git
    
    # 安装GoLinkFinder
    go get -u github.com/jaeles-project/golinkfinder
    
    # 安装getallurls
    go get -u github.com/lc/gau
    
    # 安装WayBackUrls
    go get github.com/tomnomnom/waybackurls
    
    # 安装WayBackRobots
    go get github.com/lobuhi/burp-robotbuster
    
    # 安装MassDNS
    git clone https://github.com/blechschmidt/massdns.git
    cd massdns
    make
    sudo cp bin/massdns /usr/bin/
    
    # 安装Sublist3r
    git clone https://github.com/aboul3la/Sublist3r.git
    cd Sublist3r
    sudo pip3 install -r requirements.txt
    
    # 安装FFuF
    go get -u github.com/ffuf/ffuf
    
    # 安装XSSHunter
    git clone https://github.com/mandatoryprogrammer/XSStrike.git
    
    # 安装SQLMap
    git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap-dev
    
    # 安装XXEInjector
    git clone https://github.com/enjoiz/XXEinjector.git
    
    # 安装SSRFDetector
    go get -u github.com/chenjj/ssrf-detector
    
    # 安装GitTools
    git clone https://github.com/internetwache/GitTools.git
    
    # 安装gitallsecrets
    git clone https://github.com/anshumanbh/git-all-secrets.git
    cd git-all-secrets
    sudo python3 setup.py install
    
    # 安装CORStest
    git clone https://github.com/RUB-NDS/CORStest.git
    
    # 安装EyeWitness
    git clone https://github.com/FortyNorthSecurity/EyeWitness.git
    cd EyeWitness
    sudo ./setup/setup.sh
    
    echo "安装完成！"
    
    # 安装完成后，您可以使用以下命令运行这些工具：
    
    # 运行subfinder
    subfinder -d example.com
    
    # 运行dirsearch
    python3 dirsearch.py -u https://example.com -e php
    
    # 运行nmap
    sudo nmap -sS -sV -p- example.com
    
    # 运行vulners
    sudo nmap -sS -sV --script vulners example.com
    
    # 运行GetJS
    python3 getJS.py -u https://example.com
    
    # 运行GoLinkFinder
    golinkfinder -u https://example.com -o output.txt
    
    # 运行getallurls
    gau example.com
    
    # 运行WayBackUrls
    waybackurls example.com
    
    # 运行WayBackRobots
    python3 burp-robotbuster.py -u https://example.com
    
    # 运行MassDNS
    massdns -r resolvers.txt -t A -o S example.com
    
    # 运行Sublist3r
    python3 sublist3r.py -d example.com -o output.txt
    
    # 运行FFuF
    ffuf -w wordlist.txt -u https://example.com/FUZZ
    
    # 运行XSSHunter
    python3 xsstrike.py -u https://example.com
    
    # 运行SQLMap
    python3 sqlmap.py -u https://example.com --dbs
    
    # 运行XXEInjector
    python3 XXEinjector.py -l payloads/xxe.txt -r https://example.com
    
    # 运行SSRFDetector
    ssrf-detector -u https://example.com
    
    # 运行GitTools
    ./gitdumper.sh https://example.com
    ...
    

这样我们就得到了一个基本的安装和使用的 bash 脚本。

## 如何自动化信息收集过程

> 编写一个 bash 脚本代码，使用上面的所有工具，自动化整个过程

### 回复：

> 以下是一个 bash 脚本，可以使用上述工具自动化整个信息收集过程。在运行此脚本之前，请确保您的系统上已经安装了 git 和 python3。

    #!/bin/bash
    
    if [$# -lt 1]
    then
        echo "请提供目标域名！"
        exit 1
    fi
    
    # 目标域名
    domain=$1
    
    # 创建目录
    mkdir $domain
    cd $domain
    
    # subfinder
    echo "运行subfinder..."
    subfinder -d $domain > subdomains.txt
    
    # dirsearch
    echo "运行dirsearch..."
    python3 ../dirsearch/dirsearch.py -L subdomains.txt -e php,asp,aspx,jsp,html,txt -x 403,404 -t 50 -b -o dirsearch.txt
    
    # nmap
    echo "运行nmap..."
    sudo nmap -sS -sV -p- $domain -oN nmap.txt
    
    # vulners
    echo "运行vulners..."
    sudo nmap -sS -sV --script vulners $domain -oN vulners.txt
    
    # GetJS
    echo "运行GetJS..."
    python3 ../getJS/getJS.py -i subdomains.txt -o GetJS
    
    # GoLinkFinder
    echo "运行GoLinkFinder..."
    golinkfinder -i subdomains.txt -o GoLinkFinder.txt
    
    # getallurls
    echo "运行getallurls..."
    gau $domain > getallurls.txt
    
    # WayBackUrls
    echo "运行WayBackUrls..."
    waybackurls $domain > WayBackUrls.txt
    
    # WayBackRobots
    echo "运行WayBackRobots..."
    python3 ../burp-robotbuster/burp-robotbuster.py -d $domain -o WayBackRobots.txt
    
    # MassDNS
    echo "运行MassDNS..."
    massdns -r ../resolvers.txt -t A -o S subdomains.txt -w MassDNS.txt
    
    # Sublist3r
    echo "运行Sublist3r..."
    python3 ../Sublist3r/sublist3r.py -d $domain -o Sublist3r.txt
    
    # FFuF
    echo "运行FFuF..."
    ffuf -w ../wordlist.txt -u https://$domain/FUZZ -mc 200 -ac -o FFuF.txt
    
    # XSSHunter
    echo "运行XSSHunter..."
    python3 ../XSStrike/xsstrike.py -u https://$domain -l 3 -c 10 -e -o XSSHunter.txt
    
    # SQLMap
    echo "运行SQLMap..."
    python3 ../sqlmap-dev/sqlmap.py -u https://$domain --batch --crawl=1 --dbms=mysql --level=5 --risk=3 -o SQLMap
    
    # XXEInjector
    echo "运行XXEInjector..."
    python3 ../XXEinjector/XXEinjector.py -l ../XXEinjector/payloads/xxe.txt -r https://$domain/ -o XXEInjector.txt
    
    # SSRFDetector
    echo "运行SSRFDetector..."
    ssrf-detector -i subdomains.txt -o SSRFDetector.txt
    
    # GitTools
    echo "运行GitTools..."
    ./../GitTools/gitdumper.sh https://$domain -o GitTools
    
    # gitallsecrets
    echo "运行gitallsecrets..."
    python3 ../git-all-secrets/git-all-secrets.py -R -r $domain -o gitallsecrets.txt
    
    # CORStest
    echo "运行CORStest..."
    python3 ../CORStest/corstest.py -t https://$domain -o CORStest.txt
    
    # EyeWitness
    echo "运行EyeWitness..."
    python3 ../EyeWitness/EyeWitness.py -f ../subdomains.txt -d $domain --active-scan -r EyeWitness
    
    echo "信息收集完毕！"
    

> 该脚本将在当前目录下创建一个以目标域名命名的目录，并在其中保存所有输出文件。要运行脚本，请使用以下命令：

`./autoenum.sh example.com`

> 其中 example.com 是您要枚举的目标域名。请注意，此脚本可能需要花费相当长的时间来运行，具体取决于您的目标域名的大小和复杂性。

## 使用此代码

以在 Kali Linux 系统上使用此脚本为例，按照以下步骤：

1. 将整个脚本代码复制到文本编辑器中，并使用 `.sh` 扩展名保存文件（例如，`autoenum.sh `）。
2. 在 Kali 系统上打开终端窗口。
3. 使用 `cd` 命令导航到保存 `autoenum.sh` 文件的目录。
4. 通过输入 `./autoenum.sh example.com ` 运行脚本

## BOOM!!!
