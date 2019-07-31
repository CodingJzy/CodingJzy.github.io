---
title: go语言标准库止http/template
date: 2019-07-31 12:16:19
categories: Go
keywords: go语言标准库止http/template
description: go语言标准库止http/template
---

# template

## 模版示例

创建一个`hello.html`文件：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Hello</title>
</head>
<body>
<p>Hello {{.}}</p>
</body>
</html>
```

创建服务器端：

```go
package main

import (
	"fmt"
	"html/template"
	"net/http"
)

func sayHello(w http.ResponseWriter, r *http.Request) {
	// 解析指定文件生成模版对象
	temp, err := template.ParseFiles("./hello.html")
	if err != nil {
		fmt.Println("error：", err)
		return
	}
    // 利用给定数据渲染模板，并将结果写入w
	_ = temp.Execute(w, "江子牙")
}

func main() {
	http.HandleFunc("/sayhello", sayHello)
	err := http.ListenAndServe(":8888", nil)
	if err != nil {
		fmt.Println("error：", err)
	}
}
```

测试：

```linux
[root@jw-etcd01 ~]# curl http://192.168.32.69:8888/sayhello
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Hello</title>
</head>
<body>
<p>Hello 江子牙</p>
</body>
```

我这里只是通过命令浏览，如果通过浏览器打开的话就只是显示`Hello 江子牙`。

## 模版语法

### {{.}}

模板语法都包含在`{{`和`}}`中间，其中`{{.}}`中的`.`表示当前对象。

当我们传入一个结构体时，可以通过`.`来访问其成员字段。

修改`hello.html`文件：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Hello</title>
</head>
<body>
<p>My name is {{.Name}}, I'm {{.Age}} years old and i am a {{.Sex}}. The phone number is {{.Phone}}</p>
</body>
</html>
```

修改代码：

```go
package main

import (
	"fmt"
	"html/template"
	"net/http"
)

// 定义一个用户结构体
type User struct {
	Name, Sex, Phone string
	Age              int
}

func sayHello(w http.ResponseWriter, r *http.Request) {
	// 解析指定文件生成模版对象
	temp, err := template.ParseFiles("./hello.html")
	if err != nil {
		fmt.Println("error：", err)
		return
	}

	// 实例化一个user
	user := User{
		"JiangZiYa",
		"boy",
		"13006293101",
		23,
	}

	// 传入一个user对象，并将结果写入w
	_ = temp.Execute(w, user)
}

func main() {
	http.HandleFunc("/sayhello", sayHello)
	err := http.ListenAndServe(":8888", nil)
	if err != nil {
		fmt.Println("error：", err)
	}
}

```

测试：

```go
</html>[root@jw-etcd01 ~]# curl http://192.168.32.69:8888/sayhello
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Hello</title>
</head>
<body>
<p>My name is JiangZiYa, I'm 23 years old and i am a boy. The phone number is 13006293101</p>
</body>

```

同结构体一样，当我们传入的是一个`map`类型的数据时，也可以使用`.`根据`key`取值。

### 注释

注释必须紧挨着(可以多行)：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Hello</title>
</head>
<body>
<p>My name is {{.Name}}, I'm {{.Age}} years old and i am a {{.Sex}}. The phone number is {{.Phone}}</p>
<p>{{/* 这是一个注释 */}}</p>
</body>
</html>
```

测试：

```linux
</html>[root@jw-etcd01 ~]# curl http://192.168.32.69:8888/sayhello
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Hello</title>
</head>
<body>
<p>My name is JiangZiYa, I'm 23 years old and i am a boy. The phone number is 13006293101</p>
<p></p>
</body>
```

### pipeline

`pipeline`是指产生数据的操作。比如`{{.}}`、`{{.Name}}`等。Go的模板语法中支持使用管道符号`|`链接多个命令，用法和unix下的管道类似：`|`前面的命令会将运算结果(或返回值)传递给后一个命令的最后一个位置。

**注意：**并不是只有使用了`|`才是pipeline。Go的模板语法中，`pipeline的`概念是传递数据，只要能产生数据的，都是`pipeline`。

### 变量

```go
$variable := pipeline
```

### 条件判断

修改`hello.html`文件：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Hello</title>
</head>
<body>
<p>My name is {{.Name}}, I'm {{.Age}} years old and i am a {{.Sex}}. The phone number is {{.Phone}}</p>
<p>{{/* 这是一个注释 */}}</p>
{{$isLogin := true}}
<p>{{$isLogin}}</p>
<p>{{if .Name }}{{.Name}} 已登录 {{end}}</p>
</body>
</html>
```

测试：

```go
[root@jw-etcd01 ~]# curl http://192.168.32.69:8888/sayhello
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Hello</title>
</head>
<body>
<p>My name is JiangZiYa, I'm 23 years old and i am a boy. The phone number is 13006293101</p>
<p></p>

<p>true</p>
<p>JiangZiYa 已登录 </p>
</body>
```

### range

### with

### 预定义函数

### 比较函数

### 自定义函数

### 模版嵌套

