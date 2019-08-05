title: go语言的时间包
date: 2019-08-05 13:45:28
categories: Go
keywords: go语言的时间模块的基本用法
description: go语言的时间模的块基本用法

# time包

## 时间类型

`time.Now()`获取当前时间对象。然后可以根据时间对象获取对象的年月日。。。

```go
package main

import (
	"fmt"
	"time"
)

func main() {

	// 获取当前时间对象
	now := time.Now()
	fmt.Println(now)

	// 年
	fmt.Println(now.Year())
	// 月
	fmt.Println(now.Month())
	// 日
	fmt.Println(now.Day())
	// 小时
	fmt.Println(now.Hour())
	// 分
	fmt.Println(now.Minute())
	// 秒
	fmt.Println(now.Second())
}

```

执行结果：

```
2019-08-05 13:56:04.2639783 +0800 CST m=+0.003994001
2019
August
5
13
56
4
```

## 时间戳

### 时间对象转时间戳

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	now := time.Now()
	// 获取当前时间对应的时间戳
	timeStamp1 := now.Unix()
	fmt.Println(timeStamp1)
	// 获取当前时间对应的纳秒时间戳
	timeStamp2 := now.UnixNano()
	fmt.Println(timeStamp2)
}
```

执行结果：

```linux
1564984727
1564984727247498100
```

### 时间戳转时间对象

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	var tsp int64 = 1564984727
	timeObj := time.Unix(tsp, 0)
	fmt.Println(timeObj)

	// 年
	fmt.Println(timeObj.Year())
	// 月
	fmt.Println(timeObj.Month())
	// 日
	fmt.Println(timeObj.Day())
	// 小时
	fmt.Println(timeObj.Hour())
	// 分
	fmt.Println(timeObj.Minute())
	// 秒
	fmt.Println(timeObj.Second())
}
```

执行结果：

```linux
2019-08-05 13:58:47 +0800 CST
2019
August
5
13
58
47
```

## 时间间隔

`time.Duration`是`time`包定义的一个类型，它代表两个时间点之间经过的时间，以纳秒为单位常用来时间计算。

```go
const (
    Nanosecond  Duration = 1
    Microsecond          = 1000 * Nanosecond
    Millisecond          = 1000 * Microsecond
    Second               = 1000 * Millisecond
    Minute               = 60 * Second
    Hour                 = 60 * Minute
)
```

例如：`time.Second`表示一秒，`time.Hour`表示一小时。

## 时间操作

### Add

```go
func (t Time) Add(d Duration) Time
```

时间相加：

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	now := time.Now()
	// 现在的时间
	fmt.Println(now)
	// 10秒后的时间
	fmt.Println(now.Add(time.Second * 10))

	// 三十分钟后的时间
	fmt.Println(now.Add(time.Minute * 30))

	// 一天后的时间
	fmt.Println(now.Add(time.Hour * 24))
    
    // 十分钟之前的时间
    fmt.Println(now.Add(-time.Minute * 10))

}
```

执行结果：

```linux
2019-08-05 14:13:31.230839 +0800 CST m=+0.003991501
2019-08-05 14:13:41.230839 +0800 CST m=+10.003991501
2019-08-05 14:43:31.230839 +0800 CST m=+1800.003991501
2019-08-06 14:13:31.230839 +0800 CST m=+86400.003991501
2019-08-06 14:03:31.230839 +0800 CST m=+86400.003991501
```

### Sub

```go
func (t Time) Sub(u Time) Duration
```

两个时间对象相减得到`time.Duration`：

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	now := time.Now()

	// 10小时后的时间
	later := now.Add(time.Hour * 10)

	// 计算now和later相差值
	sub := now.Sub(later)
	fmt.Println(sub)
}
```

```linux
-10h0m0s
```

### Equal

```go
func (t Time) Equal(u Time) bool
```

判断两个时间是否相同，受时区影响。

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	// UTC时间
	now1 := time.Now().UTC()
	fmt.Println(now1)
	// 北京时间
	now2 := time.Now().Local()
	fmt.Println(now2)

	// 比较两个时间是否相同，会考虑到时区影响。
	e := now1.Equal(now2)
	fmt.Println(e)
	// 与值比较不同
	fmt.Println(now2 == now1)
}
```

执行结果：

```linux
2019-08-05 06:31:17.0639578 +0000 UTC
2019-08-05 14:31:17.0639578 +0800 CST
true
false
```

### Before

```
func (t Time) Before(u Time) bool
```

 比较t时间是否在u之前：

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	now := time.Now()
	fmt.Println(now)
	before := now.Add(-time.Hour * 2)
	fmt.Println(before)

	// 判断是否在前
	b := before.Before(now)
	fmt.Println(b)
}

```

执行结果：

```linux
2019-08-05 14:40:06.0742141 +0800 CST m=+0.004017201
2019-08-05 12:40:06.0742141 +0800 CST m=-7199.995982799
true
```

### After

```go
func (t Time) After(u Time) bool
```

比较t时间是否在u之后：

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	now := time.Now()
	fmt.Println(now)
	after := now.Add(time.Hour * 2)
	fmt.Println(after)

	// 判断是否在后
	b := after.After(now)
	fmt.Println(b)
}
```

执行结果：

```linux
2019-08-05 15:09:40.8128673 +0800 CST m=+0.004022201
2019-08-05 17:09:40.8128673 +0800 CST m=+7200.004022201
true
```

## 定时器

使用`time.Tick()`来设置定时器，定时器的本质上是一个`channel`。

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	// 定义一个时间间隔为3秒的定时器，
	dingshiqi := time.Tick(time.Second * 3)

	//循环定时器
	for i := range dingshiqi {
		// 每十秒执行的任务
		fmt.Println(i)
	}
}
```

执行结果：

```linux
2019-08-05 15:14:58.4715038 +0800 CST m=+3.004032801
2019-08-05 15:15:01.4733053 +0800 CST m=+6.005834401
2019-08-05 15:15:04.4716833 +0800 CST m=+9.004212301
2019-08-05 15:15:07.4723472 +0800 CST m=+12.004876201
2019-08-05 15:15:10.4720618 +0800 CST m=+15.004590901
2019-08-05 15:15:13.4716867 +0800 CST m=+18.004215801
2019-08-05 15:15:16.4728042 +0800 CST m=+21.005333301
```

## 时间格式化

go语言的格式化和其它语言有不同之处，是使用Go的诞生时间2006年1月2号15点04分（记忆口诀为20061234）。也许这就是技术人员的浪漫吧。

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	now := time.Now()

	fmt.Println(now.Format("2006-01-02 15:04:05"))
	fmt.Println(now.Format("2006-01-02 15:04:05 PM"))
	fmt.Println(now.Format("2006/01/02"))
}
```

执行结果：

```linux
2019-08-05 15:31:39
2019-08-05 15:31:39 PM
2019/08/05
```

### 解析字符串格式的时间

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	timeStr := "2019/08/05 13:14:52"

	// 加载时区
	loc, err := time.LoadLocation("Asia/Shanghai")
	if err != nil {
		fmt.Println(err)
	}

	// 按照指定时区和字符串解析成时间
	timeObj, _ := time.ParseInLocation("2006/01/02 15:04:05", timeStr, loc)
	timeObj1, _ := time.Parse("2006/01/02 15:04:05", timeStr)
	fmt.Println(timeObj)
	fmt.Println(timeObj.Year())
	fmt.Println(timeObj1)
	fmt.Println(timeObj1.Year())
}
```

执行结果：

```linux
2019-08-05 13:14:52 +0800 CST
2019
2019-08-05 13:14:52 +0000 UTC
2019
```

