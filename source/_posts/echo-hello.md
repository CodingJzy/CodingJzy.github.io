---
title: echo快速开始
date: 2019-07-30 15:49:29
categories: Go
keywords: echo下载与安装，echo编写hello-world
description: echo下载与安装，echo编写hello-world
---

# echo快速开始

## 下载

```go
# 创建echo_study文件夹
mkdir echo_study

# 进入
cd echo_study/

# 初始化当前文件夹，会创建go.mod文件夹
go mod init echo_study

# 查看初始化后的go.mod文件内容，此时并没有任何依赖
$ cat go.mod
module echo_study

go 1.12

# 添加相关模块下载的代理，防止墙了拉不到
export GOPROXY=https://goproxy.io

# go-get下载echo库
$ go get -u github.com/labstack/echo
go: finding github.com/labstack/echo v3.3.10+incompatible
go: downloading github.com/labstack/echo v3.3.10+incompatible
go: extracting github.com/labstack/echo v3.3.10+incompatible
go: finding github.com/labstack/gommon v0.2.9
go: downloading github.com/labstack/gommon v0.2.9
go: finding golang.org/x/crypto latest
go: extracting github.com/labstack/gommon v0.2.9
go: downloading golang.org/x/crypto v0.0.0-20190701094942-4def268fd1a4
go: extracting golang.org/x/crypto v0.0.0-20190701094942-4def268fd1a4
go: finding golang.org/x/sys v0.0.0-20190412213103-97732733099d
go: finding golang.org/x/net v0.0.0-20190404232315-eb5bcb51f2a3
go: finding golang.org/x/sys v0.0.0-20190602015325-4c4f7f33c9ed
go: finding github.com/mattn/go-colorable v0.1.2
go: finding github.com/mattn/go-isatty v0.0.8
go: finding github.com/stretchr/objx v0.2.0
go: finding github.com/valyala/fasttemplate v1.0.1
go: finding github.com/stretchr/testify v1.3.0
go: finding golang.org/x/text v0.3.0
go: finding golang.org/x/crypto v0.0.0-20190308221718-c2843e01d9a2
go: finding golang.org/x/sys v0.0.0-20190222072716-a9d3bda3a223
go: finding github.com/pmezard/go-difflib v1.0.0
go: finding github.com/davecgh/go-spew v1.1.0
go: finding github.com/stretchr/objx v0.1.0
go: finding github.com/davecgh/go-spew v1.1.1
go: finding github.com/valyala/bytebufferpool v1.0.0
go: finding golang.org/x/sys v0.0.0-20190215142949-d0b11bdaac8a
go: downloading github.com/mattn/go-colorable v0.1.2
go: downloading github.com/valyala/fasttemplate v1.0.1
go: downloading github.com/mattn/go-isatty v0.0.8
go: downloading golang.org/x/net v0.0.0-20190404232315-eb5bcb51f2a3
go: extracting github.com/mattn/go-colorable v0.1.2
go: extracting github.com/valyala/fasttemplate v1.0.1
go: extracting github.com/mattn/go-isatty v0.0.8
go: downloading github.com/valyala/bytebufferpool v1.0.0
go: extracting github.com/valyala/bytebufferpool v1.0.0
go: extracting golang.org/x/net v0.0.0-20190404232315-eb5bcb51f2a3
go: downloading golang.org/x/text v0.3.0
go: extracting golang.org/x/text v0.3.0

# 下载完之后再次查看，可以看的自己添加了相关依赖
$ cat go.mod
module echo_study

go 1.12

require (
        github.com/labstack/echo v3.3.10+incompatible // indirect
        github.com/labstack/gommon v0.2.9 // indirect
        golang.org/x/crypto v0.0.0-20190701094942-4def268fd1a4 // indirect
)
```

## 编写代码

新建一个`main.go`文件：

```go
package main

import (
    "github.com/labstack/echo"
    "net/http"
)

func main() {
    // 实例化一个echo对象
    e := echo.New()
    // 为实例添加GET方法
    e.GET("/", func(c echo.Context) error {
        	// 返回状态码为200，字符串"hello world"
            return c.String(http.StatusOK, "hello world")
    })
    e.Logger.Fatal(e.Start(":1323"))

}
```

## 运行

在`main.go`文件夹下执行`go runserver main.go`

屏幕输出：

![](/uploads/echo/1.png)

打开浏览器，访问`本机ip:1323`，就可以看到屏幕打印`hello world`。

![](/uploads/echo/2.png)