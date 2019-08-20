---
title: Dockerfile
date: 2019-08-20 22:08:45
categories: Docker
keywords: 使用dockerfile创建镜像
description: 使用dockerfile创建镜像
---

# Dockerfile

Dockerfile是一个文本格式的配置文件，我们可以通过编写dockerfile构建自己的镜像。

## 基本结构

dockerfile由一行行命令语组成，支持`#`注释。

- 基础镜像
- 维护中信息
- 构建镜像的指令
- 容器启动执行指令

先来看个示例：

```dockerfile
FROM python:3.6-slim as build

LABEL author=jiang_wei email=jw19961019@gmail.com

# anchore version
ARG ANCHORE=0.4
ARG ANCHORE_CLI=0.4.1

# change mirrors
COPY ./build/configs/sources.list /etc/apt/sources.list

WORKDIR /build

RUN set -ex && \
    apt-get update -y && \
    apt-get install -y gcc git && \
    echo ">>>>>>>>git clone anchore<<<<<<<<" && \
    git clone -b ${ANCHORE} https://github.com/anchore/anchore-engine.git && \
    echo ">>>>>>>>python wheels<<<<<<<<" && \
    cd anchore-engine && \
    echo  "anchorecli==${ANCHORE_CLI}" >> ./requirements.txt && \
    pip3 wheel -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com --wheel-dir=/build/wheels  . && \
    echo ">>>>>>>>copy config<<<<<<<<" && \
    mkdir /build/configs && \ 
    cp ./conf/default_config.yaml /build/configs/default_config.yaml && \
    cp ./docker-compose.yaml /build/configs/docker-compose.yaml && \
    cp ./docker-compose-dev.yaml /build/configs/docker-compose-dev.yaml && \
    cp ./docker-entrypoint.sh /build/configs/docker-entrypoint.sh && \
    echo "clean cache" && \
    apt-get autoremove -y gcc git && apt-get autoclean && apt-get clean  && apt-get autoremove && rm -rf /var/cache/apt/ && \
    rm -rf /build/anchore-engine/
    
RUN tar -z -c -v -C /build -f /build.tgz .

FROM python:3.6-slim

COPY --from=build /build /build
COPY --from=build /etc/apt/sources.list /etc/apt/sources.list
COPY ./build/deps/skopeo /usr/bin/
COPY ./build/configs/skopeo-policy.json /etc/containers/policy.json

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 \
    ANCHORE_CONFIG_DIR=/config \
    ANCHORE_SERVICE_DIR=/anchore_service \
    ANCHORE_LOG_LEVEL=INFO \
    ANCHORE_ENABLE_METRICS=false \
    ANCHORE_INTERNAL_SSL_VERIFY=false \
    ANCHORE_WEBHOOK_DESTINATION_URL=null \
    ANCHORE_FEEDS_ENABLED=true \
    ANCHORE_FEEDS_SELECTIVE_ENABLED=true \
    ANCHORE_FEEDS_SSL_VERIFY=true \
    ANCHORE_ENDPOINT_HOSTNAME=localhost \
    ANCHORE_EVENTS_NOTIFICATIONS_ENABLED=false \
    ANCHORE_FEED_SYNC_INTERVAL_SEC=21600 \
    ANCHORE_EXTERNAL_PORT=null \
    ANCHORE_EXTERNAL_TLS=false \
    ANCHORE_AUTHZ_HANDLER=native \
    ANCHORE_EXTERNAL_AUTHZ_ENDPOINT=null \
    ANCHORE_ADMIN_PASSWORD=foobar \
    ANCHORE_ADMIN_EMAIL=admin@myanchore \
    ANCHORE_HOST_ID="anchore-quickstart" \
    ANCHORE_DB_PORT=5432 \
    ANCHORE_DB_NAME=postgres \
    ANCHORE_DB_USER=postgres \
    SET_HOSTID_TO_HOSTNAME=false \
    ANCHORE_CLI_USER=admin \
    ANCHORE_CLI_PASS=foobar \
    ANCHORE_SERVICE_PORT=8228 \
    ANCHORE_CLI_URL="http://localhost:8228" \
    ANCHORE_FEEDS_URL="https://ancho.re/v1/service/feeds" \
    ANCHORE_FEEDS_CLIENT_URL="https://ancho.re/v1/account/users" \
    ANCHORE_FEEDS_TOKEN_URL="https://ancho.re/oauth/token" \
    ANCHORE_GLOBAL_CLIENT_READ_TIMEOUT=0 \
    ANCHORE_GLOBAL_CLIENT_CONNECT_TIMEOUT=0

EXPOSE ${ANCHORE_SERVICE_PORT}

RUN set -ex && \
    apt-get update -y && \
    apt-get install -y curl && \
    groupadd --gid 1000 anchore && \
    useradd --uid 1000 --gid anchore --shell /bin/bash --create-home anchore && \
    mkdir ${ANCHORE_SERVICE_DIR} && \
    mkdir /config && \
    mkdir -p /var/log/anchore && chown -R anchore:anchore /var/log/anchore && \
    mkdir -p /var/run/anchore && chown -R anchore:anchore /var/run/anchore && \
    mkdir -p /analysis_scratch && chown -R anchore:anchore /analysis_scratch && \
    mkdir -p /workspace && chown -R anchore:anchore /workspace && \
    mkdir -p ${ANCHORE_SERVICE_DIR} && chown -R anchore:anchore /anchore_service && \
    cp /build/configs/default_config.yaml /config/config.yaml && \
    cp /build/configs/docker-compose.yaml /docker-compose.yaml && \
    cp /build/configs/docker-compose-dev.yaml /docker-compose-dev.yaml && \
    cp /build/configs/docker-entrypoint.sh /docker-entrypoint.sh && \
    md5sum /config/config.yaml > /config/build_installed && \
    chmod +x /docker-entrypoint.sh && \
    pip3 install --no-index --find-links=./ /build/wheels/*.whl && \
    chmod +x /usr/bin/skopeo && \
    chmod 777 /etc/containers/policy.json && \
    rm -rf /build /root/.cache && \
    echo "clean cache" && \
    apt-get autoclean && apt-get clean  && apt-get autoremove && rm -rf /var/cache/apt/
    
HEALTHCHECK --start-period=20s \
    CMD curl -f http://localhost:8228/health || exit 1

USER anchore:anchore

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["anchore-manager", "service", "start", "--all"]
```

