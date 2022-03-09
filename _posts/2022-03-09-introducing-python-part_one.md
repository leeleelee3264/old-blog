---
layout: post
title: "[Python] Introducing Python - Part1"
date: 2022-03-09 08:43:59
author: Jamie Lee
categories: Book
tags:	python
cover:  "/assets/img/python_logo.jpg"
pagination:
enabled: true
---

![Untitled](/assets/img/post/introducting_python.png)



처음 시작하는 파이썬을 읽고 내용을 정리한 포스팅이다. 총 12 chapter로 되어있고, 정리가 필요한 Chapter를 선별하여 part1, part2 로 나누었다. 각 part에서 다루는 chapter는 아래와 같다.

Part1

- Chapter 1 파이 맛보기
- Chapter 2 파이 재료: 숫자, 문자열 변수
- Chapter 3 파이 채우기: 리스트, 튜플, 딕셔너리, 셋
- Chatper 4 파이 크러스트: 코드 구조
- Chapter 5 파이 포장하기: 모듈, 패키지, 프로그램

Part2

- Chatper 6 객체와 클래스
- Chapter 7 데이터 주무르기
- Chapter 10 시스템
- Chatper 11 병행성과 네트워크
- Chapter 12 파이 환경 설정 및 도구: 파이써니스타 되기

Part2는 아래의 링크에서 볼 수 있다.

[[처음 시작하는 파이썬 Part2]](empty-link)


<br>


---

# 1장 파이 맛보기

파이썬은 인터프리터 언어다. 대표적인 인터프리터 언어는 자바 스크립트가 있다. 인터프리터는 소스코드를 바로 실행한다. 인터프리터의 반대는 컴파일 언어로, 자바가 이에 속한다. 컴파일 언어는 처음 프로그램을 시작할 때 모든 코드를 기계어로 바꾼다 (컴파일 한다). 그래서 처음에 프로그램을 실행할 때 시간이 오래 걸린다. 반면 인터프리터는 바로바로 실행을 하다보니 처음에 속도가 비교적 빠르다.

하지만 한 번 컴파일을 하면 실행시 기계어를 불러와 더 빨리 실행을 할 수 있어 매번 실행시마다 번역을 거치는 인터프리터 언어보다 속도가 더 빨라진다. 파이썬이 개발을 빠르게 할 수 있다는 이유도 거대한 크기의 기계어를 만들어내지 않고 실행이 가능해서가 아닐까.

<br> 

---

# 2장 파이 재료: 숫자, 문자열 변수

파이썬은 문자를 변형 할 수 없다. st[0] = 'e' 이런식으로 변경을 할 수 없다. 즉, 불변객체이다. 문자열도 중간에 수정을 할 수 없고 아예 객체를 새로 만드는 replace() 메서드를 이용해서 문자열을 변경해야 한다. 문자열을 불변으로 만드는 이유는 Java와 마찬가지로 프로그래밍을 편리하기 위해서다.

슬라이싱을 이용해 문자 reverse 하기

```python
st = "eererewrvfgrhfos"
re_st = st[::-1] # sofhrgfvrwereree
```

<br>

---

# 3장 파이 채우기: 리스트, 튜플, 딕셔너리, 셋

파이썬에서 기본으로 제공하는 자료구조에 대해 알아본다.



자료구조에서 항목을 삭제하는 커맨드는 del 인데, 이 del은 자료구조의 함수가 아닌 파이썬 구문이다. del은 객체로부터 이름을 분리하고 객체의 메모리를 비워준다.

```bash
del full[2]

# full.del(2) 처럼 쓰지 못한다.
```

## 리스트

리스트는 변경 가능하다. 항목을 할당하고, 자유롭게 수정 삭제를 할 수 있다.

