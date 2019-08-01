---
title: echo-routing
date: 2019-07-30 17:12:34
categories: go web框架 Echo
keywords: echo的路由
description: echo的路由
---

# echo的路由

## 普通

```go
package main

import (
	"github.com/labstack/echo"
	"net/http"
)

// 定义一个函数
func routing(c echo.Context) error  {
	return c.String(http.StatusOK, "routing\n")
}

func main() {
	e := echo.New()
	e.GET("/routing", routing)
	e.Logger.Fatal(e.Start(":1323"))
}
```

 当访问`/routing`时，会执行后面的`routing`函数，然后`return`

测试：

```go
[root@jw-etcd01 ~]# curl 192.168.32.69:1323/routing
routing
```

## 为所有method添加路由

如果为某个特定的方法注册路由，用`Echo.methods(path string, h Handler)`，如果为所有http请求添加，可使用`Echo.Any(path string, h Handler)`。

示例：

```linux
package main

import (
	"github.com/labstack/echo"
)

func any(c echo.Context) error {
	return c.String(200, "any http method\n")
}

func main() {
	e := echo.New()
	e.Any("/any", any)
	e.Logger.Fatal(e.Start(":1323"))
}

```

测试：

```go
[root@jw-etcd01 ~]# curl 192.168.32.69:1323/any
any http method
[root@jw-etcd01 ~]# curl -X POST 192.168.32.69:1323/any
any http method
```

## 匹配所有

支持`*`来匹配0个或多个字符的`url path`

```go
package main

import (
	"github.com/labstack/echo"
)

func all(c echo.Context) error {
	return c.String(200, "匹配所有路由\n")
}

func main() {
	e := echo.New()
	e.GET("/users/*", all)
	e.Logger.Fatal(e.Start(":1323"))
}

```

测试：

```linux
[root@jw-etcd01 ~]# curl 192.168.32.69:1323/users/
匹配所有路由
[root@jw-etcd01 ~]# curl 192.168.32.69:1323/users/1/
匹配所有路由
[root@jw-etcd01 ~]# curl 192.168.32.69:1323/users/1/2/
匹配所有路由
[root@jw-etcd01 ~]# curl 192.168.32.69:1323/users/anything
匹配所有路由
```

## 路由匹配顺序

当路由存在多种匹配条件时，会有优先顺序：

```go
package main

import (
	"github.com/labstack/echo"
)

func param(c echo.Context) error {
	return c.String(200, "参数路径\n")
}

func static(c echo.Context) error {
	return c.String(200, "固定路径\n")
}

func all(c echo.Context) error {
	return c.String(200, "匹配所有路径\n")
}

func main() {
	e := echo.New()
	e.GET("/users/1", static)
	e.GET("/users/*", all)
	e.GET("/users/:id", param)
	e.Logger.Fatal(e.Start(":1323"))
}

```

测试：

```linux
[root@jw-etcd01 ~]# curl 192.168.32.69:1323/users/1
固定路径
[root@jw-etcd01 ~]# curl 192.168.32.69:1323/users/2
参数路径
[root@jw-etcd01 ~]# curl 192.168.32.69:1323/users/1/anyting
匹配所有路径
```

## 组路由

把路由前缀相同的归为一组。这样可以达到为此类路由添加相同的功能(中间件)，比如认证，频率控制等。

```go
package main

import (
	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

func valiadate(username, password string, c echo.Context) (b bool, e error) {
	if username == "jiang_wei" && password == "echo" {
		_ = c.String(200, "登录成功\n")
		return true, nil
	}
	e = c.String(401, "用户名或密码错误\n")
	return false, e
}

func main() {
	e := echo.New()
	// 创建一个前缀以admin开头的路由组
	g := e.Group("/admin")
	// 在组路由中添加中间件
	g.Use(middleware.BasicAuth(valiadate))
	e.Logger.Fatal(e.Start(":1323"))
}
```

测试：

```
[root@jw-etcd01 ~]# curl -u jiang_wei:echo 192.168.32.69:1323/admin/
登录成功
[root@jw-etcd01 ~]# curl -u jiang_wei:echo 192.168.32.69:1323/admin/1
登录成功
[root@jw-etcd01 ~]# curl -u jiang_wei:echo 192.168.32.69:1323/admin/2
登录成功
[root@jw-etcd01 ~]# curl -u jiang_wei:ech 192.168.32.69:1323/admin/
用户名或密码错误
```

## 路由命名

## 构造路由

## 路由列表

```go
package main

import (
	"encoding/json"
	"fmt"
	"github.com/labstack/echo"
)

func createUser(c echo.Context) error {
	return nil
}

func findUser(c echo.Context) error {
	return nil
}

func updateUser(c echo.Context) error {
	return nil
}

func deleteUser(c echo.Context) error {
	return nil
}

func main() {
	e := echo.New()
	e.POST("/users", createUser)
	e.GET("/users", findUser)
	e.PUT("/users", updateUser)
	e.DELETE("/users", deleteUser)
	
    // json友好格式化输出
	data, err := json.MarshalIndent(e.Routes(), "", "    ")
	if err != nil {
		fmt.Println(err)
	} else {
		fmt.Println(string(data))
	}
}
```

执行结果：

```text
[
    {
        "method": "POST",
        "path": "/users",
        "name": "main.createUser"
    },
    {
        "method": "GET",
        "path": "/users",
        "name": "main.findUser"
    },
    {
        "method": "PUT",
        "path": "/users",
        "name": "main.updateUser"
    },
    {
        "method": "DELETE",
        "path": "/users",
        "name": "main.deleteUser"
    }
]
```

