---
title: go语言的并发
date: 2019-07-28 00:21:29
categories: Go
keywords: go语言的并发，通道，互斥锁
description: go语言的并发，通道，锁
---

# go语言的并发

## 并发与并行

- 并发：同一时间段内执行多个任务
- 并行：同一时刻执行多个任务 

go语言的并发通过`goroutine`实现。`goroutine`类似于线程，属于用户态的线程，我们可以根据需要创建成千上万的`goroutine`并发工作。

`goroutine`是由go语言运行时调度完成，而线程是由操作系统调度完成。

## goroutine

Go程序中使用go关键字为一个函数创建一个`goroutine`。一个`goroutine`对应一个(任务)函数。

### 启动单个goroutine

```go
package main

import (
	"fmt"
	"sync"
	"time"
)

// 启动goroutine

func hello() {
	fmt.Println("hello go1")
}

func main() {
    // 创建一个任务
	go hello()
    defer fmt.Println("main stop")
	fmt.Println("hello main ")
    // 创建一个goroutine需要时间，等一下他
	time.Sleep(time.Second)
}
```

### sync.WaitGroup  

用 time模块的方法等待 `goroutine`结束太生硬，有一个类型能实现优雅的等待

- Add(i)：计数器+1
- Done()：计数器-1，最好用defer语句
- Wait()：等待　　

```go
package main

import (
	"fmt"
	"sync"
	"time"
)

// 声明结构体 实现优雅的等待
var wg sync.WaitGroup

func hello() {
	fmt.Println("hello go1")
	time.Sleep(5 * time.Second)
	fmt.Println("hello go2")
	// 标记该任务已完成 最好用defer语句，保证goroutine出错或异常计数器减1。
	defer wg.Done()
}

func main() {
	defer fmt.Println("main stop")

	// 标记一个任务
	wg.Add(1)
	go hello()

	fmt.Println("hello main ")
	// 阻塞，一直等待所有的goroutine结束
	wg.Wait()
}
```

### 启动多个goroutine

```go
package main

import (
	"fmt"
	"sync"
)

var wg sync.WaitGroup

func hello(i int) {
	fmt.Println(i)
	wg.Done()
}

func main() {

	for i := 0; i < 10; i++ {
		wg.Add(1)
		go hello(i)
	}
	wg.Wait()
	fmt.Println("启动多个goroutine")
}

```

执行结果：

```go
package main

import (
	"fmt"
	"sync"
)

var wg sync.WaitGroup

func hello(i int) {
	fmt.Println(i)
	wg.Done()
}

func main() {

	for i := 0; i < 10; i++ {
		wg.Add(1)
		go hello(i)
	}
	wg.Wait()
	fmt.Println("启动多个goroutine")
}

```

多执行几次代码可以发现，每次打印的顺序都不一致，因为这十个`goroutine`是并发执行的，而`goroutine`调度又是随机的。

### goroutine与线程

#### 可增长的栈

OS线程（操作系统线程）一般都有固定的栈内存（通常为2MB）,一个`goroutine`的栈在其生命周期开始时只有很小的栈（典型情况下2KB），`goroutine`的栈不是固定的，他可以按需增大和缩小，`goroutine`的栈大小限制可以达到1GB，虽然极少会用到这个大。所以在Go语言中一次创建十万左右的`goroutine`也是可以的。

#### goroutine调度

OS线程是由OS内核来调度的，`goroutine`则是由Go运行时（runtime）自己的调度器调度的，这个调度器使用一个称为m:n调度的技术（复用/调度m个goroutine到n个OS线程）。goroutine的调度不需要切换内核语境，所以调用一个goroutine比调度一个线程成本低很多。

#### GOMAXPROCS

Go运行时的调度器使用`GOMAXPROCS`参数来确定需要使用多少个OS线程来同时执行Go代码。默认值是机器上的CPU核心数。例如在一个8核心的机器上，调度器会把Go代码同时调度到8个OS线程上（GOMAXPROCS是m:n调度中的n）。

Go语言中可以通过`runtime.GOMAXPROCS()`函数设置当前程序并发时占用的CPU逻辑核心数。

Go1.5版本之前，默认使用的是单核心执行。Go1.5版本之后，默认使用全部的CPU逻辑核心数。



## channel

单纯的将函数并发执行是没有意义的，函数与函数件需要交换数据才能体现并行函数的意义。

虽然可以使用共享内存进行数据交换，但是共享内存在不同的`goroutine`中容易发生竞态问题。为了保证数据交换的正确性和安全性。必须使用互斥量对内存的进行加锁处理，这种做法势必造成性能问题。

go语言的并发模型是CSP，提倡通过通信共享内存，而不是通过共享内存实现通信。

如果说`groutine`是go语言并发的执行体，`channel`就是执行体之间的连接，`channel`是可以让一个`goroutine`发送特定值到另一个`goroutine`的通信机制。

