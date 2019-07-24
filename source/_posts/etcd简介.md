---
title: etcd简介
date: 2019-07-23 08:17:51
categories: Etcd
---

# ETCD

## 简介

`etcd`是用go语言编写的一个开源的、分布式的键值对存储服务。但它不仅仅是存储，还可以用于配置共享和服务发现等功能。其四个核心特点：

- 简单：基于HTTP+JSON的API让你用curl命令就可以轻松使用。
- 安全：可选SSL客户认证机制。
- 快速：每个实例每秒支持一千次写操作。
- 可信：使用Raft算法充分实现了分布式。

## 架构

![](/uploads/etcd组成结构图.jpg)

## 相关词汇表

- `Raft`：`etcd`所采用的保证分布式系统强一致性的算法。
- `Node`：一个`Raft`状态机实例。
- `Member`： 一个`etcd`实例。它管理着一个`Node`，并且可以为客户端请求提供服务。
- `Cluster`：由多个`Member`构成可以协同工作的`etcd`集群。
- `Peer`：对同一个`etcd`集群中另外一个`Member`的称呼。
- `Client`： 向`etcd`集群发送HTTP请求的客户端。
- `WAL`：预写式日志，`etcd`用于持久化存储的日志格式。
- `snapshot`：`etcd`防止`WAL`文件过多而设置的快照，存储`etcd`数据状态。
- `Proxy`：`etcd`的一种模式，为`etcd`集群提供反向代理服务。
- `Leader：`Raft`算法中通过竞选而产生的处理所有数据提交的节点。
- `Follower`：竞选失败的节点作为`Raft`中的从属节点，为算法提供强一致性保证。
- `Candidate`：当`Follower`超过一定时间接收不到`Leader`的心跳时转变为`Candidate`开始`Leader`竞选。
- `Term`：某个节点成为`Leader`到下一次竞选开始的时间周期，称为一个`Term`。
- `Index`：数据项编号。`Raft`中通过`Term`和`Index`来定位数据。

## 下载安装

```linux
# 选择下载的版本
VERSION=v3.3.13

# 设置下载的url
DOWNLOAD_URL=https://github.com/etcd-io/etcd/releases/download

# 创建安装目录
mkdir -p /usr/local/etcd

# curl下载
curl -L ${DOWNLOAD_URL}/${VERSION}/etcd-${VERSION}-linux-amd64.tar.gz -o /tmp/etcd-${VERSION}-linux-amd64.tar.gz

# 解压
tar xzvf /tmp/etcd-${VERSION}-linux-amd64.tar.gz -C /usr/local/etcd --strip-components=1

# 删除下载
rm -f /tmp/etcd-${VERSION}-linux-amd64.tar.gz

# 设置环境变量
vim /etc/profile
# add etcd
export PATH=$PATH:/usr/local/etcd
export ETCDCTL_API=3

# 配置生效
source /etc/profile
```

## 编写systemd服务

```linux
# 写入文件
cat > /etc/systemd/system/etcd.service <<EOF
[Unit]
Description=etcd
Documentation=https://github.com/coreos/etcd
Conflicts=etcd.service
Conflicts=etcd2.service

[Service]
Type=notify
Restart=always
RestartSec=5s
LimitNOFILE=40000
TimeoutStartSec=0

ExecStart=/usr/local/etcd/etcd --config-file=/etc/etcd/conf-discovery-dns.yml

[Install]
WantedBy=multi-user.target
EOF

# 重新加载配置
systemctl daemon-reload

# 启动etcd
systemctl start etcd
```

#### 注意：

我这里编写的是etcd集群服务。通过dns发现的机制引导集群。单机的etcd服务需要自行更改`ExecStart`。

## 测试

### 查看版本

```linux
# etcd
[root@jw-centos1 ~]# etcd --version
etcd Version: 3.3.13
Git SHA: 98d3084
Go Version: go1.10.8
Go OS/Arch: linux/amd64

# etcdctl
[root@jw-centos1 ~]# etcdctl version
etcdctl version: 3.3.13
API version: 3.3

```

### 设置一个key

```go
[root@jw-centos1 ~]# etcdctl put foo bar
OK

[root@jw-centos1 ~]# etcdctl get foo
foo
bar
```

如果确定打印，那么`etcd`正在运行！