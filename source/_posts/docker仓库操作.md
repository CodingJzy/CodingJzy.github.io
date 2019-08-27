---
title: docker仓库操作
date: 2019-08-27 18:01:31
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

### 使用自签发证书搭建私有仓库

#### 生成证书

```bash
# 创建证书文件夹
root@jw-ubuntu01:/home/registry# mkdir certs
root@jw-ubuntu01:/home/registry# ls
certs images

# 生成证书
root@jw-ubuntu01:/home/registry# openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key -x509 -days 365 -out certs/domain.crt
Generating a 4096 bit RSA private key
..........................................++++
......................................................................................................................................................................................................................................................................................................................................................................++++
writing new private key to 'certs/domain.key'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:CH
State or Province Name (full name) [Some-State]:BeiJing
Locality Name (eg, city) []:HaiDian
Organization Name (eg, company) [Internet Widgits Pty Ltd]:jiang_wei
Organizational Unit Name (eg, section) []:linux
Common Name (e.g. server FQDN or YOUR name) []:jiangwei.org          
Email Address []:jw19961019@gmail.com
root@jw-ubuntu01:/home/registry# 
```

#### 编写compose.yaml

```yaml
version: "2"
  
services:
  registry:
    image: registry:2.1
    container_name: registry
    ports:
      - "5000:5000"
    environment:
      REGISTRY_HTTP_ADDR: "0.0.0.0:5000"
      REGISTRY_HTTP_TLS_CERTIFICATE: "/certs/domain.crt"
      REGISTRY_HTTP_TLS_KEY: "/certs/domain.key"
    volumes:
      - "./images:/var/lib/registry"
      - "./certs:/certs"
```

#### 启动私有仓库

```dockerfile
root@jw-ubuntu01:/home/registry# docker-compose up -d
WARNING: The Docker Engine you're using is running in swarm mode.

Compose does not use swarm mode to deploy services to multiple nodes in a swarm. All containers will be scheduled on the current node.

To deploy your application across the swarm, use `docker stack deploy`.

Pulling registry (registry:2.1)...
2.1: Pulling from library/registry
9943fffae777: Pull complete
fb15e825cb68: Pull complete
b9583a207297: Pull complete
a3ed95caeb02: Pull complete
87fee1c528e9: Pull complete
829473b2393f: Pull complete
2c1adb4b358c: Pull complete
Digest: sha256:e641943a78a8f634c16ad69f5c9d779f470b147865c2121d89c52ea0da6fc1bd
Status: Downloaded newer image for registry:2.1
Creating registry ... done

root@jw-ubuntu01:/home/registry# docker-compose ps
  Name                Command               State           Ports         
--------------------------------------------------------------------------
registry   /bin/registry /etc/docker/ ...   Up      0.0.0.0:5000->5000/tcp
```

#### 实验1：忽略证书访问

添加域名解析(另外的机器上)：

```bash
root@sw1:~/dsec/DSec/registry# vim /etc/hosts

127.0.0.1       localhost
172.0.0.1       sw1
192.168.32.88 jiangwei.org
```

`ping`测试(另外的机器上)：

```bash
root@sw1:~/dsec/DSec/registry# ping jiangwei.org
PING jiangwei.org (192.168.32.88) 56(84) bytes of data.
64 bytes from jiangwei.org (192.168.32.88): icmp_seq=1 ttl=60 time=0.894 ms
64 bytes from jiangwei.org (192.168.32.88): icmp_seq=2 ttl=60 time=0.799 ms
```

##### curl

```bash
# 不带证书访问，--noproxy是因为公司走的是内网，设置下不走代理
root@sw1:~/dsec/DSec/registry# curl --noproxy jiangwei.org  https://jiangwei.org:5000/v2/_catalog
curl: (60) SSL certificate problem: self signed certificate
More details here: https://curl.haxx.se/docs/sslcerts.html

curl performs SSL certificate verification by default, using a "bundle"
 of Certificate Authority (CA) public keys (CA certs). If the default
 bundle file isn't adequate, you can specify an alternate file
 using the --cacert option.
If this HTTPS server uses a certificate signed by a CA represented in
 the bundle, the certificate verification probably failed due to a
 problem with the certificate (it might be expired, or the name might
 not match the domain name in the URL).
If you'd like to turn off curl's verification of the certificate, use
 the -k (or --insecure) option.

# 忽略证书访问：-k or --insecure代表忽略证书
root@sw1:~/dsec/DSec/registry# curl --noproxy jiangwei.org  -k https://jiangwei.org:5000/v2/_catalog
{"repositories":[]}
```

