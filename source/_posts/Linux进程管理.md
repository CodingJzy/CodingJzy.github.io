---
title: Linux进程管理
date: 2019-08-30 08:44:47
categories: Linux
keywords: Linux进程管理
description: Linux进程管理
---

# 进程管理

## 进程的观察

### ps

显示某个时间点的进程运作情况

- `ps aux`：观察系统所有的进程数据
- `ps -lA`：观察系统所有的进程数据
- `ps axjf`：连同部分进程数

### top

**动态观察进程的变化：**

- `top`：预设5秒来更新进程的画面
- `top -d 1`：设置更新进程信息的时间为1秒
- `top -d 1 -p 111`：只显示pid为111的进程动态信息

**top执行过程中常用指令：**

- `P`：以CPU资源使用率排序显示
- `M`：以内存使用率排序
- `N`：以PID来排序
- `T`：以该进程使用的cpu累积时间排序
- `q`：退出top动态刷新的界面

**相关信息：**

```bash
top - 14:08:56 up 15 days,  2:56,  1 user,  load average: 0.05, 0.05, 0.05
Tasks: 164 total,   1 running, 163 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.3 us,  0.5 sy,  0.0 ni, 99.2 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem :  3881276 total,  2925316 free,   157624 used,   798336 buff/cache
KiB Swap:  2097148 total,  2097148 free,        0 used.  3209712 avail Mem 

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND                                       
 1534 root      20   0   10.0g  28460   8464 S   1.0  0.7 253:05.33 etcd 
```

- 第一行(top)
  - 目前时间，14:08:56
  - 开机到目前为止所经过的时间，15 days
  - 已经登录系统的用户人数：1 个 user
  - 工作负载，越小代表系统越闲置，若高于1就得注意系统进程是否太过繁复
- 第二行(Tasks)
  - 显示的是目前进程的总量与个别进程在什么状态，需要注意的是最后一个，如果不是0，那就好好看看那个process变成了僵尸进程吧
- 第三行(%Cpus)
  - 显示的是CPU的整体负载，需要注意的是wa。通常这个代表I/Owait，通常系统变慢是大量I/O产生的问题。如果是多核心的设备，可以按下1来切换不同cpu的负载率。
- 第四行与第五行
  - 表示目前的物理内存和虚拟内存的使用情况，swap尽量要使用，被用的多的话，表示系统物理内存实在不足
- 第六行(每个进程使用的资源情况)
  - PID：每个进程的id号
  - USER：该进程的所属使用者
  - PR：进程的优先执行顺序，越小越早被执行
  - NI：越小越早被执行

**注意：**

top预设使用cpu使用率作为排序的重点，如果想要更换为内存使用率排序，则可以按字母键`M`。如果要恢复按`P`。如果想离开top，按`q`。

## 进程的管理

进程之间是可以相互控制的，可以关闭、重启。实际上是通过给它一个信号去告知该进程做什么。

**主要信号：**

| 数字代号 | 名称    | 内容                                                         |
| -------- | ------- | ------------------------------------------------------------ |
| 1        | sighup  | 启动被终止的进程，可以让该进程重新读取自己的配置文件，类似重新启动 |
| 9        | sigkill | 代表强制中端一个进程的进行，如果该进程进行到一半，就可能有半产品产生，比如说vim，会生成.swp隐藏文件 |
| 15       | sigterm | 以正常的结束进程来终止该进程，但是如果这个进程本身已经发生问题，就无法通过正常的方法终止，也就是这个信号是无效的 |

### kill

**格式：**`kill -signal PID`

**比如：**`kill -9 1111`：强制终止pid为1111的进程

### killall

由于kill后面必须跟PIDD，所以通常会结合ps指令使用。我们也可以不用PID，直接下达名称

**格式：**`killall -signal name`

**比如：**

- `killall -1 rsyslogd`：给rsylogd这个指令启动的PID一个代号为1的信号
- `killadd -9 httpd`：强制终止以httpd启动的所有进程

## 系统资源的观察

除了系统的进程之外，我们还必须就系统的一些资源来进行检查。

### free

观察内存使用情况

```bash
[root@jw-etcd01 jw]# free
              total        used        free      shared  buff/cache   available
Mem:        3881276      161628     2961180      178876      758468     3245956
Swap:       2097148           0     2097148
[root@jw-etcd01 jw]# free -m
              total        used        free      shared  buff/cache   available
Mem:           3790         157        2891         174         740        3169
Swap:          2047           0        2047
```

仔细看看，前面的好理解，第一行是物理内存使用情况，第二行是虚拟内存使用情况。我还有2891mb物理内存可以用。后面的`shared buff/cache`是在已被使用的量中，用来作为缓冲及快取的量，是缓存。在系统比较忙碌时，可以被释放出来而继续利用，因此后面有个`available（可用的）数值。

我什么也没做，但是有740mb缓存。其实，系统把这些文件暂时存储下来，目的为了下次运作可以更快速取出之意。未来系统要用到该文件时，就可以直接在内存中搜寻取出，而不需要重新读取硬盘，速度会加快很多。

### uname

查阅系统与核心相关信息

```bash
[root@jw-etcd01 jw]# uname --help
用法：uname [选项]...
输出一组系统信息。如果不跟随选项，则视为只附加-s 选项。

  -a, --all			以如下次序输出所有信息。其中若-p 和
				-i 的探测结果不可知则被省略：
  -s, --kernel-name		输出内核名称
  -n, --nodename		输出网络节点上的主机名
  -r, --kernel-release		输出内核发行号
  -v, --kernel-version		输出内核版本
  -m, --machine		输出主机的硬件架构名称,例如i686、x86_64、sw_64
  -p, --processor		输出处理器类型或"unknown"
  -i, --hardware-platform	输出硬件平台或"unknown"
  -o, --operating-system	输出操作系统名称
      --help		显示此帮助信息并退出
      --version		显示版本信息并退出
```

