---
title: echo的响应
date: 2019-08-01 11:18:34
categories: go web框架 Echo
keywords: echo的响应
description: echo的响应
---

# 响应

## 发送string数据

`Content.String(code int, s string)`用于发送一个带有状态码的纯文本响应。

```go
package main

import (
	"github.com/labstack/echo"
)

func respString(c echo.Context) error {
	return c.String(200, "返回字符串\n")
}

func main() {
	e := echo.New()
	e.GET("/string", respString)
	
	e.Logger.Debug(e.Start(":1111"))
}
```

测试：

```linux
root@sw1:~# curl 192.168.32.69:1111/string
返回字符串
```

## 发送html响应

`Content.Html(code int, html string)`用于发送一个带有状态码的简单 HTML 响应。

```go
package main

import (
	"github.com/labstack/echo"
)

func respHtml(c echo.Context) error {
	return c.HTML(200, "<h1>这里只是返回一个简单的html字符串，想动态生成HTML请参照模版</h1>")
}

func main() {
	e := echo.New()
	e.GET("/html", respHtml)
	e.Logger.Debug(e.Start(":1111"))
}
```

测试：

```linux
root@sw1:~# curl 192.168.32.69:1111/html
<h1>这里只是返回一个简单的html字符串，想动态生成HTML请参照模版</h1>
```

## 发送json数据

### 普通json

`Context.JSON(code int, i interface{})` 用于发送一个带状态码的 JSON 对象，它会将 Golang 的对象转换成 JSON 字符串。

```go
package main

import (
	"github.com/labstack/echo"
)

type User struct {
	Name  string `json:"name" xml:"name"`
	Email string `json:"email" xml:"email"`
}

func respJson1(c echo.Context) error {
	u := &User{
		Name:  "jiang_wei",
		Email: "jw19961019@gmail.com",
	}
	return c.JSON(200, u)
}

func main() {
	e := echo.New()
	e.GET("/json1", respJson1)
	e.Logger.Debug(e.Start(":1111"))
}
```

测试：

```linux
root@sw1:~# curl -v 192.168.32.69:1111/json1
*   Trying 192.168.59.241...
* TCP_NODELAY set
* Connected to (nil) (192.168.59.241) port 8888 (#0)
> GET http://192.168.32.69:1111/json1 HTTP/1.1
> Host: 192.168.32.69:1111
> User-Agent: curl/7.52.1
> Accept: */*
> Proxy-Connection: Keep-Alive
> 
< HTTP/1.1 200 OK
< Content-Type: application/json; charset=UTF-8
< Date: Thu, 01 Aug 2019 04:15:18 GMT
< Content-Length: 52
< X-Cache: MISS from localhost.localdomain
< X-Cache-Lookup: MISS from localhost.localdomain:8888
< Via: 1.1 localhost.localdomain (squid/3.5.20)
< Connection: keep-alive
< 
{"name":"jiang_wei","email":"jw19961019@gmail.com"}
* Curl_http_done: called premature == 0
* Connection #0 to host (nil) left intact
```

### json流

`Content.JSON()`内部使用`json.Marshal`来转换json数据。但该方法面对大量的 JSON 数据会显得效率不足，对于这种情况可以直接使用 JSON 流。

```go
package main

import (
	"encoding/json"
	"github.com/labstack/echo"
)

type User struct {
	Name  string `json:"name" xml:"name"`
	Email string `json:"email" xml:"email"`
}

func respJson2(c echo.Context) error {
	u := &User{
		Name:  "jiang_wei",
		Email: "jw19961019@gmail.com",
	}

	c.Response().Header().Set(echo.HeaderContentType, echo.MIMEApplicationJSONCharsetUTF8)
	c.Response().WriteHeader(200)
	return json.NewEncoder(c.Response()).Encode(u)
}

func main() {
	e := echo.New()
	e.GET("/json2", respJson2)
	e.Logger.Debug(e.Start(":1111"))
}
```

测试：

```linux
root@sw1:~# curl  192.168.32.69:1111/json2
{"name":"jiang_wei","email":"jw19961019@gmail.com"}
```

