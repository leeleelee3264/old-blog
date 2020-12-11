---
layout: post 
title: "[Linux] Linux command cheat sheet"
date: 2020-12-12 08:43:59
author: Jamie Lee
categories: Backend
tags:	linux
cover:  "/assets/img/ubuntu.png"
pagination: 
  enabled: true
---

### **  
1\. cd -**

내가 현재 디렉토리로 옮기기 직전에 있었던 디렉토리로 가는 커맨드.

작업을 하다보면 cd를 써서 디렉토리를 옮기는 일이 정말 많다. 그런데 방금 있었던 디렉토리로 돌아가야 할 때 cd 경로를 다시 치는 것 보다 cd - 를 사용하면 손 쉽게 갈 수 있다. 

[##_Image|kage@MqY2w/btqCD7WXspd/xPTxYUxaYfRvhGHrMJhAGK/img.png|alignCenter|data-filename="cd.PNG" data-origin-width="317" data-origin-height="151" data-ke-mobilestyle="widthContent"|cd -||_##]

### **2\. !!**

바로 이전의 커맨드는 사실 ↑을 이용하는데 가끔 이전의 명령 불러오기가 안되는 경우가 있다고 한다. 그때 사용하면 좋은 커맨드. !를 잘 기억해두자. 과거의 커맨드를 불러들이는데 연관이 있는 커맨드다.

### **3\. !12**

history 커맨드를 사용하면 내가 여태까지 사용한 커맨드들의 기록을 보여준다. 그때 만약 다시 실행하고 싶은 커맨드가 있다면 !12 (실행하고 싶은 커맨드 번호)를 쓰면된다. 예를 들어 보겠다.

[##_Image|kage@dkG65l/btqCF6C80cC/d8zRzdzeegML0HLpK9NbW1/img.png|alignCenter|data-filename="cdnumber.PNG" data-origin-width="420" data-origin-height="692" width="283" height="467" data-ke-mobilestyle="widthContent"|!28||_##]

history에 나와있던 28번째 커맨드를 다시 실행하고 싶어서 !28을 쳤더니 28번째 커맨드가 실행되었다! 지금 내가 사용하는 커맨드는 짧은게 많지만 나중에 긴 커맨드를 실행하고 싶을 때 아주 유용하다.

### **4\. !cd**

아까 !12와 비슷하다. 단, 여기서는 history를 볼 필요가 없다. !cd (내가 제일 마지막으로 실행했던 cd) 라는 뜻이다. 결국 !뒤에 써진 커맨드는 내가 제일 최근에 실행했던 커맨드를 다시 실행해달라는 뜻이다.

[##_Image|kage@skTVE/btqCGRltr9s/aMXtyt1LOlnr2aVRCDrfj0/img.png|alignCenter|data-filename="!cd.PNG" data-origin-width="294" data-origin-height="75" data-ke-mobilestyle="widthContent"|!touch||_##]

### **5\. ctrl + u**

입력된 문자 모두 지우기.

윈도우를 사용하면 ctrl+a를 누르고 backspace를 누르는데 리눅스는 소용이 없다. 그럴 때 ctrl + u를 사용하면 여태 입력했던 문자가 싹 지워진다. 어떨 때 제일 좋냐하면 CUI 환경에서 비밀번호 치다가 오타 났을 때 ctrl+c 눌러서 명령 취소 안 하고 ctrl + u 눌러서 다시 입력할 때 좋다.

### **6\. top **

가끔 리눅스 안에서 실행되는 프로세스들을 확인하고 싶을 때가 생긴다. 예를 들어 실행한 jar 파일이 잘 돌고 있는지, 지금 막 db 배치를 돌렸는데 일을 잘 하고 있는지 등등. 프로세스 확인에는 ps -ef를 제일 많이 사용하겠지만 mysql, java 등등 돌아가는게 한 눈에 보기 좋은 커맨드는 top 이다.

top에서 shift+ p는 cpu 많이 잡아먹는 순으로 보여주고 shift + m 은 메모리 많이 잡아먹는 순으로 보여준다.

### **7\. netstat -ntlp**

사실 이건 고수 커맨드는 아니고 내가 자꾸 깜빡깜빡해서 넣어놨다. 운영체제 안의 몇 번 포트들이 어느 프로세스와 연결되어 열려있는지를 볼 수 있다.

[##_Image|kage@o39R0/btqCEOpqMVd/vkogOiVLhgqh056fkZH4F0/img.png|alignCenter|data-filename="netstat.PNG" data-origin-width="895" data-origin-height="105" data-ke-mobilestyle="widthContent"|로컬 말고 연결된 포트가 없음||_##]

### **8\. screen**

 대부분의 터미널은 bash 프로세스와 연결이 되어있다. 그래서 터미널을 닫아버리면 내가 실행하고 있던 프로세스가 같이 끝나버린다. (bash가 끝났으니까 거기에 올려진 프로세스들도 다 끝나는 것) 그래서 jar 실행 등 리눅스 자체가 멈추지 않는 한 계속 실행되기 바라는 작업들은 리눅스가 죽기 전 까지 죽지 않는 root 프로세스에 연결한다. nohop 커맨드가  바로 그런 역할을 한다.

 그런데 이 방법 말고도 터미널이 죽어도 작업이 죽지 않는 방법이 있다. 바로 screen 커맨드다. 사실 screen 커맨드는 하나의 터미널에 여러 tab을 만들 때 사용하면 좋다. 여기저기서 작업을 할 수 있어서 편리하다. attached/detached 개념을 사용해서 터미널에 붙어있는지 아닌지를 알 수 있다.

 이렇게 스크린을 만들어 두면 작업 도중에 회사에서 집으로 옮겼을 경우 detached된 screen을 attached해서 사용하면 회사에서 하던 작업을 그대로 할 수 있다.

screen -ls: 현재 만들어져있는 screen의 list를 보여줌

screen -S name: name이란 이름의 screen을 만들어서 실행시켜줌

ctrl + a + d: 현재 작업하고 있던 screen에서 나오기 (screen이 detached 상태가 된다)

screen -r name: detached된 name에 다시 접속

ctrl + a + c: 해당 스크린 안에서 새로운 tab(bash)를 열어줌

ctrl + a + n: 다음 tab으로 넘어가기

ctrl + a + p: 이전 tab으로 넘어가기

screen -X -S name quit : name이라는 이름의 screen을 없애버림

이렇게만 알고 있어도 사용에 크게 지장이 없다.

[##_Image|kage@bfTDSr/btqCEOXiQdn/kJgFokbYtVjOKHyx9H0UA1/img.png|alignCenter|data-filename="screenEx.PNG" data-origin-width="696" data-origin-height="232" data-ke-mobilestyle="widthContent"|screen example||_##]

그리고 screen의 환경설정을 .screenrc에서 하는데 이때 화면을 보다 보기 쉽게 만들어 줄 수 있다. 나의 추천은 아래 링크로 세팅하는 것이다. 간결해서 보기 편하다. 적용하면 밑에 그림처럼 screen창이 만들어진다.

[https://gist.github.com/ChrisWills/1337178](https://gist.github.com/ChrisWills/1337178)

[

A nice default screenrc

A nice default screenrc. GitHub Gist: instantly share code, notes, and snippets.

gist.github.com



](https://gist.github.com/ChrisWills/1337178)

[##_Image|kage@oyDdq/btqCEOiKEZT/bcMTNqm9lmeF4zBTftz5kK/img.png|alignCenter|data-filename="screenset.PNG" data-origin-width="916" data-origin-height="452" data-ke-mobilestyle="widthContent"|.screenrc 세팅됨||_##]

---

9\. tail (옵션들 알아보기 -n -f -F 등등) -f는 파일이 달라지는 걸 모른는데(포인터가 달라지는 둥) -F는 파일의 변화를 안다. 내용이 바뀐다는 것보다는 파일의 포인터가 달라진다는 얘기를 하는 것 같음.

10.head

### **11\. touch**

그냥 시간 업데이트 한다고 생각했는데 컴파일러와 상관이 있다. 컴파일러는 안의 내용이 바뀌지 않아도 시간이 갱신되면 아 얘 새로운 변경사항이 있구나~ 하고 다시 컴파일을 해준다. 그래서 컴파일을 다시 하고 싶은데 번거롭게 뭘 따로 하고 싶지 않으면 touch를 써서 쉽게 시간을 바꿔주면 컴파일이 된다.

### **12\. tmux (초강추)**

다른 분이 알려주신 커멘드인데 정말 너무너무 잘 쓰고 있다. 예전에 이거 없이 어떻게 살았나 싶을 정도.. screen 커맨드와 비슷한데 훨씬 더 좋다. session으로 이전 작업을 기억할 뿐 아니라 화면을 나눌 수 있다.

새로운 session 열기: tmux new -s session\_name

session 목록 확인: tmux ls

session 종료하기: (tmux session에 들어가있는 상태에서) exit -> 양파처럼 윈도우가 하나씩 꺼진다. 마지막으로 exit을 하면 세션이 종료된다.

session deattach 하기: ctrl+b, d

session reattach 하기: tmux attach -t session\_name

session window 새로 만들기: ctrl+b, c

화면 나누기

가로로 나누기: ctrl+b, "

세로로 나누기: ctrl+b, %

나눠진 화면 모양 바꾸기: ctrl+b, space

나눠진 화면 비율 바꾸기: ctrl+b 누른 상태로 방향키로 조정

화면 사이 이동하기: ctrl+b, 방향키

[##_Image|kage@bS8PXw/btqEo6PRJEO/DhF5pnlCsYHfPH0CSSbrHK/img.png|alignCenter|data-filename="배경.PNG" data-origin-width="1435" data-origin-height="908" data-ke-mobilestyle="widthContent"|tmux 사용 화면||_##]

새로운 운도우 만드는 커맨드가 정말 너무 안 외워져서 쓸 때마다 검색하는데 지금보니 ctrl+b, c 였던 이유가 create의 c가 아니었을까 싶다.

### **13\. nginx -t**

갑자기 리눅스 커맨드 얘기 하다가 nginx 얘기가 나왔는데 자주 깜빡해서 써두기로 했다. nignx의 conf 파일을 바꾸고 겁도 없이 바로 systemctl reload nginx 를 하고는 했는데 그 전에 conf 파일을 바꿨으면 검사를 먼저 해줘야 한다.

sudo nginx -t 를 하면 잘 썼을 경우 ok가 나오는데 그때 systemctl reload nginx로 반영을 하자.

### **14\. ss**

ss에 대한 포스트를 읽다보니 ss가 new netstat 라는 말을 봤는데 그런것 같다. 열린 포트를 보려고 netstat을 해야하는데 정말 안 외워지는 커맨드 같다. ss가 조금더 사용이 쉽다고 한다.

[##_Image|kage@cBUuD6/btqEq62ra5q/9mf7Xel1BWHUeEWJy5KAXk/img.png|alignCenter|data-origin-width="0" data-origin-height="0" data-ke-mobilestyle="widthContent"|ss 커맨드 결과||_##]

ss: 연결된 포트가 다 나온다

ss -t : 연결된 tcp 포트

ss -u : 연결된 udp 포트

ss -x : 연결된 유닉스 포트 (시스템적으로 연결된거라서 결과가 정말 많이 뜬다)

ss -tl : 연결된 tcp 포트 중에서 LISTEN 상태인것

ss -tlp : 연결된 tcp 중 LISTEN 상태를 돌리고 있는 프로세스까지 보여준다

ss state listening : 연결된 port중 LISTEN 상태인것 (ss -l 과 동일한테 줄바꿈이 안 일어난다)

ss -n : 연결된 포트를 보는데 n: numeric 옵션이라서 포트 번호를 정확하게 보여준다.

ss dst 특정 ip : 연결된 특정 ip에 대한 정보 (ip는 peer address의 ip이다.)
