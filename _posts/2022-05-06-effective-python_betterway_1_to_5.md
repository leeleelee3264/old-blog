---
layout: post
title: "[Python] Effective python better way 1 to 5"
date: 2022-06-15 08:43:59
author: Jamie Lee
categories: Book
tags:	Python
pagination:
enabled: true
---


# Chapter 1 파이썬답게 생각하기
<br>
<br>

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

<br> 

## Better way2 PEP8 스타일 가이드를 따르라

PEP8는 파이썬 코드를 어떤 형식으로 작성할지 알려주는 스타일 가이드다. 문법만 올바르다면 어떤 방식으로 원하든 파이썬 코드를 작성해도 좋지만, 일관된 스타일을 사용하면 코드에 더 친숙하게 접근하고, 코드를 더 쉽게 읽을 수 있다. (파이썬은 특히 lint가 활성화 되어있다고 느낀다, 그리고 lint에 PEP8 내용이 다 들어있는 듯 하다)

다음은 PEP8에 써있는 꼭 따라야하는 규칙이다.

<br>

### 공백

- 탭 대신 스페이스를 사용해 들여쓰기를 하라. (python editor는 자동지원을 하는 듯)
- 문법적으로 중요한 들여쓰기에는 4칸 스페이스를 사용하라.
- 라인 길이는 79개 문자 이하여야 한다.
- 긴 식을 다음 줄에 이어서 쓸 경우에는 일반적인 들여쓰기보다 4스페이스를 더 들여써야 한다.
- 파일 안에서 각 함수와 클래스 사이에는 빈 줄 두 줄 넣어라.
- 클래스 안에서 메서드와 메서드 사이에는 빈 줄을 한 줄 넣어라.
- dict에서 키와 콜론(:) 사이에는 공백을 넣지 않고, 한 줄 안에 키와 값을 같이 넣는 경우에는 콜론 다음에 스페이스를 하나 넣는다.
- 변수 대입에서 = 전후에는 스페이스를 하나씩만 넣는다.
- 타입 표기를 덧붙이는 경우에는 변수 이름과 콜론 사이에 공백을 넣지 않도록 주의하고, 콜론과 타입 정보 사이에는 스페이스를 하나 넣어라.


```python
def add(a: int, b: int): 
    return a + b
```
<br>

### 명명 규약 (name convention)

- 함수, 변수, 애트리뷰트는 lowercase_underscore 처럼 소문자와 밑줄을 사용해야 한다. (snake case)
- 보호해야(protect) 하는 인스턴스 애트리뷰트는 일반적인 애트리뷰트 이름 규칙을 따르되, 밑줄로 시작한다.

```python
_count = 100 

def _add(a, b): 
    return a + b
```

- private 인스턴스 애트리뷰는 밑줄 두 줄로 시작한다.
  - 밑줄 두 줄은 maigc method를 위한 컨벤션인줄 알았는데, 클래스에서 private 메소드와 애트리뷰트를 밑줄 두줄로 만든다.
  - **파이썬에서 private, protect 모두 정식 지원을 하지 않기 때문에, 가독성을 위한 네임 컨벤션에 더 가깝다.**

```python
__count = 100 

def __add(a, b): 
    return a + b
```

- 클래스와 예외는 CapitalizedWord 처럼 여러 단어를 이어 붙이되, 각 단어의 첫 글자를 대문자로 만든다. (PascalCase, CamelCase)
- 모듈 수준의 상수는 ALL_CAPS처럼 모든 글자를 대문자로 하고, 단어와 단어 사이를 밑줄로 연결한 형태를 사용한다.
- 클래스에 들어있는 인스턴스 메서드는 호출 대상 객체를 가리키는 첫번쨰 인자의 이름으로, 반드시 self를 사용해야한다.(자기자신을 가르키기 때문에)
- 클래스 메서드는 클래스를 가르키는 첫 번째 인자의 이름으로 반드시 cls를 사용해야 한다. (클래스 자체를 가르키기 때문에)

<br>

### 식과 문

- 긍정적인 식을 부정하지 말고, 부정을 내부에 넣어라.

```python
# 긍정적인 식을 부정
if not a is b: 

# 부정을 내부에 넣음 
if a is not b: 

# 비교 대상이 없이 자기 자신만 있을 때는 이렇게 해도 된다. 
if not a: 
```

- 빈 컨테이너나 시퀸스([], ‘’)등을 검사할 때는 길이를 0과 비교하지 말라. 빈 컨테이너나 시퀸스 값이 암묵적으로 False 취급된다는 사실을 활용해라.
  - **파이썬을 자바와 동실시 해서, 얼마전에 str ≠ ‘’ 로 비어있는 여부를 검사한 적이 있다. 파이썬에서 비어있는 str는 False 취급이라는 것을 꼭 기억하자.**

