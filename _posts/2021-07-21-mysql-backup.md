---
layout: post
title: "[MySQL] SQL 백업 종류"
date: 2021-07-21 08:43:59
author: Jamie Lee
categories: Infra
tags:	sql
pagination:
enabled: true
---




> spare section 에서 선정한 주제는 backup 입니다.

<br> 
<br>

index

1. When do I have to backup Database?
2. Concept of Backup
3. Mysql Backup Command
4. Linux DB Migration

<br> 

![https://stephcalvertart.com/wp-content/uploads/2014/07/funny-memes-wordpress-maintenance-backups-updates-hearts-and-laserbeams-ryan-gosling-hey-girl.jpg](https://stephcalvertart.com/wp-content/uploads/2014/07/funny-memes-wordpress-maintenance-backups-updates-hearts-and-laserbeams-ryan-gosling-hey-girl.jpg)

<hr> 
<br>
<br> 

# When do I have to backup Database?

내가 실무에서 접할 수 있는 디비 백업의 용도는 2가지가 정도이다.

1. (보관) 데이터 유실을 막기 위해 서비스에서 사용하는 디비 외의 다른 디비에 데이터를 저장하기 위해
2. (이전) 원래있던 디비를 버리고 새로운 디비를 사용하기 위해

2의 경위에는 디비가 바뀌니 이에 따라 코드나 명세등 여러가지를 바꿔줘야 하고, 데이터 양이 많으면 이전하는 작업 자체가 오래 걸리기 때문에 자주 일어나지 않는게 제일 좋지만, 서비스 초기와 서비스를 제공하면서 규모와 구조는 언제든지 바뀔 수 있기 때문에 항상 마음의 준비를 해두는 게 좋다.

<br>

![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/df4404af-bd0f-493c-8c73-cdcada7458e1/backup_server_structure.png](https://user-images.githubusercontent.com/35620531/127328546-12fb8880-5f29-47e1-903c-97f4fa2e6d1c.png)

<br>
 대표적인 예가 지금 회사에서 사용하고 있는 개발 서버이다. 상용서버인 API는 서버와 아마존 RDS를 사용하는 디비과 완전히 분리가 되어있기 때문에 구조적 문제가 없다. 그러나 개발서버인 TPI는 디비가 TPI 서버 안에 들어가 있다. 
<br>
<br> 

> 앱/웹서버들과 디비서버를 하나에 몰아두는 것은 좋은 구조가 아니다.
>> 한 곳에 몰아두면 관리는 쉬울 수 있겠지만 하나가 잘못되면 다른 부분까지 영향을 미쳐 결국 서비스를 마비시킬 수 있는 위험부담이 크다. 앱서버에 요청이 몰리거나, 대규모 디비 연산이 수행되면 양쪽이 정상작동 하지 않는 문제가 발행한다.

<br>

개발서버다 보니 서버안에 여러가지 앱 서버들을 띄워두었는데 초기에 개발서버가 커질 것을 예상하지 못하고 AWS에서 CPU와 메모리 성능이 작은 인스턴스를 선택해서 서버로 띄웠다. 게다가 위에서 말한 것 처럼 개발에서 사용하는 디비또한 해당 서버 안에 띄워두었다. 앱서버의 갯수가 늘수록 서버의 자원은 부족해졌고 결국 **어느 한 앱 서버에서 지나치게 CPU를 독점해서 연산을 진행하면서 다른 앱서버들과 디비가 멈췄고 심지어 서버 자체에 ssh로 접속하는 것도 불가능했다**. 자원이 적은 서버에 이것저것 올려두는 것도 무리였지만 제일 큰 문제는 **서버가 터지자 디비까지 작동을 멈췄던 점이다**. 도미노처럼 다 멈춘 서버는 결국 재부팅을 해서 살렸다.

<br> 

**이런 도미노 문제가 발생하다보니 하나에 뭉쳐있는 서버를 작게 쪼개는 수 밖에 없다**. 서버를 3대를 띄워서 2대를 앱서버 컨테이너 서버로 사용하고 나머지 하나를 디비 컨테이너 서버로 사용한다. API 처럼 RDS 디비를 사용하면 좋겠지만 RDS는 비싸기 때문에 선택하지 못했고 원래 목적인 서버와 디비의 분리는 이루어졌다!

이렇게 나눠두면 앞의 두 컨테이너 서버에 요청이 심각한 수준까지 몰려서 서버가 다운이 된다고 해도 디비 컨테이너 서버에는 아무런 영향이 없고, 디비를 띄워둔 서버에는 다른 것들을 띄워두지 않고 정말 Mysql 만 띄워두기 때문에 서버에 과부하가 걸릴 확률이 크게 낮아진다.



![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/108134dd-1aaa-4c06-ae8e-869e3e328842/msa.png](https://user-images.githubusercontent.com/35620531/127329517-f9c0f848-7c05-4796-9ffb-0ee42af67f92.PNG)

이번 문제를 직면하면서 요즘 왜 MSA가 많이 선택을 받는지 이유를 조금이나마 알 것 같았다. MSA를 다룬 글에서는 에자일식으로 빠르게 개발이 가능한게 큰 장점이었는데 이렇게 잘게 나눠두면 서버의 오류가 멀리 퍼지는 것도 최소화 할 수 있는 것도 장점이라고 생각된다. 한군데에 몰려둔 TPI 형태의 아키텍처가 모놀리틱이고 모놀리틱보다는 분리가 되어있는 게 SOA (Service-Orient Architecture) 였다.  SOA와 MSA의 차이는 여기서 더 자세히 볼 수 있다. [SOA vs MSA](http://wiki.webnori.com/display/devbegin/SOA+VS+MSA)

디비 이전을 위한 백업은 사용하고 있던 디비 속의 데이터를 몽땅 꺼내와서 새로 만든 디비에 넘겨주기만 하면 끝이라서 비교적 쉬운 백업이다. 문제는 데이터 유실을 막기위해, 정말 백업의 용도로 이루어진 디비 백업이다. 디비를 통째로 복사해서 가지고 있을 것인지, 일정한 간격으로 백업을 진행해서 마지막 백업 이후에 이어서 백업을 할 것인지 등등 여러 컨셉의 백업이 있다.

<br>

# Concept of Backup

아래의 컨셉은 데이터베이스 뿐만 아니라 컴퓨터 전반에서 이루어지는 백업에서 통용되는 컨셉이다.

1. 전체 백업 (Full Backup)
2. 차등 백업 (Differential Backup)
3. 증분 백업 (Incremental Backup)

<br>

### 전체 백업

디비 이전을 위해 진행하는 백업은 전체 백업이다. 아무 조건 없이 모든 데이터를 덤프 뜨기 때문에 조건이 없어 백업을 진행하기 쉽지만 시간이 제일 오래 걸리고 파일 크기도 제일 크다.

<br>

### 차등 백업



![https://www.easeus.com/images/en/screenshot/todo-backup/guide/differential-backup.png](https://www.easeus.com/images/en/screenshot/todo-backup/guide/differential-backup.png)

차등 백업은 전체 백업보다 조금 더 정교한 형태의 백업이다. 전체백업은 큰 규묘의 데이터를 백업하다보니 일주일에 한 번 정도 진행이 된다. 만약 저번주의 전체 백업은 잘 마쳤지만 이번주의 전체 백업이 정상적으로 진행이 안되었다면 많은 데이터를 유실하게 된다.

이런 전체백업의 문제점을 커버하기 위한 차등 백업은 전체 백업 이후 추가된 데이터들만 백업을 하는 방식으로, 그림처럼 일요일에 전체 백업을 한다고 하면

월: 월요일에 추가된 데이터

화: 월요일 + 화요일에 추가된 데이터

수: 월요일 + 화요일 + 수요일

...

이런 식으로 다음 전체 백업이 있는 일요일 전까지 백업이 진행된다. (마지막 차등백업은 무시된다고 한다). 전체 백업보다는 정교하고, 데이터도 비교적 적기 떄문에 크기도 작고 작업 시간도 단축되었으나 다음 전체 백업 날이 다가올수록 파일 크기가 커진다. 그리고 변경된 사항들을 누적해가면서 저장하기 떄문에 하루에 한 번 이상 진행하기에는 무리가 있다.

<br>

### 증분 백업

![https://networkencyclopedia.com/wp-content/uploads/2019/10/incremental-backup.png](https://networkencyclopedia.com/wp-content/uploads/2019/10/incremental-backup.png)

증분 백업은 차등백업보다 더 작은 규모의 백업을 진행한다. 차등백업이 전체백업 이후의 변경을 하루하루 누적한다면 증분백업은 딱 그날 바뀐 부분만 백업을 한다. 예를 들어 일요일날 전체백업을 진행했다면

월: 월요일에 추가된 데이터

화: 화요일에 추가된 데이터

수: 수요일에 추가된 데이터

...

이런 식으로 그날의 데이터만 저장을 한다. 때문에 크기가 가장 작고, 백업을 진행하는 속도도 가장 빠르다. 워낙에 작고 빠른 백업이 이루어지기 때문에 다른 백업들과는 다르게 한 시간에 한 번 씩 백업을 해도 무리가 없다!

이렇게 보면 증분 백업이 제일 좋아보이지만 백업본이 날아가서 복구를 해야 하거나 할 때 시간이 오래 걸린다. 정교한 백업을 진행한 만큼 데이터를 다시 똑같이 쪼개서 백업을 해야 하기 때문에. 반면 전체백업은 똑같이 통으로 가져오기만 하면 되기 때문에 가장 빠르게 복구할 수 있다.



![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/e74e7466-4801-474b-a7af-91ebb75c9e9d/backup_proscons.png](https://user-images.githubusercontent.com/35620531/127329809-136dcb6b-37aa-48ec-b4ff-7cb08b9ca30c.PNG)

<br>

# Mysql Backup Command

> 백업 커맨드는 DB서버에 직접 들어가서 실행해야 한다. (DML/DDL/DCL 처럼 DB 콘솔창에서 실행 불가)

### 백업하기

```sql
<-- 아래에 나오는 # 는 리눅스 프롬프트 입니다. ex) root# --> 

<-- DB 백업 --> 
# mysqldump -u계졍 -p패스워드 복사할_DB_이름 > file_name.sql 
# mysqldump -uroot -p1234 mine > /etc/var/log/temp/my_backup.sql

<-- Table 백업 --> 
# mysqldump -u계정 -p패스워드 DB_이름 Table_이름 > file_name.sql 
# mysqldump -uroot -p1234 mine mine_table > /etc/var/log/temp/my_table_backup.sql 
```

### 복원하기

```sql
<-- DB 복원 -->
# mysql -u계정 -p패스워드 복원할_DB_이름 < file_name.sql 
# mysql -uroot -p1234 mine < /etc/var/log/temp/my_backup.sql 

<-- Table 복원 --> 
# mysql -u계정 -p패스워드 DB_이름 Table_이름 < file_name.sql 
# mysql -uroot -p1234 mine mine_table < /etc/var/log/temp/my_table_backup.sql 
```

<br> 

# Linux Mysql DB Migration

추후에 있을 DB 이전 작업을 위해 리눅스 환경에서 한 서버(old server)에서 다른 서버(new server)로 디비를 옮기는 방법을 추가로 알아봤다.

선행 작업

- DB 백업 (위 항목의 DB 백업 Command 사용)
- 백업한 sql 파일을 FTP 등을 이용해 new server로 전달

new server에서 진행하는 작업

```bash
<-- in mysql server --> 
mysql > create database db_name 
mysql > quit 

<-- in mysql server host -->
# mysql -u계정 -p패스워드 db_name < file_name.sql 

`````
