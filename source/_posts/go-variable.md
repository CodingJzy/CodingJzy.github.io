---
title: go语言的变量
date: 2019-08-14 13:47:05
categories: Go
keywords: go语言的变量
description: go语言的变量
---

# go语言的变量

变量和常量是任何一门编程语言中必不可少的部分，也是最基础的一部分。

## 标识符与关键字

### 标识符

在编程语言中标识符就是程序员定义的具有特殊意义的词，比如变量名、常量名、函数名等等。 Go语言中标识符由字母数字和`_`(下划线）组成，并且只能以字母和`_`开头。 举几个例子：`abc`, `_`, `_123`, `a123`。

### 关键字

关键字是指编程语言中预先定义好的具有特殊含义的标识符，每门编程语言有不同和相同。

关键字和保留字不建议用作为变量名。

go语言中有25个关键字：

```go
    break        default      func         interface    select
    case         defer        go           map          struct
    chan         else         goto         package      switch
    const        fallthrough  if           range        type
    continue     for          import       return       var
```

此外，还有37个保留字：

```go
    Constants:    true  false  iota  nil

        Types:    int  int8  int16  int32  int64  
                  uint  uint8  uint16  uint32  uint64  uintptr
                  float32  float64  complex128  complex64
                  bool  byte  rune  string  error

    Functions:   make  len  cap  new  append  copy  close  delete
                 complex  real  imag
                 panic  recover
```

## 变量

### 变量的来历

程序运行过程中，数据都是保存在内存中，我们想要在代码中用到哪个数据就需要去内存上找到这个变量，但是如果我们直接通过内存地址去操作变量的话，代码的可读性会非常差，出错率也很高。所以，我们可以用变量名，把这个数据的内存地址保存起来。以后直接通过变量就能找到内存上对应的数据了。

### 变量声明

#### 标准声明

go语言和其他一些(Python、PHP、JavaScript)动态性语言不一样。声明变量的时候必须有变量的类型。

```go
var 变量名 变量类型
```

go语言以`var`关键字开头，变量类型放后面。行尾不需要`;`。写习惯了`java`语言的可能会不习惯。

比如：

```go
var username string
var age int
var isLogin bool
```

#### 批量声明

每声明一个变量都需要一个`var`会很繁琐，所以还有一种批量声明的方式：

```go
package main

import "fmt"

var (
	a string    // 字符串
	b int       // 数字
	c float64   // 浮点数
	d bool      // 布尔
	e [3]string // 数组
)

func main() {
	fmt.Println(a, b, c, d, e)
}
```

### 变量的初始化

变量在声明之后，会自动对其对应的内存区域进行初始化操作。每个变量会被初始化成其类型的默认值。

例如：整数和浮点数的默认值为`0`，字符串的默认值为`空串`，布尔类型默认为`false`。切片、函数、指针默认为`nli`。

#### 标准式

当我们进行变量声明的同时，也可以对变量进行初始化。

格式：

```go
var 变量名 变量类型 = 表达式
```

例如：

```go
var username string = "江子牙"
var age int = 23
var isLogin bool = True
```

#### 类型推倒式

按照标准格式，左右两边有冗余，而编译器会根据等号左边的值来推导出变量的类型完成初始化，所以可以省略变量类型：

```go
var username = "江子牙"
var age = 21
```

#### 批量式

```
package main

import "fmt"

var (
	a = 1
	b = 9.99
	c = "江子牙"
)

func main() {
	var d, e = 1, "呵呵"
	fmt.Println(a, b, c, d, e)
}

```

#### 短变量式：

使用该方式必须在函数内部，所以`var`常用在声明全局变量。

```go
package main

import "fmt"

// 全局变量m
var m = 100

func main() {
	// 使用短变量方式声明局部变量n
	n := 10
	fmt.Println(m, n)
}
```

### 匿名变量

可以通过`_`来使用匿名变量，匿名变量不会分配内存，也不会因为多次声明而无法使用。

```go
package main

import "fmt"

func sum() (int, int) {
	return 100, 200
}

func main() {
	// 调用sum函数返回100给变量a
	a, _ := sum()
	// 调用sum函数返回200给变量b
	_, b := sum()
	// 调用sum函数返回100给变量c, 200给变量d
	c, d := sum()
	fmt.Println(a, b, c, d)
}
```

注意事项：

- 函数外的每个语句都必须以关键字开始（var、const、func、type等）

- `:=`只能在函数内部使用
- `-`多用于占位

## 常量

相对于变量，常量是恒定不变的值，多用于定义程序运行期间不会改变的那些值。 常量的声明和变量声明非常类似，只是把`var`换成了`const`，常量在定义的时候必须赋值。

### 标准式

```go
// 圆周率
const pi = 3.1415926

// 我永远十八
const age = 18
```

### 批量式

```go
const (
    age = 18
    pi  = 3.1415926
)
```

采用批量声明时，如果下面常量的值与上一行的相同，可以省略值。

```go
// n1、n2、n3都为100
const (
    n1 = 100
    n2
    n3
)
```

### iota

go语言现阶段没有枚举，但是可以用常量配合iota来模拟枚举。

比如：

```go
package main

import "fmt"

const (
	n1 = iota //0
	n2        //1
	n3        //2
	n4        //3
)

func main() {
	fmt.Println(n1, n2, n3, n4)
}
```

使用`_`跳过某个值：

```go
package main

import "fmt"

const (
	n1 = iota //0
	n2        //1
	_
	n4 //3
)

func main() {
	fmt.Println(n1, n2, n4)
}
```

插队：

```go
package main

import "fmt"

const (
	n1 = iota //0
	n2 = 100  //100
	n3 = iota //2
	n4        //3
)
const n5 = iota //0

func main() {
	fmt.Println(n1, n2, n3, n4, n5)
}
```

多个iota定义在一行：

```go
package main

import "fmt"

const (
	a, b = iota + 1, iota + 2 //1, 2
	c, d                      //2, 3
	e, f                      //3, 4
)

func main() {
	fmt.Println(a, b, c, d, e, f)
}
```