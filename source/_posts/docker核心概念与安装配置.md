---
title: docker核心概念与安装配置
date: 2019-07-24 14:49:19
categories: Docker
---

# Docker核心概念与安装配置

## Docker核心概念

Docker的三大核心概念：

- 镜像：`image`
- 容器：`container`
- 仓库：`repository`

### 镜像

docker镜像类似于虚拟机的镜像，是一个只读的容器模版。简单一点就是：docker镜像是docker容器的静态视角，docker容器是docker镜像的运行状态。

例如：一个镜像可以包含一个基本的操作系统环境，里面安装好了`python`，或者其他一些软件。可以把它称为一个`python`镜像。

docker提供了一套十分简单的机制来创建和更新现有镜像，用户甚至可以从网上下载已经做好的镜像直接使用。

### 容器

docker容器类似于一个轻量级的沙箱，docker利用容器来运行和隔离应用。

docker容器其实就是一个进程，它是由镜像创建的运行实例。如果从面向对象思想来看，镜像就是类，而容器就是对象。可以创建、启动、开始、停止、删除。容器之间都是彼此相互隔离、互不可见。

### 仓库

docker仓库类似于代码仓库。是docker存放镜像的场所。

有时候我们会把仓库(`repository`)和仓库注册服务器(`registry`)混为一谈，并不严格区分。其实。仓库服务器是存放仓库的地方。每个仓库存放一类镜像。

打个形象的比喻：你家有一个放粮食的房间，那个房间就是仓库服务器，而房间里面有好多小粮仓。每个粮仓存放不同的粮食，五谷杂粮等等。这几个粮仓就是仓库。

根据所存储的镜像公开与否可将docker仓库分为公开(`public`)仓库和私有(`private`)仓库。

同github一样，用户可以从仓库服务器`push`和`pull`镜像。

## 安装

### centos7

#### 移除旧版本

```linux
yum remove docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-selinux \
    docker-engine-selinux \
    docker-engine
```

#### 安装必要工具

```linux
yum install -y yum-utils device-mapper-persistent-data lvm2
```

#### 添加软件源信息

```linux
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```

#### 更新 yum 缓存

```linux
yum makecache fast
```

#### 安装Docker-ce

```linux
yum -y install docker-ce
```

#### 启动与测试

```linux
# 启动
[root@jw-centos1 ~]# systemctl start docker.

# 测试：运行hello-world，需要联网去拉取hello-world镜像
[root@jw-centos1 ~]# docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
1. The Docker client contacted the Docker daemon.
2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
(amd64)
3. The Docker daemon created a new container from that image which runs the
executable that produces the output you are currently reading.
4. The Docker daemon streamed that output to the Docker client, which sent it
to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
$ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
https://hub.docker.com/

For more examples and ideas, visit:
https://docs.docker.com/get-started/
```

### ubuntu18.04

#### 下载必要工具

```linux
$ sudo apt-get update
$ sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
```

#### 添加软件源信息

```linux
# 添加gpg密钥
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ OK

# 确认导人指纹为`9DC8 5822 9FC7 DD38 854A E2D8 8D8I 803C OEBFCD88`的 GPG公钥
$ sudo apt-key fingerprint OEBFCD88 

# 添加docker官方源
$ sudo add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   bionic \
   stable"

# 更新apt软件包缓存
$ sudo apt-get update
```

#### 安装

```linux
# install docker
$ sudo apt-get install -y docker-ce
```

#### 检测

```linux
# check version
$ docker version
Client:
Version:           18.09.5
API version:       1.39
Go version:        go1.10.8
Git commit:        e8ff056
Built:             Thu Apr 11 04:43:57 2019
OS/Arch:           linux/amd64
Experimental:      false

Server: Docker Engine - Community
Engine:
Version:          18.09.5
API version:      1.39 (minimum version 1.12)
Go version:       go1.10.8
Git commit:       e8ff056
Built:            Thu Apr 11 04:10:53 2019
OS/Arch:          linux/amd64
Experimental:     false
```

## Docker配置

### 设置代理

有些镜像在国内网络环境拉取不到，比如`k8s`相关的一些镜像包。还有在公司内部网络环境，需要走代理才能访问外网，这时候需要配置代理。

#### 为docker服务创建一个内嵌的systemd目录

```linux
mkdir -p /etc/systemd/system/docker.service.d
```

#### 编辑文件

路径：`/etc/systemd/system/docker.service.d/docker.conf`

```linux
[Service]
Environment="HTTP_PROXY=http://ip:port"
Environment="HTTPS_PROXY=http://ip:port"
Environment="NO_PROXY=http://ip:port"
ExecStartPost=/sbin/iptables -P FORWARD ACCEPT
```

#### 重新加载配置并重启

```linux
systemctl daemon-reload  && systemctl restart docker
```

### 更换镜像源

更换镜像源可以加快镜像的拉取速度。

#### 编辑文件

路径：`/etc/docker/daemon.json`

```json
{
 "registry-mirrors": ["https://o9wm45c3.mirror.aliyuncs.com"]
}
```

### 添加用户到docker用户组

为了避免每次使用docker命令时都需要切换到`root`身份。可以将当前用户加入到安装中自动创建的docker用户组。

```linux
usermod -aG docker ${USER}
```

