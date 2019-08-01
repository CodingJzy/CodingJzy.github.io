---
title: echo-jwt
date: 2019-08-01 17:09:51
categories: go web框架 Echo
keywords: echo使用jwt中间件认证
description: echo使用jwt中间件认证
---

# JWT

## 服务端(map)

```go
package main

import (
	"fmt"
	"github.com/dgrijalva/jwt-go"
	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
	"time"
)

func login(c echo.Context) error {
	username := c.FormValue("username")
	password := c.FormValue("password")
	if username == "jiang_wei" && password == "echo" {
		// 创建一个token对象，传入一个header加密的算法
		token := jwt.New(jwt.SigningMethodHS256)

		// 为token对象设置载荷playload
		// 类型断言：转换为jwt.MapClaims类型
		claims := token.Claims.(jwt.MapClaims)
		claims["name"] = "jiang_wei"
		claims["admin"] = true
		claims["iat"] = time.Now().Unix()
		claims["exp"] = time.Now().Add(time.Hour * 72).Unix()

		// 生成编码令牌并将其作为响应发送
		t, err := token.SignedString([]byte("secret"))
		if err != nil {
			return err
		}
		fmt.Println(token)
		return c.JSON(200, map[string]string{
			"token": t,
		})
	}
	return echo.ErrUnauthorized
}

func accessible(c echo.Context) error {
	return c.String(200, "此路由未加认证，随意访问。")
}

func userInfo1(c echo.Context) error {
	return c.String(200, " 查看用户信息")
}

func userInfo2(c echo.Context) error {
	user := c.Get("user").(*jwt.Token)
	claims := user.Claims.(jwt.MapClaims)
	name := claims["name"].(string)

	return c.String(200, "Welcome "+name+"!")
}

func main() {
	e := echo.New()

	// 中间件
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	// login route
	e.POST("/login", login)

	// Unauthorized route 不需要认证的路由
	e.GET("/", accessible)

	// authorized route 需要认证的路由
	g := e.Group("/api/v1", middleware.JWT([]byte("secret")))
	g.GET("/user_info1", userInfo1)
	g.GET("/user_info2", userInfo2)

	e.Logger.Debug(e.Start(":1111"))
}

```

测试：

### 访问不需要认证的url

![](/uploads/echo/5.png)

### 通过登录url获取token

#### 登录失败

![](/uploads/echo/6.png)

#### 登录成功

![](/uploads/echo/7.png)

### 访问用户信息url

####　不带token访问用户信息

![](/uploads/echo/8.png)

#### 带token访问用户信息

![](/uploads/echo/9.png)

![](/uploads/echo/10.png)

## 服务端(struct)

