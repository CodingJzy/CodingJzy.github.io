---
title: go语言的单元测试
date: 2019-07-31 21:55:49
categories: Go
keywords: go语言的单元测试
description: go语言的单元测试
---

# go语言的测试

不写测试的开发不是好程序员。

## go test 工具

go语言测试依赖`go test`命令。编写测试代码和编写普通的go代码过程是类似的。

在包目录中，所有以`_test.go`为后缀名的源码文件都是`go test`测试的一部分，不会被`go build`编译到最终的可执行文件中。

在`*_test.go`文件中有三种类型的函数，单元测试函数、基准测试函数、示例函数。

|   类型   |      格式       |              作用              |
| :------: | :-------------: | :----------------------------: |
| 测试函数 |   前缀为Test    | 测试程序的一些逻辑行为是否正确 |
| 基准函数 | 前缀为Benchmark |         测试函数的性能         |
| 示例函数 |  前缀为Example  |       问文档提供示例文档       |

## 测试函数

### 测试函数的格式

```go
func TestName(t *testing.T) {
    ...
}
```

### 测试函数的示例

#### 需要测试的代码

```go
package split

import "strings"

// 定义一个字符串切割的函数，用sep切割原字符串，并返回切割后的字符串切片
// a:b:c --> [a b c]
func Split(s, sep string) (res []string) {
	// 当sep在s中，拿到sep的索引。只要索引大于0就说明有多个sep。可以进行多次切割。
	index := strings.Index(s, sep)
	for index >= 0 {
		res = append(res, s[:index])
		s = s[index+1:]
		index = strings.Index(s, sep)
	}
	res = append(res, s)
	return
}

```

#### 编写测试函数

```go
package split

import (
	"reflect"
	"testing"
)

func TestSplit(t *testing.T) {
	s := "a:b:c"
	sep := ":"
	sp := Split(s, sep)
	sp0 := []string{"a", "b", "c"}
	if ok := reflect.DeepEqual(sp, sp0); !ok {
		t.Fatalf("测试失败：期望得到：%v， 实际得到：%v\n", sp0, sp)
	}
	t.Logf("测试通过，得到：%v", sp0)
}

// 如果切割的字符串不在原有字符串
func TestSplit2(t *testing.T) {
	s := "123321"
	sep := "0"
	sp := Split(s, sep)
	sp0 := []string{"123321"}
	if ok := reflect.DeepEqual(sp, sp0); !ok {
		t.Fatal("测试失败")
	}
	t.Logf("测试通过，得到：%v", sp0)
}

```

#### 测试所有

写完测试的函数后，可以在当前包下用`go tes`t开始测试。默认会测试所有的测试函数：

```go
jiang_wei@master01:~/code/go/src/golang/study/split$ go test
PASS
ok      golang/study/split      0.001s
```

#### 测试的详细信息

但是，这样看不出详细信息，可以加参数`-v`：

```go
jiang_wei@master01:~/code/go/src/golang/study/split$ go test -v
=== RUN   TestSplit
--- PASS: TestSplit (0.00s)
    split_test.go:16: 测试通过，得到：[a b c]
=== RUN   TestSplit2
--- PASS: TestSplit2 (0.00s)
    split_test.go:28: 测试通过，得到：[123321]
PASS
ok      golang/study/split      0.001s
```

#### 测试单个

当我们只想测试一个功能时，可以加`-run` or `--run`：

```go
jiang_wei@master01:~/code/go/src/golang/study/split$ go test -v -run Split2
=== RUN   TestSplit2
--- PASS: TestSplit2 (0.00s)
    split_test.go:28: 测试通过，得到：[123321]
PASS
ok      golang/study/split      0.001s

```

这个功能是有问题的，当我们的切割符是多个字符时，会测试失败。

添加测试函数：

```go
// 如果切割的字符串是多个字符
func TestSplit3(t *testing.T) {
	s := "1200340056007800"
	sep := "00"
	sp := Split(s, sep)
	sp0 := []string{"12", "34", "56", "78", ""}
	if ok := reflect.DeepEqual(sp, sp0); !ok {
		t.Fatalf("测试失败，期望得到：%v 实际得到：%v", sp0, sp)
	}
	t.Logf("测试通过，得到：%v", sp0)
}
```

测试：

