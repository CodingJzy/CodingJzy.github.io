---
title: git初始化
date: 2020-04-05 15:47:17
categories: Git
keywords: git初始化
description: git初始化
---

# git初始化

## 查看版本

```bash
$ git --version
git version 2.18.0.windows.1
```

## 创建版本库及第一次提交

在开始git之旅之前，需要设置一下git的环境变量，这个设置是一次性的工作。也就是说，这些设置会在全局文件：`~/.gitconfig`或者`/etc/gitconfig`中做永久的记录。

### 用户名和邮件地址

配置提交时作为提交者的用户名和邮件地址，这里`--global`是设置全局。也可以针对不同项目做不同设置：`--local`。

```bash
# 配置系统(所有用户)
$ git config --system user.name "CodingJzy"
$ git config --system user.email "jw19961019@gmail.com"

# 配置全局
$ git config --global user.name "CodingJzy"
$ git config --global user.email "jw19961019@gmail.com"

# 配置当前
$ git config --local user.name "jiang_wei"
$ git config --local user.email "jiang_wei@topsec.com.cm"

# 查看全局配置
$ git config --global  --list |grep user
user.name=CodingJzy
user.email=jw19961019@gmail.com

# 查看当前配置
$ git config --local --list|grep user
user.name=jiang_wei
user.email=jiang_wei@topsec.com.cm
```

### 设置别名

可以和linux命令一样，取一些别名，方便敲。

```bash
# 设置
root@wy:~# sudo git config --system alias.br branch
root@wy:~# sudo git config --system alias.ci commit
root@wy:~# sudo git config --system alias.co checkout
root@wy:~# sudo git config --system alias.st status

# 测试
$ git br
  master
* pubsub
```

### 初始化

首先建立一个新的工作目录，进入该目录后，执行`git init `创建版本库。

```bash
jiangziya@jiang_wei MINGW64 /d/github
$ mkdir demo

jiangziya@jiang_wei MINGW64 /d/github
$ cd demo/

jiangziya@jiang_wei MINGW64 /d/github/demo
$ ls

jiangziya@jiang_wei MINGW64 /d/github/demo
$ git init
Initialized empty Git repository in D:/github/demo/.git/

jiangziya@jiang_wei MINGW64 /d/github/demo (master)
$ ls -a
./  ../  .git/
```

实际上，也可以一步到位。直接`git init dir`，自动完成目录的创建

```bash
jiangziya@jiang_wei MINGW64 /d/github
$ git init demo1
Initialized empty Git repository in D:/github/demo1/.git/

jiangziya@jiang_wei MINGW64 /d/github
$ cd demo1 && ls -a
./  ../  .git/
```

上面的两个操作中，都可以看到创建了一个隐藏文件夹`.git`。这个隐藏的目录就是git版本库(又叫仓库，`repository`)。

`demo`所在的目录被称为工作区。目前工作区除了隐藏文件外，空无一物。

下面为工作区加点料：创建一个hello-git.txt。文件内容为`hello git`。

```bash
$ echo "hello git" > hello-git.txt

jiangziya@jiang_wei MINGW64 /d/github/demo (master)
$ cat -n hello-git.txt
     1  hello git
```

为了将这个新建的文件添加到版本库，需要执行`git add`命令。

```bash
jiangziya@jiang_wei MINGW64 /d/github/demo (master)
$ git add hello-git.txt

```

切记，到这里还没有完，数据只是从工作区添加到了缓存区，并没有添加到本地仓库。还要进行`git commit`一下。

```bash
jiangziya@jiang_wei MINGW64 /d/github/demo (master)
# -m 代表提交的信息，就算不加这个参数，直接commit也会弹出一个窗口来编写提交信息
$ git commit -m "git init "
[master (root-commit) 727bc99] git init
 1 file changed, 1 insertion(+)
 create mode 100644 hello-git.txt
```

**总结：**

- 工作区
- 缓存区
- 本地仓库
- 远程仓库