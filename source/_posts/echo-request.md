---
title: echo-request
date: 2019-07-31 16:55:08
categories: go web框架 Echo
keywords: echo的请求对象
description: echo的请求对象
---

# request

## 数据绑定

将请求内容体绑定至 go 的结构体。默认绑定器支持基于`Content-Type`标头包含 `application/json`，`application/xml` 和 `application/x-www-form-urlencoded` 的数据。

```go
package main

import "github.com/labstack/echo"

type User struct {
	Name  string `json:"name" form:"name" query:"name"`
	Email string `json:"email" form:"email" query:"email"`
}

func getUser(c echo.Context) (err error) {
	u := &User{}
	if err = c.Bind(u); err != nil {
		return
	}
	return c.JSON(200, u)
}

func main() {
	e := echo.New()
	e.Any("/user", getUser)
	e.Logger.Fatal(e.Start(":1111"))
}

```

测试：

### json数据

```linux
[root@jw-etcd01 ~]# curl -X POST -H 'Content-Type: application/json' -d '{"name":"江子牙","email":"jw19961019@gmail.com"}'   192.168.32.69:1111/user
{"name":"江子牙","email":"jw19961019@gmail.com"}
```

### 表单数据

```linux
[root@jw-etcd01 ~]# curl -X POST  -d 'name=alex' -d 'email=alex@123.com'   192.168.32.69:1111/user
{"name":"alex","email":"alex@123.com"}
```

### 查询数据

```linux
[root@jw-etcd01 ~]# curl  http://192.168.32.69:1111/user\?name\=root\&email\=root@123.com
{"name":"root","email":"root@123.com"}
```

## 检索数据

### 表单数据

```go
package main

import "github.com/labstack/echo"

func getUser(c echo.Context) (err error) {
	name := c.FormValue("name")
	return c.String(200, name+"\n")
}

func main() {
	e := echo.New()
	e.Any("/user", getUser)
	e.Logger.Debug(e.Start(":1111"))
}
```

测试：

```linux
[root@jw-etcd01 ~]# curl  -d 'name=1' http://192.168.32.69:1111/user
1
```

### 查询数据

```go
package main

import "github.com/labstack/echo"

func getUser(c echo.Context) (err error) {
	name := c.QueryParam("name")
	return c.String(200, name+"\n")
}

func main() {
	e := echo.New()
	e.GET("/user", getUser)
	e.Logger.Debug(e.Start(":1111"))
}
```

测试：

```linux
[root@jw-etcd01 ~]# curl   http://192.168.32.69:1111/user?name=echo
echo
```

### 路径数据

```linux
package main

import "github.com/labstack/echo"

func getUser(c echo.Context) (err error) {
	name := c.Param("phone")
	return c.String(200, name+"\n")
}

func main() {
	e := echo.New()
	e.GET("/user/:phone", getUser)
	e.Logger.Debug(e.Start(":1111"))
}

```

测试：

```linux
[root@jw-etcd01 ~]# curl   http://192.168.32.69:1111/user/13006293101
13006293101
```

## 数据校验

Echo 没有内置的数据验证功能，但是可以通过 `Echo.Validator` 和[第三方库](https://github.com/avelino/awesome-go#validation)来注册一个数据验证器。

```go
package main

import (
	"fmt"
	"github.com/go-playground/validator"
	"github.com/labstack/echo"
)

type (
	// 定义一个user结构体
	User struct {
		Name  string `json:"name" validate:"required"`
		Email string `json:"email" validate:"required,email"`
		Age   int    `json:"age" validate:"gte=60"`
	}

	// 定义一个自定义校验结构体
	// 字段为validator库下的Validate结构体
	MyValidator struct {
		validator *validator.Validate
	}
)

// 为自定义校验结构体添加Validate方法，因为echo下的Validator的类型是一个接口，要实现接口下的Validate方法。
func (mv *MyValidator) Validate(i interface{}) error {
	return mv.validator.Struct(i)
}

func validatorUser(c echo.Context) (err error) {
	u := new(User)
	if err = c.Bind(u); err != nil {
		return c.String(404, fmt.Sprintf("%v", err)+"\n")
	}

	if err = c.Validate(u); err != nil {
		return c.String(404, fmt.Sprintf("%v", err)+"\n")
	}
	return c.JSON(200, u)
}

func main() {
	e := echo.New()

	// 实例化一个自定义校验结构体的对象
	// 字段validator的值为：用validator库下的New方法构造一个Validate对象
	myValidator := &MyValidator{
		validator: validator.New(),
	}
	e.Validator = myValidator

	e.POST("/user", validatorUser)
	e.Logger.Debug(e.Start(":1111"))
}

```

测试：

```linux
[root@jw-etcd01 ~]# curl -X POST -H 'Content-Type: application/json' -d '{"name":"jiang_wei","email":"jw19961019@gmail.com"}'  http://192.168.32.69:1111/user
Key: 'User.Age' Error:Field validation for 'Age' failed on the 'gte' tag


[root@jw-etcd01 ~]# curl -X POST -H 'Content-Type: application/json' -d '{"name":"jiang_wei","email":"jw19961019@gmail.com","age":67}'  http://192.168.32.69:1111/user
{"name":"jiang_wei","email":"jw19961019@gmail.com","age":67}


[root@jw-etcd01 ~]# curl -X POST -H 'Content-Type: application/json' -d '{"name":"jiang_wei","email":"jw19961019@gmail.com","age":6}'  http://192.168.32.69:1111/user
Key: 'User.Age' Error:Field validation for 'Age' failed on the 'gte' tag


[root@jw-etcd01 ~]# curl -X POST -H 'Content-Type: application/json' -d '{"name":"jiang_wei","email":"jw19961019@gmail","age":6}'  http://192.168.32.69:1111/user
Key: 'User.Email' Error:Field validation for 'Email' failed on the 'email' tag
Key: 'User.Age' Error:Field validation for 'Age' failed on the 'gte' tag
```



