---
title: go语言的内置包之strconv
date: 2019-07-23 17:33:21
catecories: Go
---

# go语言内置包之strconv

## 简介

go语言的内置包`sreconv`实现了基本数据类型和字符串之间的相互转换。

## 常用函数

### Atoi()

将字符串类型的整数转换为int类型。函数原型为：

```go
func Atoi(s string) (int, error) {}
```

如果传入的参数无法转换为int类型。就会返回错误。

```go
package main

import (
	"fmt"
	"strconv"
)

func main() {
	s1 := "5201314"
	i1, err := strconv.Atoi(s1)
	if err != nil {
		fmt.Println(err)
	} else {
		fmt.Printf("类型：%T\t值：%#v\n",i1, i1)
	}
	s2 := "江子牙"
	i2, err := strconv.Atoi(s2)
	if err != nil {
		fmt.Println(err)
	} else {
		fmt.Printf("类型：%T\t值：%#v\n",i2, i2)
	}
}

```

执行结果：

```go
类型：int	值：5201314
strconv.Atoi: parsing "江子牙": invalid syntax
```

### Itoa()

将int类型数据转化为对应的字符串表示。函数原型为：

```linux
func Itoa(i int) string {}
```

```go
package main

import (
	"fmt"
	"strconv"
)

func main() {
	i1 := 5201315
	s1 := strconv.Itoa(i1)
    
    // 类型：string	值："5201315"
	fmt.Printf("类型：%T\t值：%#v", s1, s1)
}
```

### parse系列

parse系列函数用于转换字符串为给定类型的值。

#### ParseBool()

```go
func ParseBool(str string) (bool, error) {}
```

返回字符串表示的bool值，但是只接收`1、0、false、true、False、True、t、T、F、f、TRUE、FALSE`，否则返回错误。

```go
package main

import (
	"fmt"
	"strconv"
)

func testBool(s string) {
	b1, err := strconv.ParseBool(s)
	if err != nil {
		fmt.Println(err)
	} else {
		fmt.Printf("类型：%T\t值：%#v\n", b1, b1)
	}
}

func main() {
	s1 := "1"
	testBool(s1)
	s2 := "t"
	testBool(s2)
	s3 := "F"
	testBool(s3)
	s4 := "-2"
	testBool(s4)

}
```

执行结果：

```go
类型：bool	值：true
类型：bool	值：true
类型：bool	值：false
strconv.ParseBool: parsing "-2": invalid syntax
```

#### ParseFloat()

解析一个浮点数表示的字符串。函数原型为：

```linux
func ParseFloat(s string, bitSize int) (float64, error) {}
```

`bitsize`表示期望的接受类型。32代表`float32`，64代表`float64`。

```go
package main

import (
	"fmt"
	"strconv"
)

func testFloat(s string) {
	b1, err := strconv.ParseFloat(s, 64)
	if err != nil {
		fmt.Println(err)
	} else {
		fmt.Printf("类型：%T\t值：%#v\n", b1, b1)
	}
}

func main() {
	s1 := "1"
	testFloat(s1)
	s2 := "3.14159"
	testFloat(s2)
	s3 := "2.22222"
	testFloat(s3)
	s4 := "呵呵"
	testFloat(s4)

}
```

执行结果：

```linux
类型：float64	值：1
类型：float64	值：3.14159
类型：float64	值：2.22222
strconv.ParseFloat: parsing "呵呵": invalid syntax
```

#### ParseInt()

解析字符串表示的整数值，接收正负号，函数原型为：

```linux
func ParseInt(s string, base int, bitSize int) (i int64, err error) {}
```

`base`表示指定进制，如果base为0，则会从字符串前缀判断。`ox`是十六进制，`o`是八进制。否则是十进制。

```go
package main

import (
	"fmt"
	"strconv"
)

func testInt(s string, base int, bitSize int) {
	b1, err := strconv.ParseInt(s, base, bitSize)
	if err != nil {
		fmt.Println(err)
	} else {
		fmt.Printf("类型：%T\t值：%#v\n", b1, b1)
	}
}

func main() {
	s1 := "1"
	testInt(s1, 0, 64)
	// 十六进制
	s2 := "0x10"
	testInt(s2, 0, 64)
	s4 := "-19"
	testInt(s4, 0, 64)
	s5 := "呵呵"
	testInt(s5, 0, 64)
	// 八进制
	s6 := "011"
	testInt(s6, 0, 64)
	// 二进制
	s7 := "1111"
	testInt(s7, 2, 64)
}

```

执行结果：

```go
类型：int64	值：1
类型：int64	值：16
类型：int64	值：-19
strconv.ParseInt: parsing "呵呵": invalid syntax
类型：int64	值：9
类型：int64	值：15

```

#### ParseUnit()

与`ParseInt`类似，但是不接受正负号，用于无符号整型。函数原型为：

```go
func ParseUint(s string, base int, bitSize int) (n uint64, err error) {}
```

### format系列

与`Parse`系列函数相反。将给定的数据类型的值转为字符串。

#### FormatBool()

将布尔值格式化为对应的字符串，函数原型为：

```go
func FormatBool(b bool) string {}
```

返回值为`true`或者`false`

```go
package main

import (
	"fmt"
	"strconv"
)

func testBool(b bool) {

	s := strconv.FormatBool(b)
	fmt.Println(s)
}

func main() {
	b1 := true
	var b2 bool
	testBool(b1)
	testBool(b2)
}

```

执行结果：

```go
true
false
```

#### FormatInt()

将数字格式化为对应的字符串，支持指定进制，函数原型为：

```go
func FormatInt(i int64, base int) string {}
```

`base` 必须在2到36之间，结果中会使用小写字母’a’到’z’表示大于10的数字。

```go
package main

import (
	"fmt"
	"strconv"
)

func testInt(i int64, base int) {

	s := strconv.FormatInt(i, base)
	fmt.Printf("类型：%T\t值：%#v\n", s, s)
}

func main() {
	var i1 int64 = 10
	var i2 int64 = 16
	testInt(i1, 2)
	testInt(i2, 16)
}

```

执行结果：

```go
类型：string	值："1010"
类型：string	值："10"
```

#### FormatUnit()

是`FormatInt`的无符号整数版本，函数原型为：

```go
func FormatUint(i uint64, base int) string {}
```

#### FormatFloat()

将浮点型的数字转换为对应的字符串，函数原型为：

```go
func FormatFloat(f float64, fmt byte, prec, bitSize int) string {}
```

`bitSize`表示f的来源类型（32：float32、64：float64），会据此进行舍入。

`fmt`表示格式：`f`（-ddd.dddd）、`b`（-ddddp±ddd，指数为二进制）、`e`（-d.dddde±dd，十进制指数）、`E`（-d.ddddE±dd，十进制指数）、`g`指数很大时用’e’格式，否则`f`格式）、`G`（指数很大时用`E`式，否则`f`格式）。

`prec`控制精度（排除指数部分）：对`f、e、E`，它表示小数点后的数字个数；对`g、G`，它控制总的数字个数。如果`prec` 为-1，则代表使用最少数量的、但又必需的数字来表示f。

```go
package main

import (
	"fmt"
	"strconv"
)

func main() {
	s1 := strconv.FormatFloat(3.1415, 'E', -1, 64)
	// 3.1415E+00
	fmt.Println(s1)
}
```

