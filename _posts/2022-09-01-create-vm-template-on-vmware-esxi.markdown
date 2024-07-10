---
layout: post
title: 在 VMware ESXi 创建虚拟机模板
date: '2022-09-01 09:52:01'
tags:
- esxi
- tips
- hash-import-2023-03-22-16-36
---

### 0x00 创建原始虚拟机

按照步骤正常创建虚拟机即可。

### 0x01 自定义虚拟机

自定义模板虚拟机，安装基础工具等，满足基础需求：

- 系统更新
- 安装所需的基础软件包
- 修改必要的系统设置

完成后，关闭虚拟机电源，并且 **禁止再次打开虚拟机电源** 。

### 0x02 创建 VMware ESXi 模板存储库

- 在 `Storage` 存储库新建用于保存虚拟机模板的文件夹，如 `TEMPLATES`  
<figure class="kg-card kg-image-card"><img src="assets/img/blog/imported/create-vm-template-on-vmware-esxi-Vmware-ESXi-Template-Datastore.jpg" class="kg-image" alt loading="lazy"></figure><figure class="kg-card kg-image-card"><img src="assets/img/blog/imported/create-vm-template-on-vmware-esxi-Vmware-ESXi-Datastore-folder.jpg" class="kg-image" alt loading="lazy"></figure><figure class="kg-card kg-image-card"><img src="assets/img/blog/imported/create-vm-template-on-vmware-esxi-Vmware-ESXI-Templates-folder.jpg" class="kg-image" alt loading="lazy"></figure>
- 浏览存储库，将上一步安装完成的虚拟机文件夹内的 `.vmx` 以及 `.vmdk` 文件，复制到 `TEMPLATES` 文件夹中  
<figure class="kg-card kg-image-card"><img src="assets/img/blog/imported/create-vm-template-on-vmware-esxi-Vmware-linux-Template-VMX.jpg" class="kg-image" alt loading="lazy"></figure><figure class="kg-card kg-image-card"><img src="assets/img/blog/imported/create-vm-template-on-vmware-esxi-Vmware-Linux-Template-VMDK.jpg" class="kg-image" alt loading="lazy"></figure>
- 到这一步，虚拟机模板已经创建成功

### 0x03 从模板创建虚拟机

- 在存储库中，新建用于创建新的虚拟机的目录，如 `NEW-VM`
- 将虚拟机模板文件夹 `TEMPLATES` 中的 `.vmx` 以及 `.vmdk` 文件 复制到新的虚拟机目录 `NEW-VM` 中
- 选择新的虚拟机目录 `NEW-VM` 中的 `.vmx` 文件，右键选择 `Register VM` 注册虚拟机  
<figure class="kg-card kg-image-card"><img src="assets/img/blog/imported/create-vm-template-on-vmware-esxi-Vmware-Template-Linux-Register-VM.jpg" class="kg-image" alt loading="lazy"></figure>
- 在弹出选项中选择 `I Copied It`  
<figure class="kg-card kg-image-card"><img src="assets/img/blog/imported/create-vm-template-on-vmware-esxi-Virtual-machine-template-question-linux.jpg" class="kg-image" alt loading="lazy"></figure>
- 打开电源，可以使用了。