```go
jiang_wei@master01:~/code/go/src/golang/study/split$ go test -v -run Split3
=== RUN   TestSplit3
--- FAIL: TestSplit3 (0.00s)
    split_test.go:38: 测试失败，期望得到：[12 34 56 78 ] 实际得到：[12 034 056 078 0]
FAIL
exit status 1
FAIL    golang/study/split      0.001s
```

可以看出测试驱动开发，修改我们的代码。

```go
// 如果切割的字符串是多个字符
func TestSplit3(t *testing.T) {
	s := "1200340056007800"
	sep := "00"
	sp := Split(s, sep)
	sp0 := []string{"12", "34", "56", "78", ""}
	if ok := reflect.DeepEqual(sp, sp0); !ok {
		t.Fatalf("测试失败，期望得到：%v 实际得到：%v", sp0, sp)
	}
	t.Logf("测试通过，得到：%v", sp0)
}
```

继续测试：

```go
jiang_wei@master01:~/code/go/src/golang/study/split$ go test -v
=== RUN   TestSplit
--- PASS: TestSplit (0.00s)
    split_test.go:16: 测试通过，得到：[a b c]
=== RUN   TestSplit2
--- PASS: TestSplit2 (0.00s)
    split_test.go:28: 测试通过，得到：[123321]
=== RUN   TestSplit3
--- PASS: TestSplit3 (0.00s)
    split_test.go:40: 测试通过，得到：[12 34 56 78 ]
PASS
ok      golang/study/split      0.001s
```

### 测试组

将多个测试用例放到一起就是测试组。

上面我们测试了三个功能，用了三个函数，这次我们只编写一个测试函数来完成所有的测试。

```go
package split

import (
	"reflect"
	"testing"
)

func TestGroup(t *testing.T) {
	type test struct {
		str  string
		sep  string
		want []string
	}

	tests := map[string]test{
		"split1": {"a:b:c", ":", []string{"a", "b", "c"}},
		"split2": {"123321", "0", []string{"123321"}},
		"split3": {"001200340056007800", "00", []string{"", "12", "34", "56", "78", ""}},
	}

	for testName, tc := range tests {
		get := Split(tc.str, tc.sep)
		if !reflect.DeepEqual(get, tc.want) {
			t.Fatalf("测试%v失败，期望得到：%#v 实际得到：%#v", testName, tc.want, get)
		}
		t.Logf("测试%v通过，得到：%#v", testName, tc.want)
	}
}
```

测试：

```linux
jiang_wei@master01:~/code/go/src/golang/study/split$ go test -v
=== RUN   TestGroup
--- PASS: TestGroup (0.00s)
    split_test.go:26: 测试split1通过，得到：[]string{"a", "b", "c"}
    split_test.go:26: 测试split2通过，得到：[]string{"123321"}
    split_test.go:26: 测试split3通过，得到：[]string{"", "12", "34", "56", "78", ""}
PASS
ok      golang/study/split      0.001s
```

### 子测试

上面的测试组也挺方便，但是当测试用例过多的时候，无法一目了然看出哪个测试失败，无法控制我执行某个测试用例。在`go 1.7+`版本中加入了子测试。我们可以按照如下方式使用`t.Run`执行子测试：

```go
package split

import (
	"reflect"
	"testing"
)

func TestGroup(t *testing.T) {
	type test struct {
		str  string
		sep  string
		want []string
	}

	tests := map[string]test{
		"split1": {"a:b:c", ":", []string{"a", "b", "c"}},
		"split2": {"123321", "0", []string{"123321"}},
		"split3": {"001200340056007800", "00", []string{"", "12", "34", "56", "78", ""}},
	}

	for testName, tc := range tests {
		t.Run(testName, func(t *testing.T) {
			get := Split(tc.str, tc.sep)
			if !reflect.DeepEqual(get, tc.want) {
				t.Fatalf("测试%v失败，期望得到：%#v 实际得到：%#v", testName, tc.want, get)
			}
			t.Logf("测试%v通过，得到：%#v", testName, tc.want)
		})
	}
}
```

这样做有什么好处呢？看看就知道了。

```linux
jiang_wei@master01:~/code/go/src/golang/study/split$ go test -v
=== RUN   TestGroup
=== RUN   TestGroup/split1
=== RUN   TestGroup/split2
=== RUN   TestGroup/split3
--- PASS: TestGroup (0.00s)
    --- PASS: TestGroup/split1 (0.00s)
        split_test.go:27: 测试split1通过，得到：[]string{"a", "b", "c"}
    --- PASS: TestGroup/split2 (0.00s)
        split_test.go:27: 测试split2通过，得到：[]string{"123321"}
    --- PASS: TestGroup/split3 (0.00s)
        split_test.go:27: 测试split3通过，得到：[]string{"", "12", "34", "56", "78", ""}
PASS
ok      golang/study/split      0.001s
```

