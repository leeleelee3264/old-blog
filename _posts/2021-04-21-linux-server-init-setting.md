---
layout: post
title: "[Linux] 리눅스 서버 설치 & 초기 세팅하기"
date: 2021-04-16 08:43:59
author: Jamie Lee
categories: Backend
tags:	linux 
pagination:
enabled: true
---

이전에는 리눅스를 사용하려면 VMWare 같은 가상 머신을 이용했는데 집에 안 쓰는 노트북이 있어서 아예 깔려있는 윈도우를 밀고 리눅스를 설치해서 서버처럼 써보기로 했다. 설치뿐만 아니라 설치 후 이것저것 초기 세팅을 해줄것들이 있어서 정리 차원에서 포스팅을 한다.

# 리눅스 설치하기

리눅스를 설치하려면 설치용 usb를 먼저 만들어야 한다. [https://webnautes.tistory.com/1146](https://webnautes.tistory.com/1146)  이 블로그에 나오는 포스팅을 참고해서 Rufus 로 우분투 20 server 용 부팅 usb 를 만들었다. 부팅용 usb가 만들어지면 다른 운영체제를 설치할때와 마찬가지로 부팅시에 boot configuration으로 들어가는 버튼을 열심히 눌러서 usb drive를 선택해서 부팅하면 리눅스 설치는 끝이 난다.

<br>

사실 이전에 한가지 실수를 했는데 우분투 20 desktop 부팅 usb를 만들어서 서버를 설치했다. 노트북을 닫을때 운영체제에서 일어나는 동작을 컨트롤 할 수 있기 때문에 닫는 동작을 무시하면 서버가 계속 켜저있을 거라고 생각했는데 1주일 정도 노트북을 닫고 서버를 돌리니 서버가 다운되었다. 찾아보니 우분투를 서버로 돌릴 목적이라면 초반부터 꼭! 우분투 서버용을 사용해야 했다. [https://ubuntuhandbook.org/index.php/2020/05/lid-close-behavior-ubuntu-20-04/](https://ubuntuhandbook.org/index.php/2020/05/lid-close-behavior-ubuntu-20-04/) 이 포스팅에 노트북 닫을 때 우분투의 작동 제어 방법이 나와있다.

리눅스를 설치할 노트북은 dell xps 14 2012 모델로  InsydeH20 bios를 사용하고 있다. 처음에는 이 bios 설정 사항들을 잘 몰라서 시간을 많이 썼는데 이 블로그를 보면서 
따라할 수 있었다. https://moadi.tistory.com/235



<br>
<br>

## 초기 네트워크 설정

정말 삽질을 많이 한 부분은 초기 네트워크 설정이다. 집에서 KT 와이파이를 쓰기 때문에 우분투 서버에서도 와이파이에 연결하려고 했는데 막 **서버를 설치하고 나서는 랜선에 우선 연결을 해야 한다.** 와이파이에 연결하려면 몇개의 패키지를 받아야 하는데 네트워크가 연결되지 않은 상태로는 다운을 받을 수 없다... 우분투 데스크톱에는 기본으로 깔려있으나 우분투 서버에서는 직접 다운 받아줘야 한다. [https://www.linuxbabe.com/ubuntu/connect-to-wi-fi-from-terminal-on-ubuntu-18-04-19-04-with-wpa-supplicant](https://www.linuxbabe.com/ubuntu/connect-to-wi-fi-from-terminal-on-ubuntu-18-04-19-04-with-wpa-supplicant) 여러가지 포스팅을 찾아보다가 이 포스트를 보고 그대로 따라하며 와이파이 연결에 성공했다.


<br>

```bash
sudo wpa_supplicant -c /etc/wpa_supplicant.conf -i wlp4s0
```
<br>



이 커맨드에서 &을 사용해서 백그라운드로 돌리려고 했는데 아무리 해도 백그라운드로 실행이 안 되어서 ctrl + alt + f1 ~f6 으로 전환할 수 있는 터미널 중 하나에서 저 커맨드를 실행하고 다른 작업들은 다른 터미널에서 진행했다. 그런데 포스트를 쓰고 있는 지금 보니까 wpa_supplicant에서 백그라운드를 지원하는 커맨드가 따로 있었다. &로 직접 백그라운드로 돌리는게 아니었다. 아래와 같은 커맨드를 사용하면 된다.

<br>

```bash
sudo wpa_supplicant -B -c /etc/wpa_supplicant.conf -i wlp4s0
```





---
<br>
<br>

### 고정 ip 설정하기

이더넷이나 와이파이를 연결해서 사용할때면 서버가 설치된 컴퓨터를 종료했다가 다시 키면 할당된 ip주소가 바뀔때가 있다. 얼마전에 회사에서 정전이 되어서 내부에서 사용하던 서버 컴퓨터 전원이 나갔다가 다시 들어왔는데 ssh로 접속이 안되어서 컴퓨터에 화면을 연결해서 직접 보니 IP 주소가 바뀌어있었다. 이런 불상사를 피하고 싶다면 고정 ip를 할당해주면 된다.

매번 이더넷으로만 고정 ip를 설정했는데 와이파이도 큰 차이 없이 아래와 같이 하면 된다. 아래에 작성된 파일은 netplan에서 사용하는 yaml 파일인데 수정하고 적용하려면 꼭 **netplan apply** 커맨드를 입력해주자. 그리고 netplan을 사용하는 우분투 버전은 18 부터다.

<br>

```bash
# This is the network config written by 'subiquity'
network:
  ethernets:
       enp7s0:
                dhcp4: true
  version: 2
  wifis:
        wlp8s0:
                dhcp4: no
                dhcp6: no
                addresses: [ 172.30.1.100/24 ]
                gateway4: 172.30.1.254
                nameservers:
                        addresses: [ 8.8.8.8, 1.1.1.1 ]
                access-points:
                       "KT_GiGA_2G_FO1F":
                               password: "wifi_password"
```

<br>

여기까지 하면 일단 네트워크 설정은 끝난다. 사실 서버 컴퓨터는 직접 작동을 시킬 일이 거의 없다. 대부분 ssh를 이용해서 외부에서 서버 컴퓨터 속의 서버에 접속을 한다. 이제 ssh 접속을 위한 세팅과 ssh 로 접속할 유저를 위한 세팅을 해보자.

---

<br>

## SSH setting

```bash
# 설치
sudo apt-get install openssh-server 

# ssh port open 
sudo ufw enable 
sudo ufw allow 22
```
<br>

설정파일에 ssh_config와 sshd_config 두개가 있는데 대부분의 조작은 sshd_config에서 바꿔줘야한다. 리눅스 네임컨밴션을 생각해보면 sshd_config는 ssh가 데몬프로세스로 백그라운드 실행이 될때를 컨트롤 하는 파일이 아닐까?

이번에는 서버 직접 설치라서 상관이 없는데 만약 aws와 같은 클라우드에서 서버를 만들어서 구동한다면 pem 키를 발급해준다. 문제는 이 pem키를 한 번 발급해주기 때문에 여러명이 해당 서버에 접속하려면 불편하다. 한명이 pem키로 서버에 접속을 하고 ssh를 설치해서 key 뿐만 아니라 비밀번호로도 접속을 할 수 있게 만들어줘야 한다.

<br>

```bash
# 비밀번호 접속허용
PasswordAuthentication yes
```

<br>

## 사용자 setting

ssh를 설정 완료 했다면 ssh를 이용해서 로그인할 사용자와 그룹을 만들어주자. 앞으로 ssh를 사용해서 로그인을 하면 이 사용자가 되어 서버를 돌아다니기 때문에 꼭 sudoer까지 설정을 해줘야 한다.  접속할때 아예 해당 유저를 넣어서 접속을 한다. `ssh user@address`

### 그룹과 사용자 생성
<br>

```bash
# make group
sudo addgroup "group_name"

# make user 
sudo adduser "user_name"

# put the user in the group 
gpasswd -a "user_name" "group_name"

# check the user is now in the group 
getent group "group_name"
```

<br>

참고로 서버 안에 있는 그룹들과 유저들을 확인하기 위해서는 /etc에 있는 group과 passwd 파일을 직접 조회하는데 아래와 같은 커맨드를 쓰면 좀 더 깔끔하게 볼 수 있다.

<br>

```bash
# group list
cut -d : -f1 /etc/group

# user list 
cut -d : -f1 /etc/passwd
```

---
<br>

### 만든 사용자에게 권한 부여해주기

딱 두가지 권한이 필요하다. 서버에서 sudo 커맨드를 쓰기 위해 **sudoer 권한이 필요**하고, 소스코드나 실행파일등 개발한 것들을 /opt 파일에 두고 조작을 하기 때문에 **소유가 root로 되어있는 opt디렉터리를 사용자로 바꿔줘야 한다.** 안 바꾸면 매번 디렉터리 안에서 뭘 조작하려면 root 권한이 필요해서 sudo를 사용해야 한다.

<br>

```bash
sudo vi /etc/sudoers

# User privilege specification
root    ALL=(ALL:ALL) ALL
dev     ALL=(ALL:ALL) ALL

# 아래처럼 하면 sudo 실행시 비밀번호를 안 넣어도 된다. 
dev     ALL=(ALL:ALL) NOPASSWD: ALL

# 디렉터리 소유권 바꾸기 (사용자) 
sudo chown "user_name" opt

# 디렉터리 소유권 바꾸기 (그룹)
sudo chown :"group_name" opt

```

---

<br>

## 프롬프트 및 시간대 변경

처음 서버를 파면 프롬프트가 보기가 다소 불편하다. 이것도 입맛에 맞게 바꿀 수 있는데 사용자 설정파일인 .bashrc안에 있는 PS1 부분을 수정해주면 된다.  사용자별로 설정이 되기 때문에 해당 사용자의 홈 디렉터리에 들어가서 수정을 해주도록 하자.

<br>

```bash
vi ~/.bashrc

IP=$( ifconfig | grep 'inet addr:' | grep -v '127.0.0.1' | tail -1 | cut -d: -f2 | awk '{ print $1}')
if [ "$color_prompt" = yes ]; then
    PS1='🎄HOME `date +%T` ${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@$IP\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='🎄HOME `date +%T` ${debian_chroot:+($debian_chroot)}\u@$IP\h:\w\$ '
fi

# apply bashrc 
source ~/.bashrc
```

<br>

간단하게 서버 이름 + 시간 + 유저이름이 보이도록 수정을 했는데 프롬프트는 무궁무진하게 수정이 가능하다. 링크를 보면 더 다양한 형태로 수정을 할 수 있다.

[https://www.cyberciti.biz/tips/howto-linux-unix-bash-shell-setup-prompt.html](https://www.cyberciti.biz/tips/howto-linux-unix-bash-shell-setup-prompt.html)

---

<br>

### 시간대 변경

서버를 처음 시작하면 시간대가 기본 UTC로 설정이 되어있다. 글로벌 서비스를 하면 세계 기준시가 UTC라서 그대로 내버려둬도 되는데 한국에서 사용하는 서버라서 시간대를 KST로 변경했다. 서버의 시간대는 `date` 를 찍어보면 맨 뒤에 어떤 시간대인지 나온다.

<br>

```bash
# 어떤 시간대를 지원하나 먼저 확인
timedatectl list-timezones 

# 시간대를 서울로 변경
timedatectl set-timezone Asia/Seoul
```

---

<br>

## 서버 설치 후 설치할 것들

**build-essential** 패키지는 개발에 필요한 기본 라이브러리와 헤더파일들을 가지고 있는데 C 컴파일러 등등이 포함되어있다. 우분투에 설치되는 패키지 상세 정보는 아래와 같은 링크에서 확인이 가능하다.

[https://packages.ubuntu.com/](https://packages.ubuntu.com/)

<br>

```bash
# install build-essential
sudo apt-get install build-essential
```

<br>

개발을 자바로 하다보니까 서버를 설치하면 필수적으로 자바를 설치해야 한다. 서버에서 어떤 자바 버전들을 지원하는지 보고 원하는 버전을 설치해주면 된다.

```bash
# 설치 가능한 jdk 확인 
sudo apt search jdk 

# 설치
sudo apt-get install "java_version"
```

<br>
<br>

---

---

<br>

이정도로 하면 초기에 기본으로 설정해줘야하는 세팅들이 어느정도 정리가 된다. 밑에는 서버 사용하면서 그때그때 생각나는 편의를 위한 세팅들을 기록할 예정이다.

# 계속 이어나가야할 기본 세팅들
<br>

## vi들어가면 줄번호 나오게
<br> 

```bash
# open vim setting for user 
vi ~/.vimrc 

# add this in vimrc file
set number
```

<br>


## 프롬프트 ip 주소 나오게
<br>

`vi ~/.bashrc` 로 user별 설정 파일을 열어주고 PS1 있는 부분을 아래와 같이 수정해주면 된다. 
그럼 `user_name@|ip_address|` 이런 형태로 프롬프트가 변한다.
<br>


```bash
# Set the prompt to include the IP address instead of hostname
function get_ip () {
  IFACE=$(ip -4 route | grep default | head -n1 | awk '{print $5}')
  if [ ! -z $IFACE ]; then
    echo -n "|"; ip -4 -o addr show scope global $IFACE | awk '{gsub(/\/.*/, "|",$4); print $4}' | paste -s -d ""
  else
    echo -n "||"
  fi
}

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u\[\033[01;34m\]@\[\033[32m\]$(get_ip)\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@$(get_ip):\w\$ '
fi
unset color_prompt force_color_prompt
```

## 우분투 기본 shell 설정 변경 

가끔 도커를 쓰거나 새로 서버를 만들면 쉘에 아무것도 나오지 않고 $ 표시만 나오는 떄가 있다. 우분투에서 기본으로 사용하는 쉘이 c shell로 되어있기 때문이고, 
기본 쉘을 bash shell로 바꿔주면 익숙한 형태의 터미널 쉘이 된다. 

<img src="/assets/img/post/bash.PNG" alt="drawing" width="500"/> 

사용자에 따라 기본으로 설정된 쉘이 다른데, 이는 /etc/passwd 파일에서 확인을 할 수 있다. 
위의 이미지처럼 사용하는 계정을 찾아 /bin 뒤의 부분을 바꿔주면 된다. 
나는 dev라는 계정을 쓰고 있고, bash shell로 바꾸고 싶었기 때문에 /bin/bash 로 수정해주었다. 
수정을 해주고 로그인을 다시 해주면 터미널이 변경된 쉘로 나온다! 

<br>

## 우분투에 Maria DB 설치하기 
개인 프로젝트에서 DB를 사용하게 되어서 우분투에 마리아 DB를 설치했는데 MySQL과 중첩이 되는 둥 몇 번 잘못 설치를 해서 
서버를 다시 밀고 설치하기를 반복했다. 결국은 이 포스팅을 보면서 무사히 DB 설치를 마쳤다. https://www.digitalocean.com/community/tutorials/how-to-install-mariadb-on-ubuntu-20-04

```shell
sudo apt update  
sudo apt install mariadb-server 
sudo mysql_secure_installation 
```

sudo mysql_secure_installation 을 실행하면 Maria DB에서 기본적으로 설정되는 보안 옵션을 조금 더 보완할 수 있게 옵션을 변경할 수 있다. 

<br> 

```shell
# localhost 에서만 access 가능한 계정 
GRANT ALL ON *.* TO 'admin'@'localhost' IDENTIFIED BY 'password' WITH GRANT OPTION;

# 모든 IP에서 access가 가능하게 와일드카드를 부여한 계정 
GRANT ALL ON *.* TO 'admin'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;

# mysql 계정과 관련된 작업 후에는 꼭 flush를 해서 refresh 를 해주자! 
FLUSH PRIVILEGES;
```

DB를 조작할 때는 되도록 ROOT를 사용하지 말아야 하기 때문에 DB 설치를 진행하면서 default로 사용할 계정도 함께 만들어줬다. 이 계정을 localhost 에서만 사용을 한다면 여기서 끝이지만 remote 환경에서 해당 계정으로 접속을 가능하게 하려면 몇가지 
설정을 더 해줘야 한다. 

### remote access to Maria DB 
원격 환경에서 DB에 접속하기 위해서는 아래의 3가지 사항을 설정해야 한다. 
1. mysql 계정을 만들 때 와일드 카드 %를 넣던가 access IP를 추가해준다. 
2. mysql conf 파일에서 bind-access가 localhost로 되어있는데 0.0.0.0으로 변경 해 모두 허용해준다. 
3. (2까지 해도 안된다면) 우분투에서도 mysql port인 3306 방화벽을 내려준다.
4. 만약 aws와 같은 cloud 도 이용하고 있다면 cloud 의 설정도 변경해야 한다. 

<br>
mysql conf에서 bind-address 를 0.0.0.0으로 해두면 모든 remote IP에서 접속이 가능하기 때문에 보안상으로 문제가 있지는 않을까 찾아봤다. bind-access는
mysql이 들을 수 있는(listen) 특정 네트워크들을 뜻한다. 이렇게 0.0.0.0 으로 열어버리면 역시나 보안상으로 좋지 않다고 한다. default 설정처럼 그냥 로컬 머신에서만 DB와 연결하는 게 제일 안전하다.

<br>

- If MySQL binds to 127.0.0.1, then only software on the same computer will be able to connect (because 127.0.0.1 is always the local computer).
- If MySQL binds to 192.168.0.2 (and the server computer's IP address is 192.168.0.2 and it's on a /24 subnet), then any computers on the same subnet (anything that starts with 192.168.0) will be able to connect.
- If MySQL binds to 0.0.0.0, then any computer which is able to reach the server computer over the network will be able to connect.


> 외부에서 접속을 해야 해서 bind-address를 활짝 열어버렸는데 보안을 조금이라도 강화하려면 mysql user 설정을 할 때 와일드 카드로 모든 IP에서 access 할 수 있게 할 게 아니라 특정 IP에서만 access 할 수 있게 해야 겠다. 

<br> 

mysql conf를 변경하고 난 후 mysql을 재시작해주면 이제 외부에서도 방금 만든 계정으로 DB에 접속할 수 있다. 
```shell
sudo /etc/init.d/mysql restart
```






