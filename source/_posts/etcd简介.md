---
title: etcd简介
date: 2019-07-23 08:17:51
categories: etcd
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
- `Cluster`：由多个Member构成可以协同工作的`etcd`集群。
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

