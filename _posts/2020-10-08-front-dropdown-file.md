---
layout: post 
title: "[Linux] Writing shell script"
date: 2021-01-05 20:39:40
author: Jamie Lee
categories: Backend
tags:	linux
cover:  "/assets/img/ubuntu.png"
pagination: 
  enabled: true
---

Today, I handed over a project to a teammate I took over from a colleague who was about to quit the job. The one thing I was concerning is the fact that the team mate 
will take over whole part of the project. It means she is going to do deploy as well and she is quite new with Linux.  I didn't think it is a good idea to let her know all the command using for deplyoment.
So I decided to making shell script containing the command! (I've wanted to learn about shell script too)

The most important beginning of shell script!

```git
#!/bin/bash
```
As far as I remember, all the shell script is working with 'bash' file in bin directory. To execute shell script, do not forget to wirte #!/bin/bash line. 

```git

touch test_bash.sh 
~ editing bash file ~

chmod +x test_bash.sh
```

Give the bash file you were writing execution roll. Bash file is for execution after all. This is almost everything I know about shell script. Now let's take a look at the bash file I wrote today. 

```git
#!/bin/bash 

# add some comment to let people know what this bash file for. 

pw="password_I_used_in_server"

echo ${pw} | sudo -kS systemctl reload shiny-server 
sleep .5

echo ${pw} | sudo -kS systemctl status shiny-server | cat 
echo "Successfully updated aiv"
```
## point
1. I wanted to make bash file which passes writing password in the middle of execution. So I just give password as param. I know It's quite bad for security. I must think other way next time.
2. sudo -kS option <br>
'S' is for getting password from 'echo' command. It means it will catch anything from stdin. 'k' is for reset timestamp. When the timestamp remains in sudo command, it might cause some error.
3. sleep .5 (5 is 5 seconds, .5 is 5 millie seconds). <br>
I just want to put some delay from reloading. 
4. systemctl status shiny-server | cat <br>
I want to show the status of service at the last part of execution for making sure it's working. But as you know, after reading status, I have to do the typing to quit. So I just make the status printed. It doesn't need quiting. 

<hr> 


/// TODO: 여기부터는 내일하면 될 것 같으다~~ 
1. option 의미들이 무엇인지 찾아보고 
2. 로그 로테이트 하는거 팀장님꺼랑은 뭐가 다른지 보고 
3. slack 에 올려둔  bash 영상 보기 (아마 오늘 할듯) 
To be honest, I already use bash command to deploy jar file and manage log file. Thoese are what I'm using now. (need to improve and do more customize later.)

```git

```


 