```python
d = {}
st = ''

if not d: 

if not st: 

# Don't do 1
if str == '':

# Dont'do 2 
if len(d) == 0:

```

- 마찬가지로 비어 있지 않은 컨테이너나 시퀸스([1], ‘hi’) 등을 검사할 때는 길이를 0과 비교하지 말라. 컨테이너가 비어있지 않은 경우 암묵적으로 True 평가가 된다는 사실을 활용해라.
- 한 줄짜리 if 문이나 한 줄짜리 for, while 루프, 한 줄 짜리 except 복합문을 사용하지 말라. 명확성을 위해 각 부분을 여러 줄에 나눠 배치하라.
- 식을 한 줄 안에 다 쓸 수 없는 경우, 식을 괄호로 둘러싸고 줄바꿈과 들여쓰기를 추가해서 읽기 쉽게 만들라.
- **여러 줄에 걸쳐 식을 쓸 때는 줄이 계속된다는 표시를 하는 \ 문자 보다는 괄호를 사용하라.**
  - editor를 사용하다보면 이렇게 \ 되는 형식을 많이 사용하는데, PEP8에서 권장하지 않은 형태였다니, 앞으로 ()를 써보도록 노력하겠다.

<br>

### 임포트

> 임포트 문은 평소에 정말 신경을 쓰지 않는데, 앞으로는 editor에서 어떻게 임포트를 하는지 보고, 신경 써서 작성하도록 하자.
>

- import 문을 항상 파일 맨 앞에 위치시켜라.
- 모듈을 임포트할 때는 절대적인 이름을 사용하고, 현 모듈의 경로에 상대적인 이름은 사용하지 말라.

```python
# bar 패키지에서 foo 모듈을 임포트 하려고 할 때 
# Do 
from bar import foo

# Don't do
import foo
```

- 반드시 상대적인 경로로 임포트를 해야 하는 경우에는 명시적인 구문을 사용하라.

```python
from . import foo 
```

- 임포트를 적을 때는 아래와 같은 순서로 섹션을 나누고, 각 세션은 알파벳 순서로 모듈을 임포트하라.
  - 표준 라이브러리 모듈
  - 서드 파티 모듈
  - 여러분이 만든 모듈

<br>

> 🔥 개인 프로젝트를 할 때에도 pylint, flake8 등의 파이썬 lint를 이용해서 스타일을 준수하도록 노력하자.
>

<br>

## Better way 3 bytes와 str의 차이를 알아두라

파이썬에는 문자열 데이터의 시퀸스를 표현하는 두 가지 타입 bytes와 str이 있다.

- bytes: 부호가 없는 8바이트 데이터가 그대로 들어가거나, 아스키 인코딩을 사용해 내부 문자를 표시한다.

```python
a = b'h\x6511o'
c = b'eojwpkmcdlklksm'
```

- str: 사람이 사용하는 언어의 문자를 표현하는 유니코드 코드 포인트가 들어간다.

<br>

**중요한 사실은 str에는 직접 대응하는 이진 인코딩이 없고, bytes에는 직접 대응하는 텍스트 인코딩이 없다는 점이다.**

→ 유니코드 데이터를 이진 데이터로 변환해야 할 때: str의 encode 메서드 호출

→ 이진 데이터를 유니코드 데이터로 변환해야 할 때: bytes의 decode 메서드 호출

<br>

해당 함수들을 호출 할 때 여러분이 원하는 인코딩 방식을 명시적으로 지정할 수 도 있고 시스템 디폴트 인코딩을 사용할 수 있는데 일반적으로 utf-8이 시스템 디폴트다.

유니코드 데이터를 인코딩하거나 디코딩하는 부분을 인터페이스의 가장 먼 경계 지점에 위치시켜라. 이런 방식을 유니코드 샌드위치라고 부른다. **프로그램의 핵심 부분은 유니코드 데이터가 들어 있는 str를 사용해야 하고, 문자 인코딩에 대해 어떤 가정도 해서는 안된다.**

<br>

→ 핵심 함수에는 이미 인코딩이 된 str이 인자로 전달되어야 한다.

→ 이런 접근을 하면 다양한 텍스트 인코딩으로 입력 데이터를 받아들일 수 있고, 출력 텍스트 인코딩은 한 가지로 엄격하게 제한할 수 있다.

![457A3AFE-66F1-487E-BBA3-7D6F78A84521.png](/assets/img/post/encode_function_box.png)

<br>

example 1: bytes나 str 인스턴스를 받아서 항상 str 반환

```python
def to_str(bytes_or_str): 
	if isinstance(bytes_or_str, bytes): 
		 value = bytes_or_str.decode('utf-8) 
	else: 
		 value = bytes_or_str 
	
	return value 
```

