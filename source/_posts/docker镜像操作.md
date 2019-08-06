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

### inspect(详细)

获取镜像的详细信息：`docker inspect image`

```linux
[root@104 ~]# docker inspect golang:1.12.7-alpine
[
    {
        "Id": "sha256:6b21b4c6e7a3d4a9496fff4ca5cf2069baaf4787d8f4adb1e2cf10acd2b69e1a",
        "RepoTags": [
            "golang:1.12.7-alpine"
        ],
        "RepoDigests": [
            "golang@sha256:1121c345b1489bb5e8a9a65b612c8fed53c175ce72ac1c76cf12bbfc35211310"
        ],
        "Parent": "",
        "Comment": "",
        "Created": "2019-07-11T23:29:27.482581015Z",
        "Container": "23d16fc333493bcb155dd8dd32c25e4067a69db5ad47a8c16465dcdf816d0cfc",
        "ContainerConfig": {
            "Hostname": "23d16fc33349",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
             ...
```

### history(镜像构建历史)

镜像是由一层层文件组成，也可以从中看出镜像的构建历史等信息。

```linux
[root@104 ~]# docker history golang:1.12.7-alpine
IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
6b21b4c6e7a3        12 days ago         /bin/sh -c #(nop) WORKDIR /go                   0B                  
<missing>           12 days ago         /bin/sh -c mkdir -p "$GOPATH/src" "$GOPATH/b…   0B                  
<missing>           12 days ago         /bin/sh -c #(nop)  ENV PATH=/go/bin:/usr/loc…   0B                  
<missing>           12 days ago         /bin/sh -c #(nop)  ENV GOPATH=/go               0B                  
<missing>           12 days ago         /bin/sh -c set -eux;  apk add --no-cache --v…   344MB               
<missing>           12 days ago         /bin/sh -c #(nop)  ENV GOLANG_VERSION=1.12.7    0B                  
<missing>           12 days ago         /bin/sh -c [ ! -e /etc/nsswitch.conf ] && ec…   17B                 
<missing>           12 days ago         /bin/sh -c apk add --no-cache   ca-certifica…   551kB               
<missing>           12 days ago         /bin/sh -c #(nop)  CMD ["/bin/sh"]              0B                  
<missing>           12 days ago         /bin/sh -c #(nop) ADD file:0eb5ea35741d23fe3…   5.58MB   
```

可以加上参数`--no-trunc`完整显示。

## 搜索镜像

可以去搜索docker官方的仓库地址中的镜像。

```linux
[root@104 ~]# docker search jiangziya
NAME                        DESCRIPTION         STARS               OFFICIAL            AUTOMATED
jiangziya/test_flask                            1                                       
jiangziya/pause             k8s.gcr.io/pause    0                                       
jiangziya/deep_scan                             0                                       
jiangziya/gcr-pause-amd64                       0                                       
jiangziya/python                                0                                       
jiangziya/anchore_engine    docker镜像扫描工具        0  
```

## 镜像标签

一个镜像id可以被不同镜像标签名引用。比如说我把docker官方的python镜像打一个tag名。



## 删除和清理镜像

### 删除

删除镜像：`docker rmi` or `docker image rm `

对于正在被容器使用的镜像，删除会失败。可以加`-f`代表强制删除。

```linux
[root@104 ~]# docker rmi -f  6b21b4c6e7a3
Untagged: golang:1.12.7-alpine
Untagged: golang@sha256:1121c345b1489bb5e8a9a65b612c8fed53c175ce72ac1c76cf12bbfc35211310
Deleted: sha256:6b21b4c6e7a3d4a9496fff4ca5cf2069baaf4787d8f4adb1e2cf10acd2b69e1a
```

在删除镜像的时候，一个镜像id可能被多个镜像引用。也就是一个镜像拥有多个标签的时候，可能会造成无法删除的情况，先删最后引用的镜像，最后删除原始镜像。

### 清理

使用docker之后，系统中可能会遗留一些临时的镜像文件，以及一些没有被使用的镜像。可以通过`docker image prune `来清理。

```linux
# 我这里没有，有的话会显示大小，久了会好几个g
[root@104 ~]# docker image prune
WARNING! This will remove all dangling images.
Are you sure you want to continue? [y/N] y
Total reclaimed space: 0B
```

也可以加参数`-f`强制删除，不进行提示。

### none

在用dockerfile构建镜像的时候，有时候也会产生标签名和仓库名为`none`的情况，所以，可以自己组装命令：

```linux
docker rmi $(docker images -f "dangling=true" -q)
```

例如：