```bash
# 생성 
empty = []
empyt2 = list()
full = [1, 2, 3]

# 리스트의 끝에 항목 추가하기  append()
full.appned(4) 

# 리스트 병합하기 extend()
added = [5, 6, 7, 8]
full.extend(added)  # [1, 2, 3, 4, 5, 6, 7, 8]
full += added # [1, 2, 3, 4, 5, 6, 7, 8]

# append 를 쓰면 리스트 자체가 추가된다 
full.appned(added) # [1, 2, 3, 4, [5, 6, 7, 8]]

# 리스트 정렬 
# sort()는 리스트 자체를 내부적으로 정렬한다. 
# sorted() 는 리스트의 정렬된 복사본을 반환한다. 
full.sort()
new_sort = full.sorted() 
```

## 튜플

튜플은 불변한다. 튜플에 항목을 할당하고 나서는 바꿀 수 없다. 때문에 튜플을 상수 리스트라 볼 수 있다.

```bash
# 생성 
empty_tuple = ()
# 콤마로 값을 나열해도 튜플을 만들 수 있다. 
empty_tuple = 1, 2, 3
empty_tuple = (1, 2, 3) 

# 튜플의 나열하는 특성을 이용해서 객체 생성없이 swap하기 
password = '12'
icecream = 'sweet' 
password, icecream = icecream, password 

```

리스트가 아닌 불변객체라 함수 지원이 더 적은 튜플을 사용하는 이유

- 더 적은 공간을 사용한다.
- 실수로 값을 바꿀 위험이 없다.
- 튜플을 딕셔너리 키로 사용이 가능하다.
- 네임드 튜플 은 객체의 대안이 될 수 있다. — 네임드 토플이 뭔지 아래에 정리**
- 함수의 인자들은 튜플로 전달된다.

## 딕셔너리

```bash
# 생성 
empty_dict = {}

# dict() 를 이용해 두 값 쌍으로 이뤄진 자료구조를 딕셔너리로 변환할 수 있다. 
lol = [['a', 'b'], ['c', 'd']] 
lol2 = lol #{'a': 'b', 'c': 'd'}

lol3 = ('ab', 'cb') 
lol4 = lol #{'a': 'b', 'c': 'd'}

# 딕셔너리 결합하기 update() 
em = {'a': 'b'}
em2 = {'c': 'd'}

em.update(em2) # {'a': 'b', 'c': 'd'}

# 딕셔너리 비우기 
em.clear() 

# 딕셔너리에 특정 키가 들어있나 확인 
'c' in em 

# 모든 키 가져오기 
em.keys() 

# 모든 값 가져오기 
em.values() 

# 모든 키, 값 가져오기
# ('a', 'b'), ('c', 'd') 처럼 튜플로 반환한다 
em.items() 
```

## 셋

어떤 것이 존재하는지 여부만 판단하기 위해서 셋을 사용한다. 중복을 허용하지 않는다. 셋은 수학시간에 배웠던 집합과 아주 유사하다.

```bash
# 생성 
# 그냥 {} 는 딕셔너리 생성자에 선점되었다. 
empty_set = set() 
empty_set2 = {1, 2, 3, 4}

# 각종 집합

# 교집합 &, intersection()
if contents & {'ice', 'cream'} # ice 와 cream 모두 들어있어야 참 

a = {1, 2} 
b = {3, 4} 

a & b = 2

# 합집합 |, union()
a | b = {1, 2, 3}

# 차집합 -, difference() 
a - b = {1}

# 대칭 차집합 ^, symmetric_difference  
# 각 항목에 별개로 가지고 있는 값을 구한다. 
a ^ b = {1, 3}

# 부분집합 <=, issubset() 
a.issubset(b) # False 
a.issubset(a) # True 
a.issubset((1, 2, 3))

# 슈퍼셋 >=, issuperset() 
a.issuperset((1)) # True
((1, 2, 3)).issuperset(a) # True
a.issuperset(a) # True 
```

<br>

---

# 4장 파이 크러스트: 코드 구조

## 컴프리헨션