是不是更详细了，还有更好玩的：

```linux
jiang_wei@master01:~/code/go/src/golang/study/split$ go test --run /split3 -v
=== RUN   TestGroup
=== RUN   TestGroup/split3
--- PASS: TestGroup (0.00s)
    --- PASS: TestGroup/split3 (0.00s)
        split_test.go:27: 测试split3通过，得到：[]string{"", "12", "34", "56", "78", ""}
PASS
ok      golang/study/split      0.001s
```

可以看出，和我们之前编写的三个测试用例一样，可以单独对一个用例进行测试。

### 测试覆盖率

测试覆盖率是你的代码被测试套件覆盖的百分比。通常我们使用的都是语句的覆盖率，也就是在测试中至少被运行一次的代码占总代码的比例。

```linux
jiang_wei@master01:~/code/go/src/golang/study/split$ go test -cover
PASS
coverage: 100.0% of statements
ok      golang/study/split      0.001s

```

从上面的结果可以看到我们的测试用例覆盖了100%的代码。

我们在我们的功能代码中写一个与我们的测试模块功能无关的函数，看看测试覆盖率变成了多少：

```go
func Add(a, b int) int {
	return a + b
}
```

```linux
jiang_wei@master01:~/code/go/src/golang/study/split$ go test -cover
PASS
coverage: 87.5% of statements
ok      golang/study/split      0.001s
```

另外一些功能

- 将覆盖率的日志记录输出到文件：`go test -cover -coverprofile=c.out`
- 以html方式打开上一步生成的文件：`go tool cover -html=c.out`

## 基准测试

测试性能

### 基准测试函数格式

```go
func BenchmarkName(b *testing.B){
    ...
}
```

### 基准测试示例

```go
package split

import "testing"

func BenchmarkSplit(b *testing.B) {
	b.Log("这是一个基准测试")
	for i := 0; i < b.N; i++ {
		Split("a:b:c", ":")
	}
}
```

测试：

```linux
jiang_wei@master01:~/code/go/src/golang/study/split$ go test -bench=Split
goos: linux
goarch: amd64
pkg: golang/study/split
BenchmarkSplit-4        10000000               223 ns/op
--- BENCH: BenchmarkSplit-4
    split_test.go:6: 这是一个基准测试
    split_test.go:6: 这是一个基准测试
    split_test.go:6: 这是一个基准测试
    split_test.go:6: 这是一个基准测试
    split_test.go:6: 这是一个基准测试
PASS
ok      golang/study/split      2.471s
```

我们还可以为基准测试添加`-benchmem`参数，来获得内存分配的统计数据。

```linux
jiang_wei@master01:~/code/go/src/golang/study/split$ go test -bench=Split -benchmem
goos: linux
goarch: amd64
pkg: golang/study/split
BenchmarkSplit-4        10000000               220 ns/op             112 B/op          3 allocs/op
--- BENCH: BenchmarkSplit-4
    split_test.go:6: 这是一个基准测试
    split_test.go:6: 这是一个基准测试
    split_test.go:6: 这是一个基准测试
    split_test.go:6: 这是一个基准测试
    split_test.go:6: 这是一个基准测试
PASS
ok      golang/study/split      2.436s
```

其中，`112 B/op`表示每次操作内存分配了112字节，`3 allocs/op`则表示每次操作进行了3次内存分配。 我们将我们的`Split`函数优化如下：

```go
package split

import "strings"

// 定义一个字符串切割的函数，用sep切割原字符串，并返回切割后的字符串切片
// a:b:c --> [a b c]
func Split(s, sep string) []string {
	// 提前申请好容量
	count := strings.Count(s, sep)
	result := make([]string, 0, count+1)

	index := strings.Index(s, sep)
	for index >= 0 {
		result = append(result, s[:index])
		s = s[index+len(sep):]
		index = strings.Index(s, sep)
	}
	return append(result, s)
}
```

这一次我们提前使用make函数将result初始化为一个容量足够大的切片，而不再像之前一样通过调用append函数来追加。我们来看一下这个改进会带来多大的性能提升：

测试：

