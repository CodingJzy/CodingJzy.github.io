# 基本数据类型

## 字符串

在go语言中，字符串用`""`表示。内部使用`UTF-8`编码。例如：

```go
package main

import "fmt"

func main() {
    // 定义两个类型为字符串变量
	s1 := "江子牙"
	s2 := "hello"
	// 江子牙 hello
	fmt.Println(s1, s2)
}
```

### 字符串转义符

转义就是不是原来所的表示的字符串了。例如：

```go
package main

import "fmt"

func main() {
	// 本来两个字符串代表一个字符串，如果不做转义处理的话，会报错
	s1 := "what's are you doing? \"呵呵\"\n"
	// 制表符
	s2 := "江\t子\t牙\t"
	fmt.Println(s1, s2)

	/*
		执行结果：
			what's are you doing? "呵呵"
			 江	子	牙
	*/
}
```

常见的转义字符如下表：

| 转义符 |  含义  |
| :----: | :----: |
|  `\r`  |  回车  |
|  `\n`  |  换行  |
|  `\t`  | 制表符 |
|  `\'`  | 单引号 |
|  `\"`  | 双引号 |
|  `\\`  | 反斜杠 |

### 防止转义

为什么要防止转义？举个例子(打印win平台的文件路径)：

```go
package main

import (
	"fmt"
)

func main() {
	// 因为转义符的存在，原来的字符串被转义了
	path := "D:\\code\\codingjzy.github.io\t1\n1"
	fmt.Println("被转义：", path)

	// 防止转义，在被转义的字符串前面加\
	path1 := "D:\\code\\codingjzy.github.io\\t1\\n1"
	fmt.Println("未转义：", path1)
}
```

执行结果：

```text
被转义： D:\code\codingjzy.github.io	1
1
未转义： D:\code\codingjzy.github.io\t1\n1
```

### 多行字符串

当有一段很长很长的字符串时，一行是不够的。用`反引号`可以解决。

```go
package main

import "fmt"

func main() {
	s1 := `第一行
第二行
第三行

注意：
	使用了反引号之后，反引号之间的换行将被视作换行
	同时，所有的转义字符均无效，文本会原样输出。
\t    \n   
`
	fmt.Println(s1)
}
```

执行结果：

```text
第一行
第二行
第三行

注意：
	使用了反引号之后，反引号之间的换行将被视作换行
	同时，所有的转义字符均无效，文本会原样输出。
\t    \n   
```

### 字符串的常用操作

|                方法                 |                             介绍                             |
| :---------------------------------: | :----------------------------------------------------------: |
|              len(str)               | 字符串的长度，准确说是示字符串的`ascii`字符个数的字节长度，而utf8.RuneCountInString()：表示`unicode`字符串长度 |
|                  +                  |                         字符串的拼接                         |
|            strings.Split            |                             分割                             |
|          strings.contains           |                         判断是否包含                         |
| strings.HasPrefix,strings.HasSuffix |                        前缀/后缀判断                         |
| strings.Index(),strings.LastIndex() |                        子串出现的位置                        |
| strings.Join(a[]string, sep string) |                           join操作                           |

### 字符串的遍历

```go
package main

import (
	"fmt"
)

func main() {
	// ascii通过for循环根据索引来获取
	// unicode通过range来获取
	str3 := "hello 江子牙"
	str4 := "你好：hello"
	
	// 每个字符对应的是该ascii的值。len方法计算的是byte字节的长度。一个中文对应3-4个字节组成。
	for i := 0; i < len(str3); i++ {
		fmt.Printf("ascii遍历：%c  %d\n", str3[i], str3[i])
	}

	for _, s := range str4 {
		fmt.Printf("unicode遍历：%c  %d\n", s, s)
	}

	for _, s := range str3 {
		fmt.Printf("%c\n", s)
	}
}
```

执行结果：

