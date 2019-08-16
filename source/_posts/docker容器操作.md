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

命令通过docker命令就可以查看帮助。命令多，但是用得少。好多都是基本不使用的命令。但是，我可以不用，你不能没有。

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

## 运行容器

我们常用`run`命令代替`create`和`start`。它可以跟好多参数。这些参数在`create`也一样可以用。

- `--add-host list`：在容器内添加一个主机名到ip地址的映射关系，通过`/etc/hosts`

- `-d, --detach `：是否在后台运行容器，默认为否
- `--dns list`：设置dns服务器
- `--dns-search list`：设置dns搜索域
- `-e, --env list`：指定容器内的环境变量
- `--env-file`：从宿主机文件中读取环境变量到容器内
- `--entrypoint string`：如果镜像存在入口命令时，覆盖为新的命令
- `--expose list`：指定容器会暴露出来的端口或端口范围
- `-h`：指定容器内的主机名
- `-i, --interactive`：保持标准输入打开，默认为false
- `-t `：是否分配一个为终端。默认false，通常`-it`连用
- `--link list`：连接到其他容器，比如：`--link kibana=kibana-host`，`kibana`可以是容器名也可以是容器名称。之后，本容器就可以通过`kibana-host`来访问`kibana`容器了。=
- `--name`：为容器指定一个别名。可以通过别名和容器id操作容器
- `--network string`：指定容器网络模式，包括bridge、none、其他容器内网络、host的网络、某个现有网络。默认default
- `--p, --publish list`：指定如何映射到宿主机端口，如：`-p 8000:80`。把容器的80端口映射到主机的8000端口
- `--restart string`：指定容器的重启策略。包括`no、on-faile、always、unless-stopped`等
- `--rm`：容器退出后自动删除，不能跟`-d`同时使用，因为`-d`代表是后台运行
- `-v, --volume`：挂载主机上的文件到容器内
- `-w, --workdir`：容器内的默认工作目录
- `--privileged `：是否给执行命令以最高权限，默认为false
- `-u，--user`：指定用户身份执行容器内的命令。也就是指定什么用户登录容器

省略的还有一些和cpu、内存、权限、安全相关的参数。实际我们也不会使用这些命令来控制容器。会有编排工具，比如小的有`docker-compose`、`docker swarm`，大的有`k8s`。但是你还是要懂。。。即使是有管理工具，yaml文件里的各种参数用的参数和指令也都离不开上面这些。

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

### 查看所有容器

```dockerfile
root@jw-ubuntu01:~# docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
13035c87a226        psql:v2             "docker-entrypoint.s…"   24 hours ago        Up 24 hours         0.0.0.0:5432->5432/tcp   anchore_anchore-db_1
```

### 查看容器详情

```dockerfile
root@jw-ubuntu01:~# docker container inspect --help

Usage:	docker container inspect [OPTIONS] CONTAINER [CONTAINER...]

Display detailed information on one or more containers

Options:
  -f, --format string   Format the output using the given Go template
  -s, --size            Display total file sizes
```

### 查看容器内进程

```dockerfile
root@jw-ubuntu01:~# docker container top --help

Usage:	docker container top CONTAINER [ps OPTIONS]

Display the running processes of a container
```

### 查看所有容器的运行状态

```dockerfile
root@jw-ubuntu01:~# docker stats --help

Usage:	docker stats [OPTIONS] [CONTAINER...]

Display a live stream of container(s) resource usage statistics

Options:
  -a, --all             Show all containers (default shows just running)
      --format string   Pretty-print images using a Go template
      --no-stream       Disable streaming stats and only pull the first result
      --no-trunc        Do not truncate output
```

```dockerfile
root@jw-ubuntu01:~# docker stats
CONTAINER ID        NAME                   CPU %               MEM USAGE / LIMIT    MEM %               NET I/O             BLOCK I/O           PIDS
13035c87a226        anchore_anchore-db_1   2.48%               36.79MiB / 5.81GiB   0.62%               3.27GB / 2.58GB     242MB / 4.38GB      26
```

## 进入容器

对于正在运行的容器，可以使用命令进入到容器里面，常用的是`exec`命令。另一个`attch`很少用。

```linux
root@jw-ubuntu01:~# docker exec --help

Usage:	docker exec [OPTIONS] CONTAINER COMMAND [ARG...]

Run a command in a running container

Options:
  -d, --detach               Detached mode: run command in the background
      --detach-keys string   Override the key sequence for detaching a container
  -e, --env list             Set environment variables
  -i, --interactive          Keep STDIN open even if not attached
      --privileged           Give extended privileges to the command
  -t, --tty                  Allocate a pseudo-TTY
  -u, --user string          Username or UID (format: <name|uid>[:<group|gid>])
  -w, --workdir string       Working directory inside the container
```

- `-d`：在容器中后台执行命令
- `-e`：指定环境变量列表
- `-i，--interactive=true|false`：打开标准输入接受用户输入命令，默认为false
- `-t`：分配伪终端，通常与`-i`结合使用，`-it`
- `--privileged `：是否给执行命令以最高权限，默认为false
- `-u，--user`：指定用户身份执行容器内的命令。也就是指定什么用户登录容器

```dockerfile
root@jw-ubuntu01:~# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
13035c87a226        psql:v2             "docker-entrypoint.s…"   25 hours ago        Up 25 hours         0.0.0.0:5432->5432/tcp   anchore_anchore-db_1
root@jw-ubuntu01:~# docker exec -it -u postgres -e  a=1  -e b=2  1303   bash
bash-5.0$ echo ${a}
1
bash-5.0$ whoami
postgres
```

