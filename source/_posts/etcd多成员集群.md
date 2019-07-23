---
title: etcd多成员集群
date: 2019-07-23 16:46:09
categories: etcd
---

# etcd多集群

## 方式

引导etcd集群的机制有三种：

- 静态
- etcd discovery
- DNS discovery

## Discovery

之前的集群演示是通过静态启动的机制引导etcd集群。但许多情况下，在集群成员的IP可能提前未知。

这在使用云提供商或网络使用DHCP时很常见。在这种情况下不是指定静态配置，而是使用etcd集群来引导新的成员，此过程称为发现。

### etcd discovery service

#### discovery url的声明周期

`discovery url`用来标识唯一的etcd集群，每个etcd实例共享一个新的`discovery url`以引导新集群，而不是重用现有的`discovery url`。

此外，`discovery url`仅用于集群的初始引导，若要在集群已运行后更改集群成员的资格，需参考运行时重新配置。

#### 自定义etcd发现服务

这种方式就是利用一个已有的etcd集群来引导自身，从而搭建一个新的etcd集群。

##### 生成一个新的发现令牌

```linux
[root@jw-etcd01 ~]# UUID=$(uuidgen)
[root@jw-etcd01 ~]# echo $UUID
0d8c6714-b4b1-4cc1-8ff4-d276f96d247f
```

##### 生成discovery url

```linux
[root@jw-etcd01 ~]# curl -X PUT http://172.19.19.122:2379/v2/keys/discovery/${UUID}/_config/size -d value=2
{"action":"set","node":{"key":"/_etcd/discovery/0d8c6714-b4b1-4cc1-8ff4-d276f96d247f/_config/size","value":"2","modifiedIndex":6,"createdIndex":6}}
```

将创建一个`discovery url`，其中`value=2`代表本集群的大小，通常为`3、5、7、9...`，我没有多余的机器，所以用两台。

`discovery url为`：`http://172.19.19.122:2379/v2/keys/discovery/0d8c6714-b4b1-4cc1-8ff4-d276f96d247f`

##### 启动

先配置好两个yml文件。

编辑`/etc/etcd/conf.yml`文件

```linux
name: etcd2
initial-advertise-peer-urls: http://172.19.19.123:2380
listen-peer-urls: http://172.19.19.123:2380
listen-client-urls: http://172.19.19.123:2379,http://127.0.0.1:2379 
advertise-client-urls: http://172.19.19.123:2379,http://127.0.0.1:2379
discovery: https://172.19.19.122:2379/v2/keys/discovery/0d8c6714-b4b1-4cc1-8ff4-d276f96d247f
```

```linux
name: etcd3
initial-advertise-peer-urls: http://172.19.19.124:2380
listen-peer-urls: http://172.19.19.124:2380
listen-client-urls: http://172.19.19.124:2379,http://127.0.0.1:2379
advertise-client-urls: http://172.19.19.124:2379,http://127.0.0.1:2379
discovery: http://172.19.19.122:2379/v2/keys/discovery/0d8c6714-b4b1-4cc1-8ff4-d276f96d247f
```

启动命令：`etcd --config-file=/etc/etcd/conf.yml`

从中可以发现，当第一个节点执行命令的时候，会等待另外一台加入，

```linux
[root@jw-etcd02 ~]# etcd --config-file=/etc/etcd/conf-discovery1.yml 
2019-07-22 15:59:54.833270 I | etcdmain: Loading server configuration from "/etc/etcd/conf-discovery1.yml"
2019-07-22 15:59:54.834202 I | etcdmain: etcd Version: 3.3.13
2019-07-22 15:59:54.834221 I | etcdmain: Git SHA: 98d3084
2019-07-22 15:59:54.834227 I | etcdmain: Go Version: go1.10.8
2019-07-22 15:59:54.834236 I | etcdmain: Go OS/Arch: linux/amd64
2019-07-22 15:59:54.834242 I | etcdmain: setting maximum number of CPUs to 2, total number of available CPUs is 2
2019-07-22 15:59:54.834255 W | etcdmain: no data-dir provided, using default data-dir ./etcd2.etcd
2019-07-22 15:59:54.834389 I | embed: listening for peers on http://172.19.19.123:2380
2019-07-22 15:59:54.834446 I | embed: listening for client requests on 127.0.0.1:2379
2019-07-22 15:59:54.834490 I | embed: listening for client requests on 172.19.19.123:2379
2019-07-22 15:59:54.937682 N | discovery: found self 7421510307215dd2 in the cluster
2019-07-22 15:59:54.937707 N | discovery: found 1 peer(s), waiting for 1 more
```

当所有成员注册之后启动集群，就构建了一个新的集群了。

查看成员状态：

