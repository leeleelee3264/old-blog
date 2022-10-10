---
layout: post
title: "[Git] Git cheat sheet for myself (On-Going)"
date: 2020-09-24 08:43:59
author: Jamie Lee
categories: Cheat
tags:	Git
cover:  "/assets/img/git.png"
pagination:
enabled: true
---

<hr>

# git tag 
## make annotated tag 
```bash
git tag -a v1.0.0 -m "leave message here for tag"
```

<br> 
<br> 
<hr>


# git log
## git log option
```bash
# show log with one line 
git log --oneline 

# show log with graph tree
git log --graph

# show log with both 
git log --oneline --graph
```

<br> 
<br> 
<hr>


# git diff
## compare file between two branches
```bash
git diff branch1..branch2 -- "file_name"

ex) diff 2021_0405_user..master -- build.gradle
```


<br> 
<br> 
<hr>


# git branch

## change branch name
```bash
git branch -m "branch_name"
```

<br> 

## making branch with specific commit


```bash
git branch branch_name commit_version 

ex) git branch 2021_0422_add a9f5fc39c52dd362f99eb58fc1a011a6a12f9b1a
```
<br> 

## switching branch hack

> going back to previous branch with one second.
> Quite similar with going back to previous directory in Linux.
```bash
git switch - 
```

<br> 

## Show branches
```bash
# local
git branch
# remote 
git branch -r 
# all 
git branch -a 
```
<br> 

## Check merged branch in Local
```bash
git branch --merged

# check no merged branch in Local
git branch --no-merged
```
<br> 

## Check merged branch in Remote
```bash
git branch -r --merged
```
<br> 

## Delete local branch 
```bash
git branch -d branch_name 

# delete non merged branch 
git branch -D branch_name 

# delete merged branches (no specific command, have to use pipe
# egrep is grep with regex expression
# egpre -v find reverse result with regex. it will return without string contains master, tpi, gov 
git branch --merged | egrep -v "(^\*|master|tpi|gov)" | xargs git branch -d
```


<br> 

## Delete remote branch new version (work fine)
```bash
(1) git push repo_name --delete branch_name 
(2) git branch -d branch_name 
    git push orign branch_name 
``` 
<br> 

## Delete remote branch (not working sometimes)
```bash
git branch origin --delete branch_name 

# If you see does not exist, it would be occuered because the remote branch you want to delete is so out-dated. 
# Using this command will automatically delete some of them. 
git fetch -p 

# difference between pull and fetch 
# pull = fetch + merge 
# fetch = only fetching. If you want, you can check first and merge later for safety.
```

<br>

## 원격 저장소 branch 가져오기

```bash
# 1. 일단 pull 하고 local 과 remote에 있는 branch 확인하기 
git branch -a 
# 2. remote에 있다고 표기된 branch 가져오기 
git checkout -t origin/0921_excel 
```


<br> 
<br> 
<hr>


# git switch

## git switch 로 브랜치 작업하기
```bash
# 1. 브랜치 변경하기 
git switch master
# 2. 브랜치 새로 만들어서 변경하기 
git switch -c master
# 3. 특정 버전 commit 에서 브랜치 새로 만들어서 변경하기 
git switch -c master commit-number

```


<br> 
<br> 
<hr>


# git resotre

## restore 로 작업 되돌리기
```bash

# 브랜치에서 작업했던 파일 작업 전으로 날려버리기 (add 하기 전) 
git restore src/path/sample.java

# 브랜치에서 작업했던 파일 작업 전으로 날려버리기 (add 한 후) 
git resotre --staged src/path/sample.java
```

<br>

## 현재 브랜치에 없는 파일 가져오기

```bash
# commit 을 안 해서 없는 (새로 생성한) 파일은 그냥 cherry-pick으로 가져오자. 
# 이 커맨드 써서 가져오려면 꼬이기만 한다. 
# 얘는 현재의 브랜치에서는 삭제되어 없는 파일을 과거 브랜치에서 가져오는 용으로

git restore --source branchName src/file/you/delete/before.java
```


<br> 
<br> 
<hr>



# git commit
## commit 취소하기

```bash
#1. commit 취소하고 add 파일까지 unstaged 하기
git reset --mixed HEAD^

#2. commit 취소하나 add 파일은 여전히 staged 하기
git reset --softed HEAD^
```
<br> 

## commit message 변경하기

```bash
#1. 제일 최근에 한 commit의 message 변경
git commit --amend
```

<br> 


## 제일 최근에 한 commit에 새로운 파일 추가하기

```bash
git add src/file/you/want/to/add.java
git commit --amend
```
<br> 

## commit 날짜 바꾸기 aka 인공 잔디 심기

