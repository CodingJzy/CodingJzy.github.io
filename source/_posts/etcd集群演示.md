---
title: etcd集群演示
date: 2019-07-22 13:43:24
categories: etcd
---

# 集群演示

集群的方式有三种，这里只是静态配置的机制来引导。

## 配置

有三种方式配置`etcd`。优先级：配置文件 > 命令行 > 环境变量。

准备好三台机器，安装好`etcd`，在每个`etcd`节点上，添加配置文件来指定集群成员。

```go
# 创建etcd配置文件夹
mkdir /etc/etcd

# 创建配置yaml文件
cat > /etc/etcd/conf.yml <<EOF
name: etcd-1
data-dir: /etc/etcd/data
listen-client-urls: http://172.19.19.122:2379,http://127.0.0.1:2379
advertise-client-urls: http://172.19.19.122:2379,http://127.0.0.1:2379
listen-peer-urls: http://172.19.19.122:2380
initial-advertise-peer-urls: http://172.19.19.122:2380
initial-cluster: etcd-1=http://172.19.19.122:2380,etcd-2=http://172.19.19.123:2380,etcd-3=http://172.19.19.124:2380
initial-cluster-token: etcd-cluster-token
initial-cluster-state: new
EOF

# 该etcd使用的api版本为v3，配置环境变量：后面的相关命令就可以不用指定
ENDPOINTS=172.19.19.122:2379,172.19.19.123:2379,172.19.19.124:2379
```

另外两台机器，更改对应的`name`，和相关的`ip:port`即可。

```go
# 创建etcd配置文件夹
mkdir /etc/etcd

# 创建配置yaml文件
cat > /etc/etcd/conf.yml <<EOF
name: etcd-2
data-dir: /etc/etcd/data
listen-client-urls: http://172.19.19.123:2379,http://127.0.0.1:2379
advertise-client-urls: http://172.19.19.123:2379,http://127.0.0.1:2379
listen-peer-urls: http://172.19.19.123:2380
initial-advertise-peer-urls: http://172.19.19.123:2380
initial-cluster: etcd-1=http://172.19.19.122:2380,etcd-2=http://172.19.19.123:2380,etcd-3=http://172.19.19.124:2380
initial-cluster-token: etcd-cluster-token
initial-cluster-state: new
EOF

# 该etcd使用的api版本为v3，配置环境变量：后面的相关命令就可以不用指定
ENDPOINTS=172.19.19.122:2379,172.19.19.123:2379,172.19.19.124:2379
```

```go
# 创建etcd配置文件夹
mkdir /etc/etcd

# 创建配置yaml文件
cat > /etc/etcd/conf.yml <<EOF
name: etcd-3
data-dir: /etc/etcd/data
listen-client-urls: http://172.19.19.124:2379,http://127.0.0.1:2379
advertise-client-urls: http://172.19.19.124:2379,http://127.0.0.1:2379
listen-peer-urls: http://172.19.19.124:2380
initial-advertise-peer-urls: http://172.19.19.124:2380
initial-cluster: etcd-1=http://172.19.19.122:2380,etcd-2=http://172.19.19.123:2380,etcd-3=http://172.19.19.124:2380
initial-cluster-token: etcd-cluster-token
initial-cluster-state: new
EOF

# 该etcd使用的api版本为v3，配置环境变量：后面的相关命令就可以不用指定
ENDPOINTS=172.19.19.122:2379,172.19.19.123:2379,172.19.19.124:2379
```

## 配置字段说明

### --name

- 该成员的名称
- env：`ETCD_NAME`
- 默认值：`default`

### --data-dir

- 数据目录的路径
- env：`ETCD_DATA_DIR`
- 默认值： `${name}.etcd`

### --listen-client-urls

- 要监听客户端流量的URL列表。此标志告诉etcd接受来自客户端的指定https(http):// ip:port的传入请求。域名无效。
- env：`ETCD_LISTEN_CLIENT_URLS`
- 默认值：`http://localhost:2379/`

### --advertise-client-urls

- 此成员的客户端URL列表，用于通告群集的其余部分。这些URL可以包含域名。
- env：`ETCD_ADVERTISE_CLIENT_URLS`
- 默认值：`http://localhost:2379/`