```linux
[root@jw-etcd02 ~]# etcdctl member list
68d21150076963a0, started, etcd3, http://172.19.19.124:2380, http://127.0.0.1:2379,http://172.19.19.124:2379
7421510307215dd2, started, etcd2, http://172.19.19.123:2380, http://127.0.0.1:2379,http://172.19.19.123:2379
```

查看集群状态：

```linux
[root@jw-etcd02 ~]# endpoints=172.19.19.124:2379,172.19.19.123:2379

[root@jw-etcd02 ~]# etcdctl --endpoints=$endpoints endpoint status -w table
+--------------------+------------------+---------+---------+-----------+-----------+------------+
|      ENDPOINT      |        ID        | VERSION | DB SIZE | IS LEADER | RAFT TERM | RAFT INDEX |
+--------------------+------------------+---------+---------+-----------+-----------+------------+
| 172.19.19.124:2379 | 68d21150076963a0 |  3.3.13 |   20 kB |     false |         2 |          6 |
| 172.19.19.123:2379 | 7421510307215dd2 |  3.3.13 |   20 kB |      true |         2 |          6 |
+--------------------+------------------+---------+---------+-----------+-----------+------------+
```

#### 公共etcd发现服务

如果没有可用的现有集群，可以使用托管在公共发现服务`discovery.etcd.io`，公共的`discovery`是通过CoreOS提供的公共`discovery`服务申请token。

##### 获取集群标识

```linux
[root@jw-etcd01 etcd]# curl https://discovery.etcd.io/new?size=3
https://discovery.etcd.io/982846b900d7c377a7716564aae3d19e
```

##### 启动

编辑配置文件

这里如果使用内网走代理的话，要加个代理，不然网络原因一只启动不了。

```linux
name: etcd1
initial-advertise-peer-urls: http://172.19.19.122:2380
listen-peer-urls: http://172.19.19.122:2380
listen-client-urls: http://172.19.19.122:2379,http://127.0.0.1:2379 
advertise-client-urls: http://172.19.19.122:2379,http://127.0.0.1:2379
discovery-proxy: http://192.168.59.241:8888
discovery: https://discovery.etcd.io/982846b900d7c377a7716564aae3d19e
```

```linux
name: etcd2
initial-advertise-peer-urls: http://172.19.19.123:2380
listen-peer-urls: http://172.19.19.123:2380
listen-client-urls: http://172.19.19.123:2379,http://127.0.0.1:2379 
advertise-client-urls: http://172.19.19.123:2379,http://127.0.0.1:2379
discovery-proxy: http://192.168.59.241:8888
discovery: https://discovery.etcd.io/982846b900d7c377a7716564aae3d19e
```

```linux
name: etcd3
initial-advertise-peer-urls: http://172.19.19.124:2380
listen-peer-urls: http://172.19.19.124:2380
listen-client-urls: http://172.19.19.124:2379,http://127.0.0.1:2379
advertise-client-urls: http://172.19.19.124:2379,http://127.0.0.1:2379
discovery-proxy: http://192.168.59.241:8888
discovery: https://discovery.etcd.io/982846b900d7c377a7716564aae3d19e
```

三台机器执行命令：`etcd --config-file=/etc/etcd/conf.yml`

```linux
[root@jw-etcd03 etcd]# etcd --config-file=./conf-discovery2.yml 
2019-07-23 01:40:59.557398 I | etcdmain: Loading server configuration from "./conf-discovery2.yml"
2019-07-23 01:40:59.558676 I | etcdmain: etcd Version: 3.3.13
2019-07-23 01:40:59.558693 I | etcdmain: Git SHA: 98d3084
2019-07-23 01:40:59.558701 I | etcdmain: Go Version: go1.10.8
2019-07-23 01:40:59.558716 I | etcdmain: Go OS/Arch: linux/amd64
2019-07-23 01:40:59.558726 I | etcdmain: setting maximum number of CPUs to 4, total number of available CPUs is 4
2019-07-23 01:40:59.558950 I | embed: listening for peers on http://172.19.19.124:2380
2019-07-23 01:40:59.559045 I | embed: listening for client requests on 127.0.0.1:2379
2019-07-23 01:40:59.559111 I | embed: listening for client requests on 172.19.19.124:2379
2019-07-23 01:40:59.576086 I | discovery: using proxy "http://192.168.59.241:8888"
2019-07-23 01:41:01.489247 N | discovery: found peer 72c1c6de2cd8a18d in the cluster
2019-07-23 01:41:01.489277 N | discovery: found peer 335a21e8bbfde639 in the cluster
2019-07-23 01:41:01.489288 N | discovery: found self c5cd5d147247c226 in the cluster

```

查看成员状态：

