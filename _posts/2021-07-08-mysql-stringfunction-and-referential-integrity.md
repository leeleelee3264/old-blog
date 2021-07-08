---
layout: post
title: "[SQL] String function & Referential Integrity"
date: 2021-07-08 08:43:59
author: Jamie Lee
categories: Backend
tags:	sql
pagination:
enabled: true
---


> section 3에서 선정한 주제는 String function과 Referential Integrity (참조무결성) 입니다.
<br>

# 리뷰 후에 알게 된 부분들
1. [[Markdown 각주/미주 달기]](https://lynmp.com/ko/article/nu86c16d8f09c9fbd8) <span>[1](#footnote_1)</span>
2. `SUBSTRING_INDEX(문자열, 구분자, 가져올 구문 갯수)`
```sql
SELECT SUBSTRING_INDEX(addr, ' ', 2)
FROM users;

# 경기도 성남시 판교동 대왕판교로 --> 경기도 성남시 까지 나옴 
```

3. `도메인 무결성`과 `고유 무결성(Unique Column Values)`
* 도메인 무결성은 만약 Gender를 표현 한다고 했을 때 남성/여성/무성 등 미리 정의가 되어있는 도메인 (convention같은 느낌)에 속한 값이 들어가야 한다.
* 고유 무결성은 row에 속해있는 특정한 column 들이 유니크한 고유의 값일때만 업데이트와 인서트를 허가한다는 뜻이다. `UNIQUE key constraints`이 이 무결성을 지키는 역할을 한다.
> A unique value rule defined on a column (or set of columns) allows the insert or update of a row only if it contains a unique value in that column (or set of columns)
...
That is, no two rows of a table have duplicate values in a specified column or set of columns.



<br>

index

1. String Function in Mysql
2. Referential Integrity
3. 소소한 하이디 SQL & markdown 팁
4. Reference



<br>
<br> 

# String Function in Mysql
<hr>

<img src="https://user-images.githubusercontent.com/35620531/124757648-c5058c00-df68-11eb-911d-6a42dcdfd0bb.PNG" alt="drawing" width="500"/> 
<img src="https://user-images.githubusercontent.com/35620531/124757701-d2bb1180-df68-11eb-84dc-825b9e9f76ca.PNG" alt="drawing" width="500"/>

<br>

## Example

### LENGTH(), CHAR_LENGTH()
LENGTH 는 바이트로 글자를 카운트하고 CHAR_LENGHT는 글자 자체의 길이를 카운트한다. 한글의 경우 1글자가 2바이트라서 `이승민` 세글자면 6바이트가 나올 것 같은데 DB에 설정된 utf8 charset은 한글을 3바이트로 저장하기 때문에 총 9바이트가 나왔다.
```sql
SELECT NAME, LENGTH(NAME), CHAR_LENGTH(NAME)
FROM users 

# where 조건에도 사용이 가능해서 검색을 할 때 응용해서 사용하면 좋을 것 같다. 
SELECT NAME
FROM users 
WHERE CHAR_LENGTH(NAME) > 3
```
result
| NAME | LENGTH(NAME) | CHAR_LENGTH(NAME) |
| --- | ---: | ---: |
| Peter | 5 | 5 |
| 이승민 | 9 | 3 |

<br>

### RIGHT(), LEFT(), MID()
RIGHT(), LEFT(), MID() 는 파이썬 String 연산과 동일해서 놀랐다.
어떻게 활용을 할까 했는데 where로 검색을 하기에는 이미 더 편한 `like`가 다 커버를 해주고 있다. where절에 걸기보다는  `select 절에 걸어서 간단하게 데이터를 조작하고 비식별화 하는 것에 사용하면 좋아보인다.`
예제를 작성하다보니 이래저래 간편하게 쓰기 좋아보이는 유틸성 함수같다.
SUBSTRING()과 SUBSTR()도 비슷한 맥락에서 사용이 되면 좋을 것 같은데 이건 좀 더 정교한 조작을 할 때 이용!

```sql
SELECT NAME
FROM users 
WHERE LEFT(NAME, 1) = '이';

# like로 더 쉽게 찾을 수 있다. 
SELECT NAME 
FROM users 
WHERE NAME LIKE ('이%');

# concat()연산과 함께 사용해서 데이터 비식별화..? 
SELECT concat(left(NAME,1), '**')
FROM users 
WHERE LEFT(NAME, 1) = '이';

# Replace() 연산과 함께 사용해도 가능!
SELECT replace(name, RIGHT(NAME, 2), '**')
FROM users 
WHERE LEFT(NAME, 1) = '이';


# 작정하고 만들면 이렇게 data format을 씌워줄 수 있는데 여러번 써야 한다면 엑셀에서 수정을 하거나 
#프로그래밍으로 정규식을 입혀주는 게 더 간편하다는 생각이 든다. 
SELECT concat(left(number,3), '-', MID(NUMBER, 4, 4), '-', RIGHT(NUMBER, 4))
FROM users 
WHERE LEFT(NAME, 1) = '이';

```
result
| concat(left(number,3), '-', MID(NUMBER, 4, 4), '-', RIGHT(NUMBER, 4)) | number |
| --- | --- |
| 010-8765-4321 | 01087654321 |

<br>

### INSERT()
```sql
SELECT INSERT(NAME, CHAR_LENGTH(NAME), 5, ' 고객님') 
FROM users

# concat으로 해결
SELECT CONCAT(NAME, ' 고객님') 
FROM users;
```

result
| INSERT(NAME, CHAR_LENGTH(NAME), CHAR_LENGTH(NAME), ' 고객님') |
| --- |
| Pete 고객님 |
| 이승 고객님 |

Peter 고객님과 이승민 고객님을 뽑고 싶었으나 내 의도대로 나오지 않았다. 받는 인자가 `INSERT(문자열, 시작위치, 길이, 새로운 문자열` 순서인데 길이가 어떤 역할을 하는지 잘 모르겠다. 스트링을 조작할 때는 INSERT()로 하려 하지 말고 `CONCAT()` 으로 간단하게 끝내야 할 것 같다.

<br> 

### LPAD(), RPAD()
LPAD는 왼쪽으로, RPAD는 오른쪽으로 해당 길이 만큼 입력된 글자들을 채워주는 기능. 단순하게 보면 글자수를 맞춰서 채워주는 기능인데 화면에서나 문서에서 글자들이 모두 같은 글자수를 가지고 있어야 할 때 쓸 일이 있어보인다. `RPAD(NAME, 10, ' ')` 로 자릿수만 채워줄 수 도 있다. <br>

```sql
SELECT RPAD(NAME, 10, '*'), LPAD(NAME, 10, '&')
FROM users;
```

result
| RPAD(NAME, 10, '*') | LPAD(NAME, 10, '&') |
| --- | --- |
| Peter***** | &&&&&Peter |
| 이승민******* | &&&&&&&이승민 |

PAD라는 단어가 익숙해서 어디서 들어봤나 했는데 저번 회차에서 주임님이 말씀하셨던 db엔진에서 글자수 비교를 할 때 CHAR형은 지정된 글자수를 맞춰주기 위해 그보다 짧은 단어들에 공백을 채워서 비교해준다는 PAD Attribute와 같은 기능이었다.

<img width="600" alt="pad" src="https://user-images.githubusercontent.com/35620531/124854634-93c9a200-dfe2-11eb-8344-3044609bfe57.PNG">

<br>
<br>

# Referential Integrity
관계를 맺은 테이블들의 데이터 사이에서 일관성을 유지하기 위해 foreign key를 만들 때 참조무결성 제약조건이 만들어진다.
강의를 듣는 처음에는 참조무결성이 왜 필요할까? 왜 foreign key를 사용하지? 라는 의구심이 들었는데 `데이터를 일관적으로 관리` 한다는 성격 때문에 참조무결성을 사용하는 것 같다.
* 본테이블에 없는 데이터를 sub 테이블 (참조하는 테이블)에 넣을 수 없다. --> 이 특성이라면 프로그래밍적 오류를 db단에서 막을 수 도 있다. (원래 db단에서 막으면 안되기는 하는데 최후의 수단으로 사용할 수 있을 것 같다)
* 본테이블에 없는 데이터로 sub의 foreign key를 수정할 수 없다.
* update와 delete에 cascade 옵션을 걸어놨을 경우 본테이블에 변경이 있으면 아무것도 안해도 sub 테이블에 알아서 반영을 해준다.
> 3번이 되게 유용한 기능으로 생각된다. 예를 들어 admin_user가 본테이블이고 admin_favorite이 sub 테이블이면 직원 중 하나가 퇴사를 하면 본테이블에 delete을 했을때 sub테이블에서도 자동으로 delete이 되어서 따로 관리를 할 필요가 없다.

<br> 

외래키를 설정하는게 이렇게 1:1로 데이터가 연관성이 크거나 (사용자-주문내역, 사용자-디바이스 정보) 이럴때 유용하지 **그냥 밑으로 확장하는 history성 테이블에서도 의미가 있을까?** 또 의심을 했는데 일단 history성이여도 본테이블에 없는 데이터를 넣지 못하는 일관성이 보장이 되기 때문에 필요 자체가 없는 기능은 아닌 것 같다.
<br>

### foreign key action
1. Restrict : 본테이블에 있는 데이터를 바꾸거나 삭제하려는데 다른테이블이 참조를 하고 있을 경우 action을 무시한다.
2. No Action : mysql에서는 restrict 와 동일하다. (Mysql 에서)
3. Cascade : 본테이블에서 수정/삭제가 일어났을 때 참조하고 있는 테이블도 동일하게 수정/삭제가 적용된다.
4. Set Null : 본테이블에서 수정/삭제가 일어났을 때 참조하고 있는 테이블의 Foreign Key를 NULL로 만든다. `수정에서 보다 삭제에서 더 유용한 설정`

<br> 

> 만약 데이터를 정말 지워버리는 Hard Delete말고 flag를 설정해줘서 지운 척을 하는 Soft Delete에서는 Foreign Key Delete Action을 어떻게 설정해주는 게 좋을까?

<br>
<br>



# 소소한 하이디 SQL & markdown 팁
하이디 sql에서 격자행 내보내기 할 때 대다수의 경우 csv 파일로 내보내기를 했는데 wiki나 블로그 작성 용으로 결과를 마크다운으로도 내보낼 수 있는 걸 오늘 발견했다. 이렇게 하면 [[Table Generator]](https://www.tablesgenerator.com/markdown_tables) 에 가서 셀 하나하나를 만들거나 결과창을 캡처 해 올 필요가 없어서 굉장히 편리하게 포스팅을 할 수 있다.

<img width="400" alt="내보내기" src="https://user-images.githubusercontent.com/35620531/124856705-fbcdb780-dfe5-11eb-9934-4b6f1fde700c.PNG">
<br> 
<br> 
result 
<br> 

<img width="600" alt="내보내기_rst" src="https://user-images.githubusercontent.com/35620531/124856718-fec8a800-dfe5-11eb-9ca6-7b1e80c76984.PNG">

<br> 

# Reference
[[Mysql String Function Official Document]](https://dev.mysql.com/doc/refman/8.0/en/string-functions.html#function_char-length)<br>
[[MySQL 문자열 함수]](https://bizadmin.tistory.com/entry/%EB%AC%B8%EC%9E%90%EC%97%B4-%ED%95%A8%EC%88%98)<br>
[[MySQL RESTRICT and NO ACTION]](https://stackoverflow.com/questions/5809954/mysql-restrict-and-no-action)<br>
[[Mysql Foreign Key Action Official Document]](https://dev.mysql.com/doc/refman/8.0/en/create-table-foreign-keys.html)



<br> 
<hr> 

<a name="footnote_1">1</a>: 주석에 관한 설명을 이곳에...