### json美化

`Context.JSONPretty(code int, i interface{}, indent string)`可以发送带有缩进的友好格式的json数据。

```go
package main

import (
	"github.com/labstack/echo"
)

type User struct {
	Name  string `json:"name" xml:"name"`
	Email string `json:"email" xml:"email"`
}

func respJson3(c echo.Context) error {
	u := &User{
		Name:  "jiang_wei",
		Email: "jw19961019@gmail.com",
	}

	return c.JSONPretty(200, u, "    ")
}

func main() {
	e := echo.New()
	e.GET("/json3", respJson3)
	e.Logger.Debug(e.Start(":1111"))
}
```

测试：

```linux
root@sw1:~# curl  192.168.32.69:1111/json3
{
    "name": "jiang_wei",
    "email": "jw19961019@gmail.com"
}
```

当然，也支持在url携带参数来输出友好的json数据，比如使用普通json的代码，但是请求的url加参数。

测试：

```linux
root@sw1:~# curl  192.168.32.69:1111/json1
{"name":"jiang_wei","email":"jw19961019@gmail.com"}

root@sw1:~# curl  192.168.32.69:1111/json1?pretty
{
  "name": "jiang_wei",
  "email": "jw19961019@gmail.com"
}
```

### json blob

`Content.JSONBlob(code int, b []byte)`可以从外部源(例如数据库)直接发送预编码的json对象。

```go
package main

import (
	"github.com/labstack/echo"
)

func respJson4(c echo.Context) error {
	var encodeJson []byte
	return c.JSONBlob(200, encodeJson)
}

func main() {
	e := echo.New()
	e.GET("/json4", respJson4)
	e.Logger.Debug(e.Start(":1111"))
}
```

测试：

```linux
root@sw1:~# curl  192.168.32.69:1111/json4 -v
*   Trying 192.168.59.241...
* TCP_NODELAY set
* Connected to (nil) (192.168.59.241) port 8888 (#0)
> GET http://192.168.32.69:1111/json4 HTTP/1.1
> Host: 192.168.32.69:1111
> User-Agent: curl/7.52.1
> Accept: */*
> Proxy-Connection: Keep-Alive
> 
< HTTP/1.1 200 OK
< Content-Type: application/json; charset=UTF-8
< Date: Thu, 01 Aug 2019 05:29:12 GMT
< Content-Length: 0
< X-Cache: MISS from localhost.localdomain
< X-Cache-Lookup: MISS from localhost.localdomain:8888
< Via: 1.1 localhost.localdomain (squid/3.5.20)
< Connection: keep-alive
< 
* Curl_http_done: called premature == 0
* Connection #0 to host (nil) left intact

```

状态码200，只是那是一个空字节切片。所以没有返回数据。

## 发送jsonp数据

`Context.JSONP(code int, callback string, i interface{})` 可以将 Golang 的数据类型转换成 JSON 类型，并通过回调以带有状态码的 JSONNP 结构发送。

```go
package main

import (
	"github.com/labstack/echo"
)

func respJson(c echo.Context) error {
	mp := map[string]string{
		"name":"jiang_wei",
		"sex":"男",
	}
	return c.JSONP(200, "hello",mp)
}

func main() {
	e := echo.New()
	e.GET("/jsonp", respJson)
	e.Logger.Debug(e.Start(":1111"))
}
```

```linux
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>测试jsonp</title>
</head>

<button class="hello">点击发送请求</button>

<script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
<script>
    // 生成标签
    function get_jsonp_data(url) {
        var Ele = $(`<script>`)
        Ele.attr('src', url);
        Ele.attr('id', 'jsonp');
        $('body').append(Ele);
        $('#jsonp').remove();
    }

    // 点击按钮发送src请求
    $(".hello").click(function () {
        get_jsonp_data("http://192.168.32.69:1111/jsonp?callback=hello");
    })

    // 服务器返回一个hello(data)
    function hello(data) {
        alert(data.name);
    }
</script>
</body>
</html>
```

