---
layout: post
title: "[Linux & MySQL] Shell Script 로 Mysql db 전체백업하기"
date: 2021-09-09 23:59:59
author: Jamie Lee
categories: Infra
tags:	linux
cover:  "/assets/img/ubuntu.png"
pagination:
enabled: true
---

> ShellScript를 사용해서 Mysql db를 전체백업 하는 방법을 알아본다.

SQL 백업에는 전체백업, 증분백업, 차등백업이 있다. 백업 종류에 대한 더 자세한 정보는 이전의 포스팅에서 확인이 가능하다. [[SQL 백업 종류]]([https://https://leeleelee3264.github.io/leeleelee3264.github.io-old//backend/2021/07/21/mysql-backup.html](https://https://leeleelee3264.github.io/leeleelee3264.github.io-old//backend/2021/07/21/mysql-backup.html))



상용에서 사용하는 디비의 데이터를 일주일에 한 번 씩 로컬 서버로 백업을 해두기로 했다. 빈번하게 진행되는 백업이 아니라서 시간이 오래 걸리지만 간단한 전체백업을 하기로 했다. 대신 서비스에 장애가 가지 않도록 사용량이 적은 월요일 오전 3시에 백업이 되도록 crontab으로 스케쥴링을 걸어두었다.

우분투 환경의 쉘 스크립트를 작성해 Mysql db 백업을 진행했다.


index

1. 백업 진행 순서
2. 백업에 사용된 스크립트 & 세부 사항
3. 개선점과 참고자료
<hr>
<br>

   

# 백업 진행 순서

상용에서 사용하는 디비 이름은 mydb 이고, 백업을 진행하는 일시는 2021년 09월 06일이다. 로컬 디비에는 저번주인 08월 30일의 snapshot 인 mydb와 2주전인 08월 23일의 snapshot인 prev_mydb가 있다.
이런 상황에서 목표는 아래와 같았다. 

1. 로컬디비의 mydb를 prev_mydb 라는 이름으로 변경한다.
2. 상용디비의 mydb를 통째로 로컬디비로 옮겨온다. (전체백업)
3. 로컬 디비에 남는 디비는 prev_mydb와 mydb가 된다. 

상용 mydb 백업을 진행하기 전에 로컬 디비에 존재하는 prev_mydb를 지우고 mydb의 이름을 prev_mydb 로 바꾸면 간단하겠지만 mysql은 데이터베이스 자체를 RENAME 할 수 없어서 prev_mydb를 지우고 다시 만들어야 했다. 전반적인 프로세스는 아래의 그림과 같다.

<br>

### 상세 작업 순서

![db_backup.png](/assets/img/post/db_backup.png)

1. 로컬 서버가 상용 db로 접속
2. mysqldump를 실행해서 상용 디비의 mydb의 전체 데이터를 로컬 서버로 복사한다. (prod mydb data 생성)
3. (**여기부터 로컬 서버에서 진행**) 서버에는 지금 막 덤프한 prod mydb data와 mydb, prev_mydb 3개가 존재한다.
4. prev_mydb 를 삭제하고, mydb를 복사한다. (local mydb data 생성)
5. local mydb data 로 prev_mydb 를 생성한다.    
6. mydb를 삭제한다. 
7. prod mydb data 로 mydb 를 생성한다.    
8. 작업이 완료되면 로컬 디비에는 새로운 mydb와 prev_mydb 가 남는다.
9. prod mydb data 는 압축을 해 gz 파일 형식으로 로컬 서버에 남겨둔다.



<hr>

# 백업에 사용된 스크립트 & 세부사항

```bash
#!/bin/bash 

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Title: bk_prod.sh   
# Author: Seungmin Lee 
# Date: 2021-08-16 
# Schedule: Every Sunday AM 03:00
#
# This script is for backup rds (product) database. Backup db will be used in statistic part 

cd ~/bk_prod

DATE=`date +'%Y%m%d'`

# dest db info 
HOST=rds.examplehost.com
READ_ID=rds_id 

# src db info 
LOCAL_ID=local_id

# pre setting file.
# default pre setting file is ~/.my.cnf
LOCAL_CNF_PATH=~/bk_prod/.my.local.cnf
LOCAL_BASIC="--defaults-file=${LOCAL_CNF_PATH} --user=${LOCAL_ID}"

DB=mydb
PRE_DB=prev_mydb

# view will be ignored from db dump 
VIEW_ONE=${DB}.v_channel_lang 
VIEW_TWO=${DB}.v_voice_usage

# --------------------------------------------------------------------------------------------------------------------------------------------- #
# --------------------------------------------------------------------------------------------------------------------------------------------- #
# dump rds db first 
mysqldump --single-transaction --host=${HOST} --user=${READ_ID} --ignore-table=${VIEW_ONE} --ignore-table=${VIEW_TWO} ${DB} > ${DB}${DATE}.sql 

# local db backup for db rename
mysqldump ${LOCAL_BASIC} ${DB} > local_${DB}${DATE}.sql

# create and dump previous db in local db 
# ---------------------------------------------------------------------------------------------------------------------------------------------- #
# ---------------------------------------------------------------------------------------------------------------------------------------------- # 

# check prev_mydb is in local db 
RESULT=`mysql ${LOCAL_BASIC} --skip-column-names -e "show databases like '${PRE_DB}'"`
if [ ${RESULT} == ${PRE_DB} ]
  then
    echo "DELETE  FORMER ${PRE_DB}"
    mysql ${LOCAL_BASIC} -e "DROP DATABASE ${PRE_DB}"
  else 
    : 
fi 

mysql ${LOCAL_BASIC} -e "CREATE DATABASE ${PRE_DB}"
mysql ${LOCAL_BASIC} pre_${DB} < local_${DB}${DATE}.sql 

# now delete xouchcare db in local db 
mysql ${LOCAL_BASIC} -e "DROP DATABASE ${DB}"

# make new xouchcare db in local db 
mysql ${LOCAL_BASIC} -e "CREATE DATABASE ${DB}" 
mysql ${LOCAL_BASIC} ${DB} < ${DB}${DATE}.sql

echo "DB back up fine"

# done
gzip *.sql
```

<br>

## mysql command options

<br>

> —defaults-file

mysqldump와 같은 mysql에서 사용하는 커맨드는 실행을 위해서는 db 접속 호스트 정보와 id, pw를 함께 입력해야 한다. 터미널에 커맨드를 실행할 때는 상관이 없지만 쉘스크립트로 실행을 할 때는 따로 터미널로 계정 정보를 기입해 줄 수 없다. 이를 해결하기 위해서는 **계정 정보를 넣어둔 my.cnf 를 미리 만들어주면 된다.**

<br>

### 상용 디비 계정 정보를 넣어둔 my.cnf 파일

```bash
 
[mysqldump] 
user=rds_id 
password=rds_pw
```

### Local 디비 계정 정보를 넣어둔 my.local.cnf 파일

```bash
[mysqldump]
user=local_id
password=local_pw

[mysql]
user=local_id
password=local_pw
```

실행하려는 쉘스크립트에서 접속을 해야 하는 디비가 상용과 local 두가지라서 각각의 계정 정보를 넣어둔 my.cnf 와 my.local.cnf 파일을 만들었다. my.local.cnf 에서 보는 것처럼 실행을 해야하는 커맨드별로 계정정보를 넣어두면 쉘에서 해당 mysql 커맨드를 실행할 때 id, pw 를 입력하지 않아도 된다.

기본 my.cnf 위치는 ~/my.cnf 로 홈디렉토리에 생성이 되거나, 홈디렉토리에 직접 만들어주면 된다. 쉘에서도 따로 경로를 표기하지 않아도 알아서 my.cnf의 위치로 가서 파일을 읽어온다. my.local.cnf 처럼 추가로 만들때면 경로를 따로 표기해줘야 한다. 실제 커맨드 라인에서 사용을 할 때는

`—defaults-file=path_of_cnf_file` 을 써주면 된다.

<br>

> —ignore-table

mysqldump 를 실행할 때 덤프를 하지 말아야 하는 테이블을 명시해주면 덤프에서 제외가 된다. 내 경우는 로컬 디비에 접속을 하려는 계정이 view에 대한 권한이 없었기 때문에 아예 상용 디비를 덤프할 때 제외를 시켜놨다.

제외를 할 테이블들이 있으면 `—ignore-table=table_name` 을 하나씩 적어주면 된다. 아쉽게도 하나의 옵션에 여러개의 테이블을 쓸 수는 없었다.

<br>

> —single-transaction

innodb는 트랜잭션을 지원하기 때문에 해당 옵션을 사용할 수 있다. 덤프를 할 때 하나의 새로운 트랜잭션을 열어서 진행을 한다. 그럼 덤프를 실행하는 딱 그 순간의 디비가 스냅샷처럼 덤프가 떠진다. 덤프를 하고 있는 중에 db에 실행된 delete, insert, update과 같은 DML 쿼리의 결과는 반영하지 않는다.

아예 트랜잭션을 걸기 때문에 덤프를 하면서 작업중인 테이블에 락을 하나하나 걸지 않아도 된다. innodb가 아니면 `lock-tables` 옵션을 걸어줘야 한다.

단, **데이터를 바꾸는 DML은 트랜잭션이 막을 수 있지만 스키마를 바꾸는 DDL은 트랜잭션이 막을 수 없다고 한다**. 그래서 성공적으로 덤프를 하기 위해서는 덤프를 하는 동안 DDL 쿼리를 해서는 안된다.

<br>

> —skip-column-names

```bash
# with column
+----------------------+
| Database (mydb)      |
+----------------------+
| mydb                 |
+----------------------+
```

```bash
# without column 
+----------------------+
| mydb                 |
+----------------------+
```

말 그대로 결과에서 컬럼의 이름을 빼고 보여주는 옵션이다. 쉘스크립트에서 mysql의 결과 값을 인자로 받아 실행을 할 때 컬럼 이름이 들어가 있으면 결과를 식별하기가 어려워 `—skip-column-names`  를 사용한다.

<br>

> -e

`—execute` 과 동일한 기능을 하는 옵션. **해당 옵션을 사용하면 mysql은 따옴표로 감싸준 쿼리(SQL statement)를 실행하고 값을 뱉어낸 다음에 종료한다**. mysql에 접속해서 콘솔을 사용하면 어떤 쿼리도 실행을 시킬 수 있는 것처럼 -e 를 사용하면 mysql 커맨드 라인에서 원하는 쿼리를 실행할 수 있다.

```bash
# 예시 1
RESULT=`mysql ${LOCAL_BASIC} --skip-column-names -e "show databases like '${PRE_DB}'"

# 예시 2
mysql -uroot -p1234 -e "select * from test.user from age=20"
```

<hr>

# 개선점과 참고자료

## 개선점

전체백업의 장점은 구현이 쉽다. 그런데 디비 속의 모든 데이터를 백업하기 때문에 시간이 오래 걸린다. 그리고 만약 전체 백업이 제대로 진행이 안된다면 많은 양의 백업 데이터를 유실할 위험도 크다. 그래서 서비스에서는 전체백업 + 차등백업 / 전체백업 + 차등백업 + 증분백업 으로 여러 주기로 백업을 진행한다.

쉘스크립트로 짤 수 있는 전체백업과는 다르게 차등백업과 증분백업은 구현된 라이브러리를 써서 많이 진행한다. 검색을 했을 때 많이 보였던 게 XtraBackup 인데 지원 문제가 있어서 요즘은 Mariabackup 을 사용한다.

나중에 좀 더 세밀한 백업을 위해 구조를 바꾸면 좋을 것 같아서 XtraBackup과 Mariabackup에 관련된 문서를 남겨둔다.

<br>

[[우아한-장애와 관련된 XtraBackup 적용기]]([https://techblog.woowahan.com/2576/](https://techblog.woowahan.com/2576/)) 

[[Mariabackup을 이용한 증분 백업]]([https://velog.io/@tkfrn4799/mariadb-mariabackup](https://velog.io/@tkfrn4799/mariadb-mariabackup)) 

[[XtraBackup에서 Mariabackup로 변경해야 하는 이유]]([https://dung-beetle.tistory.com/75](https://dung-beetle.tistory.com/75))

<br>
## 참고자료

[[Mysqldump --single-transaction option]]([https://stackoverflow.com/questions/41683158/mysqldump-single-transaction-option](https://stackoverflow.com/questions/41683158/mysqldump-single-transaction-option))

[[4.2.2.1 Using Options on the Command Line]]([https://dev.mysql.com/doc/refman/8.0/en/command-line-options.html](https://dev.mysql.com/doc/refman/8.0/en/command-line-options.html))

[[Storage Engine (InnoDB vs MyISAM)]]([https://jobc.tistory.com/196](https://jobc.tistory.com/196))
