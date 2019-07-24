---
title: docker镜像操作
date: 2019-07-24 16:13:38
categories: Docker
---

# 镜像操作

docker运行容器之前需要本地存在对应的镜像，如果镜像不存在，docker会尝试从默认的镜像仓库拉取。也可以通过配置使用自定义的镜像仓库。

## 获取镜像

docker官方的hub仓库已经提供了数十万个镜像供大家开放下载。

完整的命令：

```linux
docker pull  name[:tag|@digest]
```

- `name`：镜像仓库名字，用来区分镜像
- `tag`：镜像的标签，也可以理解为版本
- `digest`：镜像的摘要，很少用它来下载镜像

下面举几个例子：

**如果没有指定tag会默认下载tag为`latest`镜像：**

```linux
docker pull ubuntu
```

**下载tag为18.04的ubuntu镜像**

```linux
docker pull ubuntu:18.04
```

严格来讲。还需要加仓库服务器(`registry`)，因为如果不指定仓库服务器会存在镜像同名现象。

其实，上面两条命令相当于：

```linux
docker pull registry.hub.docker.com/ubuntu:18.04
```

**如果我们要下载私人服务器的镜像或者网易风巢的镜像。**

```linux
docker pull myregistry.com:18005/ubuntu:18.04
docker pull hub.c.163.com/public/ubuntu:18.04
```

镜像下载到本地后，就可以利用该镜像创建一个容器，在其中执行bash命令，执行打印`Hello Docker`命令。

```linux
root@sw1:~/jiangwei/compose-1.24.1/bin# docker run -it sw64/deepin bash
dircolors: no SHELL environment variable, and no shell type option given
root@10920811956b:/# echo "Hello Docker"
Hello Docker
root@10920811956b:/# exit
exit
root@sw1:~/jiangwei/compose-1.24.1/bin# 
```

## 查看镜像信息

### 列出所有镜像

可以使用命令来获取所有镜像：`docker images` or `docker image ls`

```linux
[root@104 ~]# docker images
REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
golang                               1.12.7-alpine       6b21b4c6e7a3        12 days ago         350MB
k8s.gcr.io/kube-proxy                v1.14.3             004666307c5b        6 weeks ago         82.1MB
k8s.gcr.io/kube-controller-manager   v1.14.3             ac2ce44462bc        6 weeks ago         158MB
k8s.gcr.io/kube-apiserver            v1.14.3             9946f563237c        6 weeks ago         210MB
k8s.gcr.io/kube-scheduler            v1.14.3             953364a3ae7a        6 weeks ago         81.6MB
k8s.gcr.io/coredns                   1.3.1               eb516548c180        6 months ago        40.3MB
k8s.gcr.io/etcd                      3.3.10              2c4adeb21b4f        7 months ago        258MB
k8s.gcr.io/pause                     3.1                 da86e6ba6ca1        19 months ago       742kB

```

- `repository`：镜像来自于哪个仓库
- `tag`：镜像标签名
- `image id`：标识了唯一镜像
- `size`：镜像大小
- `created`：镜像创建时间

## 搜索镜像

## 删除和清理镜像

## 创建镜像

## 导出和载入

## 上传