```linux
root@sw1:~/jiangwei/compose-1.24.1/bin# docker rmi $(docker images -f "dangling=true" -q)
Deleted: sha256:7e3f22046ebc8336dc484c9308f748abce68a13027fa3a81021f87c2a813ab2c
Deleted: sha256:ae6d77a20ddc1beaeec9f2807648260ea890b9ee54467ad36b4eba0e069b0024
Deleted: sha256:f1bfb4e5332b265ed19e33237de059c8805535f198572c88cd2589b20c020600
Deleted: sha256:5c7a9e8b03b90ced3b01a4a119a02bd27d8c40a16c7f3ceca94c13d2d26fe71e
Deleted: sha256:0900810aac1ba33d5c963607b683f04ae09b1d212abe54355d519b323b0d57a9
Deleted: sha256:bdf3003fee2c7a4591f6c19d547a0863a9afd6af55c33d9e66588ce6280dee36
Deleted: sha256:c99a334c2807516aca6af0974d800f5360139a44e8145aed5306998646a050fa
Deleted: sha256:afc5332d79c1e73c01f75e2019c9241d8166361cdc5db1384fbcf801545c256e
Error response from daemon: conflict: unable to delete 96df7db48070 (must be forced) - image is being used by stopped container cc9f94bbc295
Error response from daemon: conflict: unable to delete cd14e780fb73 (must be forced) - image is being used by stopped container 07639e749cee

```

```linux
root@sw1:~/jiangwei/compose-1.24.1/bin# docker rmi -f $(docker images -f "dangling=true" -q)
Deleted: sha256:96df7db48070646dab3e67ddeb1cd821f7e3ee0335b435b1e63e9bc822c1a186
Deleted: sha256:e1654fc479c942e04408e002b954d201c8ad889bf594bb2aab70855ed1da6d66
Deleted: sha256:cd14e780fb735730ca02fd5a993b70829dcf618aa7111437266c652b589f8aaa
Deleted: sha256:6199583b07a1cc1427d5e2996220029400ea0697274ee8cf952c3b156c4905f2
Deleted: sha256:c2e8ffce43ca34154972ae4d29a01f955f1f4025ff6e2be704892f77627e1744
Deleted: sha256:8472c46fe53e1cb651d2a47bebf385309398f6ff0d0fa55a19a18e8c24a129bd
Deleted: sha256:46e69e79414994b439773d0174754ca07a40bd5b5a9a0b9015bcff61f38a6107
Deleted: sha256:91891f9a9bd7ced36d91769a7d510e4b06e93e4d8b8affd1d9c83ae07f1d3bb5
```

## 创建镜像

创建镜像的方法有三种：

- 基于已有镜像的容器创建
- 基于Dockerfile创建

### 基于已有容器创建

这是利用docker的commit命令进行提交，修改的是容器运行时的可写层。原有镜像不会改变，而是创建出一个新的镜像。

这个很少用，而且弊端很大。只是适合学习用的。

### 基于Dockerfile创建

编写Dockerfile创建镜像是最常见的方式，Dockerfile是一个文本。利用一些指令描述基于某个基础镜像创建新镜像的过程。

下面给出一个简单的示例，基于`httpd`镜像。

#### 准备文件

```dockerfile
# 创建好两个文件
root@jw-ubuntu01:~/docker/images/apache_image# ls
Dockerfile.httpd  public_html

# index.html内容如下
root@jw-ubuntu01:~/docker/images/apache_image# cat public_html/index.html 
<!DOCTYPE html>
<html>
<body>
	<p>hello docker web:v1 <p>
</body>
</html>
```

#### 编写Dockerfile.httpd文件

```dockerfile
# 编写dockerfile，内容如下
root@jw-ubuntu01:~/docker/images/apache_image# vim Dockerfile.httpd 
FROM httpd:2.4
  
COPY ./public_html /usr/local/apache2/htdocs/
```

#### 执行命令开始构建

```dockerfile
# 构建web:v1：如果基础镜像不存在，默认会去docker仓库拉取镜像
root@jw-ubuntu01:~/docker/images/apache_image# docker build -f Dockerfile.httpd -t web:v1 .
Sending build context to Docker daemon  3.584kB
Step 1/2 : FROM httpd:2.4
2.4: Pulling from library/httpd
f5d23c7fed46: Pull complete 
b083c5fd185b: Pull complete 
bf5100a89e78: Pull complete 
98f47fcaa52f: Pull complete 
622a9dd8cfed: Pull complete 
Digest: sha256:dc4c86bc90593c6e4c5b06872a7a363fc7d4eec99c5d6bfac881f7371adcb2c4
Status: Downloaded newer image for httpd:2.4
 ---> ee39f68eb241
Step 2/2 : COPY ./public_html /usr/local/apache2/htdocs/
 ---> d2294d4f5ce0
Successfully built d2294d4f5ce0
Successfully tagged web:v1

# 构建web:v2，提前修改pubilc/index.html内容。
root@jw-ubuntu01:~/docker/images/apache_image# docker build -f Dockerfile.httpd -t web:v2 .
Sending build context to Docker daemon  3.584kB
Step 1/2 : FROM httpd:2.4
 ---> ee39f68eb241
Step 2/2 : COPY ./public_html /usr/local/apache2/htdocs/
 ---> c9945d69f223
Successfully built c9945d69f223
Successfully tagged web:v2
```

