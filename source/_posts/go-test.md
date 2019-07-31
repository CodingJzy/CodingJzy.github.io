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

## 测试函数

### 测试函数的格式

### 测试函数的示例

```go
package split

import "strings"

// 定义一个字符串切割的函数，用spe切割原字符串，并返回切割后的字符串切片
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

测试：

```go
package split

import (
	"reflect"
	"testing"
)

func TestSplit(t *testing.T) {
	s := "a:b:c"
	spe := ":"
	sp := Split(s, spe)
	sp0 := []string{"a", "b", "c"}
	if ok := reflect.DeepEqual(sp, sp0); !ok {
		t.Fatalf("测试失败：期望得到：%v， 实际得到：%v\n", sp0, sp)
	}
	t.Logf("测试通过，得到：%v", sp0)
}

// 如果切割的字符串不在原有字符串
func TestSplit2(t *testing.T) {
	s := "123321"
	spe := "0"
	sp := Split(s, spe)
	sp0 := []string{"123321"}
	if ok := reflect.DeepEqual(sp, sp0); !ok {
		t.Fatal("测试失败")
	}
	t.Logf("测试通过，得到：%v", sp0)
}

```



### 测试组

### 子测试

### 测试覆盖率

## 基准测试

### 基准测试函数格式

### 基准测试示例

### 性能比较函数

### 重置时间

### 并行测试

## Setup与TearDown

### TestMain

### 子测试的Setup与TearDown

## 示例函数

### 示例函数的格式

### 示例函数示例

　