```bash
#1. 제일 최근에 한 commit의 날짜 변경
# 마지막에 +0900 은 KST 시간대 설정
git commit --amend --no-edit --date "Fri Oct 23 11:11:11 2020 +0900"
```

<br> 

## working directory를 remote repo의 마지막 commit으로 되돌리기

```bash
# 내가 이전까지 작업했던 파일들이 몽땅 날아가니 주의!
git reset --hard HEAD^
```
<br> 
<br> 
<hr>


# git add
## add 취소하기

```bash
git reset HEAD 파일경로
```


<br> 
<br> 
<hr>



# git push
## push 취소하기

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


<br> 
<br> 
<hr>


# git merge
## merge 취소

```bash
#1. local에서 진행한 merge 취소하기 
git reset --merge ORIG_HEAD
#2. 더 쉬운 방법 (Conflict 발생했을 때 쓴다)
git merge --abort
```


<br> 
<br> 
<hr>


# git cherry-pick 🍒

## 특정 브랜치의 commit 가져오기

```bash
git cherry-pick 커밋아이디

# 가끔  cherry-pick으로 commit 가져오다가 branch끼리 conflict 가 난다. 그때는 cherry-pick을 취소하자
git cherry-pick --abort
```


<br> 
<br> 
<hr>


# git checkout
## get removed file back
```bash

# 1.When you didn't commit 
# Freshly made file will be tracked after adding, 
# but in terms of removing, nothing will remain. I cannot even add the change. I can only commit the removing. 

git checkout HEAD file_you_removed
```
<br> 

## reset(revert) file to specific commit version
Let's say you wrote something on A file but you were supposed to write the thing on B file.
So you just copy the content in A to B. Now B is fine. How about A? You should get the previous content back to A.
This command will be lifesaver.

```bash
# 1. Want to revert the file to specific commit version 
git checkout commit_number -- file_you_should_revert

# 2. Want to revert the file to before the specific commit version 
git checkout commit_number~1 -- file_you_should_revert
```

The second way works like this. If you change a file a lot in the latest commit and before that, the file was modified age ago.
Then you can just revert the file before the latest commit.


<br>

## 브랜치에서 작업했던 파일 작업 전으로 날려버리기 (add 하기 전)
```bash

git checkout src/path/sample.java
```



<br> 
<br> 
<hr>



# git config
## git 기본 편집기 vim 으로 설정하기
```bash
git config --global core.editor "vim" 
```

<br>

## git 계정 등록

```bash
git config --global user.name "absinthe4902"
git config --global user.email "absinthe4902@naver.com"
```

<br> 

## CRLF 개행문자 설정

```bash
# 맨날 LF Warning이 떠서 쓰기는 하는데 사실 먹히는지 모르겠다.
git config --global core.autocrlf true
```

<br> 

## working directory 에서 local 계정 만들기

git hub에서 내 commit으로 허용이 되려면 git hub에 등록된 이메일을 사용해야 한다. 개인용 컴퓨터는 상관이 없는데 회사에는 git에 회사 이메일이 등록되어있어 가끔 이메일을 바꿔줘야 하는데 **매번 바꿀 필요 없이 commit하려는 디렉토리에만 local 계정을 만들어주면 된다.**

```bash
git config --local user.name "local_absinthe4902"
git config --local user.email "local_absinthe4902@naver.com" 

# working directory 에 적용된 config 확인하기 (이 이름으로 push 된다고 생각하면 된다) 
# id name check
git config user.name 

```

<br> 
<br> 
<hr>


# git remote
## 연결된 remote repo 변경하기

```bash
# 1. check name of remote branch 
git remote -v 
# 2. change url of remote branch
git remote set-url origin https://github.com/leeleelee3264/https://leeleelee3264.github.io-old/.git
```

<br> 
<br> 
<hr>


# git cached
## .gitginore 가 안 먹힐 때 AKA tracking 하지 말아야 할 파일을 트래킹 할 때
```bash
git rm -r --cached .
git add . 
git commit -m "RESOLVED: .gitignore is not working"
```
<br> 
<br> 
<hr>


# git ERROR
## refusing to merge unrelated histories
I saw this error when I had tried to change commit with --amend but didn't finish properly.
People say it will show up when trying to merge two different projects with no history about each others.
```bash
git pull origin branch_name --allow-unrelated-histories 
```
<br> 
<br> 
<hr>



# Additional func of git

## git init cancel
 ```bash
# sometimes I make wrong directory to git repo. Then I have to cancel it. 
# It's all about .git directory. When I init directory, I'll get git repo and it works like that.
# Just remove the file and it will become normal directory 
rm -r .git 
 ```

<br>  

## git version update
 ```bash
# 1.version check 
git --version

# 2. git version update 
git update-git-for-windows
 ```
