---
layout: post
title: "[Python] Python Decorator로 간단한 profiler 만들기"
date: 2022-06-29 08:43:59
author: Jamie Lee
categories: Backend
tags:	Python
pagination:
enabled: true
---


Django 환경에서 unittest를 하며 간단하게 퍼포먼스를 측정하고 싶었다. 아주 간단하게 프로파일링을 하면 되기 때문에 Middleware 같은 것은 만들지 않았다. 대신에 Python의 Decorator로 만들었다. 앞으로 더 심화되고 유익한 정보를 포함하고 있는 Profiler를 Decorator 형식으로 만들면 유용할 것 같다.

<br>

Decorator는 총 3개를 구현했다.

1. 메모리 사용량을 보기 위한 ram_profiler
2. 함수에서 호출된 쿼리와 쿼리 실행시간을 보기 위한 query_profiler
3. 함수 실행시간 측정을 위한 elapsed_timer

<br>

## ram_profiler

이 프로파일러를 구현하다가 알게 된 사실인데 Python에서 메모리나 CPU 사용량을 보려면 psutill builtin 패키지를 사용하는 경우가 많았다. psutill은 process and system utilities의 약자이다.
Decorator는 함수 호출 전과 후의 메모리 사용량을 가져와, 함수가 호출이 되면서 얼추 어느 정도의 메모리를 사용했는지 비교할 수 있도록 한다. 

<br>

implementation of ram_profiler:

```python
def ram_profiler(fn):
    """
    퍼포먼스 체크를 위한 메모리 프로파일러
    메모리 사용량을 측정할 함수 위에 @ram_profiler 를 추가해주시면 됩니다.

    체크하는 메모리는 아래와 같습니다.
    1) 그냥 현재 memory usage 정보를 그대로 가져오는 경우
    2) 현재 process id를 통해 해당 프로세스의 memory usage를 정확하게 비교하는 경우

    ex)
    @ram_profiler
    def pre_allot_offering(offering: Offering):
    """

    def inner(*args, **kwargs):
        print('\n')
        print("===== memory usage check =====")

        memory_usage_dict = dict(psutil.virtual_memory()._asdict())
        memory_usage_percent = memory_usage_dict['percent']
        print(f"BEFORE CODE :: memory_usage_percent: {memory_usage_percent}%")

        pid = os.getpid()
        current_process = psutil.Process(pid)
        current_process_memory_usage_as_kb = current_process.memory_info()[0] / 2. ** 20
        print(f"BEFORE CODE :: Current memory KB   : {current_process_memory_usage_as_kb: 9.3f} KB")

        target_func = fn(*args, **kwargs)

        print("==" * 20)
        print(f"== {fn.__name__} memory usage check ==")

        memory_usage_dict = dict(psutil.virtual_memory()._asdict())
        memory_usage_percent = memory_usage_dict['percent']
        print(f"AFTER  CODE :: memory_usage_percent: {memory_usage_percent}%")

        pid = os.getpid()
        current_process = psutil.Process(pid)
        current_process_memory_usage_as_kb = current_process.memory_info()[0] / 2. ** 20
        print(f"AFTER  CODE :: Current memory KB   : {current_process_memory_usage_as_kb: 9.3f} KB")

        print('\n')
        return target_func

    return inner
```

<br>

result of ram_profiler:

```python
===== memory usage check =====
BEFORE CODE :: memory_usage_percent: 79.7%
BEFORE CODE :: Current memory KB   :   197.250 KB
========================================
== pre_allot_offering memory usage check ==
AFTER  CODE :: memory_usage_percent: 79.7%
AFTER  CODE :: Current memory KB   :   197.312 KB
```

<br>

## query_profiler

안드로이드를 개발할 때나 Spring boot을 사용할 때 context라는 기능을 많이 사용했는데, Django에서도 보니 굉장히 신기했다.
Decorator는 쿼리를 관리하는 context를 임포트 해와서 타겟 함수를 실행하면서 호출되었던 쿼리들을 캡처해두었다가 함수가 끝이 나면 보여준다. 
ORM에서 실제로 어떤 쿼리가 실행되는지 봐야 할 때, 조건문에 따라 쿼리가 달라질 때, N + 1 쿼리를 잡아 낼 때 사용하기 좋다. 

<br>

implementation of query_profiler:

```python
def query_profiler(fn):
    """
    호출이 된 query를 확인하기 위한 프로파일러
    호출 된 query를 확인할 함수 위헤 @query_profiler 를 추가해주시면 됩니다.

    ex)
    @query_profiler
    def pre_allot_offering(offering: Offering):
    """
    def inner(*args, **kwargs):

        print('\n')
        print(f"===== {fn.__name__} called query check =====")

        with CaptureQueriesContext(connection) as context:
            target_func = fn(*args, **kwargs)

            for index, query in enumerate(context.captured_queries):

                sql = query.get('sql')
                time = query.get('time')

                print(f'CALLED QUERY :: [{index}]')

                print(f'CALLED QUERY :: query: {sql}')
                print(f'CALLED QUERY :: executed time: {time}')
                print("=====")

        return target_func

    return inner
```

<br>

result of query_profiler:

```python
===== pre_allot_offering called query check =====
CALLED QUERY :: [0]
CALLED QUERY :: query: SAVEPOINT `s4377609600_x5`
CALLED QUERY :: executed time: 0.001
=====
CALLED QUERY :: [1]
CALLED QUERY :: query: SELECT `offering_subscription`.`id` # 실제 쿼리는 블라인드
CALLED QUERY :: executed time: 0.00
=====
CALLED QUERY :: [2]
CALLED QUERY :: query: UPDATE `offering_subscription` SET  # 실제 쿼리는 블라인드
CALLED QUERY :: executed time: 0.003
=====
CALLED QUERY :: [3]
CALLED QUERY :: query: SELECT `offering_subscription`.`id`, # 실제 쿼리는 블라인드
=====
CALLED QUERY :: [4]
CALLED QUERY :: query: SELECT `offering_subscription`.`id`, # 실제 쿼리는 블라인드
CALLED QUERY :: executed time: 0.002
=====
CALLED QUERY :: [5]
CALLED QUERY :: query: UPDATE `offering_subscription` SET  # 실제 쿼리는 블라인드
CALLED QUERY :: executed time: 0.002
=====
CALLED QUERY :: [6]
CALLED QUERY :: query: RELEASE SAVEPOINT `s4377609600_x5`
CALLED QUERY :: executed time: 0.001
=====
```

<br>

## elapsed_timer

이전 회사에서 Middleware를 개발할 때 해당 request가 몇 번 째 request인지, 실행시간은 얼마인지를 정말 유사한 형태의 코드로 logging 한 게 기억이 난다. 너무 간단한 형태라서 퍼포먼스 측정을 위한 decorator라고 하기에도 살짝 민망하다.
Decorator는 함수의 시작시간과 끝나는 시간을 측정하여 함수 실행시간이 어느정도인지를 계산한다. 

<br>


implementaion of elapsed_timer:

```python
def elapsed_timer(fn):
    """
    퍼포먼스 체크를 위한 실행 시간 측정 타이머
    실행 시간을 측정할 함수 위에 @elapsed_timer 를 추가해주시면 됩니다.
    퍼포먼스 테스트가 끝나면 지워주시길 바랍니다.

    ex)
    @elapsed_timer
    def pre_allot_offering(offering: Offering):
    """

    def inner(*args, **kwargs):

        print('\n')
        print(f"===== {fn.__name__} elapsed time check =====")

        start = perf_counter()
        target_func = fn(*args, **kwargs)
        end = perf_counter()

        print(f'ELAPSED :: total:   start: {start} sec - end: {end} sec')

        duration = end - start
        print(f'ELAPSED :: duration: {duration} sec')
        print(f'ELAPSED :: duration in minutes : {str(timedelta(seconds=duration))} mins')
        print('\n')

        return target_func

    return inner
```

<br>

result of elapsed_timer:

```python
===== pre_allot_offering elapsd time check =====
ELAPSED :: total:   start: 8.705878 sec - end: 8.72449375 sec
ELAPSED :: duration: 0.018615750000000375 sec
ELAPSED :: duration in minutes : 0:00:00.018616 mins
```

<br>

---

## 개선해야 하는 부분

Python의 Decorator는 함수의 시작 - 끝 부분에 추가 action을 할 수 있게 해주는 Wrapper이다. 함수 중간중간에 프로파일링을 해야 한다면 다른 방법으로 접근을 해야 할 것 같다.

메모리를 프로파일링하는 것에 한정한다면 Python에서 builtin으로 제공하는 `memory_profiler` 라는 것이 있다. 패키지 안의 `@profiler` 데코레이터를 사용하면 함수 안에서 코드가 실행이 될 때 한 줄 한 줄 얼마의 메모리를 사용했는지를 볼 수 있다.

example of profiler:

```python
from memory_profiler import profile

@profile
def main_func():
    import random
    arr1 = [random.randint(1,10) for i in range(100000)]
    arr2 = [random.randint(1,10) for i in range(100000)]
    arr3 = [arr1[i]+arr2[i] for i in range(100000)]
    del arr1
    del arr2
    tot = sum(arr3)
    del arr3
    print(tot)

if __name__ == "__main__":
    main_func()
```

result of profiler:

```python
Line #    Mem usage    Increment   Line Contents
================================================
     3     37.0 MiB     37.0 MiB   @profile
     4                             def main_func():
     5     37.0 MiB      0.0 MiB       import random
     6     37.6 MiB      0.3 MiB       arr1 = [random.randint(1,10) for i in range(100000)]
     7     38.4 MiB      0.3 MiB       arr2 = [random.randint(1,10) for i in range(100000)]
     8     39.9 MiB      0.5 MiB       arr3 = [arr1[i]+arr2[i] for i in range(100000)]
     9     39.9 MiB      0.0 MiB       del arr1
    10     38.0 MiB      0.0 MiB       del arr2
    11     38.0 MiB      0.0 MiB       tot = sum(arr3)
    12     37.2 MiB      0.0 MiB       del arr3
    13     37.2 MiB      0.0 MiB       print(tot)
```

이 데코레이터를 써보려고 했는데 ORM을 호출하는 부분이 있어서 인지 recursive 하게 동작을 하다가 스택이 터져서 사용을 할 수 없었다. 함수가 한 줄 씩 호출되면서 메모리 사용량을 보기에는 정말 좋은 데코레이터 처럼 보이는데 꼭 다음에 써보도록 해야겠다.
