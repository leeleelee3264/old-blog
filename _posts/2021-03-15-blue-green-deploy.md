---
layout: post 
title: "[Linux] 무중단 서버로 배포하기"
date: 2021-03-15 08:43:59
author: Jamie Lee
categories: Infra
tags:	linux
cover:  "/assets/img/ubuntu.png"
pagination: 
  enabled: true
---

# 무중단 배포하기

원래 서버를 두대 띄우는 이유는 이번 주제처럼 

1. 업데이트 칠 때 서비스를 계속 가능하게 하기 위해 
2. 서버가 하나 죽으면 다른 곳으로 요청 처리하는 백업용으로

가 있다. 그런데 이번에는 서버를 한 대 만 띄우는 무중단 배포를 목적으로 해서 2 용도로는 알맞지 않다. 결국 서버가 죽으면 서비스가 멈춰버리기 때문에 나중에 가서는 더 안정적으로 운영을 하기 위해서는 백업 서버를 동시에 하나 더 띄울 수 밖에 없을 것으로 생각된다.

 맨날 서버를 업데이트할 때 서비스가 죽는다. 왜냐하면 백업서버를 열어두지 않아서. 업데이트가 좀   잦은 편인데 계속 배포를 할 때 마다 서비스가 죽어버리면 사용하기가 힘들 것 같아 무중단 배포를 구현해보리고 했다. 그런데 서버 리소스가 좀 타이트 해서 서버 두대를 띄우기는 힘들어 보였다. 서버가 두 대 뜨면 로드밸런스에서 하나가 업데이트 하느라 죽어도 다른 쪽으로 보내줄텐데 이런 형태는 지금 상황에서는 불가능했다.

<br>

## 서버 한 대 띄우며 무중단 배포하기

그래서 생각해 낸 방법 

1. 밖에 있는 nginx는 계속 두 포트(A: 4000, B: 4001) 모두를 바라본다. 
2. nginx가 날려준 리퀘스트를 실제로 처리하는 머신의 안쪽에서는 하나의 서버 (최근 업데이트 된 A 서버) 만 운영이 되고 있다 
3. 업데이트를 할 일이 있으면 A보다 이전 버전인 B를 업데이트 한다. 
4. B 서버를 가동한다.
5. B가 완전히 뜨기 전까지 nginx는 A,B 둘 다 바라보니 리퀘스트 처리가 가능한 A가 받아서 처리한다
6. B서버가 올라간 걸 확인하면 A 서버를 죽인다. 
7. 그럼 이제 요청이 띄워져있는 서버인 B로 올라간다.
8. 다음번에 업데이트를 해야 한다면 B보다 옛날 버전인 A가 업데이트 된다. 

![Dockerfile command](/assets/img/post/blue_green_chart.png)

작업을 하면서 nginx 는 어떻게 로드밸런싱을 할까 궁금해서 찾아봤다. 내가 하는 것처럼 두개 두면 nginx는 필수적으로 요청을 분산하게 되어있다. 말 그대로 로드 밸런싱을 해야해서. 

