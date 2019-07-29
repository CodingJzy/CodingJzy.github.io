---
title: consul集群搭建
date: 2019-07-29 16:59:54
categories: Consul
keywords: consul集群搭建
description: consul集群搭建
---

# consul

## 下载

可以去官网下载，也可以通过go环境编译成二进制。

```linux
# 安装版本
CONSUL_VERSION="1.5.3"

# 下载文件
curl --silent --remote-name https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
```

## 安装

将下载好的zip文件通过`unzip`命令解压缩。之后将二进制文件移动到`/usr/local/bin/`目录下。

```linux
# 解压缩
unzip consul_${CONSUL_VERSION}_linux_amd64.zip

# 移动
mv consul /usr/local/bin/
```

## 配置自动补全

配置完成后，按`tab`键补全的效果：

```linux
[root@jw-etcd01 home]# consul 
acl          connect      force-leave  keygen       lock         members      rtt          validate     
agent        debug        info         keyring      login        monitor      services     version      
catalog      event        intention    kv           logout       operator     snapshot     watch        
config       exec         join         leave        maint        reload       tls 

[root@jw-etcd01 home]# consul kv 
delete  export  get     import  put
```

执行命令：

```linux
consul -autocomplete-install
complete -C /usr/local/bin/consul consul
```

## 编写systemd服务

编写`systemd`服务之后，方便服务的启动与暂停。

创建consul服务文件:

```linux
touch /etc/systemd/system/consul.service
```

将配置添加到此文件中，

```linux
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul/consul.d/consul.hcl

[Service]
ExecStart=/root/consul/consul agent -config-dir=/etc/consul/consul.d/
ExecReload=/root/consul/consul reload
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

说明：

- `Description`：描述`consul`服务
- `Documentation`：连接到`consul`文档
- `ConditionFileNotEmpty`：在启动服务之前，检查配置文件是否为空
- `ExecStart`：启动`consul`服务的命令
- `ExecReload`：向`consul`发送重载信号以触发`consul`中的重新加载配置
- `KillMode`：将 `consul`视为一个进程

## 配置文件

和`etcd`类似，都可以通过命令行、环境变量、配置文件来启动`consul`。

更多配置请参照官网。

### 服务端

#### 一般配置

在以下位置创建配置文件：`/etc/consul/consul.d/consul.hcl`

```linux
# 创建配置文件文件夹
mkdir -p /etc/consul/consul.d

# 编辑配置文件
vim /etc/consul/consul.d/consul.hcl
datacenter = "dc1"
data_dir = "/etc/consul/data/"
encrypt = "4iwDbM/GTs62B020zTUdUQ=="
client_addr="172.19.19.124 127.0.0.1"
```

**注意：**

- `datacenter`：集群的数据中心，多个集群可以同时使用多个数据中心。我们只部署一个集群就使用同一个数据中心
- `data_dir`：`agent`存储状态的数据目录
- `encrypt`：指定用于加密`consul`网络流量的base64密钥，可以用`consul keygen`生存或者自己通过其他方式生成
- `client_addr`：`consul`将绑定客户端接口的地址，包括HTTP和DNS服务器。默认是`127.0.0.1`，可以将其设置为以空格分割的列表。

#### 集群自动加入

我这里是因为搭建了`dnsmasq`dns服务器。在该dns服务器的机器上配置了`hosts`，这样可以通过它来管理和控制内网的dns。

```linux
[root@jw-etcd03 consul.d]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

# add consul
172.19.19.124 test-consul.com
```

该配置表示，该内网中的所有用户访问`test-consul.com`时跳转到`172.19.19.124`。也可以称为`dns 劫持`。

该`retry_join`参数允许使用通过DNS地址，IP地址或使用云自动连接访问的公共Consul服务器配置所有Consul代理以自动形成群集。这消除了手动将Consul集群节点连接在一起的需要。

```linux
retry_join = ["test-consul.com"]
```

#### 服务器配置

在以下位置创建配置文件`/etc/consul/consul.d/server.hcl`：

```linux
[root@jw-etcd03 consul.d]# cat server.hcl 
server = true
bootstrap_expect = 2
ui = true
```

**说明：**

- `server`：此标志用于控制该`agent`是处于服务器模式还是客户端模式
- `bootstrap_expect`：此标志提供数据中心中预期的服务器数。不应提供此值，或者该值必须与群集中的其他服务器一致。和`etcd`一样推荐使用单数。我这里因为演示不搭建那么多机器
- `ui`：`consul`自带的一个web界面。应该考虑选定的Consul机器而不是所有机器上运行Consul UI。

### 客户端

Consul客户端通常需要Consul服务器所需的配置子集。所有Consul客户端都可以使用配置服务器时创建的文件`consul.hcl`。

## 启动与测试

通过之前编写的`systmed`服务来控制`consul`服务。

```linux
systemctl enable consul
systemctl start consul
systemctl status consul
systemctl restart consul
```

### 查看集群成员状态

```linux
[root@jw-etcd02 consul]# consul members 
Node       Address             Status  Type    Build  Protocol  DC   Segment
jw-etcd01  172.19.19.122:8301  alive   server  1.5.3  2         dc1  <all>
jw-etcd03  172.19.19.124:8301  alive   server  1.5.3  2         dc1  <all>
jw-etcd02  172.19.19.123:8301  alive   client  1.5.3  2         dc1  <default>
```

### put

在`jw-etcd01`(client)机器上`put`一个值：

```linux
[root@jw-etcd01 consul.d]# consul kv put name jiang_wei
Success! Data written to: name
```

### get

在`jw-etcd02`机器上`get`一个值：

```linux
[root@jw-etcd02 consul]# consul kv get name
jiang_wei
```

可以看出，成功。

## ui

 因为上面配置了`ui`，还可以通过web界面来看服务状态。

浏览器访问：`http://172.19.19.124:8500/ui/`。

给几个图，自己体会：

### server

![](/uploads/server节点.jpg)

### cluster

![](/uploads/集群.jpg)

### key

![](/uploads/key.jpg)