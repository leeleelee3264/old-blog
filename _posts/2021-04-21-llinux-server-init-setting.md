
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

사실 이전에 한가지 실수를 했는데 우분투 20 desktop 부팅 usb를 만들어서 서버를 설치했다. 노트북을 닫을때 운영체제에서 일어나는 동작을 컨트롤 할 수 있기 때문에 닫는 동작을 무시하면 서버가 계속 켜저있을 거라고 생각했는데 1주일 정도 노트북을 닫고 서버를 돌리니 서버가 다운되었다. 찾아보니 우분투를 서버로 돌릴 목적이라면 초반부터 꼭! 우분투 서버용을 사용해야 했다. [https://ubuntuhandbook.org/index.php/2020/05/lid-close-behavior-ubuntu-20-04/](https://ubuntuhandbook.org/index.php/2020/05/lid-close-behavior-ubuntu-20-04/) 이 포스팅에 노트북 닫을 때 우분투의 작동 제어 방법이 나와있다.

## 초기 네트워크 설정

정말 삽질을 많이 한 부분은 초기 네트워크 설정이다. 집에서 KT 와이파이를 쓰기 때문에 우분투 서버에서도 와이파이에 연결하려고 했는데 막 **서버를 설치하고 나서는 랜선에 우선 연결을 해야 한다.** 와이파이에 연결하려면 몇개의 패키지를 받아야 하는데 네트워크가 연결되지 않은 상태로는 다운을 받을 수 없다... 우분투 데스크톱에는 기본으로 깔려있으나 우분투 서버에서는 직접 다운 받아줘야 한다. [https://www.linuxbabe.com/ubuntu/connect-to-wi-fi-from-terminal-on-ubuntu-18-04-19-04-with-wpa-supplicant](https://www.linuxbabe.com/ubuntu/connect-to-wi-fi-from-terminal-on-ubuntu-18-04-19-04-with-wpa-supplicant) 여러가지 포스팅을 찾아보다가 이 포스트를 보고 그대로 따라하며 와이파이 연결에 성공했다.



```bash
sudo wpa_supplicant -c /etc/wpa_supplicant.conf -i wlp4s0
```



이 커맨드에서 &을 사용해서 백그라운드로 돌리려고 했는데 아무리 해도 백그라운드로 실행이 안 되어서 ctrl + alt + f1 ~f6 으로 전환할 수 있는 터미널 중 하나에서 저 커맨드를 실행하고 다른 작업들은 다른 터미널에서 진행했다. 그런데 포스트를 쓰고 있는 지금 보니까 wpa_supplicant에서 백그라운드를 지원하는 커맨드가 따로 있었다. &로 직접 백그라운드로 돌리는게 아니었다. 아래와 같은 커맨드를 사용하면 된다.

```bash
sudo wpa_supplicant -B -c /etc/wpa_supplicant.conf -i wlp4s0
```





---

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