[nginx로-로드밸런싱-하기](https://kamang-it.tistory.com/entry/WebServernginxnginx%EB%A1%9C-%EB%A1%9C%EB%93%9C%EB%B0%B8%EB%9F%B0%EC%8B%B1-%ED%95%98%EA%B8%B0)

그리고 이 작업을 하다가 알게 되었는데 항상 nginx에서 설정이 바뀌면 nginx 서비스를 재시작(restart) 했는데 이것보다는 새로고침(reload) 하는게 좋다고 한다. restart는 말 그대로 재시작이라서 nginx를 한번 shutdown 하고 다시 시작한다. 반면 reload는 서버가 돌아가는 상태에서 설정 파일만 다시 불러와서 적용을 해준다. 서버 중단이 없다는 것 때문에 reload가 더 적합하다! 

<br>

```bash
// reload, restart 등을 할 때 config 파일이 문법에 맞는지 꼭 먼저 점검을 한다. 
nginx -t 

// reload 
sudo systemctl reload nginx 

// restart 
sudo systemctl restart nginx 
```

<br>

 내가 구현하려는 무중단배포의 플로우는 위의 플로우 차트와 같다. 검색을 했을 때 nginx가 두개를 바라보지 않고 살아있는 하나의 포트만 바라보도록 바꾸는 스크립트도 함께 작성하는 경우가 좀 있었는데 현재 서비스는 nginx와 어플리케이션 서버를 한 머신 안에서 운영하고 있지 않아서 앱서버 업데이트 후 nginx 업데이트까지 진행하지는 않기로 했다. 시스템의 구조는 이런 형태이다. 
![Dockerfile command](/assets/img/post/blue_green_nginx.png)


```bash
#! /bin/sh

echo ""
echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Blue Green Deployment"
echo "Author: Seungmin Lee"
echo "Date: 2021-02-26"
echo "This script is only for blue green deploy, not for back up server."
echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo ""
echo ""

# have to change for api and tpi 
SETTING=tpi
PROFILE=prod
PROFILE_BACKUP=back-prod

PORT=4000
PORT_BACKUP=4001

CURRENT_PATH=/opt/tc-admin
BACKUP_PATH=/opt/backup-tc-admin/${SETTING}

SUB_URL=/tcadmin/api/test/profile
CHECK_URL=https://${SETTING}.example.kr${SUB_URL}

echo ">Check which profile is active..."
PROFILE_CURRENT=$(curl -s $CHECK_URL)

echo ">$PROFILE_CURRENT"

if [ $PROFILE_CURRENT = $PROFILE ]
then 
	IDLE_PROFILE=$PROFILE_BACKUP
	IDLE_PORT=$PORT_BACKUP
	IDLE_DIR=$BACKUP_PATH
elif [ $PROFILE_CURRENT = $PROFILE_BACKUP ]
then
	IDLE_PROFILE=$PROFILE
	IDLE_PORT=$PORT
	IDLE_DIR=$CURRENT_PATH
else 
	echo ">Current profile is not matching with any of them..."
	echo ">Will use default $PROFILE for profile"
	IDLE_PROFILE=$PROFILE
	IDLE_PORT=$PORT
	IDLE_DIR=$CURRENT_PATH
fi

# update idle one and run 
# planed to seperate starting shell, but I have to copy/run first and kill the current one
echo ""
echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Update JAR file to new one and Run"
echo "target dir is ${IDLE_DIR}"
echo "target property is ${IDLE_PROFILE}"
echo "target port is ${IDLE_PORT}"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo ""
echo ""

cp -f ~/admin-0.1-SNAPSHOT.jar ${IDLE_DIR}/.

echo ""
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Now Deploy New Server...." 
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo ""
echo ""

DATE=`date +'%Y%m%d'`
ETC_JAVA_OPTS=-XX:+UseStringDeduplication
 
nohup java -Xms128m -Xmx128m -XX:NewRatio=1 -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -Xloggc:./gc.log -Dspring.profiles.active=${IDLE_PROFILE}  $* -jar ${IDLE_DIR}/dnx-touchcare-admin-0.1-SNAPSHOT.jar >> ./server.log & 

UP_CHECK=""

while [ -z "$UP_CHECK" ]
do 
	UP_CHECK=$(curl -s http://localhost:${IDLE_PORT}/tcadmin/api/test/profile)
done 

echo ""
echo "Now killed old server..."
echo ""

KILL_PROCESS_PID=$(pgrep -f "profiles.active=${PROFILE_CURRENT} -jar") 

echo "> kill process ${KILL_PROCESS_PID}"
if [ -z $KILL_PROCESS_PID ]
then 
	echo ">There are no pid..."
else
	echo ">kill -9 $KILL_PROCESS_PID"
	kill -9 ${KILL_PROCESS_PID}
	
fi

tail -f server.log
```

<br>
<br>

```bash
tc-admin
├── blue_green_deploy.sh
├── blue_green_deploy.txt
├── dnx-touchcare-admin-0.1-SNAPSHOT.jar
├── gc.log
├── log_rotate.sh
├── server.log
└── start.sh
tc-admin-prod
├── blue_green_deploy.sh
├── dnx-touchcare-admin-0.1-SNAPSHOT.jar
├── gc.log
├── hs_err_pid29917.log
├── hs_err_pid29917.txt
├── log_rotate.sh
├── server.log
└── start.sh
backup-tc-admin
├── api
│   └── dnx-touchcare-admin-0.1-SNAPSHOT.jar
└── tpi
    └── dnx-touchcare-admin-0.1-SNAPSHOT.jar
```

<br>
<br>

 이 스크립트에서 사용하는 환경은 tpi로, tc-admin을 이용한다. 백업 jar가 올라가는 곳은 backup-tc-admin 으로 tpi/api 로 디렉터리를 분리했다. 스트립트를 살펴보겠다. profile 은 jar 를 실행하는 환경의 정보인데 prod와 백업용 back-prod를 두었고 포트는 각각 4000 과 4001로 할당했다. 

1. 초반에 환경과 프로파일들, 포트와 jar가 있는 path들을 정해준다. 참고로 PATH는 /bin/bash 를 실행하는 환경을 잡아주는 특수한 변수라서 잘 알고 써야지 아니면 원하는 형태로 쉘이 작동하지 않는다. 
2. curl 을 이용해서 현재 띄워져있는 서버의 프로파일을 알아낸다. (이때는 도메인을 이용해서 **외부에서 서버로 요청을 보내는 것처럼 동작한다**) 
3.  서버의 프로파일에 따라서 업데이트를 할 Idle 프로파일과 포트, 패스를 지정한다. 현재 프로파일이 prod면 back-prod로, back-prod면 prod 로 설정해주면 된다. 
4. 홈디렉터리에 업로드 되어있는 가장 최신의 jar 파일을 3에서 구한 패스로 복사를 해준다. 
5. Idle profile 로 설정된 프로파일이 업데이트가 되면 해당 jar 파일을 띄운다. (prod와 back-prod 2개의 서버가 떠있는 상태) 
6. curl 을 이용해서 Idle jar 가 완전히 구동하고 있다는 응답을 받을 때까지 요청을 보낸다 (**이때는 [localhost](http://localhost) 와 Idle port 를 이용해서 내부에서 서버로 요청을 보낸다**.) 
7. 확인이 되면 이전에 구해뒀던 현재의 프로파일과 pgrep 을 이용해서 이전버전으로 돌아가고 있는 jar의 프로세스를 종료시킨다 
8. 완료! 

6을 구현하기 위해 많은 고민을 했다. 어떻게 해야 단순히 서버가 뜨는 것이 아닌 서비스 요청을 받아서 처리하는 수준의 완전히 구동된 서버의 상태를 알 수 있을까? 

<br>

```bash
// 0 try : 임의의 sleep 을 주기 
sleep(10000) 

// 1 try : 해당 프로세스로 확인하기 
pgrep -f "pfofiles.active=${IDLE_PROFLE} -jar" 

// 2 try : 해당 포트로 확인하기 
ss -tlp | grep ${IDLE_PORT}

// 3 try : 내부로 요청을 보내기
curl http://localhost/{IDLE_PORT} 
```

 처음에는 서버가 완전히 뜰 수 있게 임의의 sleep 값을 주었는데 제일 나쁜 방법이었다. 서버가 뜨는 속도가 일정하지 않기 때문에 sleep을 초과하고도 뜨지 않아서 서비스가 멈출 수 있었다. 

 두번째로는 프로세스가 떠있는 것으로 확인을 했는데 프로세스는 jar를 실행하자마자 뜨는 것이기 때문에 서버가 완전히 뜨는 것보다 훨씬 더 빠른 시점이다. 프로세스가 떠있다고 과거의 프로세스를 죽인다면 실상 서버는 완전히 뜬게 아니라서 서비스가 멈춘다. 

 세번째로는 포트가 열려있는 것으로 확인을 했다. jar를 실행시키자마자 생기는 프로세스보다는 포트가 뒤늦게 열리지만 포트 또한 서버가 완전히 뜨는 여부와는 상관이 없이 일찍 열리기 때문에, 포트만 믿고 과거의 프로세스를 죽이면 서비스가 멈춘다. 

 어쩌지 고민을 하다가 외부로 요청을 보내면 이전에 떠있는 A서버가 처리를 했는지 B서버가 처리를 했는지 몰라서 무용지물이었다. 그런데 알고보니 curl은 외부에 있는 nginx를 거쳐서 내부의 서버에 요청을 하는 것 뿐만 아니라 localhost와 port 로 내부에서 내부의 서버에 요청이 가능했다!! 이 방법으로 (1) 내가 원하는 포트로 (2) 응답이 올때까지 요청을 보내고 (3) 응답이 오면 이전의 서버를 죽일 수 있었다. 

<br>

## 결론

 이런식으로 쉘스크립트를 이용해서 업데이트 배포를 하면서 서비스는 죽지 않게 무중단으로 운영될 수 있는 환경을 만들었다. 한국에서는 무중단 배포라고 하지만 영어로는 blue green deploy 라고 한다. 

그리고 팀장님이 spring의 context event를 써보면 어떻겠냐고 하셨는데 지금의 상황에 맞는 방식은 아닌 것 같았다. 그래도 spring event는 한 번 봐야하기 때문에 링크를 남겨 나중에 보기로 했다. 

[https://www.baeldung.com/spring-context-events](https://www.baeldung.com/spring-context-events)