浏览器打开html文件，点击按钮，就看到一个`alert`。

![](/uploads/echo/3.png)

![](/uploads/echo/4.png)

## 发送xml数据

### 普通xml

`Context。XML(code int, i interface{})` 可以将 Golang 对象转换成 XML 类型，并带上状态码发送响应。

```go
package main

import (
	"github.com/labstack/echo"
)

type User struct {
	Name    string `xml:"name"`
	Age     int    `xml:"age"`
	IsLogin bool   `xml:"is_login"`
}

func respXml(c echo.Context) error {
	user := &User{
		Name:    "江伟",
		Age:     21,
		IsLogin: true,
	}
	return c.XML(200, user)
}

func main() {
	e := echo.New()
	e.GET("/xml1", respXml)
	e.Logger.Debug(e.Start(":1111"))
}
```

测试：

```linux
root@sw1:~# curl  192.168.32.69:1111/xml1
<?xml version="1.0" encoding="UTF-8"?>
<User><name>江伟</name><age>21</age><is_login>true</is_login></User>
```

### xml流

和json流类似，简单看看：

```go
func(c echo.Context) error {
  u := &User{
    Name:  "Jon",
    Email: "jon@labstack.com",
  }
  c.Response().Header().Set(echo.HeaderContentType, echo.MIMEApplicationXMLCharsetUTF8)
  c.Response().WriteHeader(http.StatusOK)
  return xml.NewEncoder(c.Response()).Encode(u)
}
```

### xml美化

和json美化类似：

```go
func(c echo.Context) error {
  u := &User{
    Name:  "Jon",
    Email: "joe@labstack.com",
  }
  return c.XMLPretty(http.StatusOK, u, "  ")
}
```

一样可以通过url携带参数来获取友好输出。

### xml blob

和json blob类似。

## 发送文件

`Context.File(file string)` 可用来发送内容为文件的响应，并且它能自动设置正确的内容类型、优雅地处理缓存。

```go
package main

import (
	"github.com/labstack/echo"
)

func respFile(c echo.Context) error {
	return c.File("file.txt")
}

func main() {
	e := echo.New()
	e.GET("/file", respFile)
	e.Logger.Debug(e.Start(":1111"))
}
```

## 发送附件

同文件类似。

```go
package main

import (
	"github.com/labstack/echo"
)

func respFile(c echo.Context) error {
	return c.Attachment("file.txt","hehe")
}

func main() {
	e := echo.New()
	e.GET("/attachment", respFile)
	e.Logger.Debug(e.Start(":1111"))
}
```

##  发送内嵌

和文件类似，只是方法名不一样。

```go
func(c echo.Context) error {
  return c.Inline("<PATH_TO_YOUR_FILE>")
}
```

## 发送二进制长文件

可用于发送带有内容类型 (content type) 和状态代码的任意类型数据。

```go
func(c echo.Context) (err error) {
  data := []byte(`0306703,0035866,NO_ACTION,06/19/2006
	  0086003,"0005866",UPDATED,06/19/2006`)
	return c.Blob(http.StatusOK, "text/csv", data)
}
```

## 发送流

可用于发送带有内容类型 (content type) 、状态代码、`io.Reader` 的任意类型数据流。

```go
func(c echo.Context) error {
  f, err := os.Open("<PATH_TO_IMAGE>")
  if err != nil {
    return err
  }
  return c.Stream(http.StatusOK, "image/png", f)
}
```

## 发送空内容

可用于发送带有状态码的空内容。

```go
func(c echo.Context) error {
  return c.NoContent(http.StatusOK)
}
```

## 重定向

可用于重定向至一个带有状态码的 URL。

```go
func(c echo.Context) error {
  return c.Redirect(http.StatusMovedPermanently, "<URL>")
}
```

## Hooks

可以用来注册在写入响应之前和响应之后调用的函数。

```go
func(c echo.Context) error {
  c.Response().Before(func() {
    println("before response")
  })
  c.Response().After(func() {
    println("after response")
  })
  return c.NoContent(http.StatusNoContent)
}
```



