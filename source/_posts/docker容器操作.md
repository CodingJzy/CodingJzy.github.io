---
title: docker容器操作
date: 2019-07-24 19:26:56
categories: Docker
keywords: docker容器操作
description: docker容器操作
---

# 容器操作

容器是docker的另一个核心概念。简单来说，容器是镜像的一个运行实例。不同的是，镜像是静态的只读文件，而容器有运行时需要的可写文件层。同时，容器的应用进程处于运行状态。

从现在开始忘掉臃肿的虚拟机吧，对容器的操作就行直接操作应用一样简单、快速。

容器的生命周期就是：创建--启动--停止--删除。

```dockerfile
create--start--stop--rm
```

## 查看容器

容器即一个进程，linux查看进程的命令是`ps`，docker也有个类似的命令：

### 查看正在运行的容器

```dockerfile
root@jw-ubuntu01:~# docker ps
CONTAINER ID        IMAGE                    COMMAND                  CREATED             STATUS                          PORTS                                            NAMES
d2e9a26de0b3        topsec-beat:latest       "/usr/share/filebeat…"   27 hours ago        Up 4 hours                                                                       topsec-beat
861845f000a6        topsec-kibana:latest     "/usr/local/bin/kiba…"   27 hours ago        Up 4 hours                      0.0.0.0:5601->5601/tcp                           topsec-kibana
03f640fd23d5        topsec-elastic:latest    "/usr/local/bin/dock…"   27 hours ago        Up 4 hours                      0.0.0.0:9200->9200/tcp, 0.0.0.0:9300->9300/tcp   topsec-elastic
64459acc2f0b        topsec-ips:latest        "/root/start.sh"         27 hours ago        Up 4 hours                                                                       topsec-ips
a33b55f3af4a        topsec-registry:latest   "/entrypoint.sh /etc…"   27 hours ago        Restarting (1) 39 seconds ago                                                    topsec-registry

```

###  查看正在运行的容器

## 创建容器

我们平时很少手动先创建`create`好一个容器，创建好之后，容器是处于停止状态的。需要再手动启动`start`这个容器。这样很麻烦。

docker有个`run`命令直接运行。因为直接运行它会先自己创建，再自己启动。所以我这里不写。后面看`run`命令就行了。

## 启动容器

对于通过`stop`命令停止的容器和`create`好的容器，可以通过`start`命令启动。

```linux
root@jw-ubuntu01:~# docker start --help

Usage:	docker start [OPTIONS] CONTAINER [CONTAINER...]

Start one or more stopped containers

Options:
  -a, --attach               Attach STDOUT/STDERR and forward signals
      --detach-keys string   Override the key sequence for detaching a container
  -i, --interactive          Attach container's STDIN
```

## 停止容器

对于正在运行的容器，我们可以对它进行停止操作。



## 进入容器

## 删除容器

## 导入和导出容器



## 其他命令 