### --listen-peer-urls

- 侦听对等流量的URL列表。此标志告诉etcd接受来自其对等体的指定https(http):// ip:port传入请求。域名无效。
- env：`ETCD_LISTEN_PEER_URLS`
- 默认值：`http://localhost:2380/`

### --initial-advertise-peer-urls

- 此成员的对等URL的列表，用于通告群集的其余部分。这些地址用于在集群周围传输etcd数据。必须至少有一个可路由到所有集群成员。这些URL可以包含域名。
- env：`ETCD_INITIAL_ADVERTISE_PEER_URLS`
- 默认值：`http://localhost:2380/`

### --initial-cluster

- 引导的初始集群配置
- env：`ETCD_INITIAL_CLUSTER`
- 默认值：`http://localhost:2380/`

### --initial-cluster-token

- 引导期间etcd集群的初始集群令牌
- env：`ETCD_INITIAL_CLUSTER_TOKEN`
- 默认值：`etcd-cluster`

### --initial-cluster-state

- 初始集群状态：`new` or `existing`，设置`new`为初始静态或DNS引导期间出现的所有成员。如果将此选项设置为`existing`，则etcd将尝试加入现有群集。如果设置了错误的值，etcd将尝试启动但安全失败。
- env：`ETCD_INITIAL_CLUSTER_STATE`
- 默认值：`new`

## 运行

在每台机器上运行。启动命令为：`etcd --config-file=/etc/etcd/conf.yml`

## 访问

### 查看集群成员

```linux
[root@jw-etcd03 ~]# etcdctl member list
1f83556bca2b8a68, started, etcd-2, http://172.19.19.123:2380, http://127.0.0.1:2379,http://172.19.19.123:2379
7e41f23968a025a0, started, etcd-3, http://172.19.19.124:2380, http://127.0.0.1:2379,http://172.19.19.124:2379
d7e3204f9f2095cc, started, etcd-1, http://172.19.19.122:2380, http://127.0.0.1:2379,http://172.19.19.122:2379
```

### 集群健康检查

```go
[root@jw-etcd03 ~]# etcdctl --endpoints=$ENDPOINTS endpoint health
172.19.19.122:2379 is healthy: successfully committed proposal: took = 1.827468ms
172.19.19.124:2379 is healthy: successfully committed proposal: took = 1.935687ms
172.19.19.123:2379 is healthy: successfully committed proposal: took = 2.141641ms
```

### 集群健康状态

```linux
[root@jw-etcd03 ~]# etcdctl --endpoints=$ENDPOINTS endpoint status -w table
+--------------------+------------------+---------+---------+-----------+-----------+------------+
|      ENDPOINT      |        ID        | VERSION | DB SIZE | IS LEADER | RAFT TERM | RAFT INDEX |
+--------------------+------------------+---------+---------+-----------+-----------+------------+
| 172.19.19.122:2379 | dfaea2c8a602307f |  3.3.13 |   20 kB |      true |      1087 |          9 |
| 172.19.19.123:2379 | 3a4962cd88561ea0 |  3.3.13 |   20 kB |     false |      1087 |          9 |
| 172.19.19.124:2379 | 3e6ee7f8b997733a |  3.3.13 |   20 kB |     false |      1087 |          9 |
+--------------------+------------------+---------+---------+-----------+-----------+------------+
```

### put

```linux
[root@jw-etcd03 ~]# etcdctl put foo 'Hello Etcd!'
OK
```

### get

```linux
[root@jw-etcd01 ~]# etcdctl get foo
foo
Hello Etcd!
```

### 通过前缀获取

```linux
# put
[root@jw-etcd01 ~]# etcdctl put web1 value1
OK
[root@jw-etcd01 ~]# etcdctl put web2 value2
OK
[root@jw-etcd01 ~]# etcdctl put web3 value3
OK

# get
[root@jw-etcd03 ~]# etcdctl get web --prefix
web1
value1
web2
value2
web3
value3
```

### del

```llinux
[root@jw-etcd03 ~]# etcdctl put key value
OK
[root@jw-etcd03 ~]# etcdctl get key
key
value
[root@jw-etcd03 ~]# etcdctl del key
1
[root@jw-etcd03 ~]# etcdctl del key
0
[root@jw-etcd03 ~]# etcdctl put k1 v1
OK
[root@jw-etcd03 ~]# etcdctl put k2 v2
OK
[root@jw-etcd03 ~]# etcdctl del k --prefix
2
```