```linux
[root@jw-etcd01 ~]# etcdctl member list
4ec2e078d2dd79af, started, etcd3, http://172.19.19.124:2380, http://127.0.0.1:2379,http://172.19.19.124:2379
4f3cb37486cdc6d6, started, etcd1, http://172.19.19.122:2380, http://127.0.0.1:2379,http://172.19.19.122:2379
558b1d86dce97a96, started, etcd2, http://172.19.19.123:2380, http://127.0.0.1:2379,http://172.19.19.123:2379
```

查看集群状态：

```linux
[root@jw-etcd01 ~]# endpoints=172.19.19.122:2379,172.19.19.124:2379,172.19.19.123:2379
[root@jw-etcd01 ~]# etcdctl --endpoints=$endpoints  endpoint status -w table
+--------------------+------------------+---------+---------+-----------+-----------+------------+
|      ENDPOINT      |        ID        | VERSION | DB SIZE | IS LEADER | RAFT TERM | RAFT INDEX |
+--------------------+------------------+---------+---------+-----------+-----------+------------+
| 172.19.19.122:2379 | 4f3cb37486cdc6d6 |  3.3.13 |   20 kB |      true |         2 |          8 |
| 172.19.19.124:2379 | 4ec2e078d2dd79af |  3.3.13 |   20 kB |     false |         2 |          8 |
| 172.19.19.123:2379 | 558b1d86dce97a96 |  3.3.13 |   20 kB |     false |         2 |          8 |
+--------------------+------------------+---------+---------+-----------+-----------+------------+

```

### DNS SRV Records

`etcd`基于dns做服务发现时，实际上利用了dns的srv记录不断轮询查询实现的，

`dns srv`：是dns数据库支持的一种资源记录的类型，它记录了哪台计算机提供了哪个服务的简单记录和信息。

这里采用`dnsmasq`作为dns服务器。

提前在hostname为`etcd03`、ip为`172.19.19.124`机器上搭建好一台dns服务器。然后另外两台机器添加这台机器的dns服务器在第一位。

```linux
[root@jw-etcd01 ~]# cat /etc/resolv.conf 
# Generated by NetworkManager
search 8.8.8.8
nameserver 172.19.19.124
nameserver 192.168.58.241

[root@jw-etcd02 ~]# cat /etc/resolv.conf
# Generated by NetworkManager
search 8.8.8.8
nameserver 172.19.19.124
nameserver 192.168.59.241
```

#### 增加dns srv记录

##### 服务端

```linux
[root@jw-etcd03 ~]# vim /etc/dnsmasq.conf
# test etcd
srv-host=_etcd-server._tcp.hi-etcd.com,etcd1.hi-etcd.com,2380,0,100
srv-host=_etcd-server._tcp.hi-etcd.com,etcd2.hi-etcd.com,2380,0,100
srv-host=_etcd-server._tcp.hi-etcd.com,etcd3.hi-etcd.com,2380,0,100
```

##### 客户端

```linux
[root@jw-etcd03 ~]# vim /etc/dnsmasq.conf
# test etcd
srv-host=_etcd-client._tcp.hi-etcd.com,etcd1.hi-etcd.com,2379,0,100
srv-host=_etcd-client._tcp.hi-etcd.com,etcd2.hi-etcd.com,2379,0,100
srv-host=_etcd-client._tcp.hi-etcd.com,etcd3.hi-etcd.com,2379,0,100

```

#### 增加对应的域名解析

```linux
[root@jw-etcd03 ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

# test etcd
172.19.19.124 etcd3.hi-etcd.com
172.19.19.123 etcd2.hi-etcd.com
172.19.19.122 etcd1.hi-etcd.com

```

#### 重启dnsmasq

```linux
systemctl restart dnsmasq

```

#### 查询dns srv记录

没有该命令的先安装：`yum install bind-utils -y`

```linux
[root@jw-etcd01 ~]# dig +noall +answer SRV _etcd-server._tcp.hi-etcd.com
_etcd-server._tcp.hi-etcd.com. 0 IN	SRV	0 100 2380 etcd2.hi-etcd.com.
_etcd-server._tcp.hi-etcd.com. 0 IN	SRV	0 100 2380 etcd1.hi-etcd.com.
_etcd-server._tcp.hi-etcd.com. 0 IN	SRV	0 100 2380 etcd3.hi-etcd.com.

[root@jw-etcd01 etcd]# dig +noall +answer SRV _etcd-client._tcp.hi-etcd.com
_etcd-client._tcp.hi-etcd.com. 0 IN	SRV	0 100 2379 etcd3.hi-etcd.com.
_etcd-client._tcp.hi-etcd.com. 0 IN	SRV	0 100 2379 etcd2.hi-etcd.com.
_etcd-client._tcp.hi-etcd.com. 0 IN	SRV	0 100 2379 etcd1.hi-etcd.com.

```