```linux
jiang_wei@master01:~/code/go/src/golang/study/split$ go test -bench=Split -benchmem
goos: linux
goarch: amd64
pkg: golang/study/split
BenchmarkSplit-4        20000000               107 ns/op              48 B/op          1 allocs/op
--- BENCH: BenchmarkSplit-4
    split_test.go:6: 这是一个基准测试
    split_test.go:6: 这是一个基准测试
    split_test.go:6: 这是一个基准测试
    split_test.go:6: 这是一个基准测试
    split_test.go:6: 这是一个基准测试
PASS
ok      golang/study/split      2.260s
```

这个使用make函数提前分配内存的改动，减少了2/3的内存分配次数，并且减少了一半的内存分配。

### 性能比较函数

编写斐波拉契函数：

```go
package fib

func Fib(n int) int {
	if n < 2 {
		return n
	}
	return Fib(n-1) + Fib(n-2)
}

```

编写性能比较函数：

```go
package fib

import "testing"

func benchmarkFib(b *testing.B, n int) {
	for i := 0; i < b.N; i++ {
		Fib(n)
	}
}

func BenchmarkFib1(b *testing.B) {
	benchmarkFib(b, 1)
}

func BenchmarkFib2(b *testing.B) {
	benchmarkFib(b, 2)
}

func BenchmarkFib20(b *testing.B) {
	benchmarkFib(b, 20)
}

func BenchmarkFib40(b *testing.B) {
	benchmarkFib(b, 40)
}
```

测试：

```linux
jiang_wei@master01:~/code/go/src/golang/study/fib$ go test -bench=.
goos: linux
goarch: amd64
pkg: golang/study/fib
BenchmarkFib1-4         1000000000               2.27 ns/op
BenchmarkFib2-4         200000000                6.40 ns/op
BenchmarkFib20-4           30000             46833 ns/op
BenchmarkFib40-4               2         703580232 ns/op
PASS
ok      golang/study/fib        8.512s
```

### 重置时间

`b.ResetTimer`之前的处理不会放到执行时间里，也不会输出到报告中，例如一些连接数据库的操作，不应该计算在内的，所以可以在之前做一些不计划作为测试报告的操作。例如：

```go
func BenchmarkSplit(b *testing.B) {
	time.Sleep(5 * time.Second) // 假设需要做一些耗时的无关操作
	b.ResetTimer()              // 重置计时器
	for i := 0; i < b.N; i++ {
		Split("沙河有沙又有河", "沙")
	}
}
```

### 并行测试

`RunParallel`会创建出多个`goroutine`，并将`b.N`分配给这些`goroutine`执行， 其中`goroutine`数量的默认值为`GOMAXPROCS`。用户如果想要增加非CPU受限（non-CPU-bound）基准测试的并行性， 那么可以在`RunParallel`之前调用`SetParallelism` 。

```go
package split

import "testing"

func BenchmarkSplit(b *testing.B) {
	b.RunParallel(func(pb *testing.PB) {
		for pb.Next() {
			Split("a:b:c", ":")
		}
	})
}

func BenchmarkSplit1(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Split("a:b:c", ":")
	}
}
```

测试：

```linux
jiang_wei@master01:~/code/go/src/golang/study/split$ go test -bench=. -v
goos: linux
goarch: amd64
pkg: golang/study/split
BenchmarkSplit-4        20000000                64.4 ns/op
BenchmarkSplit1-4       20000000               111 ns/op
PASS
ok      golang/study/split      3.692s
```

## Setup与TearDown

测试程序有时需要在测试之前进行额外的设置（setup）或在测试之后进行拆卸（teardown）。

比如说测试之前进行数据库的连接。

### TestMain

```go
package split

import (
	"fmt"
	"os"
	"reflect"
	"testing"
)

func TestSplit(t *testing.T) {
	s := "1200340056007800"
	sep := "00"
	sp := Split(s, sep)
	sp0 := []string{"12", "34", "56", "78", ""}
	if ok := reflect.DeepEqual(sp, sp0); !ok {
		t.Fatalf("测试失败，期望得到：%#v 实际得到：%#v", sp0, sp)
	}
	t.Logf("测试通过，得到：%#v", sp0)
}

func TestMain(m *testing.M) {
	// 测试之前的做一些设置
	fmt.Println("write setup code here...")

	// 如果 TestMain 使用了 flags，这里应该加上flag.Parse()
	// 执行测试，成功或失败会返回一个状态吗，退出需传入
	retCode := m.Run()

	// 测试之后做一些拆卸工作
	fmt.Println("write teardown code here...")

	// 退出测试
	os.Exit(retCode)
}
```