## 停止容器

### 暂停容器

暂停一个或多个容器中的所有进程。

```linux
root@jw-ubuntu01:~# docker pause --help

Usage:	docker pause CONTAINER [CONTAINER...]

Pause all processes within one or more containers
```

### 终止容器

```linux
root@jw-ubuntu01:~# docker stop --help

Usage:	docker stop [OPTIONS] CONTAINER [CONTAINER...]

Stop one or more running containers

Options:
  -t, --time int   Seconds to wait for stop before killing it (default 10)
```

## 删除容器

```linux
root@jw-ubuntu01:~# docker rm --help

Usage:	docker rm [OPTIONS] CONTAINER [CONTAINER...]

Remove one or more containers

Options:
  -f, --force     Force the removal of a running container (uses SIGKILL)
  -l, --link      Remove the specified link
  -v, --volumes   Remove the volumes associated with the container
```

对于多个处于停止状态的容器，可以使用`docker container prune -f`来自动清除所有。

## 导入和导出容器

### 导出

导出容器是指。导出一个已经创建好的容器到一个文件，不管这个容器此时是否处于运行状态。

```linux
root@jw-ubuntu01:~# docker export --help

Usage:	docker export [OPTIONS] CONTAINER

Export a container's filesystem as a tar archive

Options:
  -o, --output string   Write to a file, instead of STDOUT
```

### 导入

使用该命令导入变成镜像。

```linux
root@jw-ubuntu01:~# docker import --help

Usage:	docker import [OPTIONS] file|URL|- [REPOSITORY[:TAG]]

Import the contents from a tarball to create a filesystem image

Options:
  -c, --change list      Apply Dockerfile instruction to the created image
  -m, --message string   Set commit message for imported image
```

**注意：**

- `docker load `：将保存完整记录，体积更大。
- `docker import`：丢弃所有的历史记录和元数据信息。仅保留容器当时的快照状态，导入时还可以指定标签等元数据信息。

反正我很少用到`import`，大多数都是直接`load`。

## 其他命令 

### 容器与宿主机的文件复制

在工作中，经常进入到一个容器里面操作和测试。但是里面文件操作必定有局限性，这时候可以用命令复制文件进去。

```linux
root@jw-ubuntu01:~# docker cp --help

Usage:	docker cp [OPTIONS] CONTAINER:SRC_PATH DEST_PATH|-
	docker cp [OPTIONS] SRC_PATH|- CONTAINER:DEST_PATH

Copy files/folders between a container and the local filesystem

Options:
  -a, --archive       Archive mode (copy all uid/gid information)
  -L, --follow-link   Always follow symbol link in SRC_PATH
```

```dockerfile
root@jw-ubuntu01:~# docker exec -it 1303 ls /
bin                         proc
dev                         root
docker-entrypoint-initdb.d  run
docker-entrypoint.sh        sbin
etc                         srv
home                        sys
lib                         tmp
media                       usr
mnt                         var
opt
root@jw-ubuntu01:~# docker cp ./test.py 1303:/
root@jw-ubuntu01:~# docker exec -it 1303 ls /
bin                         proc
dev                         root
docker-entrypoint-initdb.d  run
docker-entrypoint.sh        sbin
etc                         srv
home                        sys
lib                         test.py
media                       tmp
mnt                         usr
opt                         var
```

### 查看变更

查看容器内的数据修改

```dockerfile
root@jw-ubuntu01:~# docker diff --help

Usage:	docker diff CONTAINER

Inspect changes to files or directories on a container's filesystem
```

### 查看端口映射

```dockerfile
root@jw-ubuntu01:~# docker port --help

Usage:	docker port CONTAINER [PRIVATE_PORT[/PROTO]]

List port mappings or a specific mapping for the container
```

```dockerfile
root@jw-ubuntu01:~# docker port anchore_anchore-db_1 
5432/tcp -> 0.0.0.0:5432
```

### 更新配置

更新容器运行时的一些配置，主要是限制一些资源份额。比如说：cpu调度、内存分配、重启策略等。

```dockerfile
root@jw-ubuntu01:~# docker update --help

Usage:	docker update [OPTIONS] CONTAINER [CONTAINER...]

Update configuration of one or more containers

Options:
      --blkio-weight uint16        Block IO (relative weight), between 10 and 1000, or 0 to disable (default 0)
      --cpu-period int             Limit CPU CFS (Completely Fair Scheduler) period
      --cpu-quota int              Limit CPU CFS (Completely Fair Scheduler) quota
      --cpu-rt-period int          Limit the CPU real-time period in microseconds
      --cpu-rt-runtime int         Limit the CPU real-time runtime in microseconds
  -c, --cpu-shares int             CPU shares (relative weight)
      --cpus decimal               Number of CPUs
      --cpuset-cpus string         CPUs in which to allow execution (0-3, 0,1)
      --cpuset-mems string         MEMs in which to allow execution (0-3, 0,1)
      --kernel-memory bytes        Kernel memory limit
  -m, --memory bytes               Memory limit
      --memory-reservation bytes   Memory soft limit
      --memory-swap bytes          Swap limit equal to memory plus swap: '-1' to enable unlimited swap
      --restart string             Restart policy to apply when a container exits
```