#### 查看构建的镜像

```dockerfile
root@jw-ubuntu01:~/docker/images/apache_image# docker images|grep web
web                                             v1                  81e7034c8b70        8 seconds ago        154MB
web                                             v2                  c9945d69f223        About a minute ago   154MB
```

#### 运行

加了一些参数，现在看不懂没关系。知道大概意思就行了。

```dockerfile
root@jw-ubuntu01:~/docker/images/apache_image# docker run -itd --name web1  -p 8001:80 web:v1
2280702042cb3a5cbb896719bd5da9858f000a1560a02a3058cb3ea802d2ca59
root@jw-ubuntu01:~/docker/images/apache_image# docker run -itd --name web2  -p 8002:80 web:v2
a6c62487a191479fe1bdc8c56c1c998b9039c491f5a3dc1456ba3ea701b9bab3

# 查看正在运行的容器
root@jw-ubuntu01:~/docker/images/apache_image# docker ps |grep web
a6c62487a191        web:v2                   "httpd-foreground"       56 seconds ago       Up 55 seconds          0.0.0.0:8002->80/tcp                                 we2
2280702042cb        web:v1                   "httpd-foreground"       About a minute ago   Up About a minute      0.0.0.0:8001->80/tcp                                 we1
```

#### 访问web应用

```dockerfile
root@jw-ubuntu01:~/docker/images/apache_image# curl 192.168.32.87:8001
<!DOCTYPE html>
<html>
<body>
	<p>hello docker web:v1 <p>
</body>
</html>

root@jw-ubuntu01:~/docker/images/apache_image# curl 192.168.32.87:8002
<!DOCTYPE html>
<html>
<body>
	<p>hello docker web:v2 <p>
</body>
</html>
```

上面利用简单的dockerfile，基于httpd基础镜像，构建出了两个web应用，还运行了两个web应用。

## 导出和导入

镜像默认是从docker仓库拉取。如果机器没网，或者需要拷贝到其他机器。我们可以用`save`和`load`命令。

### 导出

#### 单个

```dockerfile
# 这是一个标准的导出
docker save web:v1 -o  xxx.tar.gz

# 更小的体积导出
docker save web:v1 |gzip > yyy.tar.gz

# 比较两种导出方式的大小
ls -alh
-rw------- 1 root     root   152M Aug  6 15:16 xxx.tar.gz
-rw-r--r-- 1 root     root    53M Aug  6 15:17 yyy.tar.gz
```

#### 多个

```dockerfile
# 标准导出
 docker save web:v1 web:v2  > xy.tar.gz

# 更小体积导出
docker save web:v1 web:v2 |gzip > xy1.tar.gz

# 比较两种导出方式的大小
ls -alh
-rw-r--r-- 1 root     root    53M Aug  6 15:20 xy1.tar.gz
-rw-r--r-- 1 root     root   152M Aug  6 15:19 xy.tar.gz
```

### 导入

```dockerfile
# 查看本地是否存在
root@jw-ubuntu01:~/docker/images/apache_image# docker images|grep web
web                                             v1                  81e7034c8b70        About an hour ago   154MB
web                                             v2                  c9945d69f223        About an hour ago   154MB

# 强制删除，因为两个镜像正在被两个容器运行着使用。
root@jw-ubuntu01:~/docker/images/apache_image# docker rmi -f web:v1 web:v2
Untagged: web:v1
Untagged: web:v2

# 没了
root@jw-ubuntu01:~/docker/images/apache_image# docker images|grep web

# 执行命令导入
root@jw-ubuntu01:~/docker/images/apache_image# docker load < xy1.tar.gz 
Loaded image: web:v1
Loaded image: web:v2

# 验证本地是否存在
root@jw-ubuntu01:~/docker/images/apache_image# docker images|grep web
web                                             v1                  81e7034c8b70        About an hour ago   154MB
web                                             v2                  c9945d69f223        About an hour ago   154MB
```

## 上传

同github仓库一样，可以对镜像镜像`pull`和`push`操作。

默认会上传到docker官方仓库。完整命令为：

```dockerfile
docker push registry_host:registry_port/repository:tag

# 例如
docker push 172.19.19.252:18005/nginx:t1
```