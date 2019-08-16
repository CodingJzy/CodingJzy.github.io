---
title: docker仓库操作
date: 2019-08-16 17:01:31
categories: Docker
keywords: docker官方仓库、第三方镜像市场、搭建本地私有仓库
description: docker官方仓库、第三方镜像市场、搭建本地私有仓
---

# Repository

仓库(Repository)是集中存放镜像(Image)的地方，分为私有仓库和公共仓库。

有时候我们喜欢把仓库和注册服务器(`Registry`)混淆，实际上并不是。注册服务器又称仓库服务器，是存放仓库的具体服务器。一个仓库服务器下可以有好多仓库。但是，你也别太较真，口语和概念本来就是有点不一样，大家心里清楚就行了。

例如：`docker.io/library/nginx:latest`。

- 注册服务器(Registry)：`docker.io`
- 仓库(Repository)：`library/nginx`
- 标签(Tag)：`latest`

## docker hub公共镜像市场

[docker官方仓库]( https://hub.docker.com 
)。

### 登录

通过`docker login`命令登录，需提前注册好用户。登录成功后，会在宿主机当前用户的家目录创建一个`~/.docker/config.json`文件。保存用户的认证信息，之后就可以和`git`操作一样，进行`pull`和`push`。

### 基本操作

无需登录就可以`docker search`命令来查找官方仓库的镜像。

```dockerfile
root@jw-ubuntu01:~# docker search python
NAME                             DESCRIPTION                                     STARS               OFFICIAL            AUTOMATED
python                           Python is an interpreted, interactive, objec…   4421                [OK]                
django                           Django is a free web application framework, …   863                 [OK]                
pypy                             PyPy is a fast, compliant alternative implem…   203                 [OK]                
kaggle/python                    Docker image for Python scripts run on Kaggle   128                                     [OK]
arm32v7/python                   Python is an interpreted, interactive, objec…   38                                      
centos/python-35-centos7         Platform for building and running Python 3.5…   36                                      
...
```

## 第三方镜像市场

## 搭建本地私有仓库