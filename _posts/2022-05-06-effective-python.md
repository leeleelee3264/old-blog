---
layout: post
title: "[Python] Effective python Chapter 1"
date: 2022-06-15 08:43:59
author: Jamie Lee
categories: Book
tags:	Git
cover:  "/assets/img/git.png"
pagination:
enabled: true
---



# Chapter 1 파이썬답게 생각하기

## Better way 1 사용중인 파이썬의 버전을 알아두라

현재 사용하고 있는 파이썬의 버전을 알고싶다면 아래의 방법대로 하면 된다.

In command line:

```python
python --version 
```



In python source code:

```python
import sys
print (sys.version_info) 
# sys.version_info(major=3, minor=8, micro=12, releaselevel='final', serial=0)
   
print(sys.version) 
# 3.8.12 (default, Oct 22 2021, 17:47:41) 
#[Clang 13.0.0 (clang-1300.0.29.3)]
```

파이썬2는 2020년 1월 1일부로 수명이 다했다. 이제 더이상 버그수정, 보안 패치가 이뤄지지 않는다. 공식적으로 지원을 하지 않은 언어이기 때문에 사용에 대한 책임은 개발자에게 따른다.

파이썬2로 작성된 코드를 사용해야 한다면 아래와 같은 라이브러리의 도움을 받아야 한다.

2to3: 파이썬을 설치할 때 자동으로 설치된다.

six: 한 개의 파이썬 파일로 만들어져있다. 실제 사용 예제는 아래와 같다.

```python
return (
            six.text_type(user.pk) + six.text_type(timestamp) + six.text_type(user.username)
            + six.text_type(user.uuid) + six.text_type(user.type)
        )
```