看不懂没关系，哈哈！！！看下面的指令介绍。

## 指令

指令分为两种，包括`配置指令`、`操作指令`。



#### FROM

指定构建自定义镜像的基础镜像。

语法：

```dockerfile
FROM <image> [as <name>]
FROM <image>:<tag> [as <name>]
FROM <image>:<digest> [as <name>]
```

示例：

```dockerfile
# 没有指定tag，就默认latest
FROM centos

FROM ubuntu:18.04

# 取别名，下一个FROM用的到
FROM python:3.6-slim as build
```

任何一个dockerfile文件第一行指令必须为`FROM`，注释除外。

可以为基础镜像取别名，多用在构建多阶镜像。

#### ARG

定义构建镜像过程中使用的变量。

语法：

```dockerfile
ARG <name>[=<default value>]
```

示例：

```dockerfile
# 声明python
ARG python

# 声明go版本为1.12(带有默认值)
ARG GOVERSION=1.12
```

在执行`docker build`命令构建镜像的时候，可以通过参数`--build-arg k1=v1 --build-arg k2=v2`来为变量赋值，也会覆盖dockerfile定义的默认值。镜像构建成功后，该变量将不再保存。

docker内置了一些默认的ARG变量，用户无需声明而直接使用。比如，在公司内网经常遇到代理的问题。可以通过设置这几个(不区分大小写)：

- `HTTP_PROXY`
- `HTTS_PROXY`
- `FTP_PROXY`
- `NO_PROXY`

#### LABEL

为镜像元数据标签信息，这些信息可以用来辅助过滤特定的镜像。

语法：

```dockerfile
LABEL k1=v1 k2=v2 ...
LABEL k3=v3
```

示例：

```dockerfile
LABEL author=jiang_wei email=jw19961019@gmail.com
LABEL description="dockerfile"
```

可以有多个`LABEL`，但是为了尽量减少镜像构建层数，应该写一起。

#### EXPOSE

声明容器运行时监听的端口，只是起到声明作用，并不会自动完成映射。

语法：

```dockerfile
EXPOSE <port> [<port>/<protocol>] 
```

示例：

```dockerfile
EXPOSE 80 81/tcp
```

