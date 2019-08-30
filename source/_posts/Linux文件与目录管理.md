---
title: Linux文件与目录管理
date: 2019-08-30 07:34:19
categories: Linux
keywords: 目录与路径、目录浏览、文件的操作、文件内容查看
description: 目录与路径、目录浏览、文件的操作、文件内容查看
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

#### 文件夹

`mkdir`：建立一个新的目录

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

### 移动、重命名

### 删除

#### 文件

#### 文件夹

- `rmdir` ：只能删除一个空的目录。对于该目录下有文件内容的删除不了。

- `rm -rf /a/b/c`：r表示递归删除，f表示强制且不提示

### 取文件路径

## 文件内容查看

### 直接检视文件内容

### 可翻页检视

### 资料拮取

## 文件搜寻