<br>

example 2: bytes나 str 인스턴스를 받아서 항상 bytes 반환

```python
def to_bytes(bytes_or_str): 
	if isinstanceof(bytes_or_str, str): 
		 value = bytes_or_str.endode('utf-8')
	else 
		 value = bytes_or_str 
	 
	return value 
```

<br>

> 파이썬에서 bytes와 str을 다룰 때 기억해야 하는 점

 
bytes와 str이 똑같이 작동하는 것처럼 보이지만 각각의 인스턴스는 서로 호환되지 않기 때문에 전달중인 문자 시퀸스가 어떤 타입인지 알아야 한다.

```python
# 불가항목 
bytes + str 
bytes > str 
b'foo' == 'foo' >>> False 
```

(내장함수 open을 호출해 얻은) 파일 핸들과 관련한 연산들이 디폴트로 **유니코드 (str) 문자열을 요구하고, 이진 바이트 문자열을 요구하지 않는다.**

```python
with open('data.bin', 'w') as f: 
		f.write(b'\xf1\xf2\xf3') 

>>> Traceback ... 
TypeError: write() argument must be str, not bytes. 
```

→ 이진 쓰기 모드 (’wb’)가 아닌 텍스트 쓰기 모드 (’w’) 로 열어서 오류가 난 것이다. bytes로 파일 읽기, 쓰기를 하고 싶다면 이진 읽기모드 (’rb’) 또는 이진 쓰기모드 (’wb’)를 써야 한다.

→ 파일 시스템의 디폴트 텍스트 인코딩을 bytes.encode(쓰기), str.decode(읽기) 에서 사용하는데 utf-8이기 때문에 이진데이터의 경우 utf-8로 읽지 못하는 경우가 생겨 에러가 발생한다.

이런 현상을 막고자, utf-8로 인코딩을 못하는 경우에는 읽어올 때 인코딩을 아예 명시해주는 경우도 있다.

```python
with open('data.bin', 'r', encoding='cpl252') as f: 
		 data = f.read()
```
<br>

**결론: 시스템 디폴트 인코딩을 항상 검사하도록 하자.**

```python
python3 -c 'import locale; print(locale.getpreferredencoding())'
```
<br>

## Better way 4 C 스타일 형식 문자열을 str.format과 쓰기보다는 f-문자열을 통한 인터플레이션을 사용하라.

형식화는 미리 정의된 문자열에 데이터 값을 끼워 넣어 사람이 보기 좋은 문자열로 저장하는 과정이다. 파이썬에서는 f-문자열을 통한 인터플레이션 빼고는 각자의 단점이 있다.

<br>

> 형식 문자열
>

```python
print('이진수: %d, 십육진수: %d', %(a, b))
```



% 형식화 연산자를 사용한다. 왼쪽에 들어가는 미리 정의된 텍스트 템플릿을 형식 문자열이라고 부른다. **C 함수에서 비롯된 방법이다.**

문제점

1. 형식화 식에서 오른쪽에 있는 값들의 순서를 바꾸거나, 타입을 바꾸면 포멧팅이 안되어 오류가 발생한다.
2. 형식화를 조금이라도 변경하면 식이 매우 복잡해 읽기가 힘들다.
3. 같은 값을 여러번 사용하고 싶다면 오른쪽 값을 여러번 복사해야 한다.

<br>

> 내장 함수 format과 str.format
>

파이썬 3부터는 %를 사용하는 오래된 C스타일 형식화 문자열보다 더 표현력이 좋은 고급 문자열 형식화 기능이 도입됐다. 이 기능은 format 내장 함수를 통해 모든 파이썬 값에 사용할 수 있다.

```python
key = 'my_var'
value = 1.234

formatted = '{} = {}'.format(key, value) 
print(formatted) 

>>> 
my_var = 1.234

# format 메서드에 전달된 인자의 순서를 표현하는 위치 인덱스를 전달할 수도 있다. 
formatted = '{1} = {0}'.format(key, value) 
print(formatted) 

>>>
1.234 = my_var 

# 형식화 문자열 안에서 같은 위치 인덱스를 여러 번 사용할 수도 있다.
formatted = '{}는 음식을 좋아해. {0}가 요리하는 모습을 봐요'.format(name) 
print(formatted)

>>>
철수는 음식을 좋아해. 철수가 요리하는 모습을 봐요. 
```

문제점

- C 스타일의 형식화와 마찬가지로, 값을 조금 변경하는 경우에는 코드 읽기가 어려워진다. 가독성 면에서 거의 차이가 없으며, 둘 다 읽기에 좋지 않다.

<br>