##### push、pull

在docker的配置文件中加一个参数(另外的机器上)：

```bash
root@sw1:/etc/systemd/system/docker.service.d# cat /etc/docker/daemon.json 
{
    "insecure-registries": ["jiangwei.org:5000"]
}
```

**注意：**该参数就是你生成证书时填写的`CN`+`port`。我填的是`jiangwei.org`。

```bash
root@sw1:~/jiangwei# docker push jiangwei.org:5000/test/busybox:latest
The push refers to a repository [jiangwei.org:5000/test/busybox]
27a32be9858c: Pushed 
latest: digest: sha256:e9e3f57925c4725fc56076f9637adc80a45ac8f86161199926025a9455eb8e37 size: 2136

# 这是我之前push过的，所以可以直接
root@sw1:~/jiangwei# docker pull jiangwei.org:5000/test/alpine:3.8
3.8: Pulling from test/alpine
c87736221ed0: Pull complete 
Digest: sha256:030cbfe2fcf9627378255cf237b51a17dcbae11dee29a00f13670caf3fb09b80
Status: Downloaded newer image for jiangwei.org:5000/test/alpine:3.8
```

#### 实验2：带证书访问

把证书从机器1拷贝到另一机器到`/etc/docker/certs.d/jiangwei.org:5000/`下面，没有就创建这个文件夹。

```bash
root@jw-ubuntu01:/home/registry# scp certs/domain.crt sw1:/etc/docker/certs.d/jiangwei.org:5000/
domain.crt  
```

##### curl

之前的curl就可以跳过证书访问。现在来检验携带证书访问。

```bash
# 一样的-x 是因为我走了公司内网，这里设置代理为空。
root@sw1:/etc/docker/certs.d/jiangwei.org:5000# curl --cacert ./domain.crt -x ""  https://jiangwei.org:5000/v2/_catalog
{"repositories":["pause","test/alpine","test/busybox"]}
```

##### push、pull

为了检验有效性，把之前添加的`daemon.json`下的参数先删除。然后再重启docker。

```bash
# 可以正常推
root@sw1:/etc/docker/certs.d/jiangwei.org:5000# docker push jiangwei.org:5000/pause
The push refers to a repository [jiangwei.org:5000/pause]
5f70bf18a086: Pushed 
41ff149e94f2: Pushed 
latest: digest: sha256:ccc01f0fd7377553737ab082f9ff2cc4d6f00491146001aa55d4fdf5a07960ba size: 3061

# 可以正常拉
root@sw1:/etc/docker/certs.d/jiangwei.org:5000# docker pull jiangwei.org:5000/test/alpine:3.8
3.8: Pulling from test/alpine
c87736221ed0: Already exists 
Digest: sha256:030cbfe2fcf9627378255cf237b51a17dcbae11dee29a00f13670caf3fb09b80
Status: Image is up to date for jiangwei.org:5000/test/alpine:3.8
```

#### 实验3：全局带证书访问

现在不是把证书放在docker那个配置目录下，而是`/usr/local/share/ca-certificate/`目录下。

```bash
# 使用mv命令，这样原来的方式应该已经失效
root@sw1:/usr/local/share/ca-certificates# mv /etc/docker/certs.d/jiangwei.org\:5000/domain.crt ./
root@sw1:/usr/local/share/ca-certificates# ls
cacert.crt  docker-hub.cloud.top.crt  domain.crt
```

更新证书：

```bash
root@sw1:/usr/local/share/ca-certificates# update-ca-certificates 
Updating certificates in /etc/ssl/certs...
WARNING: ca.pem does not contain a certificate or CRL: skipping
1 added, 0 removed; done.
```

##### curl

现在curl可以不用证书访问了，直接get。

```bash
root@sw1:/# curl  -x ""  https://jiangwei.org:5000/v2/_catalog
{"repositories":["pause","test/alpine","test/busybox"]}
```

##### push、pull

重启docker，看看docker是否也可以。

```bash
root@sw1:/# systemctl restart docker
# 第一种忽略证书已经清空
root@sw1:/# cat /etc/docker/daemon.json 
{
}
# 第二种证书访问也已经被清空
root@sw1:/# ls /etc/docker/certs.d/jiangwei.org\:5000/

# 第三种push：检验通过
root@sw1:/# docker tag harbor.sh.deepin.com/sunway/rabbitmq:3.6.6 jiangwei.org:5000/test/rabbitmq:3.6.6
root@sw1:/# docker push jiangwei.org:5000/test/rabbitmq:3.6.6
The push refers to a repository [jiangwei.org:5000/test/rabbitmq]
0da07d84e27d: Pushed 
7bf1a725df91: Pushing [==============>                                    ]  27.68MB/97.76MB
b1a42145e518: Pushed 
121d220e2d64: Pushing [================>                                  ]  21.02MB/65.63MB
```