Go语言中，`channel`是一种引用的数据类型。像一个队列，遵循先入先出的规则，保证收发数据的顺序。

### 声明

格式：

```go
var 通道名 chan 元素类型
```

```go
package main

import "fmt"

// channel

func main() {

	// 定义一个ch1变量，是一个channel类型，这个channel内部传递的数据是int类型
	// channel是引用类型
	var ch1 chan int
	var ch2 chan string

	fmt.Println("ch1：", ch1)
	fmt.Println("ch2：", ch2)
}
```

### channel操作

#### 发送

将一个值发送到通道中：

```go
// 往通道中存取一个10
ch <- 10 
```

#### 接受

从一个通道中取值：

```go
// 取出值赋值给一个变量
num := <- ch
// 取出一个值，但是忽略
<- ch
```

#### 关闭

通过内置函数`close()`来关闭通道：

```go
close(ch)
```

通道是可以被垃圾回收机制回收的，和文件关闭不一样，那是必须做的，但关闭通道不是必须的。

- 关闭之后可以再取值，如果有值取出来；如果空了，只是为对应类型的零值值而已。
- 关闭之后不可以再次发送值，会panic。
- 关闭之后不能再关闭。

#### 例子

```go
package main

import "fmt"

func main() {
	ch3 := make(chan string, 1)
	fmt.Println("ch3：", ch3)

	// 通道的操作：发送、接受、关闭
	// 发送和接收  <-
	ch3 <- "1"			// 把10发送的通道中
	recv1 := <- ch3	    // 从通道中取出10，保存到变量中

	fmt.Println("recv1：", recv1)
	ch3 <- "2"
	recv2 := <- ch3
	fmt.Println("recv2：", recv2)

	// 关闭通道
	close(ch3)
	// 1、关闭之后可以再取值，只是为对应类型的nli值而已
	fmt.Println(<-ch3)
	// 2、关闭之后不可以再次发送值，会panic
	// 3、关闭之后不能再关闭
}
```

### 缓冲通道

#### 无缓冲通道

像四百米接力赛跑一样，棒交接的时候必须有人接棒，不然就会一直阻塞在那。

这种通道叫无缓冲通道，也称同步通道，

```go
package main

import "fmt"

func recv(ch chan bool)  {
	res := <- ch
	fmt.Println(res)
}

func main() {
	ch := make(chan bool)
	go recv(ch)
	ch <- true
	fmt.Println("mai stop")
}
```

#### 有缓冲通道

拿我们生活的例子，快递员送小区的快递，如果他打电话通知你领取，你不在，他还是会放进去，不会等你，这个丰巢快递柜的格子就是通道的容量。

只要通道的容量大于０，该通道就是有缓冲的通道，容量表示该通道最多能存放元素的数量。超过容量也会阻塞。

我们可以用 `len()`获取通道内元素的数量，使用 `cap()`函数获取通道的容量。

```go
package main

import "fmt"

func recv(ch chan bool)  {
	res := <- ch
	fmt.Println(res)
}

func main() {
	ch := make(chan bool, 1)
	ch <- false
	fmt.Println("长度：", len(ch), " 容量：", cap(ch))
	go recv(ch)
	ch <- true
	fmt.Println("main stop")
}
```

### 接收值判断通道是否关闭

```go
package main

import "fmt"

func send(ch chan int)  {
	for i := 0;i < 10; i++ {
		ch <- i
	}
	close(ch)
}

func main() {
	ch := make(chan int, 100)

	go send(ch)

	// 利用的for循环接收
	//for  {
	//	ret, ok := <- ch
	//	if !ok {
	//		break
	//	}
	//	fmt.Println(ret)
	//}

	// 利用for range接收
	for ret := range ch {
		fmt.Println(ret)
	}
}
```

### 单向通道

- 是单向的，也就是说，只能接受或者只能发送。
- 多用于函数当中，限制此函数对通道的操作。

### select多路复用

同一时刻对多个通道进行操作(存值和取值)

## 并发安全和锁

先来看一个示例，多个goroutine同时对同一个变量进行修改：

```go
package main

import (
	"fmt"
	"sync"
)

// 定义一个全局变量
var x int

var wg sync.WaitGroup

// 定义一个函数，对x进行循环递增操作
func add() {
	for i := 0; i < 5000; i++ {
		x++
	}
	wg.Done()
}

func main() {

	// 开启两个goroutine，同时对变量x进行修改。
	fmt.Println("开启")
	wg.Add(2)
	go add()
	go add()
	wg.Wait()
	fmt.Println("结束")
	fmt.Println("x的值为：", x)
}

```

执行多次结果：

```go
开启
结束
x的值为： 6731

开启
结束
x的值为： 5950

开启
结束
x的值为： 10000
```

可以看出来，会对数据造成混乱，所以需要对数据进行加锁。

