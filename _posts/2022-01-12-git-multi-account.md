---
layout: post
title: "[Git] 여러 개의 깃허브 계정 쓰기"
date: 2022-01-12 08:43:59
author: Jamie Lee
categories: General
tags:	Git
cover:  "/assets/img/git.png"
pagination:
enabled: true
---

> 여러 개의 깃허브 계정을 사용하는 방법을 다룹니다.
>

<br>

index

- 깃허브 계정 여러 개 세팅하기
  - ssh 키 발급
  - ssh config 작성
  - ssh 키 깃허브에 등록

- 매번 해줘야 하는 작업들
  - 레포지토리 주소 수정
  - 계정 정보 명시

<br>

참고: 복수의 깃허브 계정을 사용 할 때, 아래처럼 각 계정들의 root source directory를 나누어두면 관리적 측면에서도, git config 설정을 할 때에도 더 편리하다. 

```shell
.
└── home
    ├── office
    └── personal

```

<br>

맥에서 개인 깃허브 계정과 회사 깃허브 계정을 동시에 쓰는 방법을 찾아봤는데 삽질을 조금 해서 다음번에도 이런 일이 있을까봐 간략하게 문서화 해두기로 했다. 중요한 부분은 이렇게 복수 개의 계정을 세팅해두었으면, **매번 새로운 레포지토리를 만들거나 클론할 때 마다 추가 작업들을 해줘야 오류가 나지 않는다.**

## 터미널에서 여러 개 깃허브 계정 세팅하기

> ssh 키 발급
>


사용할 계정들의 키 발급:

```bash
ssh-keygen -t rsa -b 4096 -C "leelee@office.com"
ssh-keygen -t rsa -b 4096 -C "leelee@personal.com"
```

로컬의 ssh-agent 에 발급받은 키 연결:

```bash
ssh-add -K ~/.ssh/id_rsa_personal 
ssh-add -K ~/.ssh/id_rsa_office 
```

위에서 연결한 ssh 키 정보들은 `ssh-add -l` 로 확인이 가능하다.

<br> 

> ssh config 작성
>

발급받은 키들과 깃허브 계정 정보를 로컬 단에서 연결을 하기 위해 .ssh/config 에 관련 정보들을 작성을 한다.

.ssh/config:

```bash
# Personal GitHub account
Host github.com-personal 
HostName github.com
User git
AddKeysToAgent yes
UseKeychain yes
IdentityFile ~/.ssh/id_rsa

# Office Github account
Host github.com-office
HostName github.com
User git
AddKeysToAgent yes
UseKeychain yes
IdentityFile ~/.ssh/id_rsa_office
```

config 작성이 끝났다면 로컬에서 해줘야 할 일은 끝이다! 이제 ssh 키들을 깃허브에 등록을 해주도록 하자.

<br>

> ssh 키 깃허브에 등록
>

ssh-keygen 을 하면 파일이 각각 `id_rsa.pub` 와 `id_rsa` 가 생긴다. 여기서 .pub는 외부로 공개되는 공개키이다. **깃허브에 등록될 키는 이 id_rsa.pub 키로**, 해당 파일을 열어보면 파일 끝에 이메일이 들어가 있다.  그리고 일반 id_rsa 는 외부로 공개가 되어서는 안되는 키이다!

<br>

id_rsa.pub

```bash
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCruMY405yFL/6fvDvVFUTlxgXVO
XRhdXlWDGsX5Kcn7yvEiGwBhVngvL8WWfA+hlelodoIAvlgnN9sJmVDDHF8XkK6r/
INdvFBAQ28+2GlOM8l038HDiCOTg/GzhEQK0hVzE0Cgsfrw2YMSxDJ9Gr9eSDSN0ia0LM
LHMXdn5I5aeePGlt0boMIJgohzLVb4HT5KipBxbHETe05a8oOvmc9nS8r47ibSWpecuqDMJ7
7YrBa82X0d+5nAdZ1QiJg63k7ifJdPC4/CJHVvmglsHBzTkWEdn89R6q4OwyrUBRnrcITrF8
aCQMax2A5f7SaLcJ9xXQx47LT0ApfJ5UhHmLdK2vKzWEeEXhMfT3d0wIlppsEs5FuZRLqSAyZ
QCn1IxZvV+KBAe5O3B9sidhULMnTzGqLCe3lLv3K0uI2MrP694LHqjW0duppbRbZZSNGdc0AM
PtOqprI+lvBAugi6mN20sWRBMsHz1m1HdUI4yM85VAhYLNLgqs5n13ZfwUYEEh9EyqtGESToy
8DCSRqPqHNINB0skGBh9DF3ChjhdKvyn40AmpHdAzFlWgKGXbvx1DKzVhkubGNkISicwT7U+9
/18UuHJL2OsoFd9YcQ0qJqcrXWY2RxVkqAxzndxaPNeT5uXhZt0yNukm3UXd9khEd/Qn8F1n
IqgHGiVCntP9wmQ== leelee@personal.com

```