**注意：**实验都是在另外一台机器上做的。

### 登录认证方式搭建私有仓库

#### 生成用户认证文件

在运行仓库容器的服务器上操作：

```bash
# 创建auth文件夹
root@jw-ubuntu01:/home/registry# mkdir auth

# 原生生成认证文件：创建了一个用户名为testuser、密码为testpassword的文件
docker run  --entrypoint htpasswd  --rm registry:2.1 -Bbn testuser testpassword > auth/htpasswd

# 查看文件
root@jw-ubuntu01:/home/registry# cat auth/htpasswd 
testuser:$2y$05$Rds3vlTUjEYKlLcgasiIBeARLtTwQrxfZ0Jgp6YsUCn5hExmdMFCu
```

#### 修改compose.yaml文件

```bash
root@jw-ubuntu01:/home/registry# vim docker-compose.yaml 
version: "2"
  
services:
  registry:
    image: registry:2.1
    container_name: registry
    ports:
      - "5000:5000"
    environment:
      REGISTRY_HTTP_ADDR: "0.0.0.0:5000"
      REGISTRY_HTTP_TLS_CERTIFICATE: "/certs/domain.crt"
      REGISTRY_HTTP_TLS_KEY: "/certs/domain.key"
      REGISTRY_AUTH: "htpasswd"
      REGISTRY_AUTH_HTPASSWD_REALM: "Registry Realm"
      REGISTRY_AUTH_HTPASSWD_PATH: "/auth/htpasswd"
    volumes:
      - "./images:/var/lib/registry"
      - "./certs:/certs"
      - "./auth:/auth"
```

#### 测试

##### curl

为了互不影响，在第三台机器上测试：

```bash
# 取消证书验证，但是不携带用户认证
root@sw2:/# curl  -k -x ""    https://jiangwei.org:5000/v2/_catalog
{"errors":[{"code":"UNAUTHORIZED","message":"access to the requested resource is not authorized","detail":[{"Type":"registry","Name":"catalog","Action":"*"}]}]}

# 取消证书验证，但是携带错误口令认证
root@sw2:/# curl  -k -x "" -u testuser:password    https://jiangwei.org:5000/v2/_catalog
{"errors":[{"code":"UNAUTHORIZED","message":"access to the requested resource is not authorized","detail":[{"Type":"registry","Name":"catalog","Action":"*"}]}]}

# 取消证书验证，携带正确令认证
root@sw2:/# curl  -k -x "" -u testuser:testpassword    https://jiangwei.org:5000/v2/_catalog
{"repositories":["pause","test/alpine","test/busybox","test/rabbitmq"]}
```

##### docker login

```bash
# 没有登录就push
root@jw-ubuntu01:/home/registry# docker push  jiangwei.org:5000/test/alpine
The push refers to repository [jiangwei.org:5000/test/alpine]
d9ff549177a9: Preparing 
no basic auth credentials

# 登录，携带错误口令
root@jw-ubuntu01:/home/registry# docker login jiangwei.org:5000
Username: testuser
Password: 
Error response from daemon: login attempt to https://jiangwei.org:5000/v2/ failed with status: 401 Unauthorized

#登录，携带正确口令
root@jw-ubuntu01:/home/registry# docker login jiangwei.org:5000
Username: testuser
Password: 
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded

# 开始推送
root@jw-ubuntu01:/home/registry# docker push  jiangwei.org:5000/test/alpine
The push refers to repository [jiangwei.org:5000/test/alpine]
d9ff549177a9: Layer already exists 
latest: digest: sha256:94acf7e9dabda295562ebf24085bf8d4785cda54ceacc8ec879ff481d0dba708 size: 2140

```

**注意：**：您不能将身份验证和将凭据作为明文发送的身份验证方案使用。您必须首先[配置TLS](https://docs.docker.com/registry/deploying/#running-a-domain-registry)才能进行身份验证。

```bash
# 因为机器2没有证书，是登录不了的
root@sw2:/# docker login jiangwei.org:5000
Username: 1
Password: 
Error response from daemon: Get https://jiangwei.org:5000/v2/: x509: certificate signed by unknown authority
```