내가 가끔 검색해보고는 하는 한줄로 for 문 돌리기와 유사하다. 하나 이상의 이터레이터로부터 파이썬 자료구조를 만드는 방법이다. 더 파이써닉한 용법이라니는데 간단한 할당문 말고는 컴프리헨션을 사용하면 더 헷갈릴 것 같다.

> [표현식 for 항목 in 순회_가능_객체


```bash
num = [i for i in range(1, 6)]
```

## 인자

다른 언어들과 마찬가지로, 값을 순서대로 상응하는 매개변수에 복사하는 것이 위치인자이다. 키워드인자는 위치인자의 혼동을 피하기 위해 상응하는 이름을 인자 안에 지정한 것이다.

```bash
# 위치 인자 
def menu(wine, entree, dessert): 
	pass 

# 키워드 인자 
def menu(wine=wine, entree=entreee, dessert=dessert): 
	pass 

# 인자의 기본 값 지정 
def menu(wine, entree, dessert='pie'): 
	pass 
```

## 인자모으기

```bash
# 위치 인자 모으기 * 
def print_args(one, two, three, *args): 
	pass 

# 실제로 호출 시 three까지 위치에 따라 값이 들어가고 나머지는  *args가 인자를 취하게 해준다.
print_args(1, 2, 3, 4, 5, 6, 7, 8) 

# 키워드 인자 모으기 ** 
def print_keyword(**kwargs)

# 실제 호출 시 위치인자와 마찬가지로, 함수에 따로 정의가 안 된 위치인자를 취한다. 
print_keyword(one=1, two=2, three=3, four=4, five=5)
```

여러가지 종류의 인자들을 섞어서 사용하려면 함수를 정의할 때 위치인자, 키워드 인자, *args, **kwargs 순으로 정의를 해줘야한다.

## docstring

파이썬 문서화에 관련된 부분. 일반 주석은 #을 사용하지만, 모듈과 클래스와 메소드에 사용하는 주석의 형태는 따로 있다. 이것을 doctstring이라고 한다.

```python
"""
	모듈 (파이썬 파일) 최상단에 이런 형식으로 주석을 달아주세요. 
Usage: 
	python my_test.py <param>
"""

class TestClass: 
"""
클래스 아래에 이런 형식으로 주석을 달아주세요.
"""

	def test_method():
		"""
		함수 아래에 이런 형식으로 주석을 달아주세요.		
		"""

		pass
```

이렇게 docstring을 이용해서 주석을 달아두면  코드에서 이런식으로 접근을 할 수 있다. 내가 지금 사용하는 클래스가 뭘 하는 애인지 해당 클래스 파일을 읽지 않아도 콘솔에 입력만 하면 볼 수 있다는 장점이 있다.

```python
help(TestClass)
TestClass.__doc__
```

<br>

## 라인 유지하기

PEP 에 따르면 파이썬은 한 줄에 80글자를 넘으면 안된다. 가독성이 제일 중요한 언어에서 가독성이 떨어지기 때문이다. 그래서 긴 문장을 사용해야 할 때에는 백슬래시로 라인을 끊어준다.

```python

test = "this" + \ 
			"is very very" + \ 
			"long long line" 

# 추천하지 않는 라인 끊는 방법
test = ""
test += "is very very" 
test += "long long line"
```

## 일등 시민: 함수

> 함수는 뷸변하기 때문에 딕셔너리의 키로 사용할 수 있다.
>

함수를 변수에 할당할 수 있고, 다른 함수에서 이를 인자로 쓸 수 있으며, 함수에서 함수를 반환할 수 있다.

```python
def run_something_with_args(func, arg1, arg2): 
	func(arg1, arg2)

def add_args(arg1, arg2): 
	return arg1 + agr2

>> run_something(add_agrs, 5, 8 )
14
```

- 파이썬에서 **괄호 ()는 함수를 호출**한다는 의미로 사용되고, **괄호가 없으면 함수를 객체**처럼 간주한다.
- 예제에서 run_something_with_args로 전달된 add_args 는 func 매개변수로 할당된다.
- 뒤에 괄호 () 가 붙은 func 는 전달 받은 arg1, arg2를 매개변수로 해 함수를 호출한다.

<br>

아래부터 나올 내부함수, 클로저, 데코레이터는 [[Real Python: adding behavior with inner functions decorators]]([https://realpython.com/inner-functions-what-are-they-good-for/#adding-behavior-with-inner-functions-decorators](https://realpython.com/inner-functions-what-are-they-good-for/#adding-behavior-with-inner-functions-decorators)) 를 많이 참고 삼아서 이해했다.

## 내부 함수

함수 안에 또 다른 함수를 정의한다. 함수를 global scope으로부터 완전히 숨겨 encapsulation을 하거나, 복잡한 작업을 하기 위해 Helper 함수를 만들어야 할 때 내부함수를 쓴다.

```python
# global scope로부터 완전히 숨기는 예제 
def increment(number): 
	def inner_increment(): 
		return number + 1
	return inner_increment()

>> increment(10)
11
```

위처럼 작성을 하면 inner_increment 함수를 어디에서도 호출을 할 수 없다.

```python
# Helper 함수를 만들 때 
def factorial(number):
	if not isinstance(number, int):
		raise TypeError("Sorry. 'number' must be an integer.")
	if number < 0:
		raise ValueError("Sorry. 'number' must be zero or positive.")

	def inner_factorial(number):
		if number <= 1:
			return 1
		return number * inner_factorial(number - 1)

	return inner_factorial(number)
```

그런데 이렇게 **내부함수로 Helper 함수를 만들기보다는 private 으로 Helper 함수를 만드는 것을 권장한다**. private helper 함수가 훨씬 더 코드 읽기가 편하고 같은 모듈이나 클래스에서만 재사용이 가능하기 때문이다.

```python
# private helper 함수를 만들 때 
def factorial(number):
	if not isinstance(number, int):
		raise TypeError("Sorry. 'number' must be an integer.")
	if number < 0:
		raise ValueError("Sorry. 'number' must be zero or positive.")

	return _factorial(number)

def _factorial(number): 
	if number <= 1:
		return 1
	return number * inner_factorial(number - 1)
```

<br>

## 클로저

클로저는 바깥 함수로부터 전달된 변수값을 저장하고, 변경을 할 수 있는 함수이다. 파이썬에서 함수를 변수에 할당할 수 있는 이유도 클로저 기능을 지원하기 때문이다.

Example 1 generate_power 클로저 버전

```python
# closure factory function
def generate_power(exponent):
    def power(base):
        return base ** exponent
    return power

raise_two = generate_power(2) 

>> raise_two(4) 
16 
>> raise_two(5) 
25
```

<br>

클로저의 개념이 처음이다보니 제대로 이해가 가지 않아 print를 해가며 이해를 진행했다.

Example 1 generate_power 클로저 버전 with print

```python
def generate_power_with_debug(exponent):
    print(f'closure generated, passed exponent {exponent}')

    def power(base):
        print(f'inner function in closure. passed base {base}')
        return base ** exponent

    return power

# closure 생성
raise_two = generate_power_with_debug(2)

# closure 호출
print(f'result of closure : {raise_two(4)}')

# 콘솔에 출력된 결과 
closure generated, passed exponent 2
inner function in closure. passed base 4
result of closure : 16
```

호출 과정

```python
raise_two = generate_power_with_debug(2)) 

# 1. generate_power_with_debug 로 변수 exponent에 2를 넣어 클로저 생성한다.
# 2. 클로저는 매번 호출될 때마다 새로운 클로저를 생성한다. 
# 3. 내부 함수 power은 호출이 되지 않고, 새로운 power 인스턴스를 생성해 리턴이 된다.
# 3-1. 리턴값이 함수라는 얘기다. 

(중요!!)
# 3-2. power를 리턴할 때 power의 surrounding state 를 스냅셧으로 남긴다. 여기에는 exponent 변수가 포함되어있다. 

```

```python
print(f'result of closure : {raise_twon(4)}')

# 1. generate_power_with_debug 클로저를 호출한다. 
# 2. 클로저를 호출함에 따라 변수 base에 4를 넣어 내부함수 power가 호출한다. 
# 3. power는 클로저가 리턴되었을 때 함께 넘어왔던 surrounding state의 스냅샷에 저장이 된 exponent를 이용한다. 
# 4. power 결과를 리턴한다. 
```

<br>

- 클로저를 구분할 수 있는 부분은 내부함수를 괄호() 로 호출하지 않다는 것이다. 예제에서 power를 리턴하기만 하는데, 이렇게 리턴을 하면 exponent 값을 저장한 **power 함수의 복사본을** 주게 된다.
- 복사본을 할당 받은 변수 raise_two를 실제로 매개변수를 넣고 호출한다.
- 매개변수는 내부함수인 power 의 base 와 맵핑이 된다.

> 어떻게 내부함수를 호출할 때 외부함수의 값에 접근을 할까?
> 
> > 클로저를 생성할 때 내부함수를 리턴하는데, 이때 외부함수의 상태 스냅샷을 함께 리턴해주기 때문이다.


<br>

Example 2 has_permission

```python
def has_permission(page):
    def permission(username):
        if username.lower() == "admin":
            return f"'{username}' has access to {page}."
        else:
            return f"'{username}' doesn't have access to {page}."
    return permission

# 선언
check_admin_page_permision = has_permission("Admin Page")

>>> check_admin_page_permision("admin")
"'admin' has access to Admin Page."

>>> check_admin_page_permision("john")
"'john' doesn't have access to Admin Page."
```

> difference bwteern clousre and decorator? No! Decorators return a closure. A closure is what is returned by a decorator.
>

## 데코레이터

데코레이터는 callable(함수, 메소드, 클래스)를 인자로 받고, 다른 callable을 리턴한다(내부함수). 생김새와 위치는 자바의 어노테이션과 동일하다. 데코레이션을 사용하면 이미 존재하고 있던 original callable에 별도의 수정사항없이 액션을 추가 할 수 있다.

데코레이터 생성하기

- 함수를 인자로 받는 callable을 선언한다.
- 인자로 받은 함수를 호출한다.
- 추가 액션이 있는 다른 함수를 리턴한다.

```python
def example_decorator(func): 
	def _add_messages(): 
		print('This is my first decorator')
		func()
		print('bye') 
	# 데코레이터도 클로저처럼 내부함수를 괄호()로 호출하지 않는다. 
	return _add_messages

# greet = example_decorator(greet) 과 동일하다. 클로저 생성 형태와 동일하다. 
@example_decorator
def greet(): 
	print('Hello World')

>>> greet() 
This is my first decorator 
Hello World 
bye 
```

이렇게 추가로 액션을 행할 수 있게 해주는 데코레이터는 `디버깅`, `캐싱`, `로깅`, `시간측정`(timing)에 많이 쓰인다.

Example 1 debugging

```python
def debug(func):
    def _debug(*args, **kwargs):
        result = func(*args, **kwargs)
        print(
            f"{func.__name__}(args: {args}, kwargs: {kwargs}) -> {result}"
        )
        return result
    return _debug

@debug
def add(a, b):
    return a + b

>>> add(5, 6)
add(args: (5, 6), kwargs: {}) -> 11
11
```
<br>

Example 2 generate_power 데코레이터 버전

아까 위에서는 클로저로 generate_power를 구현했는데 이번에는 데코레이터로 구현을 했다.

```python
def generate_power(exponent):
    def power(func):
        def inner_power(*args):
            base = func(*args)
            return base ** exponent
        return inner_power
    return power

@generate_power(2)
def raise_two(n):
    return n

>>> raise_two(7)
49

@generate_power(3)
def raise_three(n):
    return n

>>> raise_three(5)
125
```

<br>

Example 2 generate_power_with_debug

```python
def generate_power_with_debug(exponent):
    print(f'closure is generated, passed exponent : {exponent}')

    def power(func):
        print(f'inner function in closure. passed func : {func}')

        def inner_power(*args):
            print(f'inner function in power. passed args : {args}')
            base = func(*args)
            return base ** exponent
        return inner_power
    return power

# closure 생성
# raise_two = generate_power_with_debug(2) 와 동일 하다.
@generate_power_with_debug(2) # power()를 리턴
def raise_two(n): # power()를 호출, inner_power()를 리턴
    return n

print(f'result of closure : {raise_two(7)}')

# 콘솔에 출력된 결과 
closure is generated, passed exponent : 2
inner function in closure. passed func : <function raise_two at 0x100e2dee0>
inner function in power. passed args : (7,)
result of closure : 49
```

호출과정

```python
@generate_power_with_debug(2)
def raise_two(n): 
	return n 

# 1. raise_two = generate_power_with_debug(2) 와 동일하다. 
# 2. @generate_power_with_debug 데코레이터는 exponent 값을 포함한 내부함수 power를 리턴한다.
# 3. raise_two가 선언되면서 power도 호출이 된다. 
# 4. power는 func를 포함한 내부험수 inner_function을 리턴한다. 여기에서도 inner_function은 호출되지 않고, 새로운 인스턴스를 생성해 리턴이 된다. 
```

```python
print(f'result of closure : {raise_two(7)}')

# 1. raise_two를 호출하면서 클로저를 호출한다. 
# 2. 클로저 호출함에 따라 변수 *args에는 raise_two 함수에 전달된 인자 7이 전달된다. 이또한 스냅샷으로 외부 state를 저장했기 때문이다. 
# 2-1. *args는 함수에 전달되는 모든 인자들을 뜻하고, **kwargs는 위치 지정된 모든 인자들을 뜻한다. 
# 3. inner_power 결과를 리턴한다.                                                                                
```

<br>

## 이름에 _와 __사용

[https://towardsdatascience.com/whats-the-meaning-of-single-and-double-underscores-in-python-3d27d57d6bd1](https://towardsdatascience.com/whats-the-meaning-of-single-and-double-underscores-in-python-3d27d57d6bd1)

```python
_foo # single leading underscore 
foo_ # single trailing underscore 

_ # single underscore 

__foo__ # double leading and trailing underscore 
__foo # double leading underscore 
```

| name                                 | e.g. | usage                                      |
|--------------------------------------|------|--------------------------------------------|
| single leading underscore            | _foo | - private(internally) 하게 사용이 됨을 나타낸다.      |
| - 여전히 외부에서 접근이 가능하기 때문에 문맥적 힌트에 가깝다. |      |                                            |
| single trailing underscore           | foo_ | - 파이썬에서 이미 선점한 키워드를 사용할 때 혼선을 피하기 위한 방법이다. |
| e.g. type_, from_                    |      |                                            |
| single underscore                    | _    | - 사용하지 않은 변수들을 담아두는 용도로 쓴다.                |

_ = return_something()
- 숫자가 길어질 때 혼선을 방지하기 위해 쓴다.
  e.g. 1000 → 1_000   |
  | double leading and trailing underscore  | __foo__ | - dunder method 라고 한다.
- 파이썬에서 이미 선점한 특수 목적 전역 클레스 메소드다.  |
  | double leading underscore | __foo | - 부모-자식 필드 이름을 구분하기 위해 사용되는 것으로 파악했다.
- 실 사용이 거의 없을 거 같다.  |


<br>

---

# 5장 파이 포장하기: 모듈, 패키지, 프로그램

> 파이썬을 사용하다보면 모듈이라는 단어가 자주 나오는데 여기서 모듈이란 단순히 파이썬 코드가 들어가있는 파일을 뜻한다.
>

## 패키지

파이썬을 좀 더 확장 가능한 어플리케이션으로 만들기 위해서는 모듈을 패키지라는 파일 계층구조로 구성해야 한다.  **__init__.py** 는 파일 내용을 비워놔도 되지만, 파이썬은 이 파일을 포함하는 디렉터리를 패키지로 간주하기 때문에 패키지로 사용하고 싶다면 꼭 만들어둬야 한다.

파이썬에서 batteries included 철학은 유용한 작업을 처리하는 많은 표준 라이브러리 모듈들이 내장이 되어있다는 뜻이다.

### Stack + Queue == Deque

파이썬 list는 left end의 pop()과 append()에서 빠르지가 않기 때문에 left-end와  right-end 모두 빠르고 메모리를 효과적으로 사용하기 위해 데크를 제공한다.

> list의 right-end 연산 속도는 O(1)이지만, left-end 연산 속도는 O(n)이다.
>

Deque 는 Stack과 Queue의 기능을 모두 가진, 출입구가 양 끝에 있는 Queue다.(double-ended queue의 구현체이다) Deque는 양 끝으로부터 항목을 추가하거나 삭제할 때 유용하게 쓰인다. popleft()는 left-end를 제거해서 반환하고, pop()은 right-end를 제거해서 반환한다.

```python
from collections import deque

numbers = deque([1,2,3,4]) 

>>> numbers.popleft()
1 
>>> numbers.popleft()
2 
>>> numbers 
deque([3,4])

>>> numbers.appendleft(2)
>>> numbers.appendleft(1) 
>>> numbers
deque([1,2,3,4])
```

Deque의 흥미로운 점

- 최대 길이 (maximum lenght)를 지정할 수 있다.
  - 최대 길이를 지정하지 않으면 자원이
- 때문에 한 쪽에서 데이터를 넣어 큐가 꽉 차게 되면 자동으로 다른 쪽에 있는 아이템을 버린다.
- 이러한 기능으로 인해 `이전 0회의 기록을 남기기` 와 같은 요구사항이 있을 때 활용하기가 용이하다.

  ![스크린샷 2022-03-02 오후 4.03.53.png](/assets/img/post/python_deque.png)

<br>

Example 1 히스토리 예제 남기기:

```python
from collections import deque

sites = (
    "google.com",
    "yahoo.com",
    "bing.com"
)

pages = deque(maxlen=3)
pages.maxlen

for site in sites:
    pages.appendleft(site)

>>> pages
deque(['bing.com', 'yahoo.com', 'google.com'], maxlen=3)

pages.appendleft("facebook.com")
>>> pages
deque(['facebook.com', 'bing.com', 'yahoo.com'], maxlen=3)

pages.appendleft("twitter.com")
>>> pages
deque(['twitter.com', 'facebook.com', 'bing.com'], maxlen=3)
```

<br>

Example 2 Linux의 tail 모방하기:

```python
from collections import deque

def tail(filename, lines=10):
    try:
        with open(filename) as file:
            return deque(file, lines)
    except OSError as error:
        print(f'Opening file "{filename}" failed with error: {error}')
```



- CPython에서 deque의 append(), appendleft(), pop(), popleft(), len()은 thread-safe 하게 만들어졌기 때문에 멀티쓰레드 환경에서 deque를 사용하기 좋다.

  > CPyton은 C로 구현한 파이썬으로, 가장 많이 사용되고 있는 파이썬 구현체다. 오픈소스로 관리가 되고 있기 때문에 모든 코드를 https://github.com/python/cpython 에서 볼 수 있다.


더 많은 Deque 사용법은 아래 링크에서 볼 수 있다.

[https://docs.python.org/3/library/collections.html#deque-recipes](https://docs.python.org/3/library/collections.html#deque-recipes)

---
