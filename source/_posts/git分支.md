---
title: git分支
date: 2020-06-21 09:02:01
categories: Git
keywords: Git分支
description: Git分支
---

## 分支

分支就是一个指针，跟随者最新提交。
![](./uploads/git/git分支.png)

## 查看分支

**查看本地分支：**

```bash
$ git branch
* master
```

**查看远端仓库分支：**

```bash
$ git branch -a
* hexo
  master
  remotes/origin/HEAD -> origin/hexo
  remotes/origin/dependabot/npm_and_yarn/acorn-6.4.1
  remotes/origin/dependabot/npm_and_yarn/https-proxy-agent-2.2.4
  remotes/origin/hexo
  remotes/origin/master
```

**查看每个分支的最后一次提交：**

```bash
 jw199@DESKTOP-2OG3D2D MINGW64 /c/my_code/git_study (b2)
$ git branch -v
* b2     86a66e5 1.txt
  master 86a66e5 1.txt
```

## 创建分支

**基于当前最后一次提交创建：**

```bash
$ git branch b1

$ git branch
  b1
* master
```

**指定基于某个提交创建分支：**

```bash
jw199@DESKTOP-2OG3D2D MINGW64 /c/my_code/git_study (master)
$ git log --oneline
2137bd7 (HEAD -> master) 3.txt
7c5ea26 2.txt
86a66e5 (b1) 1.txt
8502169 msg

# 基于2.txt这个提交对象来创建b2分支
jw199@DESKTOP-2OG3D2D MINGW64 /c/my_code/git_study (master)
$ git branch b2 7c5ea26

# 成功切换，可以看到b2的最后一次提交未2.txt
jw199@DESKTOP-2OG3D2D MINGW64 /c/my_code/git_study (master)
$ git branch -v
  b1     86a66e5 1.txt
  b2     7c5ea26 2.txt
* master 2137bd7 3.txt

```

## 切换分支

```bash
jw199@DESKTOP-2OG3D2D MINGW64 /c/my_code/git_study (master)
$ git checkout b1
Switched to branch 'b1'
-
jw199@DESKTOP-2OG3D2D MINGW64 /c/my_code/git_study (b1)
$ git branch
* b1
  master
```

还可以创建和切换一步完成

```bash
jw199@DESKTOP-2OG3D2D MINGW64 /c/my_code/git_study (b1)
$ git checkout -b b2
Switched to a new branch 'b2'

jw199@DESKTOP-2OG3D2D MINGW64 /c/my_code/git_study (b2)
$
```

**注意：**

切换分支时，尽量在切换之前保持当前分支是干净的，也就是该暂存的暂存，该提交的提交，最好是提交后再切换。

## 删除分支

**删除本地分支：**

> 删除一个分支时，不能处于这个分支，只能切换到另一个分支才能把它删除

```bash
jw199@DESKTOP-2OG3D2D MINGW64 /c/my_code/git_study (b2)
$ git branch
  b1
* b2
  master

jw199@DESKTOP-2OG3D2D MINGW64 /c/my_code/git_study (b2)
$ git branch -d b1
Deleted branch b1 (was 86a66e5).

```

**强制删除：**

> 当我们创建分支产生了提交信息时，但是还没有往主分支合并，删除时就会失败提示，可以强制删除。

```bash
jw199@DESKTOP-2OG3D2D MINGW64 /c/my_code/git_study (master)
$ git branch -d b2
error: The branch 'b2' is not fully merged.
If you are sure you want to delete it, run 'git branch -D b2'.

jw199@DESKTOP-2OG3D2D MINGW64 /c/my_code/git_study (master)
$ git branch -D b2
Deleted branch b2 (was ef5e3ea).
```