### 互斥锁

定义一个互斥锁`sync.Mutex`：

```go
package main

import (
	"fmt"
	"sync"
)

// 定义一个全局变量
var x int

var wg sync.WaitGroup

// 定义一个互斥锁
var lock sync.Mutex

// 定义一个函数，对x进行循环递增操作
func add() {
	for i := 0; i < 5000; i++ {

		// 加锁
		lock.Lock()
		x++
		// 解锁
		lock.Unlock()
	}
	wg.Done()
}

func main() {

	// 开启两个goroutine，同时对变量x进行修改。
	fmt.Println("开启")
	wg.Add(2)
	go add()
	go add()
	wg.Wait()
	fmt.Println("结束")
	fmt.Println("x的值为：", x)
}

```

执行多次的结果：

```go
开启
结束
x的值为： 10000

开启
结束
x的值为： 10000
```

可以看出，执行结果都是一样的，加锁后，同一时刻只能有一个`goroutine`抢到这把锁，从而执行对数据的修改。

### 读写互斥锁

互斥锁是完全互斥的，但是有时候我们只是单纯的读那个资源，加锁是没必要的。对于读多写少的场景，go语言提供了另一种锁，称为读写互斥锁。也就是`sync`包的`RWMutex`类型。

先来看一个加互斥锁的代码：

```go
package main

import (
	"fmt"
	"sync"
	"time"
)

var (
	x    int
	lock sync.Mutex
	wg   sync.WaitGroup
)

// 定义一个读方法
func read() {
	// 加互斥锁
	lock.Lock()
	// 模拟读消耗的时间为1毫秒
	time.Sleep(time.Millisecond * 1)
	// 解互斥锁
	lock.Unlock()
	wg.Done()
}

// 定义一个写方法
func write() {
	// 加互斥锁
	lock.Lock()
	// 修改x的值
	x++
	// 模拟写操作的时间为10毫秒
	time.Sleep(time.Millisecond * 10)
    // 解互斥锁
	lock.Unlock()
	wg.Done()
}

func main() {
	// 程序开始时间
	start := time.Now()

	// 模拟写场景,10次
	for i := 0; i < 10; i++ {
		wg.Add(1)
		go write()
	}
	//模拟读场景，读10000万次
	for i := 0; i < 10000; i++ {
		wg.Add(1)
		go read()
	}
	// 两个goroutine都执行完毕
	wg.Wait()

	// 程序结束时间
	end := time.Now()

	// 读写共耗时
	fmt.Println(end.Sub(start))
}
```

执行多次的结果：

```go
11.21610598s
11.234064043s
11.181700508s
```

很显然，这是加锁不合理的。因为我对数据的修改只有10次，1次消耗10毫秒，修改10次也就100毫秒，也就是0.1秒。对数据的读是不对数据进行修改的，1次消耗1毫秒，1万次就是10000毫秒。也就是10秒。所以，程序最终的耗时是以读的消耗为准。但不应该如此。这时候就用到了读写互斥锁。

读写互斥锁的特点：
 - 可以随便读，多个goroutine同时读，这将可以大大节省时间。
 - 一个`goroutine`在写的时候，其余`goroutine`啥也不能干，不能读也不能写。这就同普通互斥锁一样，保证了数据安全。

修改代码，改用读写互斥锁：

```go
package main

import (
	"fmt"
	"sync"
	"time"
)

var (
	x      int
	rwlock sync.RWMutex
	wg     sync.WaitGroup
)

// 定义一个读方法
func read() {
	// 加读锁
	rwlock.RLock()
	// 模拟读消耗的时间为1毫秒
	time.Sleep(time.Millisecond * 1)
	// 解读锁
	rwlock.RUnlock()
	wg.Done()
}

// 定义一个写方法
func write() {
	// 加写锁
	rwlock.Lock()
	// 修改x的值
	x++
	// 模拟写操作的时间为10毫秒
	time.Sleep(time.Millisecond * 10)
	// 解写锁
	rwlock.Unlock()
	wg.Done()
}

func main() {
	// 程序开始时间
	start := time.Now()

	// 模拟写场景,10次
	for i := 0; i < 10; i++ {
		wg.Add(1)
		go write()
	}
	//模拟读场景，读10000万次
	for i := 0; i < 10000; i++ {
		wg.Add(1)
		go read()
	}
	// 两个goroutine都执行完毕
	wg.Wait()

	// 程序结束时间
	end := time.Now()

	// 读写共耗时
	fmt.Println(end.Sub(start))
}
```

执行过此结果(效果很明显)：

```go
117.891745ms
119.4733ms
119.208284ms
113.77037ms
```

消耗的时间将近快于100倍。

只有在读的操作远大于写的操作时，使用读写锁才能提高性能和效率。

### sync.Once

### sync.Map

## 原子操作

### atomic包

### 示例