<br>


github setting 페이지로 이동:

![https://www.heady.io/hs-fs/hubfs/Assets%20June%202020/Blog%20Images/1_Zz-0nINK5t3TrX0KIz2rYw.png?width=227&name=1_Zz-0nINK5t3TrX0KIz2rYw.png](https://www.heady.io/hs-fs/hubfs/Assets%20June%202020/Blog%20Images/1_Zz-0nINK5t3TrX0KIz2rYw.png?width=227&name=1_Zz-0nINK5t3TrX0KIz2rYw.png)

<br>

SSH and GPG Keys 항목에서 New SSH key 로 키 등록:

![https://www.heady.io/hs-fs/hubfs/Assets%20June%202020/Blog%20Images/1_-gpWpnwo_0Ang-WMgVrY1A.png?width=900&name=1_-gpWpnwo_0Ang-WMgVrY1A.png](https://www.heady.io/hs-fs/hubfs/Assets%20June%202020/Blog%20Images/1_-gpWpnwo_0Ang-WMgVrY1A.png?width=900&name=1_-gpWpnwo_0Ang-WMgVrY1A.png)

작업이 다 끝났으면 아래에 나오는 **매번 해줘야하는 작업들** 항목을 해주면 된다. 이미 레포지토리들이 다 로컬에 클론이 되어있는 상태라면 레포지토리를 지우고 다시 클론을 해주거나, git remote set-url 을 이용해 주소를 변경해주면 된다.

<br>


> 계정 정보 명시
>

Github에서 사용하는 **name과** **email을** 별도로 설정해주지 않으면 개인 리포지토리에 올릴 커밋의 작성자가 회사 계정으로 되어있는 둥의 혼선을 겪을 수 있다. 떄문에 각각 계정별로 정보를 명시해줘야 한다.

(해당 예시에서는 개인 계정을 default로 사용한다.)
<br>

계정 명시:
1. home과 회사 office directory 에 각각 .gitconfig 파일을 하나씩 만들어준다. 
2. home에 있는 .gitconfig에 default로 사용할 계정의 name과 email을 입력해준다. 
3. home에 있는 .gitconfig에 회사 계정의 .gitconfig 를 불러오는 조건을 추가해준다. 
4. office에 있는 .gitconfig에 회사 계정의 name과 email을 입력해준다. 


home .gitconfig: 
```shell
[user]
	name = leelee-personal
	email = leelee@personal.com
[includeIf "gitdir:~/office/"]
	path = ~/office/.gitconfig
```
<br>

office .gitconfig:
```shell
[user]
	name = leelee-office
	email = leelee@office.com
```

<br>

모든 파일들을 만들었을 때 디렉터리의 구성은 아래와 같다. 
```shell
.
└── home
    ├── .gitconfig
    ├── office
    │   └── .gitconfig
    └── personal

```

<br>


## 매번 해줘야 하는 작업들

### 레포지토리 주소 수정


기존 url:

```bash
git clone git@github.com:(Repo path).git
```



수정 url:

```bash
git clone git@github.com-office:(Repo path).git
```

<br>

.ssh/config 에서 연결할 Host를 계정별로 분기해서 각각 `github.com-personal` 과 `github.com-office` 로 구분을 했는데 이제는 매번 레포지토리를 만들거나, 클론할 때 해당 작업을 해줘야 한다. git remote set-url 로 레포지토리를 연결할 떄도 똑같은 형식으로 해줘야 한다.

<br>

set-url 예시:

```bash
git remote set-url origin git@github.com-office:(Repo path).git
```


<br>

## Reference

[CodeWords: A Mobile Application Blog by Heady](https://www.heady.io/blog/how-to-manage-multiple-github-accounts)