如果要将端口映射出来，启动容器时，可以加`-P`参数。docker主机就会默认分配一个宿主机的随机端口映射到声明的一个端口上。或者加`-p`参数，指定宿主机的某个端口映射到声明的某个端口。比如将宿主机的8080映射到nginx容器的80：

```dockerfile
docker run -p 8080:80 -p 8181:81 nginx
```

#### ENV

指定环境变量，在镜像生成过程中会被后续的`RUN`指令使用，在镜像启动的容器中也会存在，不会像`ARG`那样。

语法：

```dockerfile
ENV k1 v1

ENV K2=V2 K3=V3
```

示例：

```dockerfile
# \ 代表换行
ENV username=jiang_wei \
    password=root \
    host=localhost \
    port=3306 \
    database=test
```

同样，为了减少镜像层数，应该使用少的`ENV`声明。

指定的环境变量可以被运行时指定的覆盖，比如：

```dockerfile
docker run mysql -e password=1 -e username=2
```

#### ENTRYPOINT

指定容器启动时最先执行的命令，也是入口命令。

语法：

```dockerfile
# exec调用执行
ENTRYPOINT ["executable","param1","param2"]

# shell中执行
ENTRYPOINT command param1 param2
```

每个dockerfile只能有一个该指令，当存在多个时，以最后一条为准。

运行时，也可被`--entrypoint`参数覆盖，比如：

```dockerfile
docker run --entrypoint ls
```

该命令和`CMD`有着对比，详细看后面。

#### VOLUME

创建一个数据卷挂载点。

示例：

```dockerfile
VOLUME ["/data"]
VOLUME ["/path1","/path2"]
VOLUME /var/log
VOLUME /var/db /var/nginx
```

注意：数据卷也有多种，有容器运行时指定数据卷或者数据卷容器等。

这个只是其中一种，通过此方式创建的数据卷挂载点，并不友好。

它只是会在容器运行时，把容器的挂载卷目录挂到宿主机上的一个随机目录，我们无法指定指定主机上对应的目录。况且如果容器销毁了，重新启动一个容器的时候，会重新挂载随机目录，没多大意义。当然，容器停止再次启动时，还是会用已经挂到宿主机上的卷。

#### USER

指定运行容器时的用户名或uid，后续的RUN等指令也会使用指定的用户身份。

示例：

```dockerfile
USER postgres

USER filebeat
```

#### WORKDIR

设置工作目录，对后续的`RUN CMD ENTRYPOINT COPY ADDs`生效，如果此目录不存在就会创建。

示例：

```dockerfile
WORKDIR /home

WORKDIR /filebeat
```

为避免出错，推荐后面指定的是绝对路径。

#### ONBUILD

这个指定只对当前镜像的子镜像生效，就是以该镜像为基础镜像的其他镜像，构建的时候，会执行此命令。

比如，当前A镜像的dockerfile：

```dockerfile
ONBUILD RUN ls
```

这个命令在A镜像构建过程和启动A镜像的一个容器时并不会执行。

在B镜像的dockerfile：

```dockerfile
FROM A
```

此时，在构建B镜像时，因为基于了A镜像构建，而又声明了`ONBUILD`。会执行`ls`这个命令，隐式构建。

#### HEALTHCHECK

配置启动的容器如何进行健康检查。

语法：

```dockerfile
# 根据所执行命令的返回值为0来判断
HEALTHCHECK [OPTIONS] CMD command

# 禁止健康检查
HEALTHCHECK NONE

# 参数
--start-period=DURATION 默认0s：启动时间，如果指定这个参数， 则必须大于 0s ；为需要启动的容器提供了初始化的时间段， 在这个时间段内如果检查失败， 则不会记录失败次数。 如果在启动时间内成功执行了健康检查， 则容器将被视为已经启动， 如果在启动时间内再次出现检查失败， 则会记录失败次数。
--interval=duration 默认30s:经过多久检查一次
--timeout=dauration 默认30s：每次检查等待结果的超时设置
--retries=N 默认3：如果失败了，重试的次数才最终确定失败
```

示例：

```dockerfile
HEALTHCHECK --start-period=20s \
    CMD curl -f http://localhost:8228/health || exit 1、
```

## 创建镜像

# cmd vs entrypoint

# 优化dockerfile