```text
ascii遍历：h  104
ascii遍历：e  101
ascii遍历：l  108
ascii遍历：l  108
ascii遍历：o  111
ascii遍历：   32
ascii遍历：æ  230
ascii遍历：±  177
ascii遍历：  159
ascii遍历：å  229
ascii遍历：­  173
ascii遍历：  144
ascii遍历：ç  231
ascii遍历：  137
ascii遍历：  153
unicode遍历：你  20320
unicode遍历：好  22909
unicode遍历：：  65306
unicode遍历：h  104
unicode遍历：e  101
unicode遍历：l  108
unicode遍历：l  108
unicode遍历：o  111
h
e
l
l
o
 
江
子
牙

Process finished with exit code 0
```

## 整型

分类：

- 按长度分：`int8  int16  int32 int64`
- 按对应的无符号整型：`uint8  uint16  uint32  uint64`

其中：

- `unit8` 就是`byte`型
- `int16` 就是c语言中的`short`型
- `int64` 就是c语言中的`long`型

| 类型   | 描述                                                         |
| ------ | ------------------------------------------------------------ |
| uint8  | 无符号 8位整型 (0 到 255)                                    |
| uint16 | 无符号 16位整型 (0 到 65535)                                 |
| uint32 | 无符号 32位整型 (0 到 4294967295)                            |
| uint64 | 无符号 64位整型 (0 到 18446744073709551615)                  |
| int8   | 有符号 8位整型 (-128 到 127)                                 |
| int16  | 有符号 16位整型 (-32768 到 32767)                            |
| int32  | 有符号 32位整型 (-2147483648 到 2147483647)                  |
| int64  | 有符号 64位整型 (-9223372036854775808 到 9223372036854775807) |

### 特殊整型

| 类型    | 描述                                                   |
| ------- | ------------------------------------------------------ |
| uint    | 32位操作系统上就是`uint32`，64位操作系统上就是`uint64` |
| int     | 32位操作系统上就是`int32`，64位操作系统上就是`int64`   |
| uintptr | 无符号整型，用于存放一个指针                           |

**注意：** 

- 在使用`int`和 `uint`类型时，不能假定它是32位或64位的整型，而是考虑`int`和`uint`可能在不同平台上的差异。
- 为了保持文件的结构不会受到不同编译目标平台字节长度的影响，不要使用`int`和 `uint`。

### 八进制和十六进制

Go语言中无法直接定义二进制数，关于八进制和十六进制数的示例如下：

```go
package main

import "fmt"

func main() {
	// 十进制
	var a int = 10
	fmt.Printf("%d \n", a) // 10
	fmt.Printf("%b \n", a) // 1010  占位符%b表示二进制

	// 八进制  以0开头
	var b int = 077
	fmt.Printf("%o \n", b) // 77

	// 十六进制  以0x开头
	var c int = 0xff
	fmt.Printf("%x \n", c) // ff
	fmt.Printf("%X \n", c) // FF
}
```

## 浮点型

分类：

- `float32`
- `float64`

```go
package main

import (
	"fmt"
	"math"
)

func main() {
	// 浮点型
	// float32  float64

	fmt.Printf("%f\n", math.Pi)  //3.141593
	fmt.Printf("%.2f\n", math.Pi)//3.14
}
```

`%f`和`Printf`是格式化打印的一个形式，后面会有。`.2`是代表保留2位小数。

## 布尔

计算机的世界只有两个数字`0`、`1`。

任何编程语言中的布尔类型，也有两个固定不变的值。`true`、`false`。代表真和假。

注意：

- 布尔类型变量的默认值为`false`。
- Go 语言中不允许将整型强制转换为布尔型
- 布尔型无法参与数值运算，也无法与其他类型进行转换。

## byte和rune

组成每个字符串的元素叫做`字符`，可以通过遍历或者单个获取字符串元素获得字符。 字符用单引号`'`包裹起来，如：

```go
package main

import (
	"fmt"
)

func main() {
	var a byte = 'a'
	var b = '你'
	fmt.Printf("%d 类型为：%T\n", a, a)
	fmt.Printf("%d 类型为：%T\n", b, b)

	/*
		执行结果：
			97 类型为：uint8
			20320 类型为：int32
	*/
}
```

go语言中的字符有两种：

- `uint8`：`byte`型，代表了`ASCII码`的一个字符。
- `rune`：`int32`型，代表一个 `UTF-8`一个字符。