测试：

```linux
jiang_wei@master01:~/code/go/src/golang/study/split$ go test -v
write setup code here...
=== RUN   TestSplit
--- PASS: TestSplit (0.00s)
    split_test.go:18: 测试通过，得到：[]string{"12", "34", "56", "78", ""}
PASS
write teardown code here...
ok      golang/study/split      0.001s
```

### 组测试的Setup与TearDown

有时候我们可能需要为每个测试集设置Setup与Teardown：

编写测试函数：

```go
package split

import (
	"reflect"
	"testing"
)

// 测试组的Setup与Teardown
func setupTestCase(t *testing.T) func(t *testing.T) {
	t.Log("测试之前")
	return func(t *testing.T) {
		t.Log("测试之后")
	}
}

func TestGroup(t *testing.T) {
	type test struct {
		str  string
		sep  string
		want []string
	}

	tests := map[string]test{
		"split1": {"a:b:c", ":", []string{"a", "b", "c"}},
		"split2": {"123321", "0", []string{"123321"}},
		"split3": {"001200340056007800", "00", []string{"", "12", "34", "56", "78", ""}},
	}

	// 测试之前执行setup操作
	teardownTestCase := setupTestCase(t)
	// 测试之后执行testdoen操作
	defer teardownTestCase(t)

	for testName, tc := range tests {
		get := Split(tc.str, tc.sep)
		if !reflect.DeepEqual(get, tc.want) {
			t.Fatalf("测试%v失败，期望得到：%#v 实际得到：%#v", testName, tc.want, get)
		}
		t.Logf("测试%v通过，得到：%#v", testName, tc.want)
	}
}
```

测试：

```linux
jiang_wei@master01:~/code/go/src/golang/study/split$ go test -v
=== RUN   TestGroup
--- PASS: TestGroup (0.00s)
    split_test.go:10: 测试之前
    split_test.go:39: 测试split1通过，得到：[]string{"a", "b", "c"}
    split_test.go:39: 测试split2通过，得到：[]string{"123321"}
    split_test.go:39: 测试split3通过，得到：[]string{"", "12", "34", "56", "78", ""}
    split_test.go:12: 测试之后
PASS
ok      golang/study/split      0.002s
```

### 子测试的Setup与TearDown

有可能需要为每个子测试设置Setup与Teardown。

```go
package split

import (
	"reflect"
	"testing"
)

// 子测试的Setup与Teardown
func setupSubTest(t *testing.T) func(t *testing.T) {
	t.Log("测试之前")
	return func(t *testing.T) {
		t.Log("测试之后")
	}
}

func TestGroup(t *testing.T) {
	type test struct {
		str  string
		sep  string
		want []string
	}

	tests := map[string]test{
		"split1": {"a:b:c", ":", []string{"a", "b", "c"}},
		"split2": {"123321", "0", []string{"123321"}},
		"split3": {"001200340056007800", "00", []string{"", "12", "34", "56", "78", ""}},
	}

	for testName, tc := range tests {

		t.Run(testName, func(t *testing.T) {

			// 子测试之前执行setup操作
			teardownSubTest := setupSubTest(t)
			// 子测试之后执行testdoen操作
			defer teardownSubTest(t)

			get := Split(tc.str, tc.sep)
			if !reflect.DeepEqual(get, tc.want) {
				t.Fatalf("测试%v失败，期望得到：%#v 实际得到：%#v", testName, tc.want, get)
			}
			t.Logf("测试%v通过，得到：%#v", testName, tc.want)
		})
	}
}
package split

import (
	"reflect"
	"testing"
)

// 子测试的Setup与Teardown
func setupSubTest(t *testing.T) func(t *testing.T) {
	t.Log("测试之前")
	return func(t *testing.T) {
		t.Log("测试之后")
	}
}

func TestGroup(t *testing.T) {
	type test struct {
		str  string
		sep  string
		want []string
	}

	tests := map[string]test{
		"split1": {"a:b:c", ":", []string{"a", "b", "c"}},
		"split2": {"123321", "0", []string{"123321"}},
		"split3": {"001200340056007800", "00", []string{"", "12", "34", "56", "78", ""}},
	}

	for testName, tc := range tests {

		t.Run(testName, func(t *testing.T) {

			// 子测试之前执行setup操作
			teardownSubTest := setupSubTest(t)
			// 子测试之后执行testdoen操作
			defer teardownSubTest(t)

			get := Split(tc.str, tc.sep)
			if !reflect.DeepEqual(get, tc.want) {
				t.Fatalf("测试%v失败，期望得到：%#v 实际得到：%#v", testName, tc.want, get)
			}
			t.Logf("测试%v通过，得到：%#v", testName, tc.want)
		})
	}
}
package split

import (
	"reflect"
	"testing"
)

// 子测试的Setup与Teardown
func setupSubTest(t *testing.T) func(t *testing.T) {
	t.Log("测试之前")
	return func(t *testing.T) {
		t.Log("测试之后")
	}
}

func TestGroup(t *testing.T) {
	type test struct {
		str  string
		sep  string
		want []string
	}

	tests := map[string]test{
		"split1": {"a:b:c", ":", []string{"a", "b", "c"}},
		"split2": {"123321", "0", []string{"123321"}},
		"split3": {"001200340056007800", "00", []string{"", "12", "34", "56", "78", ""}},
	}

	for testName, tc := range tests {

		t.Run(testName, func(t *testing.T) {

			// 子测试之前执行setup操作
			teardownSubTest := setupSubTest(t)
			// 子测试之后执行testdoen操作
			defer teardownSubTest(t)

			get := Split(tc.str, tc.sep)
			if !reflect.DeepEqual(get, tc.want) {
				t.Fatalf("测试%v失败，期望得到：%#v 实际得到：%#v", testName, tc.want, get)
			}
			t.Logf("测试%v通过，得到：%#v", testName, tc.want)
		})
	}
}
```