> 인터폴레이션을 통한 형식 문자열 (f-문자열)
>

위의 문제들을 완전히 해결하기 위해 파이썬 3.6 부터는 인터폴레이션을 통한 형식 문자열 (짧게 f-문자열)이 도입되었다. **이 새로운 언어 문법에서는 형식 문자열 앞에 f 문자를 붙여야 한다.**

바이트 문자열 앞에 b 문자를 붙이고, raw 문자열 앞에 r문자를 붙이는 것과 비슷하다.

```python
key = 'my_var'
value = 1.234

formatted = f'{key} = {value}'
print(formatted) 

>>> 
my_var = 1.234
```

f-문자열은 형식 문자열의 표현력을 극대화하고, 형식화 문자열에서 키와 값을 불필요하게 중복 지정해야 하는 경우를 없애준다. f-문자열은 형식화 식 안에서 현재 파이썬 영역에서 사용할 수 있는 모든 이름을 자유롭게 참조할 수 있도록 허용함으로써 이런 간결함을 제공한다.

<br>

example 파이썬에서 제공하는 형식화 문법의 차이

```python
# f-문자열 
f_string = f'{key:<10} = {value: .2f}'

# c 스타일 
c_tuple = '%-10s = %.2f' % (key, value)

# c 스타일 + 딕셔너리 
c_dict = '%{key}-10s = %{value}.2f' % {'key': key, 'value': value}

# str.format
str_args =  '{:<10} = {value: .2f}'.format(key, value) 

# str.format + 키워드 인자
str_kw = '{key:<10} = {value:.2f}'.format(key=key, value=value) 
```

<br>

결론: **f-문자열은 간결하지만, 위치 지정자 안에 임의의 파이썬 식을 직접 포함시킬 수 있으므로 매우 강력하다.** 값을 문자열로 형식화해야 하는 상황을 만나게 되면 다른 대안 대신 f-문자열을 택하라.

<br>

## Better way 5 복잡한 식을 쓰는 대신 도우미 함수를 작성하라.

파이썬은 문법이 간결하므로 상당한 로직이 들어가는 식도 한 줄로 매우 쉽게 작성할 수 있다.

예를 들어 URL의 query string를 parsing 하고 싶다고 하자.

```python
from urllib.parse import parse_qs 

my_values = parse_qs('빨강=5&파랑=0&초록=', keep_blank_values=True)

print(repr(my_values)) 

>>> 
{'빨강': ['5'], '파랑': ['0'], '초록': [''] }
```

이런 때에 파라미터가 없거나 비어 있을 경우 0이 디폴트 값으로 대입되면 좋을 것이다. 여러 줄로 작성해야 하는 if 문(if statement)를 쓰거나 도우미 함수를 쓰지 않고, if 식(if expression)으로 한줄로 처리 할 수 있다.

뿐만 아니라, 모든 파라메터 값을 정수로 변환해서 즉시 수식에서 활용하기를 바란다고 해보겠다. 그럼 식은 아래와 같아진다.

```python
red = int(my_values.get('빨강', [''])[0] or 0) 
green = int(my_values.get('초록', [''])[0] or 0) 
opacity = int(my_values.get('투명도', [''])[0] or 0) 
```

<br>

다음 각 식은 왼쪽의 식이 False인 경우 모두 or 연산자 오른쪽의 하위 식 값으로 계산된다.

현재 이 코드는 너무 읽기 어렵고 시각적 잡음도 많다. 즉, 코드를 이해하기 쉽지 않으므로 코드를 새로 읽는 사람이 이 식이 실제로 어떤 일을 하는지 이해하기 위해 너무 많은 시간을 투자해야 한다.

<br>

**코드를 짧게 유지하면 멋지기는 하지만, 모든 내용을 한줄에 우겨 넣기 위해 노력할 만큼의 가치는 없다.**

이제 동일한 로직을 if/else 조건식으로 , 여러 줄이 쎠지지만 아주 명확하게 바꿔보겠다.

```python
def get_first_int(values, key, default=0): 
		found = values.get(key, ['']) 

		if found[0]: 
			 return int(found[0]) 
		
		return default 
```

<br>

**식이 복잡해지기 시작하면 바로 식을 더 작은 조간으로 나눠서 로직을 도우미 함수로 옮길지 고려해야 한다. 특히 같은 로직을 반복해 사용할 때는 도우미 함수를 꼭 사용하라. 아무리 짧게 줄여 쓰는 것을 좋아한다 해도, 코드를 줄여 쓰는 것보다 가독성을 좋게 하는 것이 더 가치 있다.**

<br>

결론: 파이썬의 함축적인 문법이 지저분한 코드를 만들어내지 않도록 하라. 반복하지 말라는 뜻의 DRY 원칙을 따르라.
