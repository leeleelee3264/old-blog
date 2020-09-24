---
layout: post 
title: "[Git] Git cheat sheet for myself"
date: 2020-09-24
excerpt: "Every Git command I use frequently"
tags: [index, absinthe4902]
feature: /assets/img/git.png
comments: false
---

# commit

> commit 취소하기

```bash
#1. commit 취소하고 add 파일까지 unstaged 하기
git reset --mixed HEAD^

#2. commit 취소하나 add 파일은 여전히 staged 하기
git reset --softed HEAD^
```

> commit message 변경하기

```bash
#1. 제일 최근에 한 commit의 message 변경
git commit --amend
```

> working directory를 remote repo의 마지막 commit으로 되돌리기

```bash
# 내가 이전까지 작업했던 파일들이 몽땅 날아가니 주의!
git reset --hard HEAD^
```

# add

> add 취소하기

```bash
git reset HEAD 파일경로
```

# push

> push 취소하기

```bash
# remote에 올라간 push를 취소하고, local에서 수정을 한 다음 다시 push를 한다
# 취소한 commit이 remote에서도, local에서도 이전의 모습으로 돌아간다.
# 여러명과 작업할 때 버젼 문제가 있으니 조심해서 쓰자. 

(for local)
git reset HEAD^  # 커밋 취소
git reset 커밋아이디  # 내가 원하는 시점의 commit으로 이동
git commit -m "Commit to unpush" 
(for remote)
git push origin 브랜치이름 -f
```

# branch

# merge

> merge 취소

```bash
#1. local에서 진행한 merge 취소하기 
git reset --merge ORIG_HEAD
```

# cherry-pick 🍒

> 특정 브랜치의 commit 가져오기

```bash
git cherry-pick 커밋아이디
```

# config

> git 계정 등록

```bash
git config --global user.name "absinthe4902"
git config --global user.email "absinthe4902@naver.com"
```

> CRLF 개행문자 설정

```bash
# 맨날 LF Warning이 떠서 쓰기는 하는데 사실 먹히는지 모르겠다.
git config --global core.autocrlf true
```

> working directory 에서 local 계정 만들기

git hub에서 내 commit으로 허용이 되려면 git hub에 등록된 이메일을 사용해야 한다. 개인용 컴퓨터는 상관이 없는데 회사에는 git에 회사 이메일이 등록되어있어 가끔 이메일을 바꿔줘야 하는데 **매번 바꿀 필요 없이 commit하려는 디렉토리에만 local 계정을 만들어주면 된다.** 

```bash
git config --local user.name "local_absinthe4902"
git config --local user.email "local_absinthe4902@naver.com" 

# working directory 에 적용된 config 확인하기 (이 이름으로 push 된다고 생각하면 된다) 
# id name check
git config user.name 

# working directory 의 glo
```