测试：

```linux
jiang_wei@master01:~/code/go/src/golang/study/split$ go test -v 
=== RUN   TestGroup
=== RUN   TestGroup/split1
=== RUN   TestGroup/split2
=== RUN   TestGroup/split3
--- PASS: TestGroup (0.00s)
    --- PASS: TestGroup/split1 (0.00s)
        split_test.go:10: 测试之前
        split_test.go:42: 测试split1通过，得到：[]string{"a", "b", "c"}
        split_test.go:12: 测试之后
    --- PASS: TestGroup/split2 (0.00s)
        split_test.go:10: 测试之前
        split_test.go:42: 测试split2通过，得到：[]string{"123321"}
        split_test.go:12: 测试之后
    --- PASS: TestGroup/split3 (0.00s)
        split_test.go:10: 测试之前
        split_test.go:42: 测试split3通过，得到：[]string{"", "12", "34", "56", "78", ""}
        split_test.go:12: 测试之后
PASS
ok      golang/study/split      0.001s

jiang_wei@master01:~/code/go/src/golang/study/split$ go test -v -run /split2
=== RUN   TestGroup
=== RUN   TestGroup/split2
--- PASS: TestGroup (0.00s)
    --- PASS: TestGroup/split2 (0.00s)
        split_test.go:10: 测试之前
        split_test.go:42: 测试split2通过，得到：[]string{"123321"}
        split_test.go:12: 测试之后
PASS
ok      golang/study/split      0.001s
```

## 示例函数

下面的代码是我们为`Split`函数编写的一个示例函数：

```go
package split

import (
	"fmt"
)

func ExampleSplit() {
	fmt.Println(Split("a:b:c", ":"))
	fmt.Println(Split("00110022003300", "00"))
	// Output:
	// [a b c]
	// [ 11 22 33 ]
}
```

测试：

```linux
jiang_wei@master01:~/code/go/src/golang/study/split$ go test -run Split -v
=== RUN   ExampleSplit
--- PASS: ExampleSplit (0.00s)
PASS
ok      golang/study/split      0.001s
```

修改`Output`：

```go
package split

import (
	"fmt"
)

func ExampleSplit() {
	fmt.Println(Split("a:b:c", ":"))
	fmt.Println(Split("00110022003300", "00"))
	// Output:
	// [a b c]
	// [11 22 33]
}
```

测试：

```linux
jiang_wei@master01:~/code/go/src/golang/study/split$ go test -run Split -v
=== RUN   ExampleSplit
--- FAIL: ExampleSplit (0.00s)
got:
[a b c]
[ 11 22 33 ]
want:
[a b c]
[11 22 33]
FAIL
exit status 1
FAIL    golang/study/split      0.002s
```



　