### watch

先在一台机器上`watch`监听：

```linux
[root@jw-etcd02 ~]# etcdctl watch stock1

```

之后会等待状态。在另一台机器上`put`一个值：

```linux
[root@jw-etcd03 ~]# etcdctl put stock1 1000
OK
```

再回来看之前监听的机器上：

```linux
[root@jw-etcd02 ~]# etcdctl watch stock1
PUT
stock1
1000

```

再删除这个`key`：

```
[root@jw-etcd03 ~]# etcdctl del stock1
1
```

监听：

```linux
[root@jw-etcd02 ~]# etcdctl watch stock1
PUT
stock1
1000
PUT
stock1
2000
DELETE
stock1

```

也就是这个命令会一直监听这个key的增删。

### lease

#### 创建一个lease

`lease grant time`

```linux
[root@jw-etcd03 ~]# etcdctl lease grant 30
lease 733a6c05eaa6c67a granted with TTL(30s)
[root@jw-etcd03 ~]# etcdctl put k v --lease=733a6c05eaa6c67a
OK
[root@jw-etcd03 ~]# etcdctl get k
k
v
```

#### 查看到期时间

`lease timetoliv LeaseID`

```linux
[root@jw-etcd03 ~]# etcdctl lease timetoliv 733a6c05eaa6c67a
lease 733a6c05eaa6c67a granted with TTL(30s), remaining(11s)
[root@jw-etcd03 ~]# etcdctl lease timetoliv 733a6c05eaa6c67a
lease 733a6c05eaa6c67a granted with TTL(30s), remaining(5s)
[root@jw-etcd03 ~]# etcdctl get k
[root@jw-etcd03 ~]# 

```

#### 查看所有lease

`lease list`

```linux
[root@jw-etcd03 ~]# etcdctl lease grant 300
lease 733a6c05eaa6c68e granted with TTL(300s)
[root@jw-etcd03 ~]# etcdctl lease grant 300
lease 733a6c05eaa6c690 granted with TTL(300s)
[root@jw-etcd03 ~]# etcdctl lease grant 300
lease 733a6c05eaa6c692 granted with TTL(300s)
# 查看lease
[root@jw-etcd03 ~]# etcdctl lease list
found 3 leases
733a6c05eaa6c68e
733a6c05eaa6c690
733a6c05eaa6c692
```

#### 移除lease

`lease revoke LeaseID`

```linux
[root@jw-etcd03 ~]# etcdctl lease revoke 733a6c05eaa6c692
lease 733a6c05eaa6c692 revoked
[root@jw-etcd03 ~]# etcdctl lease list
found 2 leases
733a6c05eaa6c68e
733a6c05eaa6c690
```

#### 续订lease

`lease keep-alive LeaseID`

```linux
[root@jw-etcd03 ~]# etcdctl lease timetolive 733a6c05eaa6c690
lease 733a6c05eaa6c690 granted with TTL(300s), remaining(126s)
[root@jw-etcd03 ~]# etcdctl lease timetolive 733a6c05eaa6c690
lease 733a6c05eaa6c690 granted with TTL(300s), remaining(125s)
[root@jw-etcd03 ~]# etcdctl lease keep-alive 733a6c05eaa6c690
lease 733a6c05eaa6c690 keepalived with TTL(300)
```

### lock

先在一台机器创建锁：

```linux
[root@jw-etcd02 ~]# etcdctl lock mutex02
mutex02/1ea06c042f957064

```

再去另一台机器创建(会卡住)：

```linux
[root@jw-etcd03 ~]# etcdctl lock mutex02

```

返回之前机器，强行停止：

```linux
[root@jw-etcd02 ~]# etcdctl lock mutex02
mutex02/1ea06c042f957064

^C[root@jw-etcd02 ~]# 

```

然后，第二台机器就可以用，会自己生成一个锁：

```linux
[root@jw-etcd03 ~]# etcdctl lock mutex02
mutex02/733a6c05eaa6c6b2

```