- `_etcd-server`：代表一个服务，名称应以下划线开头，比如：`_ldap`、`_ftp`、`_smtp`，该标识说明把这台服务器当做响应`etcd-server`请求的服务器。
- `_tcp`：本服务使用的协议，名称应以下划线开头，可以是tcp或者udp。
- `topsec-etcd.com`：此记录所在的域名。
- `300`：此记录默认生存的时间，以秒为单位。
- `IN`：标准DNS Internet类。
- `SRV`：将这条记录标识为SRV记录。
- `0`：优先级，如果相同的服务有多条记录，会尝试先连接优先级最低的记录。
- `100`：负载均衡机制，多条srv记录并且优先级也相同，那么会尝试连接权重最高的记录。
- `2380`：此服务使用的端口。
- `etcd1.topsec-etcd.com.`：提供此服务的主机。

#### 查询域名解析结果

```linux
[root@jw-etcd01 ~]# dig +noall +answer etcd1.hi-etcd.com etcd2.hi-etcd.com etcd3.hi-etcd.com
etcd1.hi-etcd.com.	0	IN	A	172.19.19.122
etcd2.hi-etcd.com.	0	IN	A	172.19.19.123
etcd3.hi-etcd.com.	0	IN	A	172.19.19.124

```

#### 使用dns引导etcd集群

##### 启动

编辑配置文件

```linux
name: etcd1
discovery-srv: hi-etcd.com
initial-advertise-peer-urls: http://etcd1.hi-etcd.com:2380
initial-cluster-token: etcd-cluster-1
initial-cluster-state: new
listen-client-urls: http://172.19.19.122:2379,http://127.0.0.1:2379
listen-peer-urls: http://172.19.19.122:2380
discovery-proxy: 
advertise-client-urls: http://etcd1.hi-etcd.com:2379,http://127.0.0.1:2379

```

```linux
name: etcd2
discovery-srv: hi-etcd.com
initial-advertise-peer-urls: http://etcd2.hi-etcd.com:2380
initial-cluster-token: etcd-cluster-1
initial-cluster-state: new
listen-client-urls: http://172.19.19.123:2379,http://127.0.0.1:2379
listen-peer-urls: http://172.19.19.123:2380
discovery-proxy: 
advertise-client-urls: http://etcd2.hi-etcd.com:2379,http://127.0.0.1:2379

```

```linux
name: etcd3
discovery-srv: hi-etcd.com
initial-advertise-peer-urls: http://etcd3.hi-etcd.com:2380
initial-cluster-token: etcd-cluster-1
initial-cluster-state: new
listen-client-urls: http://172.19.19.124:2379,http://127.0.0.1:2379
listen-peer-urls: http://172.19.19.124:2380
discovery-proxy: 
advertise-client-urls: http://etcd3.hi-etcd.com:2379,http://127.0.0.1:2379


```

三台机器分别执行命令：

```linux
etcd --config-file=/etc/etcd/conf-discovery-dns.yml

```

查看成员状态：

```linux
[root@jw-etcd01 etcd]# etcdctl member list
5ee0e04e205fa694, started, etcd3, http://etcd3.hi-etcd.com:2380, http://127.0.0.1:2379,http://etcd3.hi-etcd.com:2379
9a99a7e8e3abdf6a, started, etcd2, http://etcd2.hi-etcd.com:2380, http://127.0.0.1:2379,http://etcd2.hi-etcd.com:2379
efb48b68f151a3b7, started, etcd1, http://etcd1.hi-etcd.com:2380, http://127.0.0.1:2379,http://etcd1.hi-etcd.com:2379

```

查看集群状态：

```linux
[root@jw-etcd01 etcd]#  endpoints=etcd1.hi-etcd.com:2379,etcd2.hi-etcd.com:2379,etcd3.hi-etcd.com:2379

[root@jw-etcd01 etcd]# etcdctl --endpoints=$endpoints  endpoint status -w table
+------------------------+------------------+---------+---------+-----------+-----------+------------+
|        ENDPOINT        |        ID        | VERSION | DB SIZE | IS LEADER | RAFT TERM | RAFT INDEX |
+------------------------+------------------+---------+---------+-----------+-----------+------------+
| etcd1.hi-etcd.com:2379 | efb48b68f151a3b7 |  3.3.13 |   20 kB |     false |         4 |          9 |
| etcd2.hi-etcd.com:2379 | 9a99a7e8e3abdf6a |  3.3.13 |   20 kB |     false |         4 |          9 |
| etcd3.hi-etcd.com:2379 | 5ee0e04e205fa694 |  3.3.13 |   20 kB |      true |         4 |          9 |
+------------------------+------------------+---------+---------+-----------+-----------+------------+

```