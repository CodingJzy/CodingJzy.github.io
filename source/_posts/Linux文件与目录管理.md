---
title: Linux文件与目录管理
date: 2019-08-30 15:20:19
categories: Linux
keywords: 目录与路径、目录浏览、文件的操作、文件内容查看、文件查找
description: 目录与路径、目录浏览、文件的操作、文件内容查看、文件查找
---

# Linux文件与目录管理

## 目录与路径

### 相对路径与绝对路径

- 绝对路径：一定由根目录`/`写起，例如：`/home/jiangwei`、`/etc/docker`
- 相对路径：相对于当前路径，一般有`./`,`../`等，例如：`./a/b/c`，`../docker/config`

注意：绝对路径的写法虽然长了点，但是一定不会出问题，相对路径虽然短点，但是可能存在问题。

### 目录的相关操作

切换目录的指令是`cd`。比较特殊的目录：

```bash
# 当前目录
.

# 上一层目录
..

# 上一个工作目录，可快速切换到执行切换到当前目录下的目录
-

# 当前登录用户所在的家目录
～
```

#### cd

`cd`表示切换目录，后面跟相对路径或绝对路径

```bash
# 切换到当前用户的家目录
jiang_wei@master01:/etc/docker$ cd ~
jiang_wei@master01:~$ 

# 切换上一层目录
jiang_wei@master01:~$ cd ..
jiang_wei@master01:/home$ 

# 切换到家目录
jiang_wei@master01:/home$ cd
jiang_wei@master01:~$

# 切换到绝对路径
jiang_wei@master01:/etc/docker$ cd /home/jiang_wei/code/gin/
jiang_wei@master01:~/code/gin$ 

# 切换到上一个工作目录
jiang_wei@master01:~/code/gin$ cd -
/etc/docker
jiang_wei@master01:/etc/docker$ cd -
/home/jiang_wei/code/gin
```

#### pwd

显示当前所在的目录

```bash
jiang_wei@master01:~/code/etcd$ pwd
/home/jiang_wei/code/etcd

jiang_wei@master01:~/code/etcd$ cd ../docker/anchore/
jiang_wei@master01:~/code/docker/anchore$ pwd
/home/jiang_wei/code/docker/anchore
```

## 目录浏览

### ls

查看目录的相关信息

```bash
# 查看当前目录
root@master01:~# ls
模板

# 查看隐藏文件，以.开头的文件或文件夹
root@master01:~# ls -a
.   .bash_history  .cache   .dbus   .ipython  .node_repl_history  .profile	   .ssh  .viminfo
..  .bashrc	   .config  .gconf  .local    .npm		  .python_history  .vim  模板

# 查看形式以列的方式显示文件与文件夹的其他信息
root@master01:~# ls -l
总用量 4
drwxr-xr-x 2 root root 4096 7月  19 22:42 模板

# 后面的选项可以相互组合
root@master01:~# ls -al
总用量 76
drwx------ 12 root root  4096 8月  10 08:22 .
drwxr-xr-x 20 root root  4096 8月  10 09:18 ..
-rw-------  1 root root  2608 8月  11 17:30 .bash_history
-rw-r--r--  1 root root   570 6月  22 19:08 .bashrc
drwx------  6 root root  4096 6月  30 10:49 .cache
drwxr-xr-x  5 root root  4096 7月  20 09:52 .config
drwx------  3 root root  4096 6月  22 11:28 .dbus
drwx------  2 root root  4096 7月  28 16:33 .gconf
drwxr-xr-x  5 root root  4096 6月  30 10:50 .ipython
drwxr-xr-x  3 root root  4096 6月  29 21:28 .local
-rw-------  1 root root     0 7月  20 09:43 .node_repl_history
drwxr-xr-x  5 root root  4096 7月  20 10:47 .npm
-rw-r--r--  1 root root   140 6月  22 19:08 .profile
-rw-------  1 root root     7 6月  30 10:48 .python_history
drwx------  2 root root  4096 6月  26 22:28 .ssh
drwxr-xr-x  2 root root  4096 7月   7 10:37 .vim
-rw-------  1 root root 11413 8月  10 08:22 .viminfo
drwxr-xr-x  2 root root  4096 7月  19 22:42 模板

# 以人性化的方式显示文件与文件夹相关信息，比如文件大小
root@master01:~# ls -alh
总用量 76K
drwx------ 12 root root 4.0K 8月  10 08:22 .
drwxr-xr-x 20 root root 4.0K 8月  10 09:18 ..
-rw-------  1 root root 2.6K 8月  11 17:30 .bash_history
-rw-r--r--  1 root root  570 6月  22 19:08 .bashrc
drwx------  6 root root 4.0K 6月  30 10:49 .cache
drwxr-xr-x  5 root root 4.0K 7月  20 09:52 .config
drwx------  3 root root 4.0K 6月  22 11:28 .dbus
drwx------  2 root root 4.0K 7月  28 16:33 .gconf
drwxr-xr-x  5 root root 4.0K 6月  30 10:50 .ipython
drwxr-xr-x  3 root root 4.0K 6月  29 21:28 .local
-rw-------  1 root root    0 7月  20 09:43 .node_repl_history
drwxr-xr-x  5 root root 4.0K 7月  20 10:47 .npm
-rw-r--r--  1 root root  140 6月  22 19:08 .profile
-rw-------  1 root root    7 6月  30 10:48 .python_history
drwx------  2 root root 4.0K 6月  26 22:28 .ssh
drwxr-xr-x  2 root root 4.0K 7月   7 10:37 .vim
-rw-------  1 root root  12K 8月  10 08:22 .viminfo
drwxr-xr-x  2 root root 4.0K 7月  19 22:42 模板
```

## 文件的操作

### 创建

#### 文件

`touch`：创建一个文件

```bash
# 创建一个普通文件
[root@jw-etcd01 test]# touch 1.py
[root@jw-etcd01 test]# ls
1.py

# 创建多个文件
[root@jw-etcd01 test]# touch {2..10}.py
[root@jw-etcd01 test]# ls
10.py  1.py  2.py  3.py  4.py  5.py  6.py  7.py  8.py  9.py
```

#### 文件夹

`mkdir`：创建一个新的目录

```bash
# 建立新的目录
jiang_wei@master01:~/test$ mkdir a

# 建立多层目录，一层一层创建很类
jiang_wei@master01:~/test$ mkdir -p a/b/c/d/e/f/g
# 树状形式显示当前目录下的层级
jiang_wei@master01:~/test$ tree
.
└── a
    └── b
        └── c
            └── d
                └── e
                    └── f
                        └── g

7 directories, 0 files
```

另外：还可以加`-m`选项来为目录文件直接设定权限，不需要看预设权限`umask`的脸色。

### 复制

`cp`：拷贝

```bash
# 拷贝文件，*代表所有，但是只能拷贝文件
[root@jw-etcd01 ~]# cp test/* test1/
cp: 略过目录"test/t1"
[root@jw-etcd01 ~]# ls test1/
10.py  1.py  2.py  3.py  4.py  5.py  6.py  7.py  8.py  9.py
[root@jw-etcd01 ~]# ls test
10.py  1.py  2.py  3.py  4.py  5.py  6.py  7.py  8.py  9.py  t1

# 拷贝文件和文件夹，递归拷贝
[root@jw-etcd01 ~]# cp -r test/* test1/
[root@jw-etcd01 ~]# ls test1
10.py  1.py  2.py  3.py  4.py  5.py  6.py  7.py  8.py  9.py  t1
```

### 移动、重命名

```bash
[root@jw-etcd01 ~]# mkdir -p  a/b/c/d
[root@jw-etcd01 ~]# tree a
a
└── b
    └── c
        └── d

3 directories, 0 files
[root@jw-etcd01 ~]# mv a/b/c/ a/b/c1
[root@jw-etcd01 ~]# tree a
a
└── b
    └── c1
        └── d

3 directories, 0 files
```

### 删除

#### 文件

- `rm -rf /home/test.go`

#### 文件夹

- `rmdir` ：只能删除一个空的目录。对于该目录下有文件内容的删除不了。

- `rm -rf /a/b/c`：r表示递归删除，f表示强制且不提示

### 取文件路径

```bash
# 获取路径最后的档名
[root@jw-etcd01 ~]# basename /etc/etcd/conf-discovery
conf-discovery

# 获取目录名
[root@jw-etcd01 ~]# dirname /etc/etcd/conf-discovery
/etc/etcd
```

## 文件内容查看

### cat

`cat`：直接从头开始查看文件内容

```bash
# 查看所有内容
[root@jw-etcd01 ~]# cat 1.py 
print(1)
print(2)
print(3)
print(4)
print(5)
print(6)
print(7)
print(8)
print(9)
print(10)
print(11)
print(12)
print(13)

print(14)
print(15)


print(16)
print(17)

# 显示行号
[root@jw-etcd01 ~]# cat -n 1.py 
     1	print(1)
     2	print(2)
     3	print(3)
     4	print(4)
     5	print(5)
     6	print(6)
     7	print(7)
     8	print(8)
     9	print(9)
    10	print(10)
    11	print(11)
    12	print(12)
    13	print(13)
    14	
    15	print(14)
    16	print(15)
    17	
    18	
    19	print(16)
    20	print(17)

# 显示行号，但是空行本身不显示
[root@jw-etcd01 ~]# cat -b 1.py 
     1	print(1)
     2	print(2)
     3	print(3)
     4	print(4)
     5	print(5)
     6	print(6)
     7	print(7)
     8	print(8)
     9	print(9)
    10	print(10)
    11	print(11)
    12	print(12)
    13	print(13)

    14	print(14)
    15	print(15)


    16	print(16)
    17	print(17)
```

### tac

与`cat`相反，从后面向前输出。

```bash
[root@jw-etcd01 ~]# tac  2.py 
5
4
3
2
1
```

### nl

`nl`：显示行号

```bash
# 默认去除本身的空行，其实是加了参数 -bt
[root@jw-etcd01 ~]# nl 3.py 
     1	一
     2	二
       
     3	三
       
     4	四

# 显示空白行本身
[root@jw-etcd01 ~]# nl -ba  3.py 
     1	一
     2	二
     3	
     4	三
     5	
     6	四
```

### more

当文件内容过多时，可以使用`more`命令。一页一页看。执行命令之后，可以按`space`键向下翻页，按`Enter`向下翻一行。`:f`显示当前内容的行数，最后按`q`或者`b`退出。

### less

`more`命令只能往下翻着看，而`less`则比它更灵活。可以自由上下。其余退出和操作和`more`类似。

### head

顾名思义，头的意思，代表取出前面几行。

默认显示前10行，加参数`-n100` or `-n 100`表示取出前面100行。`n`可省略。

如果不知道文件一共有多少行，只想显示最后100行前面的内容，可以在数字前加负号，比如：`head -n -100 1.py` 。

### tail

顾名思义，尾巴的意思，代表取出后面几行。

默认显示后10行，用法和`head`一样。

如果不知道文件一共有多少行。只想显示前面100行后面的数据，可以把数字前面加号，比如：`tail -n +100 1.py` 。

另外，它还有个特别的功能，就是滚动输出，常用语日志查看。`tail -f /log/nginx.log`。按`ctrl + c`退出。

## 文件搜寻

### which

脚本文件的搜寻。在终端的输入的一些命令。比如`ls、python、etcdctl、ping、ifocnfig`等。可以通过`which`查出它们的路径。

```bash
[root@jw-etcd01 ~]# which python
/usr/bin/python

[root@jw-etcd01 ~]# which etcd
/usr/local/etcd/etcd

[root@jw-etcd01 ~]# which ping
/usr/bin/ping

[root@jw-etcd01 ~]# which ifconfig
/usr/sbin/ifconfig

[root@jw-etcd01 ~]# which consul
/root/consul/consul

# 选项-a：将所有由 PATH 目录中可以找到的指令均列出，而不止第一个被找到的指令名称
# 有些也是找不到的，毕竟which只是根据找PATH所规范的目录，比如history。
```

### whereis

只找系统中某些特定目录底下的文件而已。

它主要针对一些`/bin/sbin`下的执行文件、`/usr/share/man`下的`man page`文件，速度很快。就是有些目录是找不到的。可以加`-l`查看到底查询了多少目录。

```bash
[root@jw-etcd01 ~]# whereis python
python: /usr/bin/python /usr/bin/python2.7 /usr/lib/python2.7 /usr/lib64/python2.7 /etc/python /usr/include/python2.7 /usr/share/man/man1/python.1.gz

[root@jw-etcd01 ~]# whereis etcd
etcd: /etc/etcd /usr/local/etcd /usr/local/etcd/etcd

[root@jw-etcd01 ~]# whereis consul
consul: /etc/consul /root/consul/consul /root/consul/consul.d
```

### find

最强大的就是它了，但是它是直接查询硬盘的数据，速度不理想。

最标准的用法就是`find / -name python`，从根目录开始查，耗时。

还有一些筛选，就是`/`换成只查找指定目录下的数据。

搜索关键词也支持正则匹配，比如`*.py`

指定筛选查找大小的文件。

```bash
[root@jw-etcd01 ~]# find /root -name "*.py"
/root/1.py
/root/2.py
/root/3.py

[root@jw-etcd01 ~]# find / -name  "python"
/etc/python
/usr/bin/python
/usr/share/gcc-4.8.2/python

[root@jw-etcd01 ~]# find / -size +100M
/proc/kcore
find: ‘/proc/3918/task/3918/fd/6’: 没有那个文件或目录
find: ‘/proc/3918/task/3918/fdinfo/6’: 没有那个文件或目录
find: ‘/proc/3918/fd/5’: 没有那个文件或目录
find: ‘/proc/3918/fdinfo/5’: 没有那个文件或目录
/sys/devices/pci0000:00/0000:00:0f.0/resource1_wc
/sys/devices/pci0000:00/0000:00:0f.0/resource1
/root/consul/consul
/usr/lib/locale/locale-archive
/home/consul